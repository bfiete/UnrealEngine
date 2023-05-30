namespace UnrealEngine;

[UObject("AudioComponent")]
class UAudioComponent : USceneComponent
{
	public struct FuncTable
	{
		public function void(UObject_Native* self, UObject_Native* sound) SetSound;
		public function void(UObject_Native* self, float startTime) Play;
		public function void(UObject_Native* self) Stop;
		public function void(UObject_Native* self, bool paused) SetPaused;
		public function void(UObject_Native* self, bool autoDestroy) SetAutoDestroy;
		public function bool(UObject_Native* self) IsPlaying;
		public function void(UObject_Native* self, float multiplier) SetVolumeMultiplier;
		public function void(UObject_Native* self, float multiplier) SetPitchMultiplier;
	}

	public void SetSound(USoundBase sound) => sFuncTable.SetSound(mNativeObject, sound.mNativeObject);
	public void Play(float startTime = 0) => sFuncTable.Play(mNativeObject, startTime);
	public void Stop() => sFuncTable.Stop(mNativeObject);
	public void SetPaused(bool paused) => sFuncTable.SetPaused(mNativeObject, paused);
	public void SetAutoDestroy(bool autoDestroy) => sFuncTable.SetAutoDestroy(mNativeObject, autoDestroy);
	public bool IsPlaying() => sFuncTable.IsPlaying(mNativeObject);
	public void SetVolumeMultiplier(float multiplier) => sFuncTable.SetVolumeMultiplier(mNativeObject, multiplier);
	public void SetPitchMultiplier(float multiplier) => sFuncTable.SetPitchMultiplier(mNativeObject, multiplier);
}