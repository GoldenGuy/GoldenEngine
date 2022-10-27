
#include "PhysicsCommon.as"

uint comp_id = 0;

Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
Vec3f gravity_force = gravity / 900.0f; // 30 ticks squared

class PhysicsEngine
{
    Scene@ scene;
    PhysicsComponent@[] physics_components;
    SpatialHash statics_spatial_hash;
    SpatialHash dynamics_spatial_hash;
    ResponseResult[] results;

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
        statics_spatial_hash = SpatialHash(2);
        //dynamics_spatial_hash = SpatialHash(4);
    }

    void Physics()
    {
        //dynamics_spatial_hash.Clear();
        dynamics_spatial_hash = SpatialHash(4);

        uint[] dynamics;

        for(uint i = 0; i < physics_components.size(); i++)
		{
			if(physics_components[i].remove)
            {
                physics_components.removeAt(i);
                i--;
            }
            
            else if (physics_components[i].type == PhysicsComponentType::DYNAMIC)
            {
                dynamics_spatial_hash.Add(@physics_components[i]);
                dynamics.push_back(i);
            }
		}

        for(int i = 0; i < dynamics.size(); i++)
        {
            ResponseResult result;
            result.id = dynamics[i];
            physics_components[dynamics[i]].Physics(@result);
            if(result.needed)
            {
                results.push_back(result);
            }
        }

        for(int i = 0; i < results.size(); i++)
        {
            physics_components[results[i].id].entity.SetPosition(results[i].new_position);
            physics_components[results[i].id].velocity = results[i].new_velocity;
        }
        results.clear();
    }

    ComponentBodyPair@[]@ getNearbyColliders(PhysicsComponent@ comp) // only for dynamics!
    {
        //dictionary copy_buffer;
        ComponentBodyPair@[] output;
        AABB bounds = comp.getBounds();
        bounds = bounds + (bounds + comp.velocity); // account for movement

        // get the statics
        statics_spatial_hash.getIn(bounds, output);

        // now get the dynamics
        dynamics_spatial_hash.getIn(bounds, output);
        /*for(int i = 0; i < comp.buckets_occupied.size(); i++)
        {
            ComponentBodyPair@[]@ pair_array = @comp.buckets_occupied[i];
            if(pair_array.size() > 0)
            {
                for(int j = 0; j < pair_array.size(); j++)
                {
                    ComponentBodyPair@ temp = @pair_array[j];
                    if(temp.comp.phy_id == comp.phy_id)
                        continue;
                    string hash = temp.comp.phy_id+"_"+temp.body.bod_id;
                    if(!copy_buffer.exists(hash))
                    {
                        output.push_back(@temp);
                    }
                }
            }
        }*/
        return @output;
    }

    bool Collide(PhysicsBody@ first, PhysicsBody@ second, CollisionData@ data) // always considers first body to be dynamic (obvious duuh), returns true if collides
    {
        switch(first.type)
        {
            case BodyType::SPHERE:
            {
                SphereBody@ sphere = cast<SphereBody>(first);
                //Vec3f orig_pos = data.start_pos;
                //Vec3f orig_vel = data.vel;

                data.start_pos /= sphere.radius;
                data.vel /= sphere.radius;
                
                switch(second.type)
                {
                    case BodyType::TRIANGLE:
                    {
                        TriangleBody@ triangle = cast<TriangleBody>(second);
                        Vec3f a = triangle.a / sphere.radius;
                        Vec3f b = triangle.b / sphere.radius;
                        Vec3f c = triangle.c / sphere.radius;

                        SphereTriangleCollision(@data, a, b, c);
                        if(data.intersect)
                        {
                            data.intersect_point *= sphere.radius;
                        }
                    }
                    break;

                    case BodyType::SPHERE:
                    {
                        SphereBody@ other_sphere = cast<SphereBody>(second);

                        sphIntersect(@data, other_sphere.radius + sphere.radius);
                        if(data.intersect)
                        {
                            data.intersect_point *= sphere.radius;
                        }
                    }
                    break;
                }
            }
        }

        return data.intersect;
    }
        
        /*if(first.type == BodyType::SPHERE && second.type == BodyType::TRIANGLE)
        {
            SphereBody@ sphere = cast<SphereBody>(first);
            data.start_pos /= sphere.radius;
            data.vel /= sphere.radius;
            TriangleBody@ triangle = cast<TriangleBody>(second);
            SphereTriangleCollision(data, triangle.a/sphere.radius, triangle.b/sphere.radius, triangle.c/sphere.radius);
            if(data.intersect)
            {
                data.intersect_point *= sphere.radius;
                //data.intersect_normal *= radius;
            }
            data.start_pos *= sphere.radius;
            data.vel *= sphere.radius;
        }*/

        /*else if (first.type == BodyType::SPHERE && second.type == BodyType::SPHERE)
        {
            SphereBody@ sphere = cast<SphereBody>(first);
            SphereBody@ other_sphere = cast<SphereBody>(second);
            data.start_pos /= sphere.radius;
            data.vel -= data.other_vel;
            data.vel /= sphere.radius;
            RaySphereCollision(data, other_sphere.radius+1.0f);
            if(data.intersect)
            {
                data.intersect_point *= sphere.radius;
            }
            if(data.inside)
            {
                data.push_out *= sphere.radius;
                data.push_out.Normalize();
            }
            data.start_pos *= sphere.radius;
            data.vel += data.other_vel;
            data.vel *= sphere.radius;
        }*/
        /*switch (other.shape)
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
    }*/

    void AddComponent(Component@ component)
	{
        PhysicsComponent@ phy_comp = cast<PhysicsComponent>(component);
        phy_comp.phy_id = comp_id++;
        physics_components.push_back(@phy_comp);

        if(phy_comp.type == PhysicsComponentType::STATIC)
        {
            statics_spatial_hash.Add(@phy_comp);
        }
    }
}