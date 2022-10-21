
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

    void opMulAssign(const Vec3f&in oof) { min *= oof; max *= oof; }
    void opAddAssign(const Vec3f&in oof) { min += oof; max += oof; }

    bool Intersects(AABB o)
    {
        return  (min.x <= o.max.x && max.x >= o.min.x) &&
                (min.y <= o.max.y && max.y >= o.min.y) &&
                (min.z <= o.max.z && max.z >= o.min.z);
    }
}