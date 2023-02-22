using System;
using System.Diagnostics;

namespace UnrealEngine;

public struct FMatrix
{
    public double m00;
    public double m01;
    public double m02;
    public double m03;
    public double m10;
    public double m11;
    public double m12;
    public double m13;
    public double m20;
    public double m21;
    public double m22;
    public double m23;
    public double m30;
    public double m31;
    public double m32;
    public double m33;

    public static readonly FMatrix Identity = FMatrix(1f, 0f, 0f, 0f,
        0f, 1f, 0f, 0f,
        0f, 0f, 1f, 0f,
        0f, 0f, 0f, 1f);

    public this(
	    double m00, double m01, double m02, double m03,
	    double m10, double m11, double m12, double m13,
	    double m20, double m21, double m22, double m23,
	    double m30, double m31, double m32, double m33)
    {
	    this.m00 = m00;
	    this.m01 = m01;
	    this.m02 = m02;
	    this.m03 = m03;
	    this.m10 = m10;
	    this.m11 = m11;
	    this.m12 = m12;
	    this.m13 = m13;
	    this.m20 = m20;
	    this.m21 = m21;
	    this.m22 = m22;
	    this.m23 = m23;
	    this.m30 = m30;
	    this.m31 = m31;
	    this.m32 = m32;
	    this.m33 = m33;
    }

	public static FMatrix CreateFromColumnMajor(
		double m00, double m10, double m20, double m30,
		double m01, double m11, double m21, double m31,
		double m02, double m12, double m22, double m32,
		double m03, double m13, double m23, double m33)
	{
		return .(
			m00, m01, m02, m03,
			m10, m11, m12, m13,
			m20, m21, m22, m23,
			m30, m31, m32, m33);
	}

    public static FMatrix CreatePerspective(double width, double height, double nearPlaneDistance, double farPlaneDistance)
    {
        FMatrix matrix;
        if (nearPlaneDistance <= 0f)
        {
            Runtime.FatalError("nearPlaneDistance <= 0");
        }
        if (farPlaneDistance <= 0f)
        {
            Runtime.FatalError("farPlaneDistance <= 0");
        }
        if (nearPlaneDistance >= farPlaneDistance)
        {
            Runtime.FatalError("nearPlaneDistance >= farPlaneDistance");
        }
        /*matrix.M11 = (2f * nearPlaneDistance) / width;
        matrix.M12 = matrix.M13 = matrix.M14 = 0f;
        matrix.M22 = (2f * nearPlaneDistance) / height;
        matrix.M21 = matrix.M23 = matrix.M24 = 0f;
        matrix.M33 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
        matrix.M31 = matrix.M32 = 0f;
        matrix.M34 = -1f;
        matrix.M41 = matrix.M42 = matrix.M44 = 0f;
        matrix.M43 = (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance);*/

        /*matrix.m00 = (2f * nearPlaneDistance) / width;
        matrix.m01 = 0f;                        
        matrix.m02 = 0f;
        matrix.m03 = 0f;

        matrix.m10 = 0f;
        matrix.m11 = (2f * nearPlaneDistance) / height;
        matrix.m12 = 0f;
        matrix.m13 = 0f;

        matrix.m20 = 0f;
        matrix.m21 = 0f;            
        matrix.m22 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
        matrix.m23 = (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance);

        matrix.m30 = 0f;
        matrix.m31 = 0f;
        matrix.m32 = -1f;
        matrix.m33 = 0f;            */

        matrix.m00 = (2f * nearPlaneDistance) / width;
        matrix.m10 = matrix.m20 = matrix.m30 = 0f;
        matrix.m11 = (2f * nearPlaneDistance) / height;
        matrix.m01 = matrix.m21 = matrix.m31 = 0f;
        matrix.m22 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
        matrix.m02 = matrix.m12 = 0f;
        matrix.m32 = -1f;
        matrix.m03 = matrix.m13 = matrix.m33 = 0f;
        matrix.m23 = (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance);

        return matrix;
    }

    public static FMatrix CreatePerspectiveFieldOfView(double fieldOfView, double aspectRatio, double nearPlaneDistance, double farPlaneDistance)
    {
        FMatrix result;
        CreatePerspectiveFieldOfView(fieldOfView, aspectRatio, nearPlaneDistance, farPlaneDistance, out result);
        return result;
    }


    public static void CreatePerspectiveFieldOfView(double fieldOfView, double aspectRatio, double nearPlaneDistance, double farPlaneDistance, out FMatrix result)
    {
        if ((fieldOfView <= 0f) || (fieldOfView >= 3.141593f))
        {
            Runtime.FatalError("fieldOfView <= 0 or >= PI");
        }
        if (nearPlaneDistance <= 0f)
        {
            Runtime.FatalError("nearPlaneDistance <= 0");
        }
        if (farPlaneDistance <= 0f)
        {
            Runtime.FatalError("farPlaneDistance <= 0");
        }
        if (nearPlaneDistance >= farPlaneDistance)
        {
            Runtime.FatalError("nearPlaneDistance >= farPlaneDistance");
        }
        double num = 1f / ((double)Math.Tan((double)(fieldOfView * 0.5f)));
        double num9 = num / aspectRatio;
        result.m00 = num9;
        result.m10 = result.m20 = result.m30 = 0;
        result.m11 = num;
        result.m01 = result.m21 = result.m31 = 0;
        result.m02 = result.m12 = 0f;
        result.m22 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
        result.m32 = -1;
        result.m03 = result.m13 = result.m33 = 0;
        result.m23 = (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance);
    }


    public static FMatrix CreatePerspectiveOffCenter(double left, double right, double bottom, double top, double nearPlaneDistance, double farPlaneDistance)
    {
        FMatrix result;
        CreatePerspectiveOffCenter(left, right, bottom, top, nearPlaneDistance, farPlaneDistance, out result);
        return result;
    }


    public static void CreatePerspectiveOffCenter(double left, double right, double bottom, double top, double nearPlaneDistance, double farPlaneDistance, out FMatrix result)
    {
        if (nearPlaneDistance <= 0f)
        {
            Runtime.FatalError("nearPlaneDistance <= 0");
        }
        if (farPlaneDistance <= 0f)
        {
            Runtime.FatalError("farPlaneDistance <= 0");
        }
        if (nearPlaneDistance >= farPlaneDistance)
        {
            Runtime.FatalError("nearPlaneDistance >= farPlaneDistance");
        }
        result.m00 = (2f * nearPlaneDistance) / (right - left);
        result.m10 = result.m20 = result.m30 = 0;
        result.m11 = (2f * nearPlaneDistance) / (top - bottom);
        result.m01 = result.m21 = result.m31 = 0;
        result.m02 = (left + right) / (right - left);
        result.m12 = (top + bottom) / (top - bottom);
        result.m22 = farPlaneDistance / (nearPlaneDistance - farPlaneDistance);
        result.m32 = -1;
        result.m23 = (nearPlaneDistance * farPlaneDistance) / (nearPlaneDistance - farPlaneDistance);
        result.m03 = result.m13 = result.m33 = 0;
    }

    public static FMatrix Multiply(FMatrix m1, FMatrix m2)
    {
	    FMatrix r;

		r.m00 = (((m1.m00 * m2.m00) + (m1.m10 * m2.m01)) + (m1.m20 * m2.m02)) + (m1.m30 * m2.m03);
		r.m10 = (((m1.m00 * m2.m10) + (m1.m10 * m2.m11)) + (m1.m20 * m2.m12)) + (m1.m30 * m2.m13);
		r.m20 = (((m1.m00 * m2.m20) + (m1.m10 * m2.m21)) + (m1.m20 * m2.m22)) + (m1.m30 * m2.m23);
		r.m30 = (((m1.m00 * m2.m30) + (m1.m10 * m2.m31)) + (m1.m20 * m2.m32)) + (m1.m30 * m2.m33);
		r.m01 = (((m1.m01 * m2.m00) + (m1.m11 * m2.m01)) + (m1.m21 * m2.m02)) + (m1.m31 * m2.m03);
		r.m11 = (((m1.m01 * m2.m10) + (m1.m11 * m2.m11)) + (m1.m21 * m2.m12)) + (m1.m31 * m2.m13);
		r.m21 = (((m1.m01 * m2.m20) + (m1.m11 * m2.m21)) + (m1.m21 * m2.m22)) + (m1.m31 * m2.m23);
		r.m31 = (((m1.m01 * m2.m30) + (m1.m11 * m2.m31)) + (m1.m21 * m2.m32)) + (m1.m31 * m2.m33);
		r.m02 = (((m1.m02 * m2.m00) + (m1.m12 * m2.m01)) + (m1.m22 * m2.m02)) + (m1.m32 * m2.m03);
		r.m12 = (((m1.m02 * m2.m10) + (m1.m12 * m2.m11)) + (m1.m22 * m2.m12)) + (m1.m32 * m2.m13);
		r.m22 = (((m1.m02 * m2.m20) + (m1.m12 * m2.m21)) + (m1.m22 * m2.m22)) + (m1.m32 * m2.m23);
		r.m32 = (((m1.m02 * m2.m30) + (m1.m12 * m2.m31)) + (m1.m22 * m2.m32)) + (m1.m32 * m2.m33);
		r.m03 = (((m1.m03 * m2.m00) + (m1.m13 * m2.m01)) + (m1.m23 * m2.m02)) + (m1.m33 * m2.m03);
		r.m13 = (((m1.m03 * m2.m10) + (m1.m13 * m2.m11)) + (m1.m23 * m2.m12)) + (m1.m33 * m2.m13);
		r.m23 = (((m1.m03 * m2.m20) + (m1.m13 * m2.m21)) + (m1.m23 * m2.m22)) + (m1.m33 * m2.m23);
		r.m33 = (((m1.m03 * m2.m30) + (m1.m13 * m2.m31)) + (m1.m23 * m2.m32)) + (m1.m33 * m2.m33);

	    return r;
    }

    public static FMatrix Transpose(FMatrix m)
    {
	    return FMatrix(
		    m.m00, m.m10, m.m20, m.m30,
		    m.m01, m.m11, m.m21, m.m31,
		    m.m02, m.m12, m.m22, m.m32,
		    m.m03, m.m13, m.m23, m.m33);
    }

    public static FMatrix CreateTranslation(double x, double y, double z)
    {
	    return FMatrix(
		    1, 0, 0, x,
		    0, 1, 0, y,
		    0, 0, 1, z,
		    0, 0, 0, 1);
    }

    public static FMatrix CreateTransform(FVector position, FVector scale, FQuat orientation)
    {
        // Ordering:
        //    1. Scale
        //    2. Rotate
        //    3. Translate

        FMatrix rot = orientation.ToMatrix();
        return FMatrix(
	        scale.X * rot.m00, scale.Y * rot.m01, scale.Z * rot.m02, position.X,
	        scale.X * rot.m10, scale.Y * rot.m11, scale.Z * rot.m12, position.Y,
	        scale.X * rot.m20, scale.Y * rot.m21, scale.Z * rot.m22, position.Z,	
	        0, 0, 0, 1);
    }

    public static FMatrix CreateRotationX(double radians)
    {
        FMatrix result = FMatrix.Identity;

        var val1 = (double)Math.Cos(radians);
        var val2 = (double)Math.Sin(radians);

        result.m11 = val1;
        result.m21 = val2;
        result.m12 = -val2;
        result.m22 = val1;

        return result;
    }

    public static FMatrix CreateRotationY(double radians)
    {
        FMatrix returnMatrix = FMatrix.Identity;

        var val1 = (double)Math.Cos(radians);
        var val2 = (double)Math.Sin(radians);

        returnMatrix.m00 = val1;
        returnMatrix.m20 = -val2;
        returnMatrix.m02 = val2;
        returnMatrix.m22 = val1;

        return returnMatrix;
    }

    public static FMatrix CreateRotationZ(double radians)
    {
        FMatrix returnMatrix = FMatrix.Identity;

        var val1 = (double)Math.Cos(radians);
        var val2 = (double)Math.Sin(radians);

        returnMatrix.m00 = val1;
        returnMatrix.m10 = val2;
        returnMatrix.m01 = -val2;
        returnMatrix.m11 = val1;

        return returnMatrix;
    }

    public static FMatrix CreateScale(double scale)
    {
        FMatrix result;
        result.m00 = scale;
        result.m10 = 0;
        result.m20 = 0;
        result.m30 = 0;
        result.m01 = 0;
        result.m11 = scale;
        result.m21 = 0;
        result.m31 = 0;
        result.m02 = 0;
        result.m12 = 0;
        result.m22 = scale;
        result.m32 = 0;
        result.m03 = 0;
        result.m13 = 0;
        result.m23 = 0;
        result.m33 = 1;
        return result;
    }

    public static FMatrix CreateScale(double xScale, double yScale, double zScale)
    {
        FMatrix result;
        result.m00 = xScale;
        result.m10 = 0;
        result.m20 = 0;
        result.m30 = 0;
        result.m01 = 0;
        result.m11 = yScale;
        result.m21 = 0;
        result.m31 = 0;
        result.m02 = 0;
        result.m12 = 0;
        result.m22 = zScale;
        result.m32 = 0;
        result.m03 = 0;
        result.m13 = 0;
        result.m23 = 0;
        result.m33 = 1;
        return result;
    }

    public static FMatrix CreateScale(FVector scales)
    {
        FMatrix result;
        result.m00 = scales.X;
        result.m10 = 0;
        result.m20 = 0;
        result.m30 = 0;
        result.m01 = 0;
        result.m11 = scales.Y;
        result.m21 = 0;
        result.m31 = 0;
        result.m02 = 0;
        result.m12 = 0;
        result.m22 = scales.Z;
        result.m32 = 0;
        result.m03 = 0;
        result.m13 = 0;
        result.m23 = 0;
        result.m33 = 1;
        return result;
    }

    public static FMatrix CreateTranslation(FVector position)
    {
        FMatrix result;
        result.m00 = 1;
        result.m10 = 0;
        result.m20 = 0;
        result.m30 = 0;
        result.m01 = 0;
        result.m11 = 1;
        result.m21 = 0;
        result.m31 = 0;
        result.m02 = 0;
        result.m12 = 0;
        result.m22 = 1;
        result.m32 = 0;
        result.m03 = position.X;
        result.m13 = position.Y;
        result.m23 = position.Z;
        result.m33 = 1;
        return result;
    }

    /*public static FMatrix Inverse()
    {
        Real m00 = m[0][0], m01 = m[0][1], m02 = m[0][2], m03 = m[0][3];
        Real m10 = m[1][0], m11 = m[1][1], m12 = m[1][2], m13 = m[1][3];
        Real m20 = m[2][0], m21 = m[2][1], m22 = m[2][2], m23 = m[2][3];
        Real m30 = m[3][0], m31 = m[3][1], m32 = m[3][2], m33 = m[3][3];

        Real v0 = m20 * m31 - m21 * m30;
        Real v1 = m20 * m32 - m22 * m30;
        Real v2 = m20 * m33 - m23 * m30;
        Real v3 = m21 * m32 - m22 * m31;
        Real v4 = m21 * m33 - m23 * m31;
        Real v5 = m22 * m33 - m23 * m32;

        Real t00 = + (v5 * m11 - v4 * m12 + v3 * m13);
        Real t10 = - (v5 * m10 - v2 * m12 + v1 * m13);
        Real t20 = + (v4 * m10 - v2 * m11 + v0 * m13);
        Real t30 = - (v3 * m10 - v1 * m11 + v0 * m12);

        Real invDet = 1 / (t00 * m00 + t10 * m01 + t20 * m02 + t30 * m03);

        Real d00 = t00 * invDet;
        Real d10 = t10 * invDet;
        Real d20 = t20 * invDet;
        Real d30 = t30 * invDet;

        Real d01 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
        Real d11 = + (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
        Real d21 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
        Real d31 = + (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

        v0 = m10 * m31 - m11 * m30;
        v1 = m10 * m32 - m12 * m30;
        v2 = m10 * m33 - m13 * m30;
        v3 = m11 * m32 - m12 * m31;
        v4 = m11 * m33 - m13 * m31;
        v5 = m12 * m33 - m13 * m32;

        Real d02 = + (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
        Real d12 = - (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
        Real d22 = + (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
        Real d32 = - (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

        v0 = m21 * m10 - m20 * m11;
        v1 = m22 * m10 - m20 * m12;
        v2 = m23 * m10 - m20 * m13;
        v3 = m22 * m11 - m21 * m12;
        v4 = m23 * m11 - m21 * m13;
        v5 = m23 * m12 - m22 * m13;

        Real d03 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
        Real d13 = + (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
        Real d23 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
        Real d33 = + (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

        return FMatrix(
            d00, d01, d02, d03,
            d10, d11, d12, d13,
            d20, d21, d22, d23,
            d30, d31, d32, d33);
    }*/

    bool IsAffine()
    {
        return m30 == 0 && m31 == 0 && m32 == 0 && m33 == 1;
    }

    public static FMatrix InverseAffine(FMatrix mtx)
    {
        Debug.Assert(mtx.IsAffine());

        double m10 = mtx.m10, m11 = mtx.m11, m12 = mtx.m12;
        double m20 = mtx.m20, m21 = mtx.m21, m22 = mtx.m22;

        double t00 = m22 * m11 - m21 * m12;
        double t10 = m20 * m12 - m22 * m10;
        double t20 = m21 * m10 - m20 * m11;

        double m00 = mtx.m00, m01 = mtx.m01, m02 = mtx.m02;

        double invDet = 1 / (m00 * t00 + m01 * t10 + m02 * t20);

        t00 *= invDet; t10 *= invDet; t20 *= invDet;

        m00 *= invDet; m01 *= invDet; m02 *= invDet;

        double r00 = t00;
        double r01 = m02 * m21 - m01 * m22;
        double r02 = m01 * m12 - m02 * m11;

        double r10 = t10;
        double r11 = m00 * m22 - m02 * m20;
        double r12 = m02 * m10 - m00 * m12;

        double r20 = t20;
        double r21 = m01 * m20 - m00 * m21;
        double r22 = m00 * m11 - m01 * m10;

        double m03 = mtx.m03, m13 = mtx.m13, m23 = mtx.m23;

        double r03 = -(r00 * m03 + r01 * m13 + r02 * m23);
        double r13 = -(r10 * m03 + r11 * m13 + r12 * m23);
        double r23 = -(r20 * m03 + r21 * m13 + r22 * m23);

        return FMatrix(
            r00, r01, r02, r03,
            r10, r11, r12, r13,
            r20, r21, r22, r23,
              0, 0, 0, 1);
    }

	public static void Invert(FMatrix matrix, out FMatrix result)
	{
		double num1 = matrix.m00;
		double num2 = matrix.m10;
		double num3 = matrix.m20;
		double num4 = matrix.m30;
		double num5 = matrix.m01;
		double num6 = matrix.m11;
		double num7 = matrix.m21;
		double num8 = matrix.m31;
		double num9 =  matrix.m02;
		double num10 = matrix.m12;
		double num11 = matrix.m22;
		double num12 = matrix.m32;
		double num13 = matrix.m03;
		double num14 = matrix.m13;
		double num15 = matrix.m23;
		double num16 = matrix.m33;
		double num17 = (double) ((double) num11 * (double) num16 - (double) num12 * (double) num15);
		double num18 = (double) ((double) num10 * (double) num16 - (double) num12 * (double) num14);
		double num19 = (double) ((double) num10 * (double) num15 - (double) num11 * (double) num14);
		double num20 = (double) ((double) num9 * (double) num16 - (double) num12 * (double) num13);
		double num21 = (double) ((double) num9 * (double) num15 - (double) num11 * (double) num13);
		double num22 = (double) ((double) num9 * (double) num14 - (double) num10 * (double) num13);
		double num23 = (double) ((double) num6 * (double) num17 - (double) num7 * (double) num18 + (double) num8 * (double) num19);
		double num24 = (double) -((double) num5 * (double) num17 - (double) num7 * (double) num20 + (double) num8 * (double) num21);
		double num25 = (double) ((double) num5 * (double) num18 - (double) num6 * (double) num20 + (double) num8 * (double) num22);
		double num26 = (double) -((double) num5 * (double) num19 - (double) num6 * (double) num21 + (double) num7 * (double) num22);
		double num27 = (double) (1.0 / ((double) num1 * (double) num23 + (double) num2 * (double) num24 + (double) num3 * (double) num25 + (double) num4 * (double) num26));
		
		result.m00 = num23 * num27;
		result.m01 = num24 * num27;
		result.m02 = num25 * num27;
		result.m03 = num26 * num27;
		result.m10 = (double)(-((double) num2 * (double) num17 - (double) num3 * (double) num18 + (double) num4 * (double) num19) * num27);
		result.m11 = (double) ((double) num1 * (double) num17 - (double) num3 * (double) num20 + (double) num4 * (double) num21) * num27;
		result.m12 = (double)(-((double) num1 * (double) num18 - (double) num2 * (double) num20 + (double) num4 * (double) num22) * num27);
		result.m13 = (double) ((double) num1 * (double) num19 - (double) num2 * (double) num21 + (double) num3 * (double) num22) * num27;
		double num28 = (double) ((double) num7 * (double) num16 - (double) num8 * (double) num15);
		double num29 = (double) ((double) num6 * (double) num16 - (double) num8 * (double) num14);
		double num30 = (double) ((double) num6 * (double) num15 - (double) num7 * (double) num14);
		double num31 = (double) ((double) num5 * (double) num16 - (double) num8 * (double) num13);
		double num32 = (double) ((double) num5 * (double) num15 - (double) num7 * (double) num13);
		double num33 = (double) ((double) num5 * (double) num14 - (double) num6 * (double) num13);
		result.m20 = (double) ((double) num2 * (double) num28 - (double) num3 * (double) num29 + (double) num4 * (double) num30) * num27;
		result.m21 = (double)(-((double) num1 * (double) num28 - (double) num3 * (double) num31 + (double) num4 * (double) num32) * num27);
		result.m22 = (double) ((double) num1 * (double) num29 - (double) num2 * (double) num31 + (double) num4 * (double) num33) * num27;
		result.m23 = (double)(-((double) num1 * (double) num30 - (double) num2 * (double) num32 + (double) num3 * (double) num33) * num27);
		double num34 = (double) ((double) num7 * (double) num12 - (double) num8 * (double) num11);
		double num35 = (double) ((double) num6 * (double) num12 - (double) num8 * (double) num10);
		double num36 = (double) ((double) num6 * (double) num11 - (double) num7 * (double) num10);
		double num37 = (double) ((double) num5 * (double) num12 - (double) num8 * (double) num9);
		double num38 = (double) ((double) num5 * (double) num11 - (double) num7 * (double) num9);
		double num39 = (double) ((double) num5 * (double) num10 - (double) num6 * (double) num9);
		result.m30 = (double)(-((double) num2 * (double) num34 - (double) num3 * (double) num35 + (double) num4 * (double) num36) * num27);
		result.m31 = (double) ((double) num1 * (double) num34 - (double) num3 * (double) num37 + (double) num4 * (double) num38) * num27;
		result.m32 = (double)(-((double) num1 * (double) num35 - (double) num2 * (double) num37 + (double) num4 * (double) num39) * num27);
		result.m33 = (double) ((double) num1 * (double) num36 - (double) num2 * (double) num38 + (double) num3 * (double) num39) * num27;
		
		/*
		
		
	    ///
	    // Use Laplace expansion theorem to calculate the inverse of a 4x4 matrix
	    // 
	    // 1. Calculate the 2x2 determinants needed the 4x4 determinant based on the 2x2 determinants 
	    // 3. Create the adjugate matrix, which satisfies: A * adj(A) = det(A) * I
	    // 4. Divide adjugate matrix with the determinant to find the inverse
	    
	    double det1, det2, det3, det4, det5, det6, det7, det8, det9, det10, det11, det12;
	    double detMatrix;
	    FindDeterminants(ref matrix, out detMatrix, out det1, out det2, out det3, out det4, out det5, out det6, 
	                     out det7, out det8, out det9, out det10, out det11, out det12);
	    
	    double invDetMatrix = 1f / detMatrix;
	    
	    Matrix ret; // Allow for matrix and result to point to the same structure
	    
	    ret.M11 = (matrix.M22*det12 - matrix.M23*det11 + matrix.M24*det10) * invDetMatrix;
	    ret.M12 = (-matrix.M12*det12 + matrix.M13*det11 - matrix.M14*det10) * invDetMatrix;
	    ret.M13 = (matrix.M42*det6 - matrix.M43*det5 + matrix.M44*det4) * invDetMatrix;
	    ret.M14 = (-matrix.M32*det6 + matrix.M33*det5 - matrix.M34*det4) * invDetMatrix;
	    ret.M21 = (-matrix.M21*det12 + matrix.M23*det9 - matrix.M24*det8) * invDetMatrix;
	    ret.M22 = (matrix.M11*det12 - matrix.M13*det9 + matrix.M14*det8) * invDetMatrix;
	    ret.M23 = (-matrix.M41*det6 + matrix.M43*det3 - matrix.M44*det2) * invDetMatrix;
	    ret.M24 = (matrix.M31*det6 - matrix.M33*det3 + matrix.M34*det2) * invDetMatrix;
	    ret.M31 = (matrix.M21*det11 - matrix.M22*det9 + matrix.M24*det7) * invDetMatrix;
	    ret.M32 = (-matrix.M11*det11 + matrix.M12*det9 - matrix.M14*det7) * invDetMatrix;
	    ret.M33 = (matrix.M41*det5 - matrix.M42*det3 + matrix.M44*det1) * invDetMatrix;
	    ret.M34 = (-matrix.M31*det5 + matrix.M32*det3 - matrix.M34*det1) * invDetMatrix;
	    ret.M41 = (-matrix.M21*det10 + matrix.M22*det8 - matrix.M23*det7) * invDetMatrix;
	    ret.M42 = (matrix.M11*det10 - matrix.M12*det8 + matrix.M13*det7) * invDetMatrix;
	    ret.M43 = (-matrix.M41*det4 + matrix.M42*det2 - matrix.M43*det1) * invDetMatrix;
	    ret.M44 = (matrix.M31*det4 - matrix.M32*det2 + matrix.M33*det1) * invDetMatrix;
	    
	    result = ret;
	    */
	}

	public static FMatrix Invert(FMatrix matrix)
	{
	    Invert(matrix, var outMatrix);
	    return outMatrix;
	}

	/// <summary>
	/// Decomposes this matrix to translation, rotation and scale elements. Returns <c>true</c> if matrix can be decomposed; <c>false</c> otherwise.
	/// </summary>
	/// <param name="scale">Scale vector as an output parameter.
	/// <param name="rotation">Rotation FQuat as an output parameter.
	/// <param name="translation">Translation vector as an output parameter.
	/// <returns><c>true</c> if matrix can be decomposed; <c>false</c> otherwise.</returns>
	public bool Decompose(
		out FVector scale,
		out FQuat rotation,
		out FVector translation
	) {
		translation.X = m03;
		translation.Y = m13;
		translation.Z = m23;

		double xs = (Math.Sign(m00 * m10 * m20 * m30) < 0) ? -1 : 1;
		double ys = (Math.Sign(m01 * m11 * m21 * m31) < 0) ? -1 : 1;
		double zs = (Math.Sign(m02 * m12 * m22 * m32) < 0) ? -1 : 1;

		scale.X = xs * (double) Math.Sqrt(m00 * m00 + m10 * m10 + m20 * m20);
		scale.Y = ys * (double) Math.Sqrt(m01 * m01 + m11 * m11 + m21 * m21);
		scale.Z = zs * (double) Math.Sqrt(m02 * m02 + m12 * m12 + m22 * m22);

		if (Math.WithinEpsilon((.)scale.X, 0.0f) ||
			Math.WithinEpsilon((.)scale.Y, 0.0f) ||
			Math.WithinEpsilon((.)scale.Z, 0.0f)	)
		{
			rotation = FQuat.Identity;
			return false;
		}

		FMatrix m1 = FMatrix.CreateFromColumnMajor(
			m00 / scale.X, m10 / scale.X, m20 / scale.X, 0,
			m01 / scale.Y, m11 / scale.Y, m21 / scale.Y, 0,
			m02 / scale.Z, m12 / scale.Z, m22 / scale.Z, 0,
			0, 0, 0, 1
		);

		rotation = FQuat.CreateFromRotationMatrix(m1);
		return true;
	}

	/// <summary>
	/// Returns a determinant of this matrix.
	/// </summary>
	/// <returns>Determinant of this matrix</returns>
	/// <remarks>See more about determinant here - http://en.wikipedia.org/wiki/Determinant.
	/// </remarks>
	public double Determinant()
	{
		double num18 = (m22 * m33) - (m32 * m23);
		double num17 = (m12 * m33) - (m32 * m13);
		double num16 = (m12 * m23) - (m22 * m13);
		double num15 = (m02 * m33) - (m32 * m03);
		double num14 = (m02 * m23) - (m22 * m03);
		double num13 = (m02 * m13) - (m12 * m03);
		return (
			(
				(
					(m00 * (((m11 * num18) - (m21 * num17)) + (m31 * num16))) -
					(m10 * (((m01 * num18) - (m21 * num15)) + (m31 * num14)))
				) + (m20 * (((m01 * num17) - (m11 * num15)) + (m31 * num13)))
			) - (m30 * (((m01 * num16) - (m11 * num14)) + (m21 * num13)))
		);
	}

	/// <summary>
	/// Creates a new matrix for spherical billboarding that rotates around specified object position.
	/// </summary>
	/// <param name="objectPosition">Position of billboard object. It will rotate around that vector.
	/// <param name="cameraPosition">The camera position.
	/// <param name="cameraUpVector">The camera up vector.
	/// <param name="cameraForwardVector">Optional camera forward vector.
	/// <returns>The matrix for spherical billboarding.</returns>
	/*public static FMatrix CreateBillboard(
		FVector objectPosition,
		FVector cameraPosition,
		FVector cameraUpVector,
		Nullable<FVector> cameraForwardVector
	) {
		FMatrix result;

		// Delegate to the other overload of the function to do the work
		CreateBillboard(
			objectPosition,
			cameraPosition,
			cameraUpVector,
			cameraForwardVector,
			out result
		);

		return result;
	}*/

	/// <summary>
	/// Creates a new matrix for spherical billboarding that rotates around specified object position.
	/// </summary>
	/// <param name="objectPosition">Position of billboard object. It will rotate around that vector.
	/// <param name="cameraPosition">The camera position.
	/// <param name="cameraUpVector">The camera up vector.
	/// <param name="cameraForwardVector">Optional camera forward vector.
	/// <param name="result">The matrix for spherical billboarding as an output parameter.
	/*public static void CreateBillboard(
		FVector objectPosition,
		FVector cameraPosition,
		FVector cameraUpVector,
		FVector? cameraForwardVector,
		out FMatrix result
	) {
		FVector vector;
		FVector vector2;
		FVector FVector;
		vector.X = objectPosition.X - cameraPosition.X;
		vector.Y = objectPosition.Y - cameraPosition.Y;
		vector.Z = objectPosition.Z - cameraPosition.Z;
		double num = vector.LengthSquared;
		if (num < 0.0001f)
		{
			vector = cameraForwardVector.HasValue ?
				-cameraForwardVector.Value :
				FVector.Forward;
		}
		else
		{
			vector *= (double) (1f / ((double) Math.Sqrt((double) num)));
		}

		FVector = FVector.Cross(cameraUpVector, vector);
		FVector.Normalize();
		vector2 = FVector.Cross(vector, FVector);
		result.m00 = FVector.X;
		result.m10 = FVector.Y;
		result.m20 = FVector.Z;
		result.m30 = 0;
		result.m01 = vector2.X;
		result.m11 = vector2.Y;
		result.m21 = vector2.Z;
		result.m31 = 0;
		result.m02 = vector.X;
		result.m12 = vector.Y;
		result.m22 = vector.Z;
		result.m32 = 0;
		result.m03 = objectPosition.X;
		result.m13 = objectPosition.Y;
		result.m23 = objectPosition.Z;
		result.m33 = 1;
	}*/

	/// <summary>
	/// Creates a new matrix for cylindrical billboarding that rotates around specified axis.
	/// </summary>
	/// <param name="objectPosition">Object position the billboard will rotate around.
	/// <param name="cameraPosition">Camera position.
	/// <param name="rotateAxis">Axis of billboard for rotation.
	/// <param name="cameraForwardVector">Optional camera forward vector.
	/// <param name="objectForwardVector">Optional object forward vector.
	/// <returns>The matrix for cylindrical billboarding.</returns>
	/*public static FMatrix CreateConstrainedBillboard(
		FVector objectPosition,
		FVector cameraPosition,
		FVector rotateAxis,
		Nullable<FVector> cameraForwardVector,
		Nullable<FVector> objectForwardVector
	) {
		FMatrix result;
		CreateConstrainedBillboard(
			objectPosition,
			cameraPosition,
			rotateAxis,
			cameraForwardVector,
			objectForwardVector,
			out result
		);
		return result;
	}*/

	/// <summary>
	/// Creates a new matrix for cylindrical billboarding that rotates around specified axis.
	/// </summary>
	/// <param name="objectPosition">Object position the billboard will rotate around.
	/// <param name="cameraPosition">Camera position.
	/// <param name="rotateAxis">Axis of billboard for rotation.
	/// <param name="cameraForwardVector">Optional camera forward vector.
	/// <param name="objectForwardVector">Optional object forward vector.
	/// <param name="result">The matrix for cylindrical billboarding as an output parameter.
	/*public static void CreateConstrainedBillboard(
		FVector objectPosition,
		FVector cameraPosition,
		FVector rotateAxis,
		FVector? cameraForwardVector,
		FVector? objectForwardVector,
		out FMatrix result
	) {
		double num;
		FVector vector;
		FVector vector2;
		FVector FVector;
		vector2.X = objectPosition.X - cameraPosition.X;
		vector2.Y = objectPosition.Y - cameraPosition.Y;
		vector2.Z = objectPosition.Z - cameraPosition.Z;
		double num2 = vector2.LengthSquared;
		if (num2 < 0.0001f)
		{
			vector2 = cameraForwardVector.HasValue ?
				-cameraForwardVector.Value :
				FVector.Forward;
		}
		else
		{
			vector2 *= (double) (1f / ((double) Math.Sqrt((double) num2)));
		}
		FVector vector4 = rotateAxis;
		num = FVector.Dot(rotateAxis, vector2);
		if (Math.Abs(num) > 0.9982547f)
		{
			if (objectForwardVector.HasValue)
			{
				vector = objectForwardVector.Value;
				num = FVector.Dot(rotateAxis, vector);
				if (Math.Abs(num) > 0.9982547f)
				{
					num = (
						(rotateAxis.X * FVector.Forward.X) +
						(rotateAxis.Y * FVector.Forward.Y)
					) + (rotateAxis.Z * FVector.Forward.Z);
					vector = (Math.Abs(num) > 0.9982547f) ?
						FVector.Right :
						FVector.Forward;
				}
			}
			else
			{
				num = (
					(rotateAxis.X * FVector.Forward.X) +
					(rotateAxis.Y * FVector.Forward.Y)
				) + (rotateAxis.Z * FVector.Forward.Z);
				vector = (Math.Abs(num) > 0.9982547f) ?
					FVector.Right :
					FVector.Forward;
			}
			FVector = FVector.Cross(rotateAxis, vector);
			FVector.Normalize();
			vector = FVector.Cross(FVector, rotateAxis);
			vector.Normalize();
		}
		else
		{
			FVector = FVector.Cross(rotateAxis, vector2);
			FVector.Normalize();
			vector = FVector.Cross(FVector, vector4);
			vector.Normalize();
		}

		result.m00 = FVector.X;
		result.m10 = FVector.Y;
		result.m20 = FVector.Z;
		result.m30 = 0;
		result.m01 = vector4.X;
		result.m11 = vector4.Y;
		result.m21 = vector4.Z;
		result.m31 = 0;
		result.m02 = vector.X;
		result.m12 = vector.Y;
		result.m22 = vector.Z;
		result.m32 = 0;
		result.m03 = objectPosition.X;
		result.m13 = objectPosition.Y;
		result.m23 = objectPosition.Z;
		result.m33 = 1;
	}*/

	/// <summary>
	/// Creates a new matrix which contains the rotation moment around specified axis.
	/// </summary>
	/// <param name="axis">The axis of rotation.
	/// <param name="angle">The angle of rotation in radians.
	/// <returns>The rotation matrix.</returns>
	public static FMatrix CreateFromAxisAngle(FVector axis, double angle)
	{
		FMatrix result;
		CreateFromAxisAngle(axis, angle, out result);
		return result;
	}

	/// <summary>
	/// Creates a new matrix which contains the rotation moment around specified axis.
	/// </summary>
	/// <param name="axis">The axis of rotation.
	/// <param name="angle">The angle of rotation in radians.
	/// <param name="result">The rotation matrix as an output parameter.
	public static void CreateFromAxisAngle(
		FVector axis,
		double angle,
		out FMatrix result
	) {
		double x = axis.X;
		double y = axis.Y;
		double z = axis.Z;
		double num2 = (double) Math.Sin((double) angle);
		double num = (double) Math.Cos((double) angle);
		double num11 = x * x;
		double num10 = y * y;
		double num9 = z * z;
		double num8 = x * y;
		double num7 = x * z;
		double num6 = y * z;
		result.m00 = num11 + (num * (1f - num11));
		result.m10 = (num8 - (num * num8)) + (num2 * z);
		result.m20 = (num7 - (num * num7)) - (num2 * y);
		result.m30 = 0;
		result.m01 = (num8 - (num * num8)) - (num2 * z);
		result.m11 = num10 + (num * (1f - num10));
		result.m21 = (num6 - (num * num6)) + (num2 * x);
		result.m31 = 0;
		result.m02 = (num7 - (num * num7)) + (num2 * y);
		result.m12 = (num6 - (num * num6)) - (num2 * x);
		result.m22 = num9 + (num * (1f - num9));
		result.m32 = 0;
		result.m03 = 0;
		result.m13 = 0;
		result.m23 = 0;
		result.m33 = 1;
	}

	/// <summary>
	/// Creates a new rotation matrix from a <see cref="FQuat"/>.
	/// </summary>
	/// <param name="FQuat"><see cref="FQuat"/> of rotation moment.
	/// <returns>The rotation matrix.</returns>
	public static FMatrix CreateFromFQuat(FQuat FQuat)
	{
		FMatrix result;
		CreateFromFQuat(FQuat, out result);
		return result;
	}

	/// <summary>
	/// Creates a new rotation matrix from a <see cref="FQuat"/>.
	/// </summary>
	/// <param name="FQuat"><see cref="FQuat"/> of rotation moment.
	/// <param name="result">The rotation matrix as an output parameter.
	public static void CreateFromFQuat(FQuat FQuat, out FMatrix result)
	{
		double num9 = FQuat.X * FQuat.X;
		double num8 = FQuat.Y * FQuat.Y;
		double num7 = FQuat.Z * FQuat.Z;
		double num6 = FQuat.X * FQuat.Y;
		double num5 = FQuat.Z * FQuat.W;
		double num4 = FQuat.Z * FQuat.X;
		double num3 = FQuat.Y * FQuat.W;
		double num2 = FQuat.Y * FQuat.Z;
		double num = FQuat.X * FQuat.W;
		result.m00 = 1f - (2f * (num8 + num7));
		result.m10 = 2f * (num6 + num5);
		result.m20 = 2f * (num4 - num3);
		result.m30 = 0f;
		result.m01 = 2f * (num6 - num5);
		result.m11 = 1f - (2f * (num7 + num9));
		result.m21 = 2f * (num2 + num);
		result.m31 = 0f;
		result.m02 = 2f * (num4 + num3);
		result.m12 = 2f * (num2 - num);
		result.m22 = 1f - (2f * (num8 + num9));
		result.m32 = 0f;
		result.m03 = 0f;
		result.m13 = 0f;
		result.m23 = 0f;
		result.m33 = 1f;
	}

	/// Creates a new rotation matrix from the specified yaw, pitch and roll values.
	/// @param yaw The yaw rotation value in radians.
	/// @param pitch The pitch rotation value in radians.
	/// @param roll The roll rotation value in radians.
	/// @returns The rotation matrix
	/// @remarks For more information about yaw, pitch and roll visit http://en.wikipedia.org/wiki/Euler_angles.
	/*public static FMatrix CreateFroYawPitchRoll(double yaw, double pitch, double roll)
	{
		FMatrix matrix;
		CreateFroYawPitchRoll(yaw, pitch, roll, out matrix);
		return matrix;
	}*/

	/// Creates a new rotation matrix from the specified yaw, pitch and roll values.
	/// @param yaw The yaw rotation value in radians.
	/// @param pitch The pitch rotation value in radians.
	/// @param roll The roll rotation value in radians.
	/// @param result The rotation matrix as an output parameter.
	/// @remarks>For more information about yaw, pitch and roll visit http://en.wikipedia.org/wiki/Euler_angles.
	/*public static void CreateFroYawPitchRoll(
		double yaw,
		double pitch,
		double roll,
		out FMatrix result
	) {
		FQuat FQuat;
		FQuat.CreateFroYawPitchRoll(yaw, pitch, roll, out FQuat);
		CreateFromFQuat(FQuat, out result);
	}*/

	/// Creates a new viewing matrix.
	/// @param cameraPosition Position of the camera.
	/// @param cameraTarget Lookup vector of the camera.
	/// @param cameraUpVector The direction of the upper edge of the camera.
	/// @returns The viewing matrix.
	/*public static FMatrix CreateLookAt(
		FVector cameraPosition,
		FVector cameraTarget,
		FVector cameraUpVector
	) {
		FMatrix matrix;
		CreateLookAt(cameraPosition, cameraTarget, cameraUpVector, out matrix);
		return matrix;
	}*/

	/// Creates a new viewing matrix.
	/// @param cameraPosition Position of the camera.
	/// @param cameraTarget Lookup vector of the camera.
	/// @param cameraUpVector The direction of the upper edge of the camera.
	/// @param result The viewing matrix as an output parameter.
	/*public static void CreateLookAt(
		FVector cameraPosition,
		FVector cameraTarget,
		FVector cameraUpVector,
		out FMatrix result
	) {
		FVector vectorA = FVector.Normalize(cameraPosition - cameraTarget);
		FVector vectorB = FVector.Normalize(FVector.Cross(cameraUpVector, vectorA));
		FVector vectorC = FVector.Cross(vectorA, vectorB);
		result.m00 = vectorB.X;
		result.m10 = vectorC.X;
		result.m20 = vectorA.X;
		result.m30 = 0f;
		result.m01 = vectorB.Y;
		result.m11 = vectorC.Y;
		result.m21 = vectorA.Y;
		result.m31 = 0f;
		result.m02 = vectorB.Z;
		result.m12 = vectorC.Z;
		result.m22 = vectorA.Z;
		result.m32 = 0f;
		result.m03 = -FVector.Dot(vectorB, cameraPosition);
		result.m13 = -FVector.Dot(vectorC, cameraPosition);
		result.m23 = -FVector.Dot(vectorA, cameraPosition);
		result.m33 = 1f;
	}*/

	/// Creates a new projection matrix for orthographic view.
	/// @param width Width of the viewing volume.
	/// @param height Height of the viewing volume.
	/// @param zNearPlane Depth of the near plane.
	/// @param zFarPlane Depth of the far plane.
	/// @returns The new projection matrix for orthographic view.</returns>
	public static FMatrix CreateOrthographic(
		double width,
		double height,
		double zNearPlane,
		double zFarPlane
	) {
		FMatrix matrix;
		CreateOrthographic(width, height, zNearPlane, zFarPlane, out matrix);
		return matrix;
	}

	/// Creates a new projection matrix for orthographic view.
	/// @param width Width of the viewing volume.
	/// @param height Height of the viewing volume.
	/// @param zNearPlane Depth of the near plane.
	/// @param zFarPlane Depth of the far plane.
	/// @param result The new projection matrix for orthographic view as an output parameter.
	public static void CreateOrthographic(
		double width,
		double height,
		double zNearPlane,
		double zFarPlane,
		out FMatrix result
	) {
		result.m00 = 2f / width;
		result.m10 = result.m20 = result.m30 = 0f;
		result.m11 = 2f / height;
		result.m01 = result.m21 = result.m31 = 0f;
		result.m22 = 1f / (zNearPlane - zFarPlane);
		result.m02 = result.m12 = result.m32 = 0f;
		result.m03 = result.m13 = 0f;
		result.m23 = zNearPlane / (zNearPlane - zFarPlane);
		result.m33 = 1f;
	}

	/// Creates a new projection matrix for customized orthographic view.
	/// @param left Lower x-value at the near plane.
	/// @param right Upper x-value at the near plane.
	/// @param bottom Lower y-coordinate at the near plane.
	/// @param top Upper y-value at the near plane.
	/// @param zNearPlane Depth of the near plane.
	/// @param zFarPlane Depth of the far plane.
	/// @returns The new projection matrix for customized orthographic view.</returns>
	public static FMatrix CreateOrthographicOffCenter(
		double left,
		double right,
		double bottom,
		double top,
		double zNearPlane,
		double zFarPlane
	) {
		FMatrix matrix;
		CreateOrthographicOffCenter(
			left,
			right,
			bottom,
			top,
			zNearPlane,
			zFarPlane,
			out matrix
		);
		return matrix;
	}

	/// Creates a new projection matrix for customized orthographic view.
	/// @param left Lower x-value at the near plane.
	/// @param right Upper x-value at the near plane.
	/// @param bottom Lower y-coordinate at the near plane.
	/// @param top Upper y-value at the near plane.
	/// @param zNearPlane Depth of the near plane.
	/// @param zFarPlane Depth of the far plane.
	/// @param result The new projection matrix for customized orthographic view as an output parameter.
	public static void CreateOrthographicOffCenter(
		double left,
		double right,
		double bottom,
		double top,
		double zNearPlane,
		double zFarPlane,
		out FMatrix result
	)
	{
		result.m00 = (double) (2.0 / ((double) right - (double) left));
		result.m10 = 0.0f;
		result.m20 = 0.0f;
		result.m30 = 0.0f;
		result.m01 = 0.0f;
		result.m11 = (double) (2.0 / ((double) top - (double) bottom));
		result.m21 = 0.0f;
		result.m31 = 0.0f;
		result.m02 = 0.0f;
		result.m12 = 0.0f;
		result.m22 = (double) (1.0 / ((double) zNearPlane - (double) zFarPlane));
		result.m32 = 0.0f;
		result.m03 = (double) (
			((double) left + (double) right) /
			((double) left - (double) right)
		);
		result.m13 = (double) (
			((double) top + (double) bottom) /
			((double) bottom - (double) top)
		);
		result.m23 = (double) (
			(double) zNearPlane /
			((double) zNearPlane - (double) zFarPlane)
		);
		result.m33 = 1.0f;
	}

	/// Creates a new matrix that flattens geometry into a specified <see cref="Plane"/> as if casting a shadow from a specified light source.
	/// @param lightDirection A vector specifying the direction from which the light that will cast the shadow is coming.
	/// @param plane The plane onto which the new matrix should flatten geometry so as to cast a shadow.
	/// @returns>A matrix that can be used to flatten geometry onto the specified plane from the specified direction.
	/*public static FMatrix CreateShadow(FVector lightDirection, Plane plane)
	{
		FMatrix result;
		result = CreateShadow(lightDirection, plane);
		return result;
	}

	/// Creates a new matrix that flattens geometry into a specified <see cref="Plane"/> as if casting a shadow from a specified light source.
	/// @param lightDirection A vector specifying the direction from which the light that will cast the shadow is coming.
	/// @param plane The plane onto which the new matrix should flatten geometry so as to cast a shadow.
	/// @param result A matrix that can be used to flatten geometry onto the specified plane from the specified direction as an output parameter.
	public static void CreateShadow(
		FVector lightDirection,
		Plane plane,
		out FMatrix result)
	{
		double dot = (
			(plane.Normal.X * lightDirection.X) +
			(plane.Normal.Y * lightDirection.Y) +
			(plane.Normal.Z * lightDirection.Z)
		);
		double x = -plane.Normal.X;
		double y = -plane.Normal.Y;
		double z = -plane.Normal.Z;
		double d = -plane.D;

		result.m00 = (x * lightDirection.X) + dot;
		result.m10 = x * lightDirection.Y;
		result.m20 = x * lightDirection.Z;
		result.m30 = 0;
		result.m01 = y * lightDirection.X;
		result.m11 = (y * lightDirection.Y) + dot;
		result.m21 = y * lightDirection.Z;
		result.m31 = 0;
		result.m02 = z * lightDirection.X;
		result.m12 = z * lightDirection.Y;
		result.m22 = (z * lightDirection.Z) + dot;
		result.m32 = 0;
		result.m03 = d * lightDirection.X;
		result.m13 = d * lightDirection.Y;
		result.m23 = d * lightDirection.Z;
		result.m33 = dot;
	}*/

	public override void ToString(System.String strBuffer)
	{
		for (int row < 4)
			for (int col < 4)
			{
#unwarn
				strBuffer.AppendF($"M{row+1}{col+1}:{((double*)&this)[row+col*4]}\n");
			}
	}
}