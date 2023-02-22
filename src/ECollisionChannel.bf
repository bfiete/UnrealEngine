namespace UnrealEngine;

enum ECollisionChannel : int32
{
	WorldStatic,
	WorldDynamic,
	Pawn,
	Visibility,
	Camera,
	PhysicsBody,
	Vehicle,
	Destructible,

	/** Reserved for gizmo collision */
	EngineTraceChannel1,

	EngineTraceChannel2,
	EngineTraceChannel3,
	EngineTraceChannel4, 
	EngineTraceChannel5,
	EngineTraceChannel6,

	GameTraceChannel1,
	GameTraceChannel2,
	GameTraceChannel3,
	GameTraceChannel4,
	GameTraceChannel5,
	GameTraceChannel6,
	GameTraceChannel7,
	GameTraceChannel8,
	GameTraceChannel9,
	GameTraceChannel10,
	GameTraceChannel11,
	GameTraceChannel12,
	GameTraceChannel13,
	GameTraceChannel14,
	GameTraceChannel15,
	GameTraceChannel16,
	GameTraceChannel17,
	GameTraceChannel18,

	OverlapAll_Deprecated,
	MAX,
}