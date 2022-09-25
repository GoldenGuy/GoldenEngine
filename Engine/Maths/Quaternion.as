
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
    
    Quaternion(Vec3f normal, float angle)
    {
        float sin_a = Maths::Sin(angle / 2.0f);
        float cos_a = Maths::Cos(angle / 2.0f);
        x = normal.x * sin_a;
        y = normal.y * sin_a;
        z = normal.z * sin_a;
        w = cos_a;
    }

    Quaternion(float pitch, float yaw, float roll)
    {
        // Assuming the angles are in radians.
        float c1 = Maths::Cos(yaw/2.0f);
        float s1 = Maths::Sin(yaw/2.0f);
        float c2 = Maths::Cos(roll/2.0f);
        float s2 = Maths::Sin(roll/2.0f);
        float c3 = Maths::Cos(pitch/2.0f);
        float s3 = Maths::Sin(pitch/2.0f);
        float c1c2 = c1*c2;
        float s1s2 = s1*s2;
        w = c1c2*c3 - s1s2*s3;
        x = c1c2*s3 + s1s2*c3;
        y = s1*c2*c3 + c1*s2*s3;
        z = c1*s2*c3 - s1*c2*s3;
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
		return Quaternion(x + (desired.x - x) * t, y + (desired.y - y) * t, z + (desired.z - z) * t, w + (desired.w - w) * t);
	}

    void getMatrix(float[]&inout dest)
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

        dest[3] = 0.f;
        dest[7] = 0.f;
        dest[11] = 0.f;
        dest[15] = 1.f;
    }
}