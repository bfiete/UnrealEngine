using System;

namespace UnrealEngine;

[UObject("Object")]
class UObject
{
	protected struct FuncTable
	{
		public function UClass_Native*(UObject_Native* self) GetClass;
		public function bool(UObject_Native* self, UClass_Native* toClass) CanCast;
		public function void(UObject_Native* self, ref int32 objectIndex, ref int32 objectSerialNumber) GetWeakRef;
		public function UObject_Native*(int32 objectIndex, int32 objectSerialNumber) CheckWeakRef;
		public function UObject_Native*(UObject_Native* self) GetGameMode;
		public function UObject_Native*(UObject_Native* self) GetGameState;
		public function void(UObject_Native* self) GCMarkObject;
	}
	///

	public UObject_Native* mNativeObject;
	public int32 mObjectIndex;
	public int32 mObjectSerialNumber;

	public bool IsObjectValid => sFuncTable.CheckWeakRef(mObjectIndex, mObjectSerialNumber) == mNativeObject;
	public AGameModeBase GameMode => AppLink.GetObject(sFuncTable.GetGameMode(mNativeObject)) as AGameModeBase;

	public this()
	{

	}

	public this(UObject_Native* self)
	{
		mNativeObject = self;
	}

	public virtual void Init()
	{
		sFuncTable.GetWeakRef(mNativeObject, ref mObjectIndex, ref mObjectSerialNumber);
	}

	public void GCMarkObject() => sFuncTable.GCMarkObject(mNativeObject);
}