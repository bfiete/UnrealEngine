namespace UnrealEngine;

enum EAttachLocation : int32
{
	KeepRelativeOffset,
	/// Automatically calculates the relative transform such that the attached component maintains the same world transform
	KeepWorldPosition,
	/// Snaps location and rotation to the attach point. Calculates the relative scale so that the final world scale of the component remains the same. 
	SnapToTarget,
	/// Snaps entire transform to target, including scale. */
	SnapToTargetIncludingScale
}