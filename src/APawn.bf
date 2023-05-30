using System;

namespace UnrealEngine;

[UObject("Pawn")]
class APawn : AActor
{
	protected struct FuncTable
	{
		public function AController_Native*(UObject_Native* self) GetController;
	}
	
	public AController Controller => AppLink.GetObject(sFuncTable.GetController(mNativeObject)) as AController;
}