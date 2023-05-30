using System;

namespace UnrealEngine;

[CRepr]
public struct FVector : IHashable, IEquatable<FVector>
{
	[Reflect]
    public double X;
	[Reflect]
    public double Y;
	[Reflect]
    public double Z;

    private static FVector sZero = FVector(0f, 0f, 0f);
    private static FVector sOne = FVector(1f, 1f, 1f);
    private static FVector sUnitX = FVector(1f, 0f, 0f);
    private static FVector sUnitY = FVector(0f, 1f, 0f);
    private static FVector sUnitZ = FVector(0f, 0f, 1f);
    private static FVector sUp = FVector(0f, 1f, 0f);
    private static FVector sDown = FVector(0f, -1f, 0f);
    private static FVector sRight = FVector(1f, 0f, 0f);
    private static FVector sLeft = FVector(-1f, 0f, 0f);
    private static FVector sForward = FVector(0f, 0f, -1f);
    private static FVector sBackward = FVector(0f, 0f, 1f);

    public static FVector Zero
    {
        get { return sZero; }
    }

    public static FVector One
    {
        get { return sOne; }
    }

    public static FVector UnitX
    {
        get { return sUnitX; }
    }

    public static FVector UnitY
    {
        get { return sUnitY; }
    }

    public static FVector UnitZ
    {
        get { return sUnitZ; }
    }

    public static FVector Up
    {
        get { return sUp; }
    }

    public static FVector Down
    {
        get { return sDown; }
    }

    public static FVector Right
    {
        get { return sRight; }
    }

    public static FVector Left
    {
        get { return sLeft; }
    }

    public static FVector Forward
    {
        get { return sForward; }
    }

    public static FVector Backward
    {
        get { return sBackward; }
    }

    public double Length
    {
        get
        {
            return (double)Math.Sqrt(X * X + Y * Y + Z * Z);
        }
    }

    public double LengthSquared
    {
        get
        {
            return X * X + Y * Y + Z * Z;
        }
    }

	public FVector Normalized
	{
		get
		{
			Normalize(this, var vec);
			return vec;
		}
	}

	public this()
	{
		this = default;
	}

    public this(double x, double y, double z)
    {
        X = x;
        Y = y;
        Z = z;
    }

    public bool Equals(FVector other)
    {
        return this == other;
    }

    public int GetHashCode()
    {
        return (int)(this.X + this.Y + this.Z);
    }


    /*public static Vector2D Add(Vector2D vec1, Vector2D vec2)
    {
        return new Vector2D(vec1.X + vec2.X, vec1.Y + vec2.Y);
    }

    public static Vector2D Subtract(Vector2D vec1, Vector2D vec2)
    {
        return new Vector2D(vec1.X - vec2.X, vec1.Y - vec2.Y);
    }*/
    

    public static FVector Normalize(FVector vector)
    {
		FVector newVec;
        Normalize(vector, out newVec);
        return newVec;
    }

    public static void Normalize(FVector value, out FVector result)
    {
        double factor= Distance(value, sZero);
        factor = 1f / factor;
        result.X = value.X * factor;
        result.Y = value.Y * factor;
        result.Z = value.Z * factor;
    }

    public static double Dot(FVector vec1, FVector vec2)
    {
        return vec1.X * vec2.X + vec1.Y * vec2.Y + vec1.Z * vec2.Z;
    }

    public static FVector Cross(FVector vector1, FVector vector2)
    {
        return FVector(vector1.Y * vector2.Z - vector2.Y * vector1.Z,
                             -(vector1.X * vector2.Z - vector2.X * vector1.Z),
                             vector1.X * vector2.Y - vector2.X * vector1.Y);
    }

    public static double DistanceSquared(FVector value1, FVector value2)
    {
        return (value1.X - value2.X) * (value1.X - value2.X) +
                 (value1.Y - value2.Y) * (value1.Y - value2.Y) +
                 (value1.Z - value2.Z) * (value1.Z - value2.Z);
    }

    public static double Distance(FVector vector1, FVector vector2)
    {
        double result = DistanceSquared(vector1, vector2);
        return (double)Math.Sqrt(result);
    }

    /*public static Vector2D FromAngle(double angle, double length = 1.0f)
    {
        return new Vector2D((double)Math.Cos(angle) * length, (double)Math.Sin(angle) * length);
    }*/

    public static FVector TransformW(FVector vec, FMatrix matrix)
    {
		FVector result;
        double fInvW = 1.0f / (matrix.m30 * vec.X + matrix.m31 * vec.Y + matrix.m32 * vec.Z + matrix.m33);

        result.X = (matrix.m00 * vec.X + matrix.m01 * vec.Y + matrix.m02 * vec.Z + matrix.m03) * fInvW;
        result.Y = (matrix.m10 * vec.X + matrix.m11 * vec.Y + matrix.m12 * vec.Z + matrix.m13) * fInvW;
        result.Z = (matrix.m20 * vec.X + matrix.m21 * vec.Y + matrix.m22 * vec.Z + matrix.m23) * fInvW;

		return result;
    }

	public static FVector Transform(FVector vec, FMatrix matrix)
	{
		FVector result;
		result.X = (vec.X * matrix.m00) + (vec.Y * matrix.m01) + (vec.Z * matrix.m02) + matrix.m03;
		result.Y = (vec.X * matrix.m10) + (vec.Y * matrix.m11) + (vec.Z * matrix.m12) + matrix.m13;
		result.Z = (vec.X * matrix.m20) + (vec.Y * matrix.m21) + (vec.Z * matrix.m22) + matrix.m23;
		return result;
	}

    /*public static void Transform(FVector[] sourceArray, ref Matrix4 matrix, FVector[] destinationArray)
    {
        //Debug.Assert(destinationArray.Length >= sourceArray.Length, "The destination array is smaller than the source array.");
        
        for (var i = 0; i < sourceArray.Length; i++)
        {
            var position = sourceArray[i];
            destinationArray[i] =
                new FVector(
                    (position.X * matrix.m11) + (position.Y * matrix.m21) + (position.Z * matrix.m31) + matrix.m41,
                    (position.X * matrix.m12) + (position.Y * matrix.m22) + (position.Z * matrix.m32) + matrix.m42,
                    (position.X * matrix.m13) + (position.Y * matrix.m23) + (position.Z * matrix.m33) + matrix.m43);
        }
    }*/

	/// <summary>
	/// Returns a <see>FVector</see> pointing in the opposite
	/// direction of <paramref name="value"/>.
	/// </summary>
	/// <param name="value">The vector to negate.</param>
	/// <returns>The vector negation of <paramref name="value"/>.</returns>
	public static FVector Negate(FVector value)
	{
	    return .(-value.X, -value.Y, -value.Z);
	}

	/// <summary>
	/// Stores a <see>FVector</see> pointing in the opposite
	/// direction of <paramref name="value"/> in <paramref name="result"/>.
	/// </summary>
	/// <param name="value">The vector to negate.</param>
	/// <param name="result">The vector that the negation of <paramref name="value"/> will be stored in.</param>
	public static void Negate(FVector value, out FVector result)
	{
	    result.X = -value.X;
	    result.Y = -value.Y;
	    result.Z = -value.Z;
	}

	/// <summary>
	/// Creates a new <see cref="FVector"/> that contains a multiplication of two vectors.
	/// </summary>
	/// <param name="value1">Source <see cref="FVector"/>.</param>
	/// <param name="value2">Source <see cref="FVector"/>.</param>
	/// <returns>The result of the vector multiplication.</returns>
	public static FVector Multiply(FVector value1, FVector value2)
	{
		return .(value1.X * value2.X, value1.Y * value2.Y, value1.Z * value2.Z);
	}

	public static FVector Multiply(FVector value1, double value2)
	{
		return .(value1.X * value2, value1.Y * value2, value1.Z * value2);
	}

	public void Normalize() mut
	{
	    Normalize(this, out this);
	}

    public static FVector Transform(FVector vec, FQuat quat)
    {        
        FMatrix matrix = quat.ToMatrix();
        return Transform(vec, matrix);
    }

    public static FVector TransformNormal(FVector normal, FMatrix matrix)
    {
        return FVector((normal.X * matrix.m11) + (normal.Y * matrix.m21) + (normal.Z * matrix.m31),
                             (normal.X * matrix.m12) + (normal.Y * matrix.m22) + (normal.Z * matrix.m32),
                             (normal.X * matrix.m13) + (normal.Y * matrix.m23) + (normal.Z * matrix.m33));
    }

    public static bool operator ==(FVector value1, FVector value2)
    {
        return (value1.X == value2.X) &&
            (value1.Y == value2.Y) &&
            (value1.Z == value2.Z);
    }

    public static bool operator !=(FVector value1, FVector value2)
    {
        return !(value1 == value2);
    }

    public static FVector operator +(FVector vec1, FVector vec2)
    {
        return FVector(vec1.X + vec2.X, vec1.Y + vec2.Y, vec1.Z + vec2.Z);
    }        

    public static FVector operator -(FVector vec1, FVector vec2)
    {
        return FVector(vec1.X - vec2.X, vec1.Y - vec2.Y, vec1.Z - vec2.Z);
    }

	public static FVector operator -(FVector vec1)
	{
	    return FVector(-vec1.X, -vec1.Y, -vec1.Z);
	}

    public static FVector operator *(FVector vec, double scale)
    {
        return FVector(vec.X * scale, vec.Y * scale, vec.Z * scale);
    }

    public override void ToString(String str)
    {
        str.AppendF("{0:0.0#}, {1:0.0#}, {2:0.0#}", X, Y, Z);
    }
}