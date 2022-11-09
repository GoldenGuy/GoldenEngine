
class Plane
{
    Vec3f origin;
    Vec3f normal;
    float plane_constant;
    //float[] equation;

    Plane()
    {
        origin = Vec3f();
        normal = Vec3f();
        plane_constant = 0.0f;
    }

    Plane(Vec3f origin, Vec3f normal)
    {
        this.origin = origin;
        this.normal = normal;
        plane_constant = -(normal.Dot(origin));
    }

    // from 3 points
    Plane(Vec3f p0, Vec3f p1, Vec3f p2)
    {
        normal = (p1 - p0).Cross(p2 - p0);
        normal.Normalize();
        origin = p0;
        plane_constant = -(normal.Dot(origin));
    }

    bool isFrontFacingTo(Vec3f direction)
    {
        return normal.Dot(direction) <= 0.0f;
    }

    float signedDistanceTo(Vec3f point)
    {
        return point.Dot(normal) + plane_constant;
        //return point.Dot(normal) + equation[3];
    }
}