
class Quaternion
{
    float x, y, z, w;

    Quaternion()
    {
        x = 0;
        y = 0;
        z = 0;
        w = 1;
    }

    Quaternion(float _x, float _y, float _z, float _w)
    {
        x = _x;
        y = _y;
        z = _z;
        w = _w;
    }

    Quaternion(float roll, float pitch, float yaw)
    {
        float angle;

        angle = roll * 0.5;
        const float sr = Maths::Sin(angle);
        const float cr = Maths::Cos(angle);

        angle = pitch * 0.5;
        const float sp = Maths::Sin(angle);
        const float cp = Maths::Cos(angle);

        angle = yaw * 0.5;
        const float sy = Maths::Sin(angle);
        const float cy = Maths::Cos(angle);

        const float cpcy = cp * cy;
        const float spcy = sp * cy;
        const float cpsy = cp * sy;
        const float spsy = sp * sy;

        x = sr * cpcy - cr * spsy;
        y = cr * spcy + sr * cpsy;
        z = cr * cpsy - sr * spcy;
        w = cr * cpcy + sr * spsy;
    }

    void Normalize()
    {
        const float n = x*x + y*y + z*z + w*w;

        if (n != 1)

        this *= 1.0f/Maths::FastSqrt(n);
    }

    Quaternion opMul(Quaternion q) const
    {
        Quaternion r;
        r.x = w * q.x + x * q.w + y * q.z - z * q.y;
        r.y = w * q.y - x * q.z + y * q.w + z * q.x;
        r.z = w * q.z + x * q.y - y * q.x + z * q.w;
        r.w = w * q.w - x * q.x - y * q.y - z * q.z;
        return r;
    }

    Vec3f opMul(Vec3f&in v) const
    {
        Vec3f uv;
        Vec3f uuv;
        Vec3f qvec(x, y, z);
        uv = qvec.Cross(v);
        uuv = qvec.Cross(uv);
        uv *= (2.0f * w);
        uuv *= 2.0f;

        return v + uv + uuv;
    }

    void opMulAssign(float f)
    {
        x *= f;
        y *= f;
        z *= f;
        w *= f;
    }

    Quaternion Inverse()
    {
        return Quaternion(-x, -y, -z, w);
    }

    Quaternion Lerp(const Quaternion&in desired, float t)
	{
		const float scale = 1.0f - t;
        return Quaternion(x*scale + desired.x*t, y*scale + desired.y*t, z*scale + desired.z*t, w*scale + desired.w*t);
        //return Quaternion(x + (desired.x - x) * t, y + (desired.y - y) * t, z + (desired.z - z) * t, w + (desired.w - w) * t);
	}

    void getMatrix(float[]& dest, Vec3f center = Vec3f_ZERO)
    {
        dest[0] = 1.0f - 2.0f*y*y - 2.0f*z*z;
        dest[1] = 2.0f*x*y + 2.0f*z*w;
        dest[2] = 2.0f*x*z - 2.0f*y*w;
        dest[3] = 0.0f;

        dest[4] = 2.0f*x*y - 2.0f*z*w;
        dest[5] = 1.0f - 2.0f*x*x - 2.0f*z*z;
        dest[6] = 2.0f*z*y + 2.0f*x*w;
        dest[7] = 0.0f;

        dest[8] = 2.0f*x*z + 2.0f*y*w;
        dest[9] = 2.0f*z*y - 2.0f*x*w;
        dest[10] = 1.0f - 2.0f*x*x - 2.0f*y*y;
        dest[11] = 0.0f;

        dest[12] = center.x;
        dest[13] = center.y;
        dest[14] = center.z;
        dest[15] = 1.0f;
    }

    void getMatrixTransposed(float[]& dest)
    {
        dest[0] = 1.0f - 2.0f*y*y - 2.0f*z*z;
        dest[4] = 2.0f*x*y + 2.0f*z*w;
        dest[8] = 2.0f*x*z - 2.0f*y*w;
        dest[12] = 0.0f;

        dest[1] = 2.0f*x*y - 2.0f*z*w;
        dest[5] = 1.0f - 2.0f*x*x - 2.0f*z*z;
        dest[9] = 2.0f*z*y + 2.0f*x*w;
        dest[13] = 0.0f;

        dest[2] = 2.0f*x*z + 2.0f*y*w;
        dest[6] = 2.0f*z*y - 2.0f*x*w;
        dest[10] = 1.0f - 2.0f*x*x - 2.0f*y*y;
        dest[14] = 0.0f;

        dest[3] = 0.0f;
        dest[7] = 0.0f;
        dest[11] = 0.0f;
        dest[15] = 1.0f;
    }

    void toEuler(Vec3f&out euler) const
    {
        const float sqw = w*w;
        const float sqx = x*x;
        const float sqy = y*y;
        const float sqz = z*z;
        const float test = 2.0f * (y*w - x*z);

        if (equals(test, 1.0f, 0.000001f))
        {
            // heading = rotation about z-axis
            euler.z = (-2.0f*Maths::ATan2(x, w));
            // bank = rotation about x-axis
            euler.x = 0;
            // attitude = rotation about y-axis
            euler.y = (Maths::Pi/2.0f);
        }
        else if (equals(test, -1.0f, 0.000001f))
        {
            // heading = rotation about z-axis
            euler.z = (2.0*Maths::ATan2(x, w));
            // bank = rotation about x-axis
            euler.x = 0;
            // attitude = rotation about y-axis
            euler.y = (Maths::Pi/-2.0f);
        }
        else
        {
            // heading = rotation about z-axis
            euler.z = Maths::ATan2(2.0f * (x*y +z*w), (sqx - sqy - sqz + sqw));
            // bank = rotation about x-axis
            euler.x = Maths::ATan2(2.0f * (y*z + x*w), (-sqx - sqy + sqz + sqw));
            // attitude = rotation about y-axis
            euler.y = Maths::ASin( Maths::Clamp(test, -1.0f, 1.0f) );
        }
    }

    /*void toAngleAxis(float& angle, Vec3f& axis) const
    {
        float scale = sqrtf(X*X + Y*Y + Z*Z);

        if (core::iszero(scale) || W > 1.0f || W < -1.0f)
        {
            angle = 0.0f;
            axis.X = 0.0f;
            axis.Y = 1.0f;
            axis.Z = 0.0f;
        }
        else
        {
            const f32 invscale = reciprocal(scale);
            angle = 2.0f * acosf(W);
            axis.X = X * invscale;
            axis.Y = Y * invscale;
            axis.Z = Z * invscale;
        }
    }*/
}

Quaternion QuatFromAngleAxis(float angle, Vec3f axis)
{
    const float fHalfAngle = 0.5f*angle;
    const float fSin = Maths::Sin(fHalfAngle);
    const float w = Maths::Cos(fHalfAngle);
    const float x = fSin*axis.x;
    const float y = fSin*axis.y;
    const float z = fSin*axis.z;
    return Quaternion(x,y,z,w);
}