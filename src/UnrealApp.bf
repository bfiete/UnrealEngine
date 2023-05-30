using System;

namespace UnrealEngine;

class UnrealApp
{
	public int32 mUpdateCnt;
	public float mTimeAcc;
	public bool mIsUpdateBatchStart;

	public this()
	{
		gUnrealApp = this;
	}

	public ~this()
	{
		gUnrealApp = null;
	}

	public virtual void Init()
	{

	}

	public virtual void Update(bool batchStart)
	{
		mUpdateCnt++;
	}

	public virtual void UpdateF(float pct)
	{
		
	}

	public virtual void StartTick(ELevelTick tick, float deltaTime)
	{
		float frameTime = 1 / 60.0f;

		float lastFramePct = mTimeAcc / frameTime;

		mIsUpdateBatchStart = true;

		mTimeAcc = Math.Min(mTimeAcc + (.)deltaTime, 1.0f);
		while (mTimeAcc > frameTime)
		{
			Update(mIsUpdateBatchStart);
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
}
