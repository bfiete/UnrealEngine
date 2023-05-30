using System;

namespace UnrealEngine;

[UObject("PlayerController")]
class APlayerController : AController
{
	protected struct FuncTable
	{
		public function bool(UObject_Native* self, char8* keyName) IsInputKeyDown;
		public function bool(UObject_Native* self, char8* keyName) WasInputKeyJustPressed;
		public function bool(UObject_Native* self, char8* keyName) WasInputKeyJustReleased;
		public function UObject_Native*(UObject_Native* self) GetHUD;
		public function void(UObject_Native* self, UObject_Native* component, FVector location, FRotator rotation) SetAudioListenerOverride;
		public function void(UObject_Native* self) ClearAudioListenerOverride;
		public function void(UObject_Native* self, UObject_Native* component, FVector attenuationLocationOverride) SetAudioListenerAttenuationOverride;
		public function void(UObject_Native* self) ClearAudioListenerAttenuationOverride;
	}

	public bool IsInputKeyDown(StringView keyName) => sFuncTable.IsInputKeyDown(mNativeObject, keyName.ToScopeCStr!());
	public bool WasInputKeyJustPressed(StringView keyName) => sFuncTable.WasInputKeyJustPressed(mNativeObject, keyName.ToScopeCStr!());
	public bool WasInputKeyJustReleased(StringView keyName) => sFuncTable.WasInputKeyJustReleased(mNativeObject, keyName.ToScopeCStr!());
	public AHUD HUD => AppLink.GetObject(sFuncTable.GetHUD(mNativeObject)) as AHUD;
	public void SetAudioListenerOverride(USceneComponent component, FVector location, FRotator rotation) => sFuncTable.SetAudioListenerOverride(mNativeObject, component.GetNative(), location, rotation);
	public void ClearAudioListenerOverride() => sFuncTable.ClearAudioListenerOverride(mNativeObject);
	public void SetAudioListenerAttenuationOverride(USceneComponent component, FVector attenuationLocationOverride) => sFuncTable.SetAudioListenerAttenuationOverride(mNativeObject, component.GetNative(), attenuationLocationOverride);
	public void ClearAudioListenerAttenuationOverride() => sFuncTable.ClearAudioListenerAttenuationOverride(mNativeObject);;
}