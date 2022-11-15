
const float aabb_margin = 0.4f;

enum BodyType
{
    NONE,
    POINT,
    PLANE,
    //TRIANGLE,
    //MESH, // should never be dynamic, sorry
    //POLYGON,
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
        bounds = AABB(Vec3f(-radius-aabb_margin), Vec3f(radius+aabb_margin));
    }
}

class EllipsoidBody : PhysicsBody
{
    Vec3f radius;

    EllipsoidBody(Vec3f _radius)
    {
        radius = _radius;
        type = BodyType::ELLIPSOID;
        bounds = AABB(-radius-aabb_margin, radius+aabb_margin);
    }
}

class BoxBody : PhysicsBody
{
    AABB body_bounds;

    BoxBody(AABB _body)
    {
        body_bounds = _body;
        type = BodyType::AABB;
        bounds = AABB(body_bounds.min - aabb_margin, body_bounds.max + aabb_margin);
    }
}

class OBBBody : PhysicsBody
{
    AABB body_bounds;
    Transform transform;

    OBBBody(AABB _body, Transform _transform)
    {
        body_bounds = _body;
        transform = _transform;
        type = BodyType::OBB;

        //bounds = AABB(body_bounds.min - aabb_margin, body_bounds.max + aabb_margin);
        Vec3f _min = (transform.rotation * (body_bounds.min * transform.scale));
        Vec3f _max = (transform.rotation * (body_bounds.max * transform.scale));

        float x_min = Maths::Min(_max.x, _min.x);
        float y_min = Maths::Min(_max.y, _min.y);
        float z_min = Maths::Min(_max.z, _min.z);

        float x_max = Maths::Max(_min.x, _max.x);
        float y_max = Maths::Max(_min.y, _max.y);
        float z_max = Maths::Max(_min.z, _max.z);
        
        bounds = AABB(Vec3f(x_min, y_min, z_min) - aabb_margin, Vec3f(x_max, y_max, z_max) + aabb_margin);
    }
}