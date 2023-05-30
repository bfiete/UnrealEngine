using System;

namespace UnrealEngine;

[UObject("SceneComponent")]
class USceneComponent : UActorComponent
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, FRotator rotator, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) AddLocalRotation;
		public function void(UObject_Native* self, FRotator rotator, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetRelativeRotation;
		public function void(UObject_Native* self, FRotator rotator, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetWorldRotation;
		public function void(UObject_Native* self, FVector location, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetRelativeLocation;
		public function void(UObject_Native* self, FVector location, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetWorldLocation;
		public function void(UObject_Native* self, UObject_Native* component) AttachToComponent;
	}
	
	public void AddLocalRotation(FRotator rotator, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.AddLocalRotation(mNativeObject, rotator, sweep, outSweepHitResult, teleport);
	public void SetRelativeRotation(FRotator rotator, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.SetRelativeRotation(mNativeObject, rotator, sweep, outSweepHitResult, teleport);
	public void SetWorldRotation(FRotator rotator, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.SetWorldRotation(mNativeObject, rotator, sweep, outSweepHitResult, teleport);
	public void SetRelativeLocation(FVector location, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.SetRelativeLocation(mNativeObject, location, sweep, outSweepHitResult, teleport);
	public void SetWorldLocation(FVector location, bool sweep = false, FHitResult* outSweepHitResult = null, ETeleportType teleport = .None) => sFuncTable.SetWorldLocation(mNativeObject, location, sweep, outSweepHitResult, teleport);
	public void AttachToComponent(USceneComponent component) => sFuncTable.AttachToComponent(mNativeObject, (component == null) ? null : component.mNativeObject);
}