using System;
namespace UnrealEngine;

class AController : UObject
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, UObject_Native* pawn) Possess;
	}

	protected static new FuncTable sFuncTable;
	static UClassHandler sHandler = AppLink.RegisterClassHandler(.. new UClassHandler("Controller", typeof(Self))..SetFuncTable(ref sFuncTable));

	public void Possess(APawn pawn)
	{
		sFuncTable.Possess(mNativeObject, pawn.mNativeObject);
	}
}