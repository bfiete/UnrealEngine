using System;

namespace UnrealEngine;

struct UWeakRef<T> where T : UObject
{
	public int32 mObjectIndex;
	public int32 mObjectSerialNumber;

	public bool IsValid
	{
		get
		{
			if (mObjectIndex == 0)
				return false;
			return UObject.[Friend]sFuncTable.CheckWeakRef(mObjectIndex, mObjectSerialNumber) != null;
		}
	}

	public T Value
	{
		get
		{
			if (mObjectIndex == 0)
				return null;
			var nativeObject = UObject.[Friend]sFuncTable.CheckWeakRef(mObjectIndex, mObjectSerialNumber);
			if (nativeObject == null)
				return null;
			return AppLink.GetObject(nativeObject) as T;
		}
	}

	public this()
	{
		this = default;
	}

	public this(UObject object)
	{
		mObjectIndex = object.mObjectIndex;
		mObjectSerialNumber = object.mObjectSerialNumber;
	}

	public void Set(UObject object) mut
	{
		mObjectIndex = object.mObjectIndex;
		mObjectSerialNumber = object.mObjectSerialNumber;
	}

	public void Clear() mut
	{
		this = default;
	}
}