using System;
using System.Diagnostics;
using System.Collections;

namespace UnrealEngine;

struct UObject_Native
{
	void* mVTable;
}

struct AGameModeBase_Native : UObject_Native
{

}

struct AActor_Native : UObject_Native
{

}

struct APawn_Native : AActor_Native
{

}

struct UWorld_Native : UObject_Native
{

}

struct AHUD_Native : UObject_Native
{

}

struct AController_Native : UObject_Native
{

}

struct UClass_Native;


static class AppLink
{
	protected struct FuncTable
	{
		public function char16*(UClass_Native* uclass) Class_GetName;
		public function UClass_Native*(UClass_Native* uclass) Class_GetSuperClass;
		public function void(uint64 Key, float TimeToDisplay, uint32 DisplayColor, char8* DebugMessage, bool bNewerOnTop, FVector2D TextScale) Engine_AddOnScreenDebugMessage;
		public function void(bool onGameModeExit, bool onCPPRebuild) SetWantsDLLUnload;
		public function void(bool fullPurge) Engine_ForceGarbageCollection;
		public function FVector(FTransform transform, FVector vec) TransformPosition;
		public function FVector(FTransform transform, FVector vec) TransformPositionNoScale;
		public function FVector(FTransform transform, FVector vec) TransformVector;
		public function FVector(FTransform transform, FVector vec) TransformVectorNoScale;
		public function UObject_Native*(char8* name) FindObject;
		public function UObject_Native*(UClass_Native* uclass) CreateObject;
	}

	protected static FuncTable sFuncTable;
	static Dictionary<String, UClassHandler> sClassHandlerNameDict = new .() ~ DeleteDictionaryAndKeysAndValues!(_);
	static Dictionary<UClass_Native*, UClassHandler> sClassHandlerDict = new .() ~ delete _;
	static Dictionary<UObject_Native*, (UClassHandler classHandler, UObject object)> sObjectDict = new .() ~ delete _;
	static HashSet<UObject> sObjectSet = new .() ~ DeleteContainerAndItems!(_);
	public static Type sAppType;

	public static ~this()
	{
		delete gUnrealApp;
	}

	public static void RegisterClassHandler(UClassHandler classHandler)
	{
		Debug.Assert(classHandler.mClassName != null);
		if (sClassHandlerNameDict.TryAdd(classHandler.mClassName, var keyPtr, var valuePtr))
		{
			*keyPtr = new .(classHandler.mClassName);
		}
		*valuePtr = classHandler;
	}

	public static void SetWantsDLLUnload(bool onAppDone, bool onCPPRebuild)
	{
		sFuncTable.SetWantsDLLUnload(onAppDone, onCPPRebuild);
	}

	static UObject AllocObject(UObject_Native* uobject)
	{
		UClass_Native* uclass = UObject.[Friend]sFuncTable.GetClass(uobject);
		while (uclass != null)
		{
			if (sClassHandlerDict.TryGet(uclass, ?, var classHandler))
			{
				var object = classHandler.mClassType.CreateObject().GetValueOrDefault() as UObject;
				if (object != null)
				{
					object.mNativeObject = uobject;
					object.Init();
					sObjectSet.Add(object);
					sObjectDict[uobject] = (classHandler, object);
				}
				return object;
			}

			uclass = sFuncTable.Class_GetSuperClass(uclass);
		}

		return null;
	}

	public static UObject GetObject(UObject_Native* uobject)
	{
		if (uobject == null)
			return null;
		if (sObjectDict.TryGet(uobject, ?, var kv))
			return kv.object;
		return AllocObject(uobject);
	}

	static void ObjectDeleted(UObject_Native* uobject)
	{
		if (sObjectDict.GetAndRemove(uobject) case .Ok(var tup))
		{
			sObjectSet.Remove(tup.value.object);
			delete tup.value.object;
		}
	}

	static UObject GetUObject(UObject_Native* uobject)
	{
		if (sObjectDict.TryGet(uobject, ?, var kv))
			return kv.object;
		return null;
	}

	public static void CheckObjectWeakRefs()
	{
		List<UObject> deleteList = scope .();
		for (var object in sObjectSet)
		{
			if (object.IsObjectValid)
				continue;
			
			@object.Remove();
			var uobject = object.mNativeObject;
			if (sObjectDict.GetAndRemove(uobject) case .Ok(var tup))
			{
				Debug.Assert(tup.value.object == object);
			}
			deleteList.Add(object);
			object.PreDelete();
		}

		for (var object in deleteList)
			delete object;
	}

	[Export, CLink]
	static void App_Init(int32 version, void** funcTable)
	{
		sFuncTable = *(FuncTable*)funcTable;
	}

	[Export, CLink]
	static void App_Start()
	{
		if (sAppType != null)
			sAppType.CreateObject();

		gUnrealApp?.Init();
	}

	[Export, CLink]
	static void App_Done()
	{
		delete gUnrealApp;
	}

	[Export, CLink]
	static void App_PreGarbageCollectDelegate()
	{
		for (var obj in sObjectSet)
		{
			//obj.GCMarkObject();
		}
	}

	[Export, CLink]
	static void Class_Register(UClass_Native* uclass, void** funcTable)
	{
		String className = scope .();
		className.Append(sFuncTable.Class_GetName(uclass));

		if (sClassHandlerNameDict.TryGet(className, ?, var classHandler))
		{
			sClassHandlerDict[uclass] = classHandler;
			classHandler.mClass = uclass;
			if (funcTable != null)
				Internal.MemCpy(classHandler.mFuncTableRef.Ptr, funcTable, classHandler.mFuncTableRef.Length * sizeof(void*), sizeof(void*));
		}
		else
		{
			Debug.FatalError(scope $"Class '{className}'' not found");
		}
	}

	[Export, CLink]
	static void Object_Created(UObject_Native* self)
	{
		AllocObject(self);
	}

	[Export, CLink]
	static void Object_Deleted(UObject_Native* self)
	{
		ObjectDeleted(self);
	}

	[Export, CLink]
	static void Actor_Tick(UObject_Native* self, float tickDelta)
	{
		if (var actor = GetUObject(self) as AActor)
			actor.Tick(tickDelta);
	}

	[Export, CLink]
	static void World_StartTick(UWorld_Native* self, ELevelTick tick, float timeDelta)
	{
		CheckObjectWeakRefs();
		gUnrealApp?.StartTick(tick, timeDelta);
	}

	[Export, CLink]
	static void HUD_DrawHUD(AHUD_Native* self)
	{
		if (var hud = GetUObject(self) as AHUD)
			hud.DrawHUD();
	}

	///

	public static void AddOnScreenDebugMessage(int64 Key, float TimeToDisplay, uint32 DisplayColor, StringView DebugMessage, bool bNewerOnTop = true, FVector2D TextScale = .(1, 1))
	{
		sFuncTable.Engine_AddOnScreenDebugMessage((.)Key, TimeToDisplay, DisplayColor, DebugMessage.ToScopeCStr!(), bNewerOnTop, TextScale);
	}

	public static void ForceGarbageCollection(bool fullPurge = false) => sFuncTable.Engine_ForceGarbageCollection(fullPurge);

	public static UObject FindObject(StringView name) => GetObject(sFuncTable.FindObject(name.ToScopeCStr!()));
	public static T CreateObject<T>() where T : UObject, var => GetObject(sFuncTable.CreateObject(T.[Friend]sHandler.mClass)) as T;
}

static
{
	public static UnrealApp gUnrealApp;
}