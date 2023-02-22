using System;

namespace UnrealEngine;

[AlwaysInclude(AssumeInstantiated=true)]
class AGameModeBase : AActor
{
	protected struct FuncTable
	{
		
	}
	protected new static FuncTable sFuncTable;
	static UClassHandler sHandler = AppLink.RegisterClassHandler(.. new UClassHandler("GameModeBase", typeof(Self))..SetFuncTable(ref sFuncTable));
}