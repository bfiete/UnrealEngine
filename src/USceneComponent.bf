using System;

namespace UnrealEngine;

[UObject("SceneComponent")]
class USceneComponent : UActorComponent
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, FRotator rotator, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) AddLocalRotation;
		public function void(UObject_Native* self, FRotator rotator, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetRelativeRotation;
	}
	
	public void AddLocalRotation(FRotator rotator, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.AddLocalRotation(mNativeObject, rotator, sweep, outSweepHitResult, teleport);
	public void SetRelativeRotation(FRotator rotator, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.SetRelativeRotation(mNativeObject, rotator, sweep, outSweepHitResult, teleport);
}