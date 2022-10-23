
class AABB
{
    Vec3f min, max;

    AABB(Vec3f _min, Vec3f _max)
    {
        min = _min;
        max = _max;
    }

    AABB(Vec3f start, float size)
    {
        min = start;
        max = start + size;
    }

    AABB opAdd(AABB oof) const
    {
        float x_min = Maths::Min(min.x, oof.min.x);
        float y_min = Maths::Min(min.y, oof.min.y);
        float z_min = Maths::Min(min.z, oof.min.z);

        float x_max = Maths::Max(max.x, oof.max.x);
        float y_max = Maths::Max(max.y, oof.max.y);
        float z_max = Maths::Max(max.z, oof.max.z);

        return AABB(Vec3f(x_min, y_min, z_min), Vec3f(x_max, y_max, z_max));
    }

    AABB opAdd(Vec3f oof) const
    {
        return AABB(min+oof, max+oof);
    }

    void opMulAssign(const Vec3f&in oof) { min *= oof; max *= oof; }
    void opAddAssign(const Vec3f&in oof) { min += oof; max += oof; }

    AABB opMul(const Transform&in oof)
    {
        Vec3f _min = min;
        Vec3f _max = max;

        _min *= oof.scale;
        _max *= oof.scale;

        _min += oof.position;
        _max += oof.position;

        return AABB(_min, _max);
    }

    bool Intersects(AABB o)
    {
        return  (min.x <= o.max.x && max.x >= o.min.x) &&
                (min.y <= o.max.y && max.y >= o.min.y) &&
                (min.z <= o.max.z && max.z >= o.min.z);
    }
}