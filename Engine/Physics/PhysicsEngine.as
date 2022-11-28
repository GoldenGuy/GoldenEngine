
#include "PhysicsCommon.as"

uint comp_id = 0;

Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
Vec3f gravity_force = gravity / 900.0f; // 30 ticks squared

class PhysicsEngine
{
    Scene@ scene;
    PhysicsComponent@[] physics_components;
    SpatialHash statics_spatial_hash;

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
        statics_spatial_hash = SpatialHash(2);
    }

    void Physics()
    {
        uint[] dynamics;

        for(uint i = 0; i < physics_components.size(); i++)
		{
			if(physics_components[i].remove)
            {
                physics_components.removeAt(i);
                i--;
                continue;
            }
            
            if (physics_components[i].type == PhysicsComponentType::DYNAMIC)
            {
                dynamics.push_back(i);
            }
		}

        ResponseResult[] results;

        for(int i = 0; i < dynamics.size(); i++)
        {
            ResponseResult result;
            physics_components[dynamics[i]].Physics(result);
            if(result.needed)
            {
                result.id = dynamics[i];
                results.push_back(result);
            }
        }

        for(int i = 0; i < results.size(); i++)
        {
            physics_components[results[i].id].entity.SetPosition(results[i].new_position);
            physics_components[results[i].id].velocity = results[i].new_velocity;
        }
    }

    ComponentBodyPair@[]@ getNearbyColliders(PhysicsComponent@ comp) // only for dynamics! (obvious)
    {
        ComponentBodyPair@[] output;
        AABB bounds = comp.getBounds();
        bounds = bounds + (bounds + comp.velocity*2); // account for movement

        // get the statics
        statics_spatial_hash.getIn(bounds, output);

        return @output;
    }

    bool Collide(PhysicsBody@ first, PhysicsBody@ second, CollisionData@ data) // always considers first body to be dynamic (obvious duuh), returns true if collides
    {
        switch(first.type)
        {
            case BodyType::SPHERE:
            {
                SphereBody@ sphere = cast<SphereBody>(first);

                switch(second.type)
                {
                    case BodyType::AABB:
                    {
                        BoxBody@ box = cast<BoxBody>(second);
                        AABB bounds = box.body_bounds;

                        Vec3f nearest_point;
                        nearest_point.x = Maths::Max(bounds.min.x, Maths::Min(data.final_pos.x, bounds.max.x));
                        nearest_point.y = Maths::Max(bounds.min.y, Maths::Min(data.final_pos.y, bounds.max.y));
                        nearest_point.z = Maths::Max(bounds.min.z, Maths::Min(data.final_pos.z, bounds.max.z));

                        Vec3f ray_to_nearest = nearest_point - data.final_pos;
                        float ray_len = ray_to_nearest.Length();

                        if(ray_len > 0)
                        {
                            float overlap = sphere.radius - ray_len;

                            if(overlap > 0)
                            {
                                Vec3f surf_normal = ray_to_nearest / ray_len; // basically .Normal()
                                data.final_pos -= surf_normal * overlap;
                                data.distance_to_collision = overlap;
                                data.surface_point = nearest_point;
                                data.surface_normal = (surf_normal * (-1.0f)).Normal();

                                return true;
                            }
                        }
                        return false;
                    }
                    break;

                    case BodyType::OBB:
                    {
                        OBBBody@ box = cast<OBBBody>(second);
                        AABB bounds = box.body_bounds * box.transform.scale;

                        Vec3f _final_pos = box.transform.rotation.Inverse() * data.final_pos;

                        Vec3f nearest_point;
                        nearest_point.x = Maths::Max(bounds.min.x, Maths::Min(_final_pos.x, bounds.max.x));
                        nearest_point.y = Maths::Max(bounds.min.y, Maths::Min(_final_pos.y, bounds.max.y));
                        nearest_point.z = Maths::Max(bounds.min.z, Maths::Min(_final_pos.z, bounds.max.z));

                        Vec3f ray_to_nearest = nearest_point - _final_pos;
                        float ray_len = ray_to_nearest.Length();

                        if(ray_len > 0)
                        {
                            float overlap = sphere.radius - ray_len;

                            if(overlap > 0)
                            {
                                Vec3f surf_normal = ray_to_nearest / ray_len; // basically .Normal()
                                _final_pos -= surf_normal * overlap;
                                data.final_pos = box.transform.rotation * _final_pos;
                                data.distance_to_collision = overlap;
                                data.surface_point = box.transform.rotation * nearest_point;
                                data.surface_normal = (box.transform.rotation * surf_normal * (-1.0f)).Normal();

                                return true;
                            }
                        }
                        return false;
                    }
                    break;

                    case BodyType::TRIANGLE:
                    {
                        TriangleBody@ triangle = cast<TriangleBody>(second);

                        Vec3f bar = ClosestPtPointTriangle(data.final_pos, triangle.a, triangle.b, triangle.c);
                        
                        Vec3f nearest_point = bar;

                        Vec3f ray_to_nearest = nearest_point - data.final_pos;
                        float ray_len = ray_to_nearest.Length();

                        if(ray_len > 0)
                        {
                            float overlap = sphere.radius - ray_len;

                            if(overlap > 0)
                            {
                                Vec3f surf_normal = ray_to_nearest / ray_len; // basically .Normal()
                                data.final_pos -= surf_normal * overlap;
                                data.distance_to_collision = overlap;
                                data.surface_point = nearest_point;
                                data.surface_normal = (surf_normal * (-1.0f)).Normal();

                                return true;
                            }
                        }
                        return false;
                    }
                    break;
                }
            }
            break;

            /*case BodyType::ELLIPSOID:
            {
                EllipsoidBody@ ellips = cast<EllipsoidBody>(first);
                Vec3f _final_pos = data.final_pos / ellips.radius;

                switch(second.type)
                {
                    case BodyType::AABB:
                    {
                        BoxBody@ box = cast<BoxBody>(second);
                        AABB bounds = box.body_bounds / ellips.radius;

                        Vec3f nearest_point;
                        nearest_point.x = Maths::Max(bounds.min.x, Maths::Min(_final_pos.x, bounds.max.x));
                        nearest_point.y = Maths::Max(bounds.min.y, Maths::Min(_final_pos.y, bounds.max.y));
                        nearest_point.z = Maths::Max(bounds.min.z, Maths::Min(_final_pos.z, bounds.max.z));

                        Vec3f ray_to_nearest = nearest_point - _final_pos;
                        float ray_len = ray_to_nearest.Length();

                        if(ray_len > 0)
                        {
                            float overlap = 1.0f - ray_len;

                            if(overlap > 0)
                            {
                                Vec3f surf_normal = ray_to_nearest / ray_len; // basically .Normal()
                                _final_pos -= surf_normal * overlap;

                                data.final_pos = _final_pos * ellips.radius;
                                data.surface_normal = surf_normal * (-1.0f) * ellips.radius;

                                return true;
                            }
                        }
                        return false;
                    }
                    break;

                    case BodyType::OBB:
                    {
                        OBBBody@ box = cast<OBBBody>(second);
                        AABB bounds = box.body_bounds * box.transform.scale / ellips.radius;

                        _final_pos = box.transform.rotation.Inverse() * data.final_pos;

                        Vec3f nearest_point;
                        nearest_point.x = Maths::Max(bounds.min.x, Maths::Min(_final_pos.x, bounds.max.x));
                        nearest_point.y = Maths::Max(bounds.min.y, Maths::Min(_final_pos.y, bounds.max.y));
                        nearest_point.z = Maths::Max(bounds.min.z, Maths::Min(_final_pos.z, bounds.max.z));

                        Vec3f ray_to_nearest = nearest_point - _final_pos;
                        float ray_len = ray_to_nearest.Length();

                        if(ray_len > 0)
                        {
                            float overlap = 1.0f - ray_len;

                            if(overlap > 0)
                            {
                                Vec3f surf_normal = ray_to_nearest / ray_len; // basically .Normal()
                                _final_pos -= surf_normal * overlap;

                                data.final_pos = box.transform.rotation * _final_pos * ellips.radius;
                                data.surface_normal = box.transform.rotation * surf_normal * (-1.0f);// * ellips.radius;

                                return true;
                            }
                        }
                        return false;
                    }
                    break;
                }
            }
            break;*/
        }

        return data.intersect;
    }

    void AddComponent(Component@ component)
	{
        PhysicsComponent@ phy_comp = cast<PhysicsComponent>(component);
        phy_comp.phy_id = comp_id++;
        physics_components.push_back(@phy_comp);

        if(phy_comp.type == PhysicsComponentType::STATIC)
        {
            PhysicsBody@ body = @phy_comp.body;
            if(body.type == BodyType::MESH) // mesh ist a real body, add it as separate triangles
            {
                MeshBody@ mesh_body = cast<MeshBody>(body);
                const int size = mesh_body.tris.size();
                print("addin mesh: "+size);
                for(int i = 0; i < size; i++)
                {
                    statics_spatial_hash.Add(@ComponentBodyPair(@phy_comp, @mesh_body.tris[i]));
                }
            }
            else
                statics_spatial_hash.Add(@ComponentBodyPair(@phy_comp, @body));
        }
    }
}