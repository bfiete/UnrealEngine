using System;

namespace UnrealEngine;

[AlwaysInclude(AssumeInstantiated=true)]
class APawn : AActor
{
	protected struct FuncTable
	{
		public function AController_Native*(UObject_Native* self) GetController;
	}
	protected static new FuncTable sFuncTable;
	static UClassHandler sHandler = AppLink.RegisterClassHandler(.. new UClassHandler("Pawn", typeof(Self))..SetFuncTable(ref sFuncTable));

	///

	public AController GetController() => AppLink.GetObject(sFuncTable.GetController(mNativeObject)) as AController;
}