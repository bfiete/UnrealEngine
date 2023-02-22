using System;

namespace UnrealEngine;

[CRepr]
struct FRotator
{
	public double Pitch, Yaw, Roll;

	public this()
	{
		this = default;
	}

	public this(double pitch, double yaw, double roll)
	{
		Pitch = pitch;
		Yaw = yaw;
		Roll = roll;
	}
}