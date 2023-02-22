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
	}

	public bool IsInputKeyDown(StringView keyName) => sFuncTable.IsInputKeyDown(mNativeObject, keyName.ToScopeCStr!());
	public bool WasInputKeyJustPressed(StringView keyName) => sFuncTable.WasInputKeyJustPressed(mNativeObject, keyName.ToScopeCStr!());
	public bool WasInputKeyJustReleased(StringView keyName) => sFuncTable.WasInputKeyJustReleased(mNativeObject, keyName.ToScopeCStr!());
}