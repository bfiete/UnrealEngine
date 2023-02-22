using System;

namespace UnrealEngine;

class UClassHandler
{
	public UClass_Native* mClass;
	public String mClassName ~ delete _;
	public Type mClassType;
	public Span<void*> mFuncTableRef;

	public this(StringView className, Type classType = null)
	{
		mClassName = new .(className);
		mClassType = classType;
	}

	public void SetFuncTable<T>(ref T funcTable) where T : struct
	{
		mFuncTableRef = .((void**)&funcTable, sizeof(T) / sizeof(void*));
	}
}