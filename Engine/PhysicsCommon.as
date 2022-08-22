
#include "PhysicsScene.as"

const int DYNAMIC_ITERATIONS = 5;

enum BodyType
{
    STATIC,
    DYNAMIC,
    KINEMATIC,
    TRIGGER
}

enum BodyShape
{
    TRIANGLE,
    SPHERE,
    ELIPSOID,
    BOX,
    MESH,
    NONE
};

class CollisionData
{
	bool intersect;
    bool inside;
    Vec3f start_pos;
    Vec3f vel;
	Vec3f intersect_point;
	Vec3f intersect_normal;
    Vec3f push_out;
	float t; // time of collision 
	//int collision_type; // 0 = triangle, 1 = point, 2 = edge

	CollisionData(Vec3f _start_pos = Vec3f(), Vec3f _velocity = Vec3f())
	{
		intersect = false;
        inside = false;
        start_pos = _start_pos;
        vel = _velocity;
		intersect_point = Vec3f();
		intersect_normal = Vec3f();
        push_out = Vec3f();
		t = 1.0f;
		//collision_type = -1;
	}
}

class ColliderBody
{
    BodyShape shape = BodyShape::NONE;

    void Collide(ColliderBody@ other, CollisionData@ data)
    {
        // override
        //error("Collide not implemented");
        //printTrace();
    }
};

class SphereBody : ColliderBody
{
    float radius;

    SphereBody(float _radius)
    {
        shape = BodyShape::SPHERE;
        radius = _radius;
    }

    void Collide(ColliderBody@ other, CollisionData@ data)
    {
        switch (other.shape)
        {
            case BodyShape::TRIANGLE:
            {
                data.start_pos /= radius;
                data.vel /= radius;
                TriangleBody@ other_triangle = cast<TriangleBody>(other);
                SphereTriangleCollision(data, other_triangle.v1/radius, other_triangle.v2/radius, other_triangle.v3/radius);
                if(data.intersect)
                {
                    data.intersect_point *= radius;
                    //data.intersect_normal *= radius;
                }
                data.start_pos *= radius;
                data.vel *= radius;
                break;
            }
            case BodyShape::MESH:
            {
                data.start_pos /= radius;
                data.vel /= radius;
                MeshBody@ other_mesh = cast<MeshBody>(other);
                CollisionData _data = data;
                //_data.start_pos /= radius;
                //_data.vel /= radius;
                for(int i = 0; i < other_mesh.triangles.size(); i++)
                {
                    TriangleBody@ other_triangle = other_mesh.triangles[i];
                    SphereTriangleCollision(_data, other_triangle.v1/radius, other_triangle.v2/radius, other_triangle.v3/radius);
                    if(_data.intersect)
                    {
                        if(_data.t < data.t)
                        {
                            //data.intersect_point = _data.intersect_point*radius;
                            //data.intersect_normal = _data.intersect_normal*radius;
                            //data.t = _data.t;
                            data = _data;
                            //data.intersect_point *= radius;
                            //data.intersect_normal *= radius;
                        }
                        //data.intersect_point *= radius;
                        //data.intersect_normal *= radius;
                    }
                }
                if(data.intersect)
                {
                    data.intersect_point *= radius;
                    //data.intersect_normal *= radius;
                }
                if(data.inside)
                {
                    data.push_out *= radius;
                    data.push_out.Normalize();
                }
                data.start_pos *= radius;
                data.vel *= radius;
                //SphereMeshCollision(this, other_mesh, data);
                break;
            }
            case BodyShape::SPHERE:
            {
                SphereBody@ other_sphere = cast<SphereBody>(other);
                data.start_pos /= radius;
                data.vel /= radius;
                RaySphereCollision(data, other_sphere.radius+1.0f);
                if(data.intersect)
                {
                    data.intersect_point *= radius;
                }
                if(data.inside)
                {
                    data.push_out *= radius;
                    data.push_out.Normalize();
                }
                data.start_pos *= radius;
                data.vel *= radius;
                break;
            }
            default:
            {
                //error("SphereBody::Collide - Unsupported body shape");
                //printTrace();
            }
        }
    }
};

class TriangleBody : ColliderBody
{
    Vec3f v1, v2, v3;

    TriangleBody(Vec3f _v1, Vec3f _v2, Vec3f _v3)
    {
        shape = BodyShape::TRIANGLE;
        v1 = _v1;
        v2 = _v2;
        v3 = _v3;
    }
}

class MeshBody : ColliderBody
{
    TriangleBody@[] triangles;
    dictionary spatial_hash;

    MeshBody(Vertex[] mesh, int prim_type = 0) // prim_type = 0 - triangles, 1 - quads
    {
        shape = BodyShape::MESH;
        
        switch (prim_type)
        {
            case 0:
            {
                for (int i = 0; i < mesh.size(); i += 3)
                {
                    Vec3f v1 = Vec3f(mesh[i].x, mesh[i].y, mesh[i].z);
                    Vec3f v2 = Vec3f(mesh[i + 1].x, mesh[i + 1].y, mesh[i + 1].z);
                    Vec3f v3 = Vec3f(mesh[i + 2].x, mesh[i + 2].y, mesh[i + 2].z);
                    triangles.push_back(TriangleBody(v1, v2, v3));
                }
                break;
            }
            case 1:
            {
                for (int i = 0; i < mesh.size(); i += 4)
                {
                    Vec3f v1 = Vec3f(mesh[i].x, mesh[i].y, mesh[i].z);
                    Vec3f v2 = Vec3f(mesh[i + 1].x, mesh[i + 1].y, mesh[i + 1].z);
                    Vec3f v3 = Vec3f(mesh[i + 2].x, mesh[i + 2].y, mesh[i + 2].z);
                    Vec3f v4 = Vec3f(mesh[i + 3].x, mesh[i + 3].y, mesh[i + 3].z);
                    triangles.push_back(TriangleBody(v1, v2, v3));
                    triangles.push_back(TriangleBody(v1, v3, v4));
                }
                break;
            }
        }
    }
}

void SphereTriangleCollision(CollisionData@ data, Vec3f triangle_v1, Vec3f triangle_v2, Vec3f triangle_v3)
{
    Vec3f pos = data.start_pos;// / sphere.radius;
    Vec3f vel = data.vel;// / sphere.radius;
    
    /*if(triangle.entity !is null) // has entity, rotate and translate
    {
        // rotate using quaternion
        triangle_v1 = triangle_v1.Rotate(triangle.entity.rotation);
        triangle_v2 = triangle_v2.Rotate(triangle.entity.rotation);
        triangle_v3 = triangle_v3.Rotate(triangle.entity.rotation);

        // translate
        triangle_v1 = triangle_v1 + triangle.entity.position;
        triangle_v2 = triangle_v2 + triangle.entity.position;
        triangle_v3 = triangle_v3 + triangle.entity.position;
    }*/
    //triangle_v1 /= sphere.radius;
   // triangle_v2 /= sphere.radius;
   // triangle_v3 /= sphere.radius;
    Vec3f triangle_normal = (triangle_v2 - triangle_v1).Cross(triangle_v3 - triangle_v1).Normal();

    float normal_dot_vel = triangle_normal.Dot(vel);

    // check if moving at triangle's front face, exit if at back face
	if (normal_dot_vel > 0.0f)
    {
        //print("moving in direction of triangle's normal");
        return;
    }

    float t0 = 0.0f;
    float t1 = 0.0f;
    bool embedded_in_plane = false;

    float signed_dist_to_plane = pos.Dot(triangle_normal) - triangle_normal.Dot(triangle_v1); // MIGHT BE + or - idk

    //int collision_type = -1;
    bool collides = false;
    Vec3f intersect_point;
    float t = 1.0f;

    // we moving parallel to the plane
    if(normal_dot_vel == 0.0f)
    {
        // and we are not touching triangle
        if (Maths::Abs(signed_dist_to_plane) >= 1.0f)
        {
            // no collision possible 
            //print("moving parallel to triangle's plane, not touching");
            return;
        }
        else
        {
            //print("embedded_in_plane");
            // sphere is in plane in whole range [0..1]
            embedded_in_plane = true;
            t0 = 0.0f;
            t1 = 1.0f;
        }
    }
    else
    {
        // N dot D is not 0, calc intersect interval
        t0 = (-1.0f - signed_dist_to_plane) / normal_dot_vel;
        t1 = ( 1.0f - signed_dist_to_plane) / normal_dot_vel;

        // swap so t0 < t1
        if (t0 > t1)
        {
            float temp = t1;
            t1 = t0;
            t0 = temp;
        }

        // check that at least one result is within range
        if (t0 > 1.0f || t1 < 0.0f)
        {
            // both values outside range [0,1] so no collision
            //print("no collision possible");
            return;
        }

        // clamp to [0,1]
        if (t0 < 0.0f) { t0 = 0.0f; }
        if (t1 < 0.0f) { t1 = 0.0f; }
        if (t0 > 1.0f) { t0 = 1.0f; }
        if (t1 > 1.0f) { t1 = 1.0f; }
    }

    //print("t: "+t0+" "+t1);

    if(!embedded_in_plane)
    {
        Vec3f plane_intersect_point = pos - triangle_normal;
        Vec3f temp = vel * t0;
        plane_intersect_point += temp;

        //print("plane_intersect_point: "+plane_intersect_point.FloatString());
        //print("triangle_v1: "+triangle_v1.FloatString());
        //print("triangle_v2: "+triangle_v2.FloatString());
        //print("triangle_v3: "+triangle_v3.FloatString());

        if(PointInsideTriangle(plane_intersect_point, triangle_v1, triangle_v2, triangle_v3))
        {
            //print("inside triangle");
            intersect_point = plane_intersect_point;
            collides = true;
            t = t0;
            //collision_type = 0;
        }
    }
    
    /*if(!collides)
    {
        float velocitySquaredLength = vel.SquaredLength();
        float a,b,c; // Params for equation
        float newT;

        a = velocitySquaredLength;

        // P1
        b = 2.0f * (vel.Dot(pos - triangle_v1));
        c = (triangle_v1 - pos).SquaredLength() - 1.0f;
        newT = get_lowest_root(a, b, c, t);
        if (newT != -1.0f)
        {
            t = newT;
            intersect_point = triangle_v1;
            collides = true;
            //collision_type = 1;
        }

        // P2
        b = 2.0f * (vel.Dot(pos - triangle_v2));
        c = (triangle_v2 - pos).SquaredLength() - 1.0f;
        newT = get_lowest_root(a, b, c, t);
        if (newT != -1.0f)
        {
            t = newT;
            intersect_point = triangle_v2;
            collides = true;
            //collision_type = 1;
        }

        // P3
        b = 2.0f * (vel.Dot(pos - triangle_v3));
        c = (triangle_v3 - pos).SquaredLength() - 1.0f;
        newT = get_lowest_root(a, b, c, t);
        if (newT != -1.0f)
        {
            t = newT;
            intersect_point = triangle_v3;
            collides = true;
            //collision_type = 1;
        }

        // Check agains edges:
        // triangle_v1 -> triangle_v2:
        Vec3f edge = triangle_v2 - triangle_v1;
        Vec3f baseToVertex = triangle_v1 - pos;
        float edgeSquaredLength = edge.SquaredLength();
        float edgeDotVelocity = edge.Dot(vel);
        float edgeDotBaseToVertex = edge.Dot(baseToVertex);
        // Calculate parameters for equation
        a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
        if(a != 0.0f)
        {
            b = edgeSquaredLength * (2.0f * vel.Dot(baseToVertex)) - 2.0f * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0f - baseToVertex.SquaredLength()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
            // Does the swept sphere collide against infinite edge?

            newT = get_lowest_root(a, b, c, t);
            if (newT != -1.0f)
            {
                // Check if intersection is within line segment:
                float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                if (f >= 0.0 && f <= 1.0)
                {
                    print("line segment v1 -> v2");
                    // intersection took place within segment.
                    t = newT;
                    intersect_point = triangle_v1 + edge * f;
                    collides = true;
                    //collision_type = 2;
                }
            }
        }

        // triangle_v2 -> triangle_v3:
        edge = triangle_v3 - triangle_v2;
        baseToVertex = triangle_v2 - pos;
        edgeSquaredLength = edge.SquaredLength();
        edgeDotVelocity = edge.Dot(vel);
        edgeDotBaseToVertex = edge.Dot(baseToVertex);
        a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
        if(a != 0.0f)
        {
            b = edgeSquaredLength * (2.0f * vel.Dot(baseToVertex))-2.0f * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0f - baseToVertex.SquaredLength()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
            newT = get_lowest_root(a, b, c, t);
            if (newT != -1.0f)
            {
                float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                if (f >= 0.0 && f <= 1.0)
                {
                    print("line segment v2 -> v3");
                    t = newT;
                    intersect_point = triangle_v2 + edge * f;
                    collides = true;
                    //collision_type = 2;
                }
            }
        }

        // triangle_v3 -> triangle_v1:
        edge = triangle_v1-triangle_v3;
        baseToVertex = triangle_v3 - pos;
        edgeSquaredLength = edge.SquaredLength();
        edgeDotVelocity = edge.Dot(vel);
        edgeDotBaseToVertex = edge.Dot(baseToVertex);
        a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
        if(a != 0.0f)
        {
            b = edgeSquaredLength * (2.0f * vel.Dot(baseToVertex)) - 2.0f * edgeDotVelocity * edgeDotBaseToVertex;
            c = edgeSquaredLength * (1.0f - baseToVertex.SquaredLength()) + edgeDotBaseToVertex*edgeDotBaseToVertex;
            newT = get_lowest_root(a, b, c, t);
            if (newT != -1.0f)
            {
                float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                if (f >= 0.0 && f <= 1.0)
                {
                    print("line segment v3 -> v1");
                    t = newT;
                    intersect_point = triangle_v3 + edge * f;
                    collides = true;
                    //collision_type = 2;
                }
            }
        }
    }*/

    if(collides)
    {
        // if closer than previous intersection
        if(t <= data.t || !data.intersect)
        {
            data.t = t;
            data.intersect_point = intersect_point;// * sphere.radius;
            data.intersect = true;
            //data.collision_type = collision_type;
            //print("collision");
            return;
        }
        else
        {
            //print("too far?");
        }
    }
    //print("guh?");
}

void RaySphereCollision(CollisionData@ data, float sphere_radius)
{
    Vec3f oc = data.start_pos;
    if(oc.Length() < sphere_radius)
    {
        //data.intersect = false;
        data.inside = true;
        //data.t = (oc.Length() / sphere_radius)-1.0f;
        //data.intersect_point = Vec3f();
        data.push_out = data.start_pos.Normal();
        return;
    }
    float b = oc.Dot(data.vel.Normal());
    float c = oc.Dot(oc) - sphere_radius*sphere_radius;
    float h = b*b - c;
    if(h<0.0) // no intersection
    {
        //print("h: " + h);
        return;
    }
    h = Maths::Sqrt( h );
    float dist = -b-h;
    float time = 1.0f-(dist / data.vel.Length());
    //float vel_length = data.vel.Length();
    //if(dist > 0.0 && data.t > dist)
    if(time > 0.0f && time < 1.0f && data.t > time)
    {
        //print("time: " + time);
        data.t = time;
        data.intersect_point = Vec3f();
        data.intersect = true;
    }
}

bool PointInsideTriangle(Vec3f point, Vec3f a, Vec3f b, Vec3f c)
{
    /*Vec3f _a = a - point;
    Vec3f _b = b - point;
    Vec3f _c = c - point;

    Vec3f u = _b.Cross(_c);
    Vec3f v = _c.Cross(_a);
    Vec3f w = _a.Cross(_b);

    if (u.Dot(v) < 0.0f) {
        return false;
    }
    if (u.Dot(w) < 0.0f) {
        return false;
    }

    return true;*/

    Vec3f v0 = c - a;
		Vec3f v1 = b - a;
		Vec3f v2 = point - a;

		float dot00 = v0.Dot(v0);
		float dot01 = v0.Dot(v1);
		float dot02 = v0.Dot(v2);
		float dot11 = v1.Dot(v1);
		float dot12 = v1.Dot(v2);

		float invDenom = 1.0f / (dot00 * dot11 - dot01 * dot01);
		float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

		return ((u >= 0.0f) && (v >= 0.0f) && (u + v < 1.0f));
}