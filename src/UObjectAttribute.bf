using System;

namespace UnrealEngine;

[AttributeUsage(.Class, .DisallowAllowMultiple, AlwaysIncludeUser=.AssumeInstantiated, ReflectUser=.DefaultConstructor)]
struct UObjectAttribute : Attribute, IOnTypeInit
{
	String mTypeName;

	public this(String typeName)
	{
		mTypeName = typeName;
	}

	[Comptime]
	public void OnTypeInit(Type type, Self* prev)
	{
		String codeStr = scope .();

		codeStr.AppendF($"""
			static protected new FuncTable sFuncTable;
			static UnrealEngine.UClassHandler sHandler = UnrealEngine.AppLink.RegisterClassHandler(.. new UClassHandler("{mTypeName}", typeof(Self))..SetFuncTable(ref sFuncTable));
		""");
		
		Compiler.EmitTypeBody(type, codeStr);
	}
}
