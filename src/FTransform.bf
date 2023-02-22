using System;

namespace UnrealEngine;

struct VectorRegister4Double
{
	public double X, Y, Z, W;
}

[CRepr]
struct FTransform
{
	public FQuat Rotation;
	public FVector4 Translation;
	public FVector4 Scale3D;

	public FVector TransformPosition(FVector vec) => AppLink.[Friend]sFuncTable.TransformPosition(this, vec);
	public FVector TransformPositionNoScale(FVector vec) => AppLink.[Friend]sFuncTable.TransformPositionNoScale(this, vec);
	public FVector TransformVector(FVector vec) => AppLink.[Friend]sFuncTable.TransformVector(this, vec);
	public FVector TransformVectorNoScale(FVector vec) => AppLink.[Friend]sFuncTable.TransformVectorNoScale(this, vec);
}