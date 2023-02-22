#pragma once

#include <stdint.h>
#include "Engine/EngineTypes.h"
#include "GameFramework/GameModeBase.h"

#define UBF_VERSION 1

#pragma warning(disable:4191)

bool UBF_Init(const char* dllPath);
void UBF_Unload();
void UBF_GameModeFinish();
void UBF_SetWantsDLLUnload(bool onGameModeExit, bool onCPPRebuild);

#ifdef UBF_IMPLEMENTATION

#define DECLPROC(name, sig, paramNames) \
	typedef int(*T_##name)##sig; \
	static T_##name g##name; \
	void UBF_##name##sig \
	{ \
		if (g##name == NULL) return; \
		g##name##paramNames; \
	}

#else

#define DECLPROC(name, sig, paramNames) \
	typedef int(*T_##name)##sig; \
	void UBF_##name##sig;

#endif

#define IFACEDECL(kind, name, sig, paramNames) \
	typedef int(*T_##name)##sig; \
	void UBFImpl_##kind##name##sig \
	{ \
		if (g##name == NULL) return; \
		self->##name##paramNames; \
	}

//IFACEDECL(USceneComponent, );
//FRotator DeltaRotation, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport

//IFACEDECL();

DECLPROC(App_Init, (int32 version, void** callbacks), (version, callbacks));
DECLPROC(App_PreGarbageCollectDelegate, (), ());

DECLPROC(Class_Register, (UClass* uclass, void** callbacks), (uclass, callbacks));

DECLPROC(Object_Created, (UObject* uobject), (uobject));
DECLPROC(Object_Deleted, (UObject* uobject), (uobject));

DECLPROC(Actor_Tick, (AActor* self, float deltaTime), (self, deltaTime));

DECLPROC(World_StartTick, (UWorld* uworld, ELevelTick tick, float deltaTime), (uworld, tick, deltaTime));

#ifdef UBF_IMPLEMENTATION

#include "Engine/World.h"
#include "Kismet/GameplayStatics.h"
#include "UObject/UObjectGlobals.h"
#include "DrawDebugHelpers.h"

//#define WIN32_LEAN_AND_MEAN
//#undef TEXT
//#include <windows.h>

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
bool gUBF_WantsDLLUnload_OnGameModeExit = false;
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

void UBF_SetWantsDLLUnload(bool onGameModeExit, bool onCPPRebuild)
{
	gUBF_WantsDLLUnload_OnGameModeExit = onGameModeExit;
	gUBF_WantsDLLUnload_OnCPPRebuild = onCPPRebuild;
}

void Engine_ForceGarbageCollection(bool fullPurge)
{
	GEngine->ForceGarbageCollection(fullPurge);
}

FVector Transform_TransformPosition(const FTransform& transform, const FVector& vec)
{
	return transform.TransformPosition(vec);
}

FVector Transform_TransformPositionNoScale(const FTransform& transform, const FVector& vec)
{
	return transform.TransformPositionNoScale(vec);
}

FVector Transform_TransformVector(const FTransform& transform, const FVector& vec)
{
	return transform.TransformVector(vec);
}

FVector Transform_TransformVectorNoScale(const FTransform& transform, const FVector& vec)
{
	return transform.TransformVectorNoScale(vec);
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

// USceneComponent

static void USceneComponent_AddLocalRotation(USceneComponent* self, const FRotator& rotator, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->AddLocalRotation(rotator, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

static void USceneComponent_SetRelativeRotation(USceneComponent* self, const FRotator& rotator, bool bSweep, BF_FHitResult* OutSweepHitResult, ETeleportType Teleport)
{
	self->SetRelativeRotation(rotator, bSweep, BF_FHitResult_Handler(OutSweepHitResult), Teleport);
}

// UActorComponent

static void UActorComponent_DestroyComponent(UActorComponent* self, bool promoteChildren)
{
	self-> DestroyComponent(promoteChildren);
}

static void UActorComponent_UnregisterComponent(UActorComponent* self)
{
	self->UnregisterComponent();
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

//void HelloWorldActor::BeginPlay()
//{
	//Super::BeginPlay();


//


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

///

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
		&Transform_TransformVector, &Transform_TransformVectorNoScale };
	UBF_App_Init(UBF_VERSION, mainCallbacks);

	void* objectCallbacks[] = { &UObject_GetClass, &UObject_CanCast, &UObject_GetWeakRef, &UObject_CheckWeakRef, &UObject_GetGameMode, &UObject_GetGameState,
		&UObject_GCMarkObject };
	UBF_Class_Register(UObject::StaticClass(), objectCallbacks);

	void* usceneCallbacks[] = { &USceneComponent_AddLocalRotation, &USceneComponent_SetRelativeRotation };
	UBF_Class_Register(USceneComponent::StaticClass(), usceneCallbacks);

	void* uactorCallbacks[] = { &UActorComponent_DestroyComponent, &UActorComponent_UnregisterComponent };
	UBF_Class_Register(UActorComponent::StaticClass(), uactorCallbacks);

	void* gamemodeCallbacks[] = { NULL };
	UBF_Class_Register(AGameModeBase::StaticClass(), gamemodeCallbacks);

	void* worldCallbacks[] = { &World_DrawDebugLine, &World_LineTraceSingleByChannel, &World_RemoveActor, &World_SpawnActor, &World_DrawDebugDirectionalArrow,
		& World_DrawDebugCircle };
	UBF_Class_Register(UWorld::StaticClass(), worldCallbacks);

	void* actorCallbacks[] = { &Actor_GetWorld, &Actor_GetActorForwardVector, &Actor_GetActorUpVector, &Actor_GetActorRightVector,
		&Actor_GetActorLocation,  &Actor_GetActorQuat, &Actor_GetActorRotation, &Actor_GetActorScale, &Actor_GetTransform,
		&Actor_GetVelocity, &Actor_SetActorLocation, &Actor_SetActorTransform, &Actor_SetActorRotation_Rotator, &Actor_SetActorRotation_Quat,
		&Actor_Destroy, &Actor_IsBeingDestroyed, &Actor_GetActorTickInterval, &Actor_SetActorTickInterval };
	UBF_Class_Register(AActor::StaticClass(), actorCallbacks);

	void* pawnCallbacks[] = { &Pawn_GetController };
	UBF_Class_Register(APawn::StaticClass(), pawnCallbacks);

	void* controllerCallbacks[] = { &Controller_Possess };
	UBF_Class_Register(AController::StaticClass(), controllerCallbacks);

	void* playerControllerCallbacks[] = { &PlayerController_IsInputKeyDown, &PlayerController_WasInputKeyJustPressed, &PlayerController_WasInputKeyJustReleased };
	UBF_Class_Register(APlayerController::StaticClass(), playerControllerCallbacks);

	FCoreUObjectDelegates::GetPreGarbageCollectDelegate().AddStatic(&UBF_App_PreGarbageCollectDelegate);
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
		return gUBF_Initialized;

	gUBF_DLLPath = dllPath;
	gUBF_BeefModule = ::LoadLibraryA(dllPath);

	if (gUBF_BeefModule == NULL)
		return false;
	LOADPROC(App_Init);
	LOADPROC(App_PreGarbageCollectDelegate);
	LOADPROC(Class_Register);
	LOADPROC(Object_Created);
	LOADPROC(Object_Deleted);
	LOADPROC(Actor_Tick);
	LOADPROC(World_StartTick);

	FWorldDelegates::OnWorldTickStart.AddStatic(&UBF_World_StartTick);
	FCoreUObjectDelegates::ReloadCompleteDelegate.AddStatic(&UBF_ReloadComplete);

	UBF_RegisterClasses();

	gUBF_Initialized = true;
	return true;
}

void UBF_GameModeFinish()
{
	if (gUBF_WantsDLLUnload_OnGameModeExit)
	{
		UBF_Unload();
	}
}

#endif