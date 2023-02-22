using System;

namespace UnrealEngine;

[CRepr]
struct FVector2D
{
	public double X, Y;

	public this()
	{
		this = default;
	}

	public this(double x, double y)
	{
		X = x;
		Y = y;
	}
}