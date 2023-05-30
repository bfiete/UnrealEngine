#pragma once

#include <stdint.h>
#include "Engine/EngineTypes.h"
#include "GameFramework/GameModeBase.h"

#define UBF_VERSION 1

#pragma warning(disable:4191)

bool UBF_Init(const char* dllPath);
void UBF_Unload();
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

#define DECLPROC_NOIMPL(name, sig, paramNames) \
	typedef int(*T_##name)##sig; \
	static T_##name g##name; \
	void UBF_##name##sig;

#else

#define DECLPROC(name, sig, paramNames) \
	typedef int(*T_##name)##sig; \
	void UBF_##name##sig;

#define DECLPROC_NOIMPL(name, sig, paramNames) \
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

DECLPROC(App_Init, (int32 version, void** callbacks), (version, callbacks));
DECLPROC(App_Start, (), ());
DECLPROC_NOIMPL(App_Done, (), ());
DECLPROC(App_PreGarbageCollectDelegate, (), ());

DECLPROC(Class_Register, (UClass* uclass, void** callbacks), (uclass, callbacks));

DECLPROC(Object_Created, (UObject* uobject), (uobject));
DECLPROC(Object_Deleted, (UObject* uobject), (uobject));

DECLPROC(Actor_Tick, (AActor* self, float deltaTime), (self, deltaTime));
DECLPROC(HUD_DrawHUD, (AHUD* self), (self));

DECLPROC(World_StartTick, (UWorld* uworld, ELevelTick tick, float deltaTime), (uworld, tick, deltaTime));

#ifdef UBF_IMPLEMENTATION

#include "UnrealBeef.cpp"

#endif