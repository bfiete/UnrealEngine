using System;

namespace UnrealEngine;

[UObject("SoundBase")]
class USoundBase : UObject
{
	public struct FuncTable
	{
		public function void(UObject_Native* self, UObject_Native* refObject, float volumeMultiplier, float pitchMultiplier, float startTime) Play2D;
		public function void(UObject_Native* self, UObject_Native* refObject, FVector location, float volumeMultiplier, float pitchMultiplier, float startTime) PlayAtLocation;
		public function void(UObject_Native* self) PrimeSound;
		public function UObject_Native*(UObject_Native* self, UObject_Native* refObject, float volumeMultiplier, float pitchMultiplier, float startTime) SpawnSound2D;
		public function UObject_Native*(UObject_Native* self, UObject_Native* refObject, float volumeMultiplier, float pitchMultiplier, float startTime) CreateSound2D;
		public function UObject_Native*(UObject_Native* self, UObject_Native* component, char8* pointName, FVector location, EAttachLocation locationType,
			bool stopWhenAttachedToDestroyed, float volumeMultiplier, float pitchMultiplier, float startTime, bool autoDestroy) SpawnAttached;
	}


	public void Play2D(UObject refObject, float volumeMultiplier = 1, float pitchMultiplier = 1, float startTime = 0) =>
		sFuncTable.Play2D(mNativeObject, (refObject != null) ? refObject.mNativeObject : null, volumeMultiplier, pitchMultiplier, startTime);
	public void PlayAtLocation(UObject refObject, FVector location, float volumeMultiplier = 1, float pitchMultiplier = 1, float startTime = 0) =>
		sFuncTable.PlayAtLocation(mNativeObject, (refObject != null) ? refObject.mNativeObject : null, location, volumeMultiplier, pitchMultiplier, startTime);
	public void PrimeSound() => sFuncTable.PrimeSound(mNativeObject);
	public UAudioComponent SpawnSound2D(UObject refObject, float volumeMultiplier = 1, float pitchMultiplier = 1, float startTime = 0) =>
		AppLink.GetObject(sFuncTable.SpawnSound2D(mNativeObject, (refObject != null) ? refObject.mNativeObject : null, volumeMultiplier, pitchMultiplier, startTime)) as UAudioComponent;
	public UAudioComponent CreateSound2D(UObject refObject, float volumeMultiplier = 1, float pitchMultiplier = 1, float startTime = 0) =>
		AppLink.GetObject(sFuncTable.CreateSound2D(mNativeObject, (refObject != null) ? refObject.mNativeObject : null, volumeMultiplier, pitchMultiplier, startTime)) as UAudioComponent;
	public UAudioComponent SpawnAttached(USceneComponent component, StringView attachPointName, FVector location, EAttachLocation attachLocation = .KeepRelativeOffset,  bool stopWhenAttachEdToDestroyed = false,
		float volumeMultiplier = 1, float pitchMultiplier = 1, float startTime = 0, bool autoDestroy = true) =>
		AppLink.GetObject(sFuncTable.SpawnAttached(mNativeObject, (component != null) ? component.mNativeObject : null, (attachPointName.IsEmpty) ? null : attachPointName.ToScopeCStr!(),
			location, attachLocation, stopWhenAttachEdToDestroyed, volumeMultiplier, pitchMultiplier, startTime, autoDestroy)) as UAudioComponent;
}