
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

    Quaternion(float roll, float yaw, float pitch) //Euler To Quaternion
    {
        x = Maths::Sin(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Cos(roll / 2.0f) - Maths::Cos(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Sin(roll / 2.0f);
        y = Maths::Cos(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Cos(roll / 2.0f) + Maths::Sin(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Sin(roll / 2.0f);
        z = Maths::Cos(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Sin(roll / 2.0f) - Maths::Sin(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Cos(roll / 2.0f);
        w = Maths::Cos(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Cos(roll / 2.0f) + Maths::Sin(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Sin(roll / 2.0f);
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

    Quaternion Inverse()
    {
        return Quaternion(-x, -y, -z, w);
    }

    Quaternion Lerp(const Quaternion&in desired, float t)
	{
		return Quaternion(x + (desired.x - x) * t, y + (desired.y - y) * t, z + (desired.z - z) * t, w + (desired.w - w) * t);
	}
}

Quaternion EulerToQuaternion(float roll, float yaw, float pitch)
{
    float x = Maths::Sin(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Cos(roll / 2.0f) - Maths::Cos(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Sin(roll / 2.0f);
    float y = Maths::Cos(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Cos(roll / 2.0f) + Maths::Sin(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Sin(roll / 2.0f);
    float z = Maths::Cos(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Sin(roll / 2.0f) - Maths::Sin(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Cos(roll / 2.0f);
    float w = Maths::Cos(pitch / 2.0f) * Maths::Cos(yaw / 2.0f) * Maths::Cos(roll / 2.0f) + Maths::Sin(pitch / 2.0f) * Maths::Sin(yaw / 2.0f) * Maths::Sin(roll / 2.0f);

    return Quaternion(x, y, z, w);
}