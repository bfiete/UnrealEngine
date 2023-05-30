using System;
namespace UnrealEngine;

[UObject("HUD")]
class AHUD : AActor
{
	protected struct FuncTable
	{
		public function void(UObject_Native* self, char8* text, float x, float y, uint32 color, UObject_Native* font, float scale, bool scalePosition) DrawText;
		public function void(UObject_Native* self, uint32 color, float x, float y, float width, float height) DrawRect;
	}

	public void DrawText(StringView text, float x, float y, uint32 color = 0xFFFFFFFF, UFont font = null, float scale = 1.0f, bool scalePosition = false) =>
		sFuncTable.DrawText(mNativeObject, text.ToScopeCStr!(), x, y, color, (font != null) ? font.mNativeObject : null, scale, scalePosition);
	public void DrawRect(uint32 color, float x, float y, float width, float height) => sFuncTable.DrawRect(mNativeObject, color, x, y, width, height);

	public virtual void DrawHUD()
	{

	}
}