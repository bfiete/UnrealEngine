using System;

namespace UnrealEngine;

[AlwaysInclude(AssumeInstantiated=true)]
class AActor : UObject
{
	protected struct FuncTable
	{
		public function UWorld_Native*(UObject_Native* self) GetWorld;
		public function FVector(UObject_Native* self) GetActorForwardVector;
		public function FVector(UObject_Native* self) GetActorUpVector;
		public function FVector(UObject_Native* self) GetActorRightVector;
		public function FVector(UObject_Native* self) GetActorLocation;
		public function FQuat(UObject_Native* self) GetActorQuat;
		public function FRotator(UObject_Native* self) GetActorRotation;
		public function FVector(UObject_Native* self) GetActorScale;
		public function FTransform(UObject_Native* self) GetTransform;
		public function FVector(UObject_Native* self) GetVelocity;
		public function bool(UObject_Native* self, FVector NewLocation, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetActorLocation;
		public function bool(UObject_Native* self, FTransform NewTransform, bool bSweep, FHitResult* OutSweepHitResult, ETeleportType Teleport) SetActorTransform;
		public function bool(UObject_Native* self, FRotator NewRotation, ETeleportType Teleport) SetActorRotation_Rotator;
		public function bool(UObject_Native* self, FQuat NewRotation, ETeleportType Teleport) SetActorRotation_Quat;
		public function bool(UObject_Native* self, bool netForce, bool shouldModifyLevel) Destroy;
		public function bool(UObject_Native* self) IsActorBeingDestroyed;
		public function float(UObject_Native* self) GetActorTickInterval;
		public function void(UObject_Native* self, float tickInterval) SetActorTickInterval;
		public function UObject_Native*(UObject_Native* self) GetRootComponent;
	}
	protected static new FuncTable sFuncTable;
	static UClassHandler sHandler = AppLink.RegisterClassHandler(.. new UClassHandler("Actor", typeof(Self))..SetFuncTable(ref sFuncTable));

	///

	public int32 mUpdateCnt;
	public float mTimeAcc;
	public bool mIsUpdateBatchStart;

	public UWorld World => AppLink.GetObject(sFuncTable.GetWorld(mNativeObject)) as UWorld;
	public USceneComponent RootComponent => AppLink.GetObject(sFuncTable.GetRootComponent(mNativeObject)) as USceneComponent;
	public FVector ForwardVector => sFuncTable.GetActorForwardVector(mNativeObject);
	public FVector UpVector => sFuncTable.GetActorUpVector(mNativeObject);
	public FVector RightVector => sFuncTable.GetActorRightVector(mNativeObject);
	public FQuat Quat => sFuncTable.GetActorQuat(mNativeObject);
	public FRotator Rotation
	{
		get => sFuncTable.GetActorRotation(mNativeObject);
		set => sFuncTable.SetActorRotation_Rotator(mNativeObject, value, .None);
	}
	public FVector Scale => sFuncTable.GetActorScale(mNativeObject);
	public FTransform Transform => sFuncTable.GetTransform(mNativeObject);
	public FVector Velocity => sFuncTable.GetVelocity(mNativeObject);
	public bool IsBeingDestroyed => sFuncTable.IsActorBeingDestroyed(mNativeObject);

	public FVector Location
	{
		get => sFuncTable.GetActorLocation(mNativeObject);
		set => sFuncTable.SetActorLocation(mNativeObject, value, false, null, .None);
	}

	public float TickInterval
	{
		get => sFuncTable.GetActorTickInterval(mNativeObject);
		set => sFuncTable.SetActorTickInterval(mNativeObject, value);
	}

	public bool SetActorLocation(FVector NewLocation, bool bSweep, FHitResult* OutSweepHitResult = null, ETeleportType Teleport = .None) => sFuncTable.SetActorLocation(mNativeObject, NewLocation, bSweep, OutSweepHitResult, Teleport);
	public bool SetActorTransform(FTransform NewTransform, bool bSweep, FHitResult* OutSweepHitResult = null, ETeleportType Teleport = .None) => sFuncTable.SetActorTransform(mNativeObject, NewTransform, bSweep, OutSweepHitResult, Teleport);
	public bool SetActorRotation(FRotator NewRotation, ETeleportType Teleport= .None) => sFuncTable.SetActorRotation_Rotator(mNativeObject, NewRotation, Teleport);
	public bool SetActorRotation(FQuat NewRotation, ETeleportType Teleport = .None) => sFuncTable.SetActorRotation_Quat(mNativeObject, NewRotation, Teleport);
	public bool Destroy(bool netForce = false, bool shouldModifyLevel = true) => sFuncTable.Destroy(mNativeObject, netForce, shouldModifyLevel);

	public this()
	{

	}

	public ~this()
	{

	}

	public virtual void FirstTick()
	{

	}

	public virtual void Update()
	{
		mUpdateCnt++;
	}

	public virtual void UpdateF(float pct)
	{
		
	}

	public virtual void Tick(float deltaTime)
	{
		if ((mUpdateCnt == 0) && (mTimeAcc == 0))
			FirstTick();

		float frameTime = 1 / 60.0f;

		float lastFramePct = mTimeAcc / frameTime;

		mIsUpdateBatchStart = true;

		mTimeAcc = Math.Min(mTimeAcc + (.)deltaTime, 1.0f);
		while (mTimeAcc > frameTime)
		{
			Update();
			mTimeAcc -= frameTime;
			lastFramePct = 0;
			mIsUpdateBatchStart = false;
		}

		float framePct = mTimeAcc / frameTime;
		if (Math.Abs(framePct) > 0.001f)
		{
			UpdateF(framePct - lastFramePct);
		}
	}

	///
}