namespace UnrealEngine;

[UObject("NiagaraSystem")]
class UNiagaraSystem : UObject
{
	protected struct FuncTable
	{
		public function UObject_Native*(UObject_Native* self, UObject_Native* world, FVector location, FRotator rotation) SpawnSystemAtLocation;
	}

	public UNiagaraComponent SpawnSystemAtLocation(UWorld world, FVector location, FRotator rotation) =>
		AppLink.GetObject(sFuncTable.SpawnSystemAtLocation(mNativeObject, world.mNativeObject, location, rotation)) as UNiagaraComponent;
}