namespace UnrealEngine;

[UObject("ActorComponent")]
class UActorComponent : UObject
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, bool promoteChildren) DeleteComponent;
		public function void(UObject_Native* self) UnregisterComponent;
		public function void(UObject_Native* self) RegisterComponent;
	}

	public void DeleteComponent(bool promoteChildren = false) => sFuncTable.DeleteComponent(mNativeObject, promoteChildren);
	public void RegisterComponent() => sFuncTable.RegisterComponent(mNativeObject);
	public void UnregisterComponent() => sFuncTable.UnregisterComponent(mNativeObject);
}