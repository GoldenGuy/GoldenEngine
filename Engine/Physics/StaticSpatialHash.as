
// ONLY USED FOR WORLDS
// STATIC STUFF... OK?

// MAP TRIANGLES AND SHAPES

// THAT DONT MOVEEEEE!!!! >:(

class SpatialHash
{
    private dictionary hash_map;

    private float GRID_SIZE;

    SpatialHash(float grid)
    {
        GRID_SIZE = grid;
    }

    void Add(ComponentBodyPair@ pair)
    {
        int x_start = pair.bounds.min.x/GRID_SIZE;
        int y_start = pair.bounds.min.y/GRID_SIZE;
        int z_start = pair.bounds.min.z/GRID_SIZE;
        int x_end = pair.bounds.max.x/GRID_SIZE;
        int y_end = pair.bounds.max.y/GRID_SIZE;
        int z_end = pair.bounds.max.z/GRID_SIZE;

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
                        bucket.push_back(@pair);
                        hash_map.set(hash, bucket);
                    }
                    else
                    {
                        ComponentBodyPair@[] bucket;
                        bucket.push_back(@pair);
                        hash_map.set(hash, bucket);
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
                            if(bounds.Intersects(pair.body.bounds)) // dont add if not actually touching
                            {
                                if(!copy_buffer.exists(pair.unique_id))
                                {
                                    colliders.push_back(pair);
                                    copy_buffer.set(pair.unique_id, true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private string getHash(int x, int y, int z)
    {
        return x+";"+y+";"+z;
    }
}

class ComponentBodyPair
{
    PhysicsComponent@ comp;
    PhysicsBody@ body;
    AABB bounds;
    string unique_id;

    ComponentBodyPair(PhysicsComponent@ _comp, PhysicsBody@ _body)
    {
        @comp = @_comp;
        @body = @_body;
        bounds = _body.getBounds() * _comp.entity.transform;
        unique_id = comp.phy_id+"_"+body.bod_id; // very unique
    }
}