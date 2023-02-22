using System;
namespace UnrealEngine;

[CRepr, Align(16)]
public struct FQuat : IHashable, IEquatable<FQuat>
{
    public double X;
    public double Y;
    public double Z;
    public double W;
    public static readonly FQuat Identity = .(0, 0, 0, 1);

	public this()
	{
		this = default;
	}

    public this(double x, double y, double z, double w)
    {
        X = x;
        Y = y;
        Z = z;
        W = w;
    }
    
    public this(FVector vectorPart, double scalarPart)
    {
        X = vectorPart.X;
        Y = vectorPart.Y;
        Z = vectorPart.Z;
        W = scalarPart;
    }

    public static FQuat Add(FQuat FQuat1, FQuat FQuat2)
    {            
        FQuat FQuat;
        FQuat.X = FQuat1.X + FQuat2.X;
        FQuat.Y = FQuat1.Y + FQuat2.Y;
        FQuat.Z = FQuat1.Z + FQuat2.Z;
        FQuat.W = FQuat1.W + FQuat2.W;
        return FQuat;
    }


    public static void Add(ref FQuat FQuat1, ref FQuat FQuat2, out FQuat result)
    {            
        result.X = FQuat1.X + FQuat2.X;
        result.Y = FQuat1.Y + FQuat2.Y;
        result.Z = FQuat1.Z + FQuat2.Z;
        result.W = FQuat1.W + FQuat2.W;
    }

    public static FQuat Concatenate(FQuat value1, FQuat value2)
    {
        FQuat FQuat;
        double x = value2.X;
        double y = value2.Y;
        double z = value2.Z;
        double w = value2.W;
        double num4 = value1.X;
        double num3 = value1.Y;
        double num2 = value1.Z;
        double num = value1.W;
        double num12 = (y * num2) - (z * num3);
        double num11 = (z * num4) - (x * num2);
        double num10 = (x * num3) - (y * num4);
        double num9 = ((x * num4) + (y * num3)) + (z * num2);
        FQuat.X = ((x * num) + (num4 * w)) + num12;
        FQuat.Y = ((y * num) + (num3 * w)) + num11;
        FQuat.Z = ((z * num) + (num2 * w)) + num10;
        FQuat.W = (w * num) - num9;
        return FQuat;
    }

    public static void Concatenate(ref FQuat value1, ref FQuat value2, out FQuat result)
    {
        double x = value2.X;
        double y = value2.Y;
        double z = value2.Z;
        double w = value2.W;
        double num4 = value1.X;
        double num3 = value1.Y;
        double num2 = value1.Z;
        double num = value1.W;
        double num12 = (y * num2) - (z * num3);
        double num11 = (z * num4) - (x * num2);
        double num10 = (x * num3) - (y * num4);
        double num9 = ((x * num4) + (y * num3)) + (z * num2);
        result.X = ((x * num) + (num4 * w)) + num12;
        result.Y = ((y * num) + (num3 * w)) + num11;
        result.Z = ((z * num) + (num2 * w)) + num10;
        result.W = (w * num) - num9;
    }
            
    public void Conjugate() mut
    {
        X = -X;
        Y = -Y;
        Z = -Z;
    }
            
    public static FQuat Conjugate(FQuat value)
    {
        FQuat FQuat;
        FQuat.X = -value.X;
        FQuat.Y = -value.Y;
        FQuat.Z = -value.Z;
        FQuat.W = value.W;
        return FQuat;
    }

    public static void Conjugate(ref FQuat value, out FQuat result)
    {
        result.X = -value.X;
        result.Y = -value.Y;
        result.Z = -value.Z;
        result.W = value.W;
    }

    public static FQuat CreateFromAxisAngle(FVector axis, double angle)
    {
        FQuat FQuat;
        double num2 = angle * 0.5f;
        double num = (double)Math.Sin((double)num2);
        double num3 = (double)Math.Cos((double)num2);
        FQuat.X = axis.X * num;
        FQuat.Y = axis.Y * num;
        FQuat.Z = axis.Z * num;
        FQuat.W = num3;
        return FQuat;
    }

    public static void CreateFromAxisAngle(ref FVector axis, double angle, out FQuat result)
    {
        double num2 = angle * 0.5f;
        double num = (double)Math.Sin((double)num2);
        double num3 = (double)Math.Cos((double)num2);
        result.X = axis.X * num;
        result.Y = axis.Y * num;
        result.Z = axis.Z * num;
        result.W = num3;
    }

    public static FQuat CreateFromRotationMatrix(FMatrix matrix)
    {
        double num8 = (matrix.m11 + matrix.m22) + matrix.m33;
        FQuat FQuat = FQuat();
        if (num8 > 0f)
        {
            double num = (double)Math.Sqrt((double)(num8 + 1f));
            FQuat.W = num * 0.5f;
            num = 0.5f / num;
            FQuat.X = (matrix.m23 - matrix.m32) * num;
            FQuat.Y = (matrix.m31 - matrix.m13) * num;
            FQuat.Z = (matrix.m12 - matrix.m21) * num;
            return FQuat;
        }
        if ((matrix.m11 >= matrix.m22) && (matrix.m11 >= matrix.m33))
        {
            double num7 = (double)Math.Sqrt((double)(((1f + matrix.m11) - matrix.m22) - matrix.m33));
            double num4 = 0.5f / num7;
            FQuat.X = 0.5f * num7;
            FQuat.Y = (matrix.m12 + matrix.m21) * num4;
            FQuat.Z = (matrix.m13 + matrix.m31) * num4;
            FQuat.W = (matrix.m23 - matrix.m32) * num4;
            return FQuat;
        }
        if (matrix.m22 > matrix.m33)
        {
            double num6 = (double)Math.Sqrt((double)(((1f + matrix.m22) - matrix.m11) - matrix.m33));
            double num3 = 0.5f / num6;
            FQuat.X = (matrix.m21 + matrix.m12) * num3;
            FQuat.Y = 0.5f * num6;
            FQuat.Z = (matrix.m32 + matrix.m23) * num3;
            FQuat.W = (matrix.m31 - matrix.m13) * num3;
            return FQuat;
        }
        double num5 = (double)Math.Sqrt((double)(((1f + matrix.m33) - matrix.m11) - matrix.m22));
        double num2 = 0.5f / num5;
        FQuat.X = (matrix.m31 + matrix.m13) * num2;
        FQuat.Y = (matrix.m32 + matrix.m23) * num2;
        FQuat.Z = 0.5f * num5;
        FQuat.W = (matrix.m12 - matrix.m21) * num2;

        return FQuat;

    }

    public static void CreateFromRotationMatrix(ref FMatrix matrix, out FQuat result)
    {
        double sqrt;
		double half;
		double scale = matrix.m00 + matrix.m11 + matrix.m22;

		if (scale > 0.0f)
		{
			sqrt = (double) Math.Sqrt(scale + 1.0f);
			result.W = sqrt * 0.5f;
			sqrt = 0.5f / sqrt;

			result.X = (matrix.m21 - matrix.m12) * sqrt;
			result.Y = (matrix.m02 - matrix.m20) * sqrt;
			result.Z = (matrix.m10 - matrix.m01) * sqrt;
		}
		else if ((matrix.m00 >= matrix.m11) && (matrix.m00 >= matrix.m22))
		{
			sqrt = (double) Math.Sqrt(1.0f + matrix.m00 - matrix.m11 - matrix.m22);
			half = 0.5f / sqrt;

			result.X = 0.5f * sqrt;
			result.Y = (matrix.m10 + matrix.m01) * half;
			result.Z = (matrix.m20 + matrix.m02) * half;
			result.W = (matrix.m21 - matrix.m12) * half;
		}
		else if (matrix.m11 > matrix.m22)
		{
			sqrt = (double) Math.Sqrt(1.0f + matrix.m11 - matrix.m00 - matrix.m22);
			half = 0.5f/sqrt;

			result.X = (matrix.m01 + matrix.m10)*half;
			result.Y = 0.5f*sqrt;
			result.Z = (matrix.m12 + matrix.m21)*half;
			result.W = (matrix.m02 - matrix.m20)*half;
		}
		else
		{
			sqrt = (double) Math.Sqrt(1.0f + matrix.m22 - matrix.m00 - matrix.m11);
			half = 0.5f / sqrt;

			result.X = (matrix.m02 + matrix.m20) * half;
			result.Y = (matrix.m12 + matrix.m21) * half;
			result.Z = 0.5f * sqrt;
			result.W = (matrix.m10 - matrix.m01) * half;
		}
    }

    public static FQuat CreateFroYawPitchRoll(double yaw, double pitch, double roll)
    {
        FQuat FQuat;
        double num9 = roll * 0.5f;
        double num6 = (double)Math.Sin((double)num9);
        double num5 = (double)Math.Cos((double)num9);
        double num8 = pitch * 0.5f;
        double num4 = (double)Math.Sin((double)num8);
        double num3 = (double)Math.Cos((double)num8);
        double num7 = yaw * 0.5f;
        double num2 = (double)Math.Sin((double)num7);
        double num = (double)Math.Cos((double)num7);
        FQuat.X = ((num * num4) * num5) + ((num2 * num3) * num6);
        FQuat.Y = ((num2 * num3) * num5) - ((num * num4) * num6);
        FQuat.Z = ((num * num3) * num6) - ((num2 * num4) * num5);
        FQuat.W = ((num * num3) * num5) + ((num2 * num4) * num6);
        return FQuat;
    }

    public static void CreateFroYawPitchRoll(double yaw, double pitch, double roll, out FQuat result)
    {
        double num9 = roll * 0.5f;
        double num6 = (double)Math.Sin((double)num9);
        double num5 = (double)Math.Cos((double)num9);
        double num8 = pitch * 0.5f;
        double num4 = (double)Math.Sin((double)num8);
        double num3 = (double)Math.Cos((double)num8);
        double num7 = yaw * 0.5f;
        double num2 = (double)Math.Sin((double)num7);
        double num = (double)Math.Cos((double)num7);
        result.X = ((num * num4) * num5) + ((num2 * num3) * num6);
        result.Y = ((num2 * num3) * num5) - ((num * num4) * num6);
        result.Z = ((num * num3) * num6) - ((num2 * num4) * num5);
        result.W = ((num * num3) * num5) + ((num2 * num4) * num6);
    }

    public static FQuat Divide(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num14 = (((FQuat2.X * FQuat2.X) + (FQuat2.Y * FQuat2.Y)) + (FQuat2.Z * FQuat2.Z)) + (FQuat2.W * FQuat2.W);
        double num5 = 1f / num14;
        double num4 = -FQuat2.X * num5;
        double num3 = -FQuat2.Y * num5;
        double num2 = -FQuat2.Z * num5;
        double num = FQuat2.W * num5;
        double num13 = (y * num2) - (z * num3);
        double num12 = (z * num4) - (x * num2);
        double num11 = (x * num3) - (y * num4);
        double num10 = ((x * num4) + (y * num3)) + (z * num2);
        FQuat.X = ((x * num) + (num4 * w)) + num13;
        FQuat.Y = ((y * num) + (num3 * w)) + num12;
        FQuat.Z = ((z * num) + (num2 * w)) + num11;
        FQuat.W = (w * num) - num10;
        return FQuat;
    }

    public static void Divide(ref FQuat FQuat1, ref FQuat FQuat2, out FQuat result)
    {
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num14 = (((FQuat2.X * FQuat2.X) + (FQuat2.Y * FQuat2.Y)) + (FQuat2.Z * FQuat2.Z)) + (FQuat2.W * FQuat2.W);
        double num5 = 1f / num14;
        double num4 = -FQuat2.X * num5;
        double num3 = -FQuat2.Y * num5;
        double num2 = -FQuat2.Z * num5;
        double num = FQuat2.W * num5;
        double num13 = (y * num2) - (z * num3);
        double num12 = (z * num4) - (x * num2);
        double num11 = (x * num3) - (y * num4);
        double num10 = ((x * num4) + (y * num3)) + (z * num2);
        result.X = ((x * num) + (num4 * w)) + num13;
        result.Y = ((y * num) + (num3 * w)) + num12;
        result.Z = ((z * num) + (num2 * w)) + num11;
        result.W = (w * num) - num10;
    }

    public static double Dot(FQuat FQuat1, FQuat FQuat2)
    {
        return ((((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W));
    }

    public static void Dot(ref FQuat FQuat1, ref FQuat FQuat2, out double result)
    {
        result = (((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W);
    }

    public bool Equals(FQuat other)
    {
        return (X == other.X) && (Y == other.Y) && (Z == other.Z) && (W == other.W);
    }

    public int GetHashCode()
    {
        //return ((X.GetHashCode() + Y.GetHashCode()) + Z.GetHashCode()) + mW.GetHashCode();
		ThrowUnimplemented();
    }

    public static FQuat Inverse(FQuat FQuat)
    {
        FQuat FQuat2;
        double num2 = (((FQuat.X * FQuat.X) + (FQuat.Y * FQuat.Y)) + (FQuat.Z * FQuat.Z)) + (FQuat.W * FQuat.W);
        double num = 1f / num2;
        FQuat2.X = -FQuat.X * num;
        FQuat2.Y = -FQuat.Y * num;
        FQuat2.Z = -FQuat.Z * num;
        FQuat2.W = FQuat.W * num;
        return FQuat2;
    }

    public static void Inverse(ref FQuat FQuat, out FQuat result)
    {
        double num2 = (((FQuat.X * FQuat.X) + (FQuat.Y * FQuat.Y)) + (FQuat.Z * FQuat.Z)) + (FQuat.W * FQuat.W);
        double num = 1f / num2;
        result.X = -FQuat.X * num;
        result.Y = -FQuat.Y * num;
        result.Z = -FQuat.Z * num;
        result.W = FQuat.W * num;
    }

    public double Length()
    {
        double num = (((X * X) + (Y * Y)) + (Z * Z)) + (W * W);
        return (double)Math.Sqrt((double)num);
    }

    public double LengthSquared()
    {
        return ((((X * X) + (Y * Y)) + (Z * Z)) + (W * W));
    }

    public static FQuat Lerp(FQuat FQuat1, FQuat FQuat2, double amount)
    {
        double num = amount;
        double num2 = 1f - num;
        FQuat FQuat = FQuat();
        double num5 = (((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W);
        if (num5 >= 0f)
        {
            FQuat.X = (num2 * FQuat1.X) + (num * FQuat2.X);
            FQuat.Y = (num2 * FQuat1.Y) + (num * FQuat2.Y);
            FQuat.Z = (num2 * FQuat1.Z) + (num * FQuat2.Z);
            FQuat.W = (num2 * FQuat1.W) + (num * FQuat2.W);
        }
        else
        {
            FQuat.X = (num2 * FQuat1.X) - (num * FQuat2.X);
            FQuat.Y = (num2 * FQuat1.Y) - (num * FQuat2.Y);
            FQuat.Z = (num2 * FQuat1.Z) - (num * FQuat2.Z);
            FQuat.W = (num2 * FQuat1.W) - (num * FQuat2.W);
        }
        double num4 = (((FQuat.X * FQuat.X) + (FQuat.Y * FQuat.Y)) + (FQuat.Z * FQuat.Z)) + (FQuat.W * FQuat.W);
        double num3 = 1f / ((double)Math.Sqrt((double)num4));
        FQuat.X *= num3;
        FQuat.Y *= num3;
        FQuat.Z *= num3;
        FQuat.W *= num3;
        return FQuat;
    }

    public static void Lerp(ref FQuat FQuat1, ref FQuat FQuat2, double amount, out FQuat result)
    {
        double num = amount;
        double num2 = 1f - num;
        double num5 = (((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W);
        if (num5 >= 0f)
        {
            result.X = (num2 * FQuat1.X) + (num * FQuat2.X);
            result.Y = (num2 * FQuat1.Y) + (num * FQuat2.Y);
            result.Z = (num2 * FQuat1.Z) + (num * FQuat2.Z);
            result.W = (num2 * FQuat1.W) + (num * FQuat2.W);
        }
        else
        {
            result.X = (num2 * FQuat1.X) - (num * FQuat2.X);
            result.Y = (num2 * FQuat1.Y) - (num * FQuat2.Y);
            result.Z = (num2 * FQuat1.Z) - (num * FQuat2.Z);
            result.W = (num2 * FQuat1.W) - (num * FQuat2.W);
        }
        double num4 = (((result.X * result.X) + (result.Y * result.Y)) + (result.Z * result.Z)) + (result.W * result.W);
        double num3 = 1f / ((double)Math.Sqrt((double)num4));
        result.X *= num3;
        result.Y *= num3;
        result.Z *= num3;
        result.W *= num3;
    }

    public static FQuat Slerp(FQuat FQuat1, FQuat FQuat2, double amount)
    {
        double num2;
        double num3;
        FQuat FQuat;
        double num = amount;
        double num4 = (((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W);
        bool flag = false;
        if (num4 < 0f)
        {
            flag = true;
            num4 = -num4;
        }
        if (num4 > 0.999999f)
        {
            num3 = 1f - num;
            num2 = flag ? -num : num;
        }
        else
        {
            double num5 = (double)Math.Acos((double)num4);
            double num6 = (double)(1.0 / Math.Sin((double)num5));
            num3 = ((double)Math.Sin((double)((1f - num) * num5))) * num6;
            num2 = flag ? (((double)(-Math.Sin((double)(num * num5))) * num6)) : (((double)Math.Sin((double)(num * num5))) * num6);
        }
        FQuat.X = (num3 * FQuat1.X) + (num2 * FQuat2.X);
        FQuat.Y = (num3 * FQuat1.Y) + (num2 * FQuat2.Y);
        FQuat.Z = (num3 * FQuat1.Z) + (num2 * FQuat2.Z);
        FQuat.W = (num3 * FQuat1.W) + (num2 * FQuat2.W);
        return FQuat;
    }
    
    public static void Slerp(ref FQuat FQuat1, ref FQuat FQuat2, double amount, out FQuat result)
    {
        double num2;
        double num3;
        double num = amount;
        double num4 = (((FQuat1.X * FQuat2.X) + (FQuat1.Y * FQuat2.Y)) + (FQuat1.Z * FQuat2.Z)) + (FQuat1.W * FQuat2.W);
        bool flag = false;
        if (num4 < 0f)
        {
            flag = true;
            num4 = -num4;
        }
        if (num4 > 0.999999f)
        {
            num3 = 1f - num;
            num2 = flag ? -num : num;
        }
        else
        {
            double num5 = (double)Math.Acos((double)num4);
            double num6 = (double)(1.0 / Math.Sin((double)num5));
            num3 = ((double)Math.Sin((double)((1f - num) * num5))) * num6;
            num2 = flag ? (((double)(-Math.Sin((double)(num * num5))) * num6)) : (((double)Math.Sin((double)(num * num5))) * num6);
        }
        result.X = (num3 * FQuat1.X) + (num2 * FQuat2.X);
        result.Y = (num3 * FQuat1.Y) + (num2 * FQuat2.Y);
        result.Z = (num3 * FQuat1.Z) + (num2 * FQuat2.Z);
        result.W = (num3 * FQuat1.W) + (num2 * FQuat2.W);
    }


    public static FQuat Subtract(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        FQuat.X = FQuat1.X - FQuat2.X;
        FQuat.Y = FQuat1.Y - FQuat2.Y;
        FQuat.Z = FQuat1.Z - FQuat2.Z;
        FQuat.W = FQuat1.W - FQuat2.W;
        return FQuat;
    }
    
    public static void Subtract(ref FQuat FQuat1, ref FQuat FQuat2, out FQuat result)
    {
        result.X = FQuat1.X - FQuat2.X;
        result.Y = FQuat1.Y - FQuat2.Y;
        result.Z = FQuat1.Z - FQuat2.Z;
        result.W = FQuat1.W - FQuat2.W;
    }
    
    public static FQuat Multiply(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num4 = FQuat2.X;
        double num3 = FQuat2.Y;
        double num2 = FQuat2.Z;
        double num = FQuat2.W;
        double num12 = (y * num2) - (z * num3);
        double num11 = (z * num4) - (x * num2);
        double num10 = (x * num3) - (y * num4);
        double num9 = ((x * num4) + (y * num3)) + (z * num2);
        FQuat.X = ((x * num) + (num4 * w)) + num12;
        FQuat.Y = ((y * num) + (num3 * w)) + num11;
        FQuat.Z = ((z * num) + (num2 * w)) + num10;
        FQuat.W = (w * num) - num9;
        return FQuat;
    }
    
    public static FQuat Multiply(FQuat FQuat1, double scaleFactor)
    {
        FQuat FQuat;
        FQuat.X = FQuat1.X * scaleFactor;
        FQuat.Y = FQuat1.Y * scaleFactor;
        FQuat.Z = FQuat1.Z * scaleFactor;
        FQuat.W = FQuat1.W * scaleFactor;
        return FQuat;
    }
    
    public static void Multiply(ref FQuat FQuat1, double scaleFactor, out FQuat result)
    {
        result.X = FQuat1.X * scaleFactor;
        result.Y = FQuat1.Y * scaleFactor;
        result.Z = FQuat1.Z * scaleFactor;
        result.W = FQuat1.W * scaleFactor;
    }
    
    public static void Multiply(ref FQuat FQuat1, ref FQuat FQuat2, out FQuat result)
    {
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num4 = FQuat2.X;
        double num3 = FQuat2.Y;
        double num2 = FQuat2.Z;
        double num = FQuat2.W;
        double num12 = (y * num2) - (z * num3);
        double num11 = (z * num4) - (x * num2);
        double num10 = (x * num3) - (y * num4);
        double num9 = ((x * num4) + (y * num3)) + (z * num2);
        result.X = ((x * num) + (num4 * w)) + num12;
        result.Y = ((y * num) + (num3 * w)) + num11;
        result.Z = ((z * num) + (num2 * w)) + num10;
        result.W = (w * num) - num9;
    }
    
    public static FQuat Negate(FQuat FQuat)
    {
        FQuat FQuat2;
        FQuat2.X = -FQuat.X;
        FQuat2.Y = -FQuat.Y;
        FQuat2.Z = -FQuat.Z;
        FQuat2.W = -FQuat.W;
        return FQuat2;
    }
    
    public static void Negate(ref FQuat FQuat, out FQuat result)
    {
        result.X = -FQuat.X;
        result.Y = -FQuat.Y;
        result.Z = -FQuat.Z;
        result.W = -FQuat.W;
    }
    
    public void Normalize() mut
    {
        double num2 = (((X * X) + (Y * Y)) + (Z * Z)) + (W * W);
        double num = 1f / ((double)Math.Sqrt((double)num2));
        X *= num;
        Y *= num;
        Z *= num;
        W *= num;
    }
    
    public static FQuat Normalize(FQuat FQuat)
    {
        FQuat FQuat2;
        double num2 = (((FQuat.X * FQuat.X) + (FQuat.Y * FQuat.Y)) + (FQuat.Z * FQuat.Z)) + (FQuat.W * FQuat.W);
        double num = 1f / ((double)Math.Sqrt((double)num2));
        FQuat2.X = FQuat.X * num;
        FQuat2.Y = FQuat.Y * num;
        FQuat2.Z = FQuat.Z * num;
        FQuat2.W = FQuat.W * num;
        return FQuat2;
    }
    
    public static void Normalize(ref FQuat FQuat, out FQuat result)
    {
        double num2 = (((FQuat.X * FQuat.X) + (FQuat.Y * FQuat.Y)) + (FQuat.Z * FQuat.Z)) + (FQuat.W * FQuat.W);
        double num = 1f / ((double)Math.Sqrt((double)num2));
        result.X = FQuat.X * num;
        result.Y = FQuat.Y * num;
        result.Z = FQuat.Z * num;
        result.W = FQuat.W * num;
    }
    
    public static FQuat operator +(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        FQuat.X = FQuat1.X + FQuat2.X;
        FQuat.Y = FQuat1.Y + FQuat2.Y;
        FQuat.Z = FQuat1.Z + FQuat2.Z;
        FQuat.W = FQuat1.W + FQuat2.W;
        return FQuat;
    }
    
    public static FQuat operator /(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num14 = (((FQuat2.X * FQuat2.X) + (FQuat2.Y * FQuat2.Y)) + (FQuat2.Z * FQuat2.Z)) + (FQuat2.W * FQuat2.W);
        double num5 = 1f / num14;
        double num4 = -FQuat2.X * num5;
        double num3 = -FQuat2.Y * num5;
        double num2 = -FQuat2.Z * num5;
        double num = FQuat2.W * num5;
        double num13 = (y * num2) - (z * num3);
        double num12 = (z * num4) - (x * num2);
        double num11 = (x * num3) - (y * num4);
        double num10 = ((x * num4) + (y * num3)) + (z * num2);
        FQuat.X = ((x * num) + (num4 * w)) + num13;
        FQuat.Y = ((y * num) + (num3 * w)) + num12;
        FQuat.Z = ((z * num) + (num2 * w)) + num11;
        FQuat.W = (w * num) - num10;
        return FQuat;
    }
    
    public static bool operator ==(FQuat FQuat1, FQuat FQuat2)
    {
        return ((((FQuat1.X == FQuat2.X) && (FQuat1.Y == FQuat2.Y)) && (FQuat1.Z == FQuat2.Z)) && (FQuat1.W == FQuat2.W));
    }
    
    public static bool operator !=(FQuat FQuat1, FQuat FQuat2)
    {
        if (((FQuat1.X == FQuat2.X) && (FQuat1.Y == FQuat2.Y)) && (FQuat1.Z == FQuat2.Z))            
            return (FQuat1.W != FQuat2.W);            
        return true;
    }
    
    public static FQuat operator *(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        double x = FQuat1.X;
        double y = FQuat1.Y;
        double z = FQuat1.Z;
        double w = FQuat1.W;
        double num4 = FQuat2.X;
        double num3 = FQuat2.Y;
        double num2 = FQuat2.Z;
        double num = FQuat2.W;
        double num12 = (y * num2) - (z * num3);
        double num11 = (z * num4) - (x * num2);
        double num10 = (x * num3) - (y * num4);
        double num9 = ((x * num4) + (y * num3)) + (z * num2);
        FQuat.X = ((x * num) + (num4 * w)) + num12;
        FQuat.Y = ((y * num) + (num3 * w)) + num11;
        FQuat.Z = ((z * num) + (num2 * w)) + num10;
        FQuat.W = (w * num) - num9;
        return FQuat;
    }
    
    public static FQuat operator *(FQuat FQuat1, double scaleFactor)
    {
        FQuat FQuat;
        FQuat.X = FQuat1.X * scaleFactor;
        FQuat.Y = FQuat1.Y * scaleFactor;
        FQuat.Z = FQuat1.Z * scaleFactor;
        FQuat.W = FQuat1.W * scaleFactor;
        return FQuat;
    }
    
    public static FQuat operator -(FQuat FQuat1, FQuat FQuat2)
    {
        FQuat FQuat;
        FQuat.X = FQuat1.X - FQuat2.X;
        FQuat.Y = FQuat1.Y - FQuat2.Y;
        FQuat.Z = FQuat1.Z - FQuat2.Z;
        FQuat.W = FQuat1.W - FQuat2.W;
        return FQuat;
    }
    
    public static FQuat operator -(FQuat FQuat)
    {
        FQuat FQuat2;
        FQuat2.X = -FQuat.X;
        FQuat2.Y = -FQuat.Y;
        FQuat2.Z = -FQuat.Z;
        FQuat2.W = -FQuat.W;
        return FQuat2;
    }
    
    public override void ToString(String outStr)
    {
        ThrowUnimplemented();
    }

    public FMatrix ToMatrix()
    {
        FMatrix matrix = FMatrix.Identity;
        ToMatrix(out matrix);
        return matrix;
    }

    /*internal void ToMatrix(out Matrix4 matrix)
    {
        FQuat.ToMatrix(this, out matrix);
    }*/

    public void ToMatrix(out FMatrix matrix)
    {            
        double fTx = X + X;
        double fTy = Y + Y;
        double fTz = Z + Z;
        double fTwx = fTx * W;
        double fTwy = fTy * W;
        double fTwz = fTz * W;
        double fTxx = fTx * X;
        double fTxy = fTy * X;
        double fTxz = fTz * X;
        double fTyy = fTy * Y;
        double fTyz = fTz * Y;
        double fTzz = fTz * Z;

        matrix.m00 = 1.0f - (fTyy + fTzz);
        matrix.m01 = fTxy - fTwz;
        matrix.m02 = fTxz + fTwy;
        matrix.m03 = 0;

        matrix.m10 = fTxy + fTwz;
        matrix.m11 = 1.0f - (fTxx + fTzz);
        matrix.m12 = fTyz - fTwx;
        matrix.m13 = 0;

        matrix.m20 = fTxz - fTwy;
        matrix.m21 = fTyz + fTwx;
        matrix.m22 = 1.0f - (fTxx + fTyy);
        matrix.m23 = 0;

        matrix.m30 = 0;
        matrix.m31 = 0;
        matrix.m32 = 0;
        matrix.m33 = 1.0f;
    }

    public FVector XYZ
    {
        get
        {
            return FVector(X, Y, Z);
        }

        set mut
        {
            X = value.X;
            Y = value.Y;
            Z = value.Z;
        }
    }
}