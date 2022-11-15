
#include "PhysicsBodies.as"
#include "PhysicsComponent.as"

class SpatialHash
{
    dictionary hash_map;

    float GRID_SIZE;

    SpatialHash(float grid)
    {
        GRID_SIZE = grid;
    }

    void Add(PhysicsComponent@ comp)
    {
        // for mesh (many triangles)
        /*if(comp.body.type == BodyType::MESH)
        {
            MeshBody@ mesh = cast<MeshBody>(comp.body);
            if(mesh is null)
            {
                print("mesh isnt mesh!");
                return;
            }
            TriangleBody[]@ tris = @mesh.tris;
            for(int i = 0; i < tris.size(); i++)
            {
                AABB bounds = tris[i].bounds * comp.entity.transform;
                int x_start = bounds.min.x/GRID_SIZE;
                int y_start = bounds.min.y/GRID_SIZE;
                int z_start = bounds.min.z/GRID_SIZE;
                int x_end = bounds.max.x/GRID_SIZE;
                int y_end = bounds.max.y/GRID_SIZE;
                int z_end = bounds.max.z/GRID_SIZE;

                for(int x = x_start; x <= x_end; x++)
                {
                    for(int y = y_start; y <= y_end; y++)
                    {
                        for(int z = z_start; z <= z_end; z++)
                        {
                            string hash = getHash(x, y, z);
                            if(hash_map.exists(hash))
                            {
                                ComponentBodyPair@[] bucket;
                                hash_map.get(hash, bucket);
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, bucket);
                            }
                            else
                            {
                                ComponentBodyPair@[] bucket;
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, bucket);
                            }
                        }
                    }
                }
            }
        }
        // for all the singular bodies
        else*/
        {
            AABB bounds = comp.getBounds();
            int x_start = bounds.min.x/GRID_SIZE;
            int y_start = bounds.min.y/GRID_SIZE;
            int z_start = bounds.min.z/GRID_SIZE;
            int x_end = bounds.max.x/GRID_SIZE;
            int y_end = bounds.max.y/GRID_SIZE;
            int z_end = bounds.max.z/GRID_SIZE;

            for(int x = x_start; x <= x_end; x++)
            {
                for(int y = y_start; y <= y_end; y++)
                {
                    for(int z = z_start; z <= z_end; z++)
                    {
                        string hash = getHash(x, y, z);
                        if(hash_map.exists(hash))
                        {
                            ComponentBodyPair@[] bucket;
                            hash_map.get(hash, bucket);
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, bucket);
                        }
                        else
                        {
                            ComponentBodyPair@[] bucket;
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, bucket);
                        }
                    }
                }
            }
        }
    }

    void getIn(AABB&in bounds, ComponentBodyPair@[]& colliders)
    {
        int x_start = bounds.min.x/GRID_SIZE;
        int y_start = bounds.min.y/GRID_SIZE;
        int z_start = bounds.min.z/GRID_SIZE;
        int x_end = bounds.max.x/GRID_SIZE;
        int y_end = bounds.max.y/GRID_SIZE;
        int z_end = bounds.max.z/GRID_SIZE;

        dictionary copy_buffer;
        for(int x = x_start; x <= x_end; x++)
        {
            for(int y = y_start; y <= y_end; y++)
            {
                for(int z = z_start; z <= z_end; z++)
                {
                    string hash = getHash(x, y, z);
                    if(hash_map.exists(hash))
                    {
                        ComponentBodyPair@[] bucket;
                        hash_map.get(hash, bucket);

                        for(int j = 0; j < bucket.size(); j++)
                        {
                            ComponentBodyPair@ pair = @bucket[j];
                            //if(bounds.Intersects(pair.body.bounds))
                            {
                                string clone_hash = pair.comp.phy_id+"_"+pair.body.bod_id;
                                if(!copy_buffer.exists(clone_hash))
                                {
                                    colliders.push_back(pair);
                                    copy_buffer.set(clone_hash, true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    string getHash(int x, int y, int z)
    {
        return x+";"+y+";"+z;
    }
}

// -----------------------------------------------------------------------------------------

// common 

class ComponentBodyPair
{
    PhysicsComponent@ comp;
    PhysicsBody@ body;
    AABB bounds;

    ComponentBodyPair(PhysicsComponent@ _comp, PhysicsBody@ _body)
    {
        @comp = @_comp;
        @body = @_body;
        bounds = _body.getBounds() * _comp.entity.transform;
    }
}

class PairBucket
{
    ComponentBodyPair[] data;
    int size;
}

class CollisionData
{
	bool intersect;
    Vec3f start_pos;
    Vec3f vel;
    Vec3f final_pos;
    float distance_to_collision;
	Vec3f surface_normal;

	CollisionData(Vec3f _start_pos = Vec3f_ZERO, Vec3f _velocity = Vec3f_ZERO)
	{
		intersect = false;
        start_pos = _start_pos;
        vel = _velocity;
        final_pos = start_pos + vel;
        distance_to_collision = 0.0f;
		surface_normal = Vec3f_ZERO;
	}
}

class ResponseResult
{
    bool needed;
    uint id;
    Vec3f new_position;
    Vec3f new_velocity;

    ResponseResult()
    {
        needed = false;
    }
}

