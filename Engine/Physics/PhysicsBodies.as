
enum BodyType
{
    NONE,
    POINT,
    PLANE,
    TRIANGLE,
    MESH, // should never be dynamic, sorry
    POLYGON,
    SPHERE,
    ELLIPSOID,
    AABB,
    OBB
}

class PhysicsBody
{
    uint bod_id = 0;
    
    BodyType type;
    AABB bounds;

    AABB getBounds()
    {
        return bounds;
    }
}

class SphereBody : PhysicsBody
{
    float radius;

    SphereBody(float _radius)
    {
        radius = _radius;
        type = BodyType::SPHERE;
        bounds = AABB(Vec3f(-radius), Vec3f(radius));
    }
}

class EllipsoidBody : PhysicsBody
{
    Vec3f radius;

    EllipsoidBody(Vec3f _radius)
    {
        radius = _radius;
        type = BodyType::ELLIPSOID;
        bounds = AABB(-radius, radius);
    }
}

class TriangleBody : PhysicsBody
{
    Vec3f a;
    Vec3f b;
    Vec3f c;

    TriangleBody(Vec3f _a, Vec3f _b, Vec3f _c)
    {
        a = _a;
        b = _b;
        c = _c;
        type = BodyType::TRIANGLE;

        float x_min = Maths::Min(Maths::Min(a.x, b.x), c.x);
        float y_min = Maths::Min(Maths::Min(a.y, b.y), c.y);
        float z_min = Maths::Min(Maths::Min(a.z, b.z), c.z);

        float x_max = Maths::Max(Maths::Max(a.x, b.x), c.x);
        float y_max = Maths::Max(Maths::Max(a.y, b.y), c.y);
        float z_max = Maths::Max(Maths::Max(a.z, b.z), c.z);

        bounds = AABB(Vec3f(x_min, y_min, z_min)-Vec3f(0.1f), Vec3f(x_max, y_max, z_max)+Vec3f(0.1f));
    }
}

class MeshBody : PhysicsBody
{
    TriangleBody[] tris;

    MeshBody(Vertex[] _tris)
    {
        type = BodyType::MESH;
        int size = _tris.size();

        float x_min = 0;
        float y_min = 0;
        float z_min = 0;

        float x_max = 0;
        float y_max = 0;
        float z_max = 0;

        for(int i = 0; i < size; i += 3)
        {
            Vertex vert_a = _tris[i];
            Vertex vert_b = _tris[i+1];
            Vertex vert_c = _tris[i+2];
            tris.push_back(TriangleBody(Vec3f(vert_a.x, vert_a.y, vert_a.z), Vec3f(vert_b.x, vert_b.y, vert_b.z), Vec3f(vert_c.x, vert_c.y, vert_c.z)));

            x_min = Maths::Min(Maths::Min(Maths::Min(vert_a.x, vert_b.x), vert_c.x), x_min);
            y_min = Maths::Min(Maths::Min(Maths::Min(vert_a.y, vert_b.y), vert_c.y), y_min);
            z_min = Maths::Min(Maths::Min(Maths::Min(vert_a.z, vert_b.z), vert_c.z), z_min);
            x_max = Maths::Max(Maths::Max(Maths::Max(vert_a.x, vert_b.x), vert_c.x), x_max);
            y_max = Maths::Max(Maths::Max(Maths::Max(vert_a.y, vert_b.y), vert_c.y), y_max);
            z_max = Maths::Max(Maths::Max(Maths::Max(vert_a.z, vert_b.z), vert_c.z), z_max);
        }

        bounds = AABB(Vec3f(x_min, y_min, z_min), Vec3f(x_max, y_max, z_max));
    }
}