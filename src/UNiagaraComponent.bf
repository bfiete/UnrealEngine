using System;

namespace UnrealEngine;

[UObject("NiagaraComponent")]
class UNiagaraComponent : USceneComponent
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, char8* name, float value) SetVariableFloat;
		public function void(UObject_Native* self, char8* name, int value) SetVariableInt;
		public function void(UObject_Native* self) DestroyInstance;
		public function void(UObject_Native* self) ReinitializeSystem;
	}

	public void SetVariableFloat(StringView name, float value) => sFuncTable.SetVariableFloat(mNativeObject, name.ToScopeCStr!(), value);
	public void SetVariableInt(StringView name, int32 value) => sFuncTable.SetVariableInt(mNativeObject, name.ToScopeCStr!(), value);
	public void DestroyInstance() => sFuncTable.DestroyInstance(mNativeObject);
	public void ReinitializeSystem() => sFuncTable.ReinitializeSystem(mNativeObject);
}