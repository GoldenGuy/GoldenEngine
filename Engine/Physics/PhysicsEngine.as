
#include "PhysicsCommon.as"

uint comp_id = 0;

Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
Vec3f gravity_force = gravity / 900.0f; // 30 ticks squared

class PhysicsEngine
{
    Scene@ scene;
    PhysicsComponent@[] physics_components;
    SpatialHash statics_spatial_hash;
    //SpatialHash dynamics_spatial_hash;

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
        statics_spatial_hash = SpatialHash(1);
        //dynamics_spatial_hash = SpatialHash(4);
    }

    void Physics()
    {
        //dynamics_spatial_hash.Clear();
        //dynamics_spatial_hash = SpatialHash(4);

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
                //dynamics_spatial_hash.Add(@physics_components[i]);
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

    ComponentBodyPair@[]@ getNearbyColliders(PhysicsComponent@ comp) // only for dynamics!
    {
        ComponentBodyPair@[] output;
        AABB bounds = comp.getBounds();

        /*int x_start = Maths::Floor(bounds.min.x/statics_spatial_hash.GRID_SIZE);
        int y_start = Maths::Floor(bounds.min.y/statics_spatial_hash.GRID_SIZE);
        int z_start = Maths::Floor(bounds.min.z/statics_spatial_hash.GRID_SIZE);
        int x_end = Maths::Ceil(bounds.max.x/statics_spatial_hash.GRID_SIZE);
        int y_end = Maths::Ceil(bounds.max.y/statics_spatial_hash.GRID_SIZE);
        int z_end = Maths::Ceil(bounds.max.z/statics_spatial_hash.GRID_SIZE);

        dictionary copy_buffer;
        for(int x = x_start; x < x_end; x++)
        {
            for(int y = y_start; y < y_end; y++)
            {
                for(int z = z_start; z < z_end; z++)
                {
                    string hash = statics_spatial_hash.getHash(x, y, z);
                    if(statics_spatial_hash.hash_map.exists(hash))
                    {
                        ComponentBodyPair@[] bucket;
                        statics_spatial_hash.hash_map.get(hash, bucket);

                        for(int j = 0; j < bucket.size(); j++)
                        {
                            ComponentBodyPair@ pair = @bucket[j];
                            string _hash = pair.comp.phy_id+"_"+pair.body.bod_id;
                            if(!copy_buffer.exists(_hash) && comp.phy_id != pair.comp.phy_id)
                            {
                                output.push_back(pair);
                                copy_buffer.set(_hash, true);
                            }
                        }
                    }
                }
            }
        }*/

        //bounds = bounds + (bounds + comp.velocity); // account for movement

        // get the statics
        statics_spatial_hash.getIn(bounds, output);

        // now get the dynamics
        //dynamics_spatial_hash.getIn(bounds, output);
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