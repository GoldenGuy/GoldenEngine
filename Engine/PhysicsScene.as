
class PhysicsScene
{
    Scene@ scene;

    Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
    Vec3f gravity_force = gravity / 1080.0f; // 1440

    //dictionary spatial_hash;
    //PBHash spatial_hash;
    Physical@[] physicals;
    ResolutionResult[] results;
    uint[] dynamics_to_wakeup;

    //TriangleBody floor;
    
    PhysicsScene(Scene@ _scene)
    {
        @scene = @_scene;
        physicals.clear();
        //spatial_hash = PBHash(1, Vec3f(50,50,50));
        //floor = TriangleBody(Vec3f(-10, 3, 0), Vec3f(1, -3.5, 3), Vec3f(1, -3.5, -3));//Vec3f(-5, -1, 5), Vec3f(5, -6, 5), Vec3f(-5, -1, -5));
    }

    void AddPhysicsBody(Physical@ physical)
    {
        physical.physics_id = physicals.size();
        physicals.push_back(physical);
        //spatial_hash.AddId(physical.physics_id, physical.getAABB());
    }

    void Tick()
    {
        results.clear();
        dynamics_to_wakeup.clear();
        for(int j = 0; j < physicals.size(); j++)
        {
            Physical@ body_a = physicals[j];
            switch(body_a.body_type)
            {
                case BodyType::STATIC:
                case BodyType::TRIGGER:
                    break;
                
                case BodyType::DYNAMIC:
                {
                    DynamicBodyComponent@ dyn_body_a = cast<DynamicBodyComponent>(body_a);
                    Physical@[] possible_collisions;
                    possible_collisions.clear();
                    /*for(int i = 0; i < physicals.size(); i++)
                    {
                        if(body_a.physics_id == physicals[i].physics_id)
                            continue;
                        possible_collisions.push_back(physicals[i]); // for now no broadphase
                    }*/
                    /*int[] cells = spatial_hash.getCellsInAABB(body_a.getAABB());
                    {
                        array<bool> already_added(MAX_ENTS, false);
                        //already_added.clear();
                        //already_added.resize(MAX_ENTS);

                        for(int c = 0; c < cells.size(); c++)
                        {
                            int cell_id = cells[c];
                            IdsInCell cell = spatial_hash.data[cell_id];
                            for(int i = 0; i < cell.ids.size(); i++)
                            {
                                int id = cell.ids[i].id;
                                //if(!already_added[id])
                                {
                                    //already_added[id] = true;
                                    possible_collisions.push_back(physicals[i]);
                                }
                            }
                        }
                    }*/
                    //print("a: "+possible_collisions.size());
                    ResolutionResult result = dyn_body_a.Physics(possible_collisions);
                    results.push_back(result);
                    //dyn_body_a.entitiy.SetPosition(result.new_position);
                    //dyn_body_a.velocity = result.new_velocity;
                }
            }
        }
        for(int i = 0; i < results.size(); i++)
        {
            ResolutionResult result = results[i];
            DynamicBodyComponent@ body = cast<DynamicBodyComponent>(physicals[result.id]);
            body.velocity = result.new_velocity;
            body.entity.SetPosition(result.new_position);
            //spatial_hash.UpdateId(result.id, body.getAABB());
        }

        /*for(int i = 0; i < dynamics_to_wakeup.size(); i++)
        {
            int id = dynamics_to_wakeup[i];
            Physical@ body = physicals[id];
            body.Awake();
        }*/
    }

    void DebugDraw()
    {
        //Vertex[] vertices;
        //vertices.push_back(Vertex(floor.v1.x, floor.v1.y, floor.v1.z, 0, 0));
        //vertices.push_back(Vertex(floor.v2.x, floor.v2.y, floor.v2.z, 1, 0));
        //vertices.push_back(Vertex(floor.v3.x, floor.v3.y, floor.v3.z, 0, 1));

        //Render::RawTriangles("default.png", vertices);
    }
}

class ResolutionResult
{
    bool needed;
    uint id;
    Vec3f new_position;
    Vec3f new_velocity;

    ResolutionResult()
    {
        needed = false;
    }
}

/*class PBHash : SpatialHash
{
    PBHash(int _GRID_SIZE, Vec3f _MAX_SIZE){super(_GRID_SIZE, _MAX_SIZE);}
    
    int getCellAt(Vec3f pos) override
    {
        Vec3f hash_space = Vec3f(int((pos.x + MAX_SIZE.x/2.0f)/GRID_SIZE), int((pos.y + MAX_SIZE.y/2.0f)/GRID_SIZE), int((pos.z + MAX_SIZE.z/2.0f)/GRID_SIZE));
        return int(hash_space.x + hash_space.y * MAX_SIZE.x + hash_space.z * (MAX_SIZE.x * MAX_SIZE.y));
    }

    int[] getCellsInAABB(AABB aabb) override
    {
        int[] result;
        for(int x = aabb.min.x; x < aabb.max.x; x += GRID_SIZE)
        {
            for(int y = aabb.min.y; y < aabb.max.y; y += GRID_SIZE)
            {
                for(int z = aabb.min.z; z < aabb.max.z; z += GRID_SIZE)
                {
                    result.push_back(getCellAt(Vec3f(x,y,z)));
                }
            }
        }
        return result;
    }
}

const int MAX_ENTS = 1024;

class SpatialHash
{
    int GRID_SIZE = 2;
    Vec3f MAX_SIZE = Vec3f(100,100,100); // x y and z
    IdsCells[] ids;
    IdsInCell[] data;

    SpatialHash(int _GRID_SIZE, Vec3f _MAX_SIZE)
    {
        GRID_SIZE = _GRID_SIZE;
        MAX_SIZE = _MAX_SIZE;
        ids.clear();
        ids.resize(MAX_ENTS);
        data.clear();
        data.resize(int(MAX_SIZE.x * MAX_SIZE.y * MAX_SIZE.z));
    }

    int getCellAt(Vec3f pos) // implement
    {
        return 0;
    }

    int[] getCellsInAABB(AABB aabb) // too
    {
        int[] result;
        return result;
    }

    void AddId(int id, AABB aabb)
    {
        int[] cells = getCellsInAABB(aabb);
        IdsCells object;
        object.id = id;
        object.cells = cells;
        for(int i = 0; i < cells.size(); i++)
        {
            data[i].ids.push_back(object);
        }
        ids[id] = object;
    }

    void UpdateId(int id, AABB aabb)
    {
        //IdsCells object = ids[id];
        RemoveIdFromCells(id);
        AddId(id, aabb);
    }

    void RemoveIdFromCells(int id)
    {
        IdsCells object = ids[id];
        for(int i = 0; i < object.cells.size(); i++)
        {
            int cell_id = object.cells[i];
            IdsInCell cell = data[cell_id];
            for(int j = 0; j < cell.ids.size(); j++)
            {
                if(cell.ids[j].id == id)
                {
                    data[cell_id].ids.removeAt(j);
                    break;
                }
            }
        }
        ids[id].cells.clear();
    }
}

class IdsInCell
{
    IdsCells[] ids;
}

class IdsCells
{
    int id;
    int[] cells;

    IdsCells()
    {
        id = -1;
        cells.clear();
    }
}*/