using System;

namespace UnrealEngine;

[UObject("World")]
class UWorld : UObject
{
	protected struct FuncTable
	{
		public function void (UObject_Native* self, FVector lineStart, FVector lineEnd, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness) DrawDebugLine;
		public function bool(UObject_Native* self, FHitResult* hitResult, FVector from, FVector to, ECollisionChannel collisionChannel, UObject_Native* ignoredActor) LineTraceSingleByChannel;
		public function void (UObject_Native* self, UObject_Native* actor, bool shouldModifyLevel) World_RemoveActor;
		public function AActor_Native*(UObject_Native* self, UClass_Native* uclass, FVector* location, FRotator* rotation, char8* name, EObjectFlags flags) World_SpawnActor;
		public function void (UObject_Native* self, FVector lineStart, FVector lineEnd, float arrowSize, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness) DrawDebugDirectionalArrow;
		public function void (UObject_Native* self, FVector center, float radius, int32 segments, uint32 color, bool persistentLine, float lifetime, uint8 depthPriority, float thickness, FVector yAxis, FVector zAxis, bool drawAxis) DrawDebugCircle;
	}

	public this(UWorld_Native* self) : base(self)
	{

	}

	public void DrawDebugLine(FVector lineStart, FVector lineEnd, uint32 color, bool persistentLine = false, float lifetime = -1, uint8 depthPriority = 0, float thickness = 0) => sFuncTable.DrawDebugLine(mNativeObject, lineStart, lineEnd, color, persistentLine, lifetime, depthPriority, thickness);
	public bool LineTraceSingleByChannel(FHitResult* hitResult, FVector from, FVector to, ECollisionChannel collisionChannel, AActor ignoredActor) => sFuncTable.LineTraceSingleByChannel(mNativeObject, hitResult, from, to, collisionChannel, (ignoredActor == null) ? null : ignoredActor.mNativeObject);
	public void RemoveActor(AActor actor, bool shouldModifyLevel) => sFuncTable.World_RemoveActor(mNativeObject, actor.mNativeObject, shouldModifyLevel);

	public void DrawDebugDirectionalArrow(FVector lineStart, FVector lineEnd, float arrowSize, uint32 color, bool persistentLine = false, float lifetime = -1, uint8 depthPriority = 0, float thickness = 0) =>
		sFuncTable.DrawDebugDirectionalArrow(mNativeObject, lineStart, lineEnd, arrowSize, color, persistentLine, lifetime, depthPriority, thickness);
	public void DrawDebugCircle(FVector center, float radius, int32 segments, uint32 color, bool persistentLine = false, float lifetime = -1, uint8 depthPriority = 0, float thickness = 0, FVector yAxis = .(0, 1, 0), FVector zAxis = .(0, 0, 1), bool drawAxis = false) =>
		sFuncTable.DrawDebugCircle(mNativeObject, center, radius, segments, color, persistentLine, lifetime, depthPriority, thickness, yAxis, zAxis, drawAxis);

	public T SpawnActor<T>(FVector? location, FRotator? rotator, StringView name, EObjectFlags flags) where T : UObject, var
	{
		var location;
		var rotator;
		var result = sFuncTable.World_SpawnActor(mNativeObject, sHandler.mClass,
			(location == null) ? null : &location.ValueRef, (rotator == null) ? null : &rotator.ValueRef,
			name.IsEmpty ? null : name.ToScopeCStr!(), flags);
		return AppLink.GetObject(result) as T;
	}
}
