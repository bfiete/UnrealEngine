using System;

namespace UnrealEngine;

[CRepr]
struct FHitResult
{
	public int32 mFaceIndex;
	public float mDistance;
	public FVector mLocation;
	public FVector mImpactPoint;
	public FVector mNormal;
	public FVector mImpactNormal;
	public FVector mTraceStart;
	public FVector mTraceEnd;
	public float mPenetrationDepth;
	public int32 mMyItem;
	public int32 mItem;
	public uint8 mElementIdx;
	public bool mBlockingHit;
	public bool mStartPenetrating;
	public UWeakRef<AActor> mHitActor;
	public UWeakRef<USceneComponent> mHitComponent;
}