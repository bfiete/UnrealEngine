using System;

namespace UnrealEngine;

[CRepr]
struct FVector4
{
	[Reflect]
	public double X;
	[Reflect]
	public double Y;
	[Reflect]
	public double Z;
	[Reflect]
	public double W;
}