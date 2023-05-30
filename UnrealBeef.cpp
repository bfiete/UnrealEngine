#include "UnrealBeef.h"

#include "Engine/World.h"
#include "Kismet/GameplayStatics.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/ConstructorHelpers.h"
#include "Components/AudioComponent.h"
#include "Engine/Font.h"
#include "Engine/Canvas.h"
#include "Sound/SoundCue.h"
#include "GameFramework/HUD.h"
#include "DrawDebugHelpers.h"
#include "UnrealClient.h"
#include "NiagaraFunctionLibrary.h"
#include "NiagaraComponent.h"

typedef void* HMODULE;
extern "C" HMODULE LoadLibraryA(const char* lpLibFileName);
extern "C" int FreeLibrary(HMODULE hModule);
extern "C" void* GetProcAddress(HMODULE hModule, const char* lpProcName);
extern "C" void GetCurrentDirectoryA(int pathLen, char* path);
extern "C" void SetCurrentDirectoryA(char* path);
extern "C" void OutputDebugStringA(char* path);

std::string gUBF_DLLPath;
HMODULE gUBF_BeefModule = NULL;
bool gUBF_Initialized = false;
FString gUBF_ResultStr;
bool gUBF_WantsDLLUnload_OnAppDone = false;
bool gUBF_WantsDLLUnload_OnCPPRebuild = false;
std::vector<void**> gUBF_FuncPtrs;

#define LOADPROC(name) \
	g##name = (T_##name)::GetProcAddress(gUBF_BeefModule, #name); \
	if (g##name == NULL) return false; \
	gUBF_FuncPtrs.push_back((void**)&g##name);

struct BF_FHitResult
{
	int32 mFaceIndex;
	float mDistance;
	FVector mLocation;
	FVector mImpactPoint;
	FVector mNormal;
	FVector mImpactNormal;
	FVector mTraceStart;
	FVector mTraceEnd;
	float mPenetrationDepth;
	int32 mMyItem;
	int32 mItem;
	uint8 mElementIdx;
	bool mBlockingHit;
	bool mStartPenetrating;
	int32 mHitActor_Index;
	uint32 mHitActor_Serial;
	int32 mHitComponent_Index;
	uint32 mHitComponent_Serial;

	BF_FHitResult& operator=(const FHitResult& hitResult)
	{
		mFaceIndex = hitResult.FaceIndex;
		mDistance = hitResult.Distance;
		mLocation = hitResult.Location;
		mImpactPoint = hitResult.ImpactPoint;
		mNormal = hitResult.Normal;
		mImpactNormal = hitResult.ImpactNormal;
		mTraceStart = hitResult.TraceStart;
		mTraceEnd = hitResult.TraceEnd;
		mPenetrationDepth = hitResult.PenetrationDepth;
		mMyItem = hitResult.MyItem;
		mItem = hitResult.Item;
		mElementIdx = hitResult.ElementIndex;
		mBlockingHit = hitResult.bBlockingHit;
		mStartPenetrating = hitResult.bStartPenetrating;
		auto actor = hitResult.HitObjectHandle.FetchActor();
		if (actor != NULL)
		{
			mHitActor_Index = GUObjectArray.ObjectToIndex((UObjectBase*)actor);
			mHitActor_Serial = GUObjectArray.AllocateSerialNumber(mHitActor_Index);
		}
		auto component = hitResult.Component.Get();
		if (component != NULL)
		{
			mHitComponent_Index = GUObjectArray.ObjectToIndex((UObjectBase*)component);
			mHitComponent_Serial = GUObjectArray.AllocateSerialNumber(mHitComponent_Index);
		}
		return *this;
	}
};

struct BF_FHitResult_Handler
{
	FHitResult mHitResult;
	BF_FHitResult* mBFHitResult;

	BF_FHitResult_Handler(BF_FHitResult* bfHitResult) : mHitResult(ForceInit)
	{
		mBFHitResult = bfHitResult;
	}

	~BF_FHitResult_Handler()
	{
		if (mBFHitResult != NULL)
			*mBFHitResult = mHitResult;
	}

	operator FHitResult* ()
	{
		if (mBFHitResult = NULL)
			return NULL;
		return &mHitResult;
	}

	operator FHitResult& ()
	{
		return mHitResult;
	}
};

// GLOBAL

static const wchar_t* UBF_Class_GetName(UClass* uclass)
{
	uclass->GetName(gUBF_ResultStr);
	return *gUBF_ResultStr;
}

static UClass* UBF_Class_GetSuperClass(UClass* uclass)
{
	return uclass->GetSuperClass();
}

static void Engine_AddOnScreenDebugMessage(uint64 Key, float TimeToDisplay, uint32 DisplayColor, const char* DebugMessage, bool bNewerOnTop, const FVector2D& TextScale)
{
	GEngine->AddOnScreenDebugMessage(Key, TimeToDisplay, FColor(DisplayColor), DebugMessage, bNewerOnTop, TextScale);
}

void UBF_SetWantsDLLUnload(bool onAppDone, bool onCPPRebuild)
{
	gUBF_WantsDLLUnload_OnAppDone = onAppDone;
	gUBF_WantsDLLUnload_OnCPPRebuild = onCPPRebuild;
}

static void Engine_ForceGarbageCollection(bool fullPurge)
{
	GEngine->ForceGarbageCollection(fullPurge);
}

static FVector Transform_TransformPosition(const FTransform& transform, const FVector& vec)
{
	return transform.TransformPosition(vec);
}

static FVector Transform_TransformPositionNoScale(const FTransform& transform, const FVector& vec)
{
	return transform.TransformPositionNoScale(vec);
}

static FVector Transform_TransformVector(const FTransform& transform, const FVector& vec)
{
	return transform.TransformVector(vec);
}

static FVector Transform_TransformVectorNoScale(const FTransform& transform, const FVector& vec)
{
	return transform.TransformVectorNoScale(vec);
}

static UObject* Engine_FindObject(const char* name)
{
	FString fsName(name);
	ConstructorHelpers::FObjectFinder<UObject> res(*fsName);
	return res.Object;
}

static UObject* UBF_CreateObject(UClass* uclass)
{
	return NewObject<UObject>((UObject*)GetTransientPackage(), uclass);
}

// UObject

static void UObject_GetWeakRef(UObject* self, int32& objectIndex, int32& objectSerialNumber)
{
	objectIndex = GUObjectArray.ObjectToIndex((UObjectBase*)self);
	auto object = GUObjectArray.GetObjectItemArrayUnsafe().GetObjectPtr(objectIndex);
	objectSerialNumber = GUObjectArray.AllocateSerialNumber(objectIndex);
}

static UObjectBase* UObject_CheckWeakRef(int32 objectIndex, int32 objectSerialNumber)
{
	auto objectItem = GUObjectArray.IndexToObject(objectIndex);
	if (objectItem == NULL)
		return NULL;
	if (objectItem->GetSerialNumber() != objectSerialNumber)
		return NULL;
	return objectItem->Object;
}

static UClass* UObject_GetClass(UObject* self)
{
	return self->GetClass();
}

static bool UObject_CanCast(UObject* self, UClass* toClass)
{
	if (self == NULL)
		return false;

	auto fromClass = self->GetClass();
	if (fromClass == toClass)
		return true;
	return fromClass->IsChildOf(toClass);
}

static AGameModeBase* UObject_GetGameMode(UObject* uobject)
{
	return UGameplayStatics::GetGameMode(uobject);
}

static AGameStateBase* UObject_GetGameState(UObject* uobject)
{
	return UGameplayStatics::GetGameState(uobject);
}

static void UObject_GCMarkObject(UObject* self)
{
	int objectIndex = GUObjectArray.ObjectToIndex((UObjectBase*)self);
	auto object = GUObjectArray.GetObjectItemArrayUnsafe().GetObjectPtr(objectIndex);
	object->ClearFlags(EInternalObjectFlags::Unreachable);
}

static UObject* UObject_CreateDefaultSubobject(UObject* self, UClass* uclass, const char* name, bool transient)
{
	return self->CreateDefaultSubobject(name, uclass, uclass, /*bIsRequired =*/ true, transient);
}

// USceneComponent

static void USceneComponent_AddLocalRotation(USceneComponent* self, const FRotator& rotator, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->AddLocalRotation(rotator, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_SetRelativeRotation(USceneComponent* self, const FRotator& rotator, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->SetRelativeRotation(rotator, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_SetWorldRotation(USceneComponent* self, const FRotator& rotator, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->SetWorldRotation(rotator, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_SetRelativeLocation(USceneComponent* self, const FVector& position, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->SetRelativeLocation(position, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_SetWorldLocation(USceneComponent* self, const FVector& position, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->SetWorldLocation(position, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_AttachToComponent(USceneComponent* self, USceneComponent* component)
{
	FAttachmentTransformRules transRules(EAttachmentRule::KeepWorld, false);
	self->AttachToComponent(component, transRules);
}

// UActorComponent

static void UActorComponent_DestroyComponent(UActorComponent* self, bool promoteChildren)
{
	self->DestroyComponent(promoteChildren);
}

static void UActorComponent_UnregisterComponent(UActorComponent* self)
{
	self->UnregisterComponent();
}

static void UActorComponent_RegisterComponent(UActorComponent* self)
{
	self->RegisterComponent();
}

// AGameModeBase


// UWorld

static void World_DrawDebugLine(UWorld* self, const FVector& lineStart, const FVector& lineEnd, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness)
{
	DrawDebugLine(self, lineStart, lineEnd, FColor(color), persistentLine, lifetime, depthPriority, thickness);
}

static bool World_LineTraceSingleByChannel(UWorld* world, BF_FHitResult* hitResult, const FVector& start, const FVector& end, ECollisionChannel collisionChannel, AActor* ignoredActor)
{
	FCollisionQueryParams collisionParams = FCollisionQueryParams::DefaultQueryParam;
	if (ignoredActor != NULL)
		collisionParams.AddIgnoredActor(ignoredActor);
	bool hit = world->LineTraceSingleByChannel(BF_FHitResult_Handler(hitResult), start, end, collisionChannel, collisionParams);
	return hit;
}

static void World_RemoveActor(UWorld* self, AActor* actor, bool shouldModifyLevel)
{
	self->RemoveActor(actor, shouldModifyLevel);
}

static AActor* World_SpawnActor(UWorld* self, UClass* uclass, FVector* location, FRotator* rotation, const char* name, EObjectFlags flags)
{
	FActorSpawnParameters spawnParams;
	if (name != NULL)
		spawnParams.Name = name;
	spawnParams.ObjectFlags = flags;
	return self->SpawnActor(uclass, location, rotation, spawnParams);
}

static void World_DrawDebugDirectionalArrow(UWorld* self, const FVector& lineStart, const FVector& lineEnd, float arrowSize, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness)
{
	DrawDebugDirectionalArrow(self, lineStart, lineEnd, arrowSize, FColor(color), persistentLine, lifetime, depthPriority, thickness);
}

static void World_DrawDebugCircle(UWorld* self, const FVector& center, float radius, int32 segments, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness, const FVector& yAxis, const FVector& zAxis, bool drawAxis)
{
	DrawDebugCircle(self, center, radius, segments, FColor(color), persistentLine, lifetime, depthPriority, thickness, yAxis, zAxis, drawAxis);
}

static void World_GetScreenSize(UWorld* self, float* width, float* height)
{
	FVector2D sizeXY;
	self->GetGameViewport()->GetViewportSize(sizeXY);
	*width = sizeXY.X;
	*height = sizeXY.Y;
}

// AActor

static UWorld* Actor_GetWorld(AActor* self)
{
	return self->GetWorld();
}

static FVector Actor_GetActorForwardVector(AActor* self)
{
	return self->GetActorForwardVector();
}

static FVector Actor_GetActorUpVector(AActor* self)
{
	return self->GetActorUpVector();
}

static FVector Actor_GetActorRightVector(AActor* self)
{
	return self->GetActorRightVector();
}

static FVector Actor_GetActorLocation(AActor* self)
{
	return self->GetActorLocation();
}

static FQuat Actor_GetActorQuat(AActor* self)
{
	return self->GetActorQuat();
}

static FRotator Actor_GetActorRotation(AActor* self)
{
	return self->GetActorRotation();
}

static FVector Actor_GetActorScale(AActor* self)
{
	return self->GetActorScale();
}

static FTransform Actor_GetTransform(AActor* self)
{
	int size = sizeof(FTransform);
	auto trans = self->GetTransform();
	return trans;
}

static FVector Actor_GetVelocity(AActor* self)
{
	return self->GetVelocity();
}

static bool Actor_SetActorLocation(AActor* self, const FVector& NewLocation, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	return self->SetActorLocation(NewLocation, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static bool Actor_SetActorTransform(AActor* self, const FTransform& NewTransform, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	return self->SetActorTransform(NewTransform, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static bool Actor_SetActorRotation_Rotator(AActor* self, FRotator NewRotation, ETeleportType Teleport)
{
	return self->SetActorRotation(NewRotation, Teleport);
}

static bool Actor_SetActorRotation_Quat(AActor* self, const FQuat& NewRotation, ETeleportType Teleport)
{
	return self->SetActorRotation(NewRotation, Teleport);
}

static bool Actor_Destroy(AActor* self, bool netForce, bool shouldModifyLevel)
{
	return self->Destroy(netForce, shouldModifyLevel);
}

static bool Actor_IsBeingDestroyed(AActor* self)
{
	return self->IsActorBeingDestroyed();
}

static void Actor_SetActorTickInterval(AActor* self, float tickInterval)
{
	self->SetActorTickInterval(tickInterval);
}

static float Actor_GetActorTickInterval(AActor* self)
{
	return self->GetActorTickInterval();
}

static USceneComponent* Actor_GetRootComponent(AActor* self)
{
	return self->GetRootComponent();
}

// Pawn

static AController* Pawn_GetController(APawn* self)
{
	return self->GetController();
}

// AController

static void Controller_Possess(AController* self, APawn* pawn)
{
	self->Possess(pawn);
}

// APlayerController
static bool PlayerController_IsInputKeyDown(APlayerController* self, const char* keyName)
{
	return self->IsInputKeyDown(FKey(keyName));
}

static bool PlayerController_WasInputKeyJustPressed(APlayerController* self, const char* keyName)
{
	return self->WasInputKeyJustPressed(FKey(keyName));
}

static bool PlayerController_WasInputKeyJustReleased(APlayerController* self, const char* keyName)
{
	return self->WasInputKeyJustReleased(FKey(keyName));
}

static AHUD* PlayerController_GetHUD(APlayerController* self)
{
	return self->GetHUD();
}

static void PlayerController_SetAudioListenerOverride(APlayerController* self, USceneComponent* component, const FVector& location, const FRotator& rotation)
{
	self->SetAudioListenerOverride(component, location, rotation);
}

static void PlayerController_ClearAudioListenerOverride(APlayerController* self)
{
	self->ClearAudioListenerOverride();
}

static void PlayerController_SetAudioListenerAttenuationOverride(APlayerController* self, USceneComponent* component, const FVector& attenuationLocationOverride)
{
	self->SetAudioListenerAttenuationOverride(component, attenuationLocationOverride);
}

static void PlayerController_ClearAudioListenerAttenuationOverride(APlayerController* self)
{
	self->ClearAudioListenerAttenuationOverride();
}

// AHUD
static void HUD_DrawText(AHUD* self, const char* text, float x, float y, uint32 color, UFont* font, float scale, bool scalePosition)
{
	self->DrawText(text, FLinearColor(FColor(color)), x, y, font, scale, scalePosition);
}

static void HUD_DrawRect(AHUD* self, uint32 color, float x, float y, float width, float height)
{
	self->DrawRect(FLinearColor(FColor(color)), x, y, width, height);
}

// UAudioComponent

static void AudioComponent_SetSound(UAudioComponent* self, USoundBase* soundBase)
{
	self->SetSound(soundBase);
}

static void AudioComponent_Play(UAudioComponent* self, float startTime)
{
	self->Play(startTime);
}

static void AudioComponent_Stop(UAudioComponent* self)
{
	self->Stop();
}

static void AudioComponent_SetPaused(UAudioComponent* self, bool paused)
{
	self->SetPaused(paused);
}

static void AudioComponent_SetAutoDestroy(UAudioComponent* self, bool autoDestroy)
{
	self->bAutoDestroy = autoDestroy;
}

static bool AudioComponent_IsPlaying(UAudioComponent* self)
{
	return self->IsPlaying();
}

static void AudioComponent_SetVolumeMultiplier(UAudioComponent* self, float multiplier)
{
	self->SetVolumeMultiplier(multiplier);
}

static void AudioComponent_SetPitchMultiplier(UAudioComponent* self, float multiplier)
{
	self->SetPitchMultiplier(multiplier);
}

/// USoundBase

static void USoundBase_Play2D(USoundBase* self, UObject* refObject, float volumeMultiplier, float pitchMultiplier, float startTime)
{
	UGameplayStatics::PlaySound2D(refObject, self, volumeMultiplier, pitchMultiplier, startTime);
}

static void USoundBase_PlayAtLocation(USoundBase* self, UObject* refObject, const FVector& location, float volumeMultiplier, float pitchMultiplier, float startTime)
{
	UGameplayStatics::PlaySoundAtLocation(refObject, self, location, volumeMultiplier, pitchMultiplier, startTime);
}

static void USoundBase_PrimeSound(USoundBase* self)
{
	UGameplayStatics::PrimeSound(self);
}

static UAudioComponent* USoundBase_SpawnSound2D(USoundBase* self, UObject* refObject, float volumeMultiplier, float pitchMultiplier, float startTime)
{
	return UGameplayStatics::SpawnSound2D(refObject, self, volumeMultiplier, pitchMultiplier, startTime);
}

static UAudioComponent* USoundBase_CreateSound2D(USoundBase* self, UObject* refObject, float volumeMultiplier, float pitchMultiplier, float startTime)
{
	return UGameplayStatics::CreateSound2D(refObject, self, volumeMultiplier, pitchMultiplier, startTime);
}

static UAudioComponent* USoundBase_SpawnAttached(USoundBase* self, USceneComponent* component, const char* pointName, const FVector& location, EAttachLocation::Type locationType,
	bool stopWhenAttachedToDestroyed, float volumeMultiplier, float pitchMultiplier, float startTime, bool autoDestroy)
{
	return UGameplayStatics::SpawnSoundAttached(self, component, pointName, location, locationType, stopWhenAttachedToDestroyed, volumeMultiplier, pitchMultiplier, startTime, NULL, NULL, autoDestroy);
}

/// UNiagaraSystem

UNiagaraComponent* NiagaraSystem_SpawnSystemAtLocation(UNiagaraSystem* self, UWorld* world, const FVector& location, const FRotator& rotation)
{
	return UNiagaraFunctionLibrary::SpawnSystemAtLocation(world, self, location, rotation);
}

/// UNiagaraComponent

void NiagaraComponent_SetVariableFloat(UNiagaraComponent* self, const char* name, float value)
{
	self->SetVariableFloat(name, value);
}

void NiagaraComponent_SetVariableInt(UNiagaraComponent* self, const char* name, int value)
{
	self->SetVariableInt(name, value);
}

void NiagaraComponent_DestroyInstance(UNiagaraComponent* self)
{
	self->DestroyInstance();
}

void NiagaraComponent_ReinitializeSystem(UNiagaraComponent* self)
{
	self->ReinitializeSystem();
}


void UBF_Unload()
{
	if (!gUBF_Initialized)
		return;

	for (auto& ptr : gUBF_FuncPtrs)
		*ptr = NULL;
	gUBF_FuncPtrs.clear();

	gUBF_Initialized = false;
	::FreeLibrary(gUBF_BeefModule);
	gUBF_BeefModule = NULL;
}

void UBF_RegisterClasses()
{
	void* mainCallbacks[] = { &UBF_Class_GetName, &UBF_Class_GetSuperClass, &Engine_AddOnScreenDebugMessage, &UBF_SetWantsDLLUnload,
		&Engine_ForceGarbageCollection, &Transform_TransformPosition, &Transform_TransformPositionNoScale,
		&Transform_TransformVector, &Transform_TransformVectorNoScale, &Engine_FindObject, &UBF_CreateObject };
	UBF_App_Init(UBF_VERSION, mainCallbacks);

	void* objectCallbacks[] = { &UObject_GetClass, &UObject_CanCast, &UObject_GetWeakRef, &UObject_CheckWeakRef, &UObject_GetGameMode, &UObject_GetGameState,
		&UObject_GCMarkObject, &UObject_CreateDefaultSubobject };
	UBF_Class_Register(UObject::StaticClass(), objectCallbacks);

	void* usceneComponentCallbacks[] = { &USceneComponent_AddLocalRotation, &USceneComponent_SetRelativeRotation, &USceneComponent_SetWorldRotation,
		&USceneComponent_SetRelativeLocation, &USceneComponent_SetWorldLocation, &USceneComponent_AttachToComponent };
	UBF_Class_Register(USceneComponent::StaticClass(), usceneComponentCallbacks);

	void* uactorComponentCallbacks[] = { &UActorComponent_DestroyComponent, &UActorComponent_UnregisterComponent,  &UActorComponent_RegisterComponent };
	UBF_Class_Register(UActorComponent::StaticClass(), uactorComponentCallbacks);

	void* gamemodeCallbacks[] = { NULL };
	UBF_Class_Register(AGameModeBase::StaticClass(), gamemodeCallbacks);

	void* worldCallbacks[] = { &World_DrawDebugLine, &World_LineTraceSingleByChannel, &World_RemoveActor, &World_SpawnActor, &World_DrawDebugDirectionalArrow,
		&World_DrawDebugCircle, &World_GetScreenSize };
	UBF_Class_Register(UWorld::StaticClass(), worldCallbacks);

	void* actorCallbacks[] = { &Actor_GetWorld, &Actor_GetActorForwardVector, &Actor_GetActorUpVector, &Actor_GetActorRightVector,
		&Actor_GetActorLocation,  &Actor_GetActorQuat, &Actor_GetActorRotation, &Actor_GetActorScale, &Actor_GetTransform,
		&Actor_GetVelocity, &Actor_SetActorLocation, &Actor_SetActorTransform, &Actor_SetActorRotation_Rotator, &Actor_SetActorRotation_Quat,
		&Actor_Destroy, &Actor_IsBeingDestroyed, &Actor_GetActorTickInterval, &Actor_SetActorTickInterval, &Actor_GetRootComponent };
	UBF_Class_Register(AActor::StaticClass(), actorCallbacks);

	void* pawnCallbacks[] = { &Pawn_GetController };
	UBF_Class_Register(APawn::StaticClass(), pawnCallbacks);

	void* controllerCallbacks[] = { &Controller_Possess };
	UBF_Class_Register(AController::StaticClass(), controllerCallbacks);

	void* playerControllerCallbacks[] = { &PlayerController_IsInputKeyDown, &PlayerController_WasInputKeyJustPressed, &PlayerController_WasInputKeyJustReleased,
		&PlayerController_GetHUD, &PlayerController_SetAudioListenerOverride, & PlayerController_ClearAudioListenerOverride,
		&PlayerController_SetAudioListenerAttenuationOverride, & PlayerController_ClearAudioListenerAttenuationOverride };
	UBF_Class_Register(APlayerController::StaticClass(), playerControllerCallbacks);

	void* hudCallbacks[] = { &HUD_DrawText, &HUD_DrawRect };
	UBF_Class_Register(AHUD::StaticClass(), hudCallbacks);

	void* fontCallbacks[] = { NULL };
	UBF_Class_Register(UFont::StaticClass(), fontCallbacks);

	void* soundBaseCallbacks[] = { &USoundBase_Play2D, &USoundBase_PlayAtLocation, &USoundBase_PrimeSound, &USoundBase_SpawnSound2D, &USoundBase_CreateSound2D,
		&USoundBase_SpawnAttached};
	UBF_Class_Register(USoundBase::StaticClass(), soundBaseCallbacks);

	void* soundCueCallbacks[] = { NULL };
	UBF_Class_Register(USoundCue::StaticClass(), soundCueCallbacks);

	void* audioComponentCallbacks[] = { &AudioComponent_SetSound, &AudioComponent_Play, &AudioComponent_Stop, &AudioComponent_SetPaused, &AudioComponent_SetAutoDestroy,
		&AudioComponent_IsPlaying, &AudioComponent_SetVolumeMultiplier, &AudioComponent_SetPitchMultiplier };
	UBF_Class_Register(UAudioComponent::StaticClass(), audioComponentCallbacks);

	void* niagaraSystemCallbacks[] = { &NiagaraSystem_SpawnSystemAtLocation };
	UBF_Class_Register(UNiagaraSystem::StaticClass(), niagaraSystemCallbacks);

	void* niagaraComponentCallbacks[] = { &NiagaraComponent_SetVariableFloat, &NiagaraComponent_SetVariableInt, &NiagaraComponent_DestroyInstance, &NiagaraComponent_ReinitializeSystem };
	UBF_Class_Register(UNiagaraComponent::StaticClass(), niagaraComponentCallbacks);
}

void UBF_ReloadComplete(EReloadCompleteReason completeReason)
{
	if (gUBF_WantsDLLUnload_OnCPPRebuild)
	{
		UBF_Unload();
		UBF_Init(gUBF_DLLPath.c_str());
	}
	else
	{
		UBF_RegisterClasses();
	}
}

bool UBF_Init(const char* dllPath)
{
	if (gUBF_BeefModule != NULL)
	{
		UBF_App_Start();
		return gUBF_Initialized;
	}

	gUBF_DLLPath = dllPath;
	gUBF_BeefModule = ::LoadLibraryA(dllPath);

	if (gUBF_BeefModule == NULL)
		return false;
	LOADPROC(App_Init);
	LOADPROC(App_Start);
	LOADPROC(App_Done);
	LOADPROC(App_PreGarbageCollectDelegate);
	LOADPROC(Class_Register);
	LOADPROC(Object_Created);
	LOADPROC(Object_Deleted);
	LOADPROC(Actor_Tick);
	LOADPROC(World_StartTick);
	LOADPROC(HUD_DrawHUD);

	FWorldDelegates::OnWorldTickStart.AddStatic(&UBF_World_StartTick);
	FCoreUObjectDelegates::ReloadCompleteDelegate.AddStatic(&UBF_ReloadComplete);
	FCoreUObjectDelegates::GetPreGarbageCollectDelegate().AddStatic(&UBF_App_PreGarbageCollectDelegate);

	UBF_RegisterClasses();

	UBF_App_Start();

	gUBF_Initialized = true;
	return true;
}

void UBF_App_Done()
{
	gApp_Done();

	if (gUBF_WantsDLLUnload_OnAppDone)
	{
		UBF_Unload();
	}
}
