
class PhysicsScene
{
    Scene@ scene;

    Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
    Vec3f gravity_force = gravity / 1080.0f; // 1440

    //dictionary spatial_hash;
    //PBHash spatial_hash;
    SpatialHash spatial_hash;
    Physical@[] physicals;
    ResolutionResult[] results;
    uint[] dynamics_to_wakeup;

    //TriangleBody floor;
    
    PhysicsScene(Scene@ _scene)
    {
        @scene = @_scene;
        physicals.clear();
        spatial_hash = SpatialHash(2);
        //spatial_hash = PBHash(1, Vec3f(50,50,50));
        //floor = TriangleBody(Vec3f(-10, 3, 0), Vec3f(1, -3.5, 3), Vec3f(1, -3.5, -3));//Vec3f(-5, -1, 5), Vec3f(5, -6, 5), Vec3f(-5, -1, -5));
    }

    void AddPhysicsBody(Physical@ physical)
    {
        physical.physics_id = physicals.size();
        physicals.push_back(physical);
        spatial_hash.Add(physical.physics_id, physical.getAABB());
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

                    dictionary already_added;

                    AABB aabb = body_a.getAABB();
                    for(int x = int(aabb.min.x/spatial_hash.cell_size); x <= int(aabb.max.x/spatial_hash.cell_size); x++)
                    {
                        for(int y = int(aabb.min.y/spatial_hash.cell_size); y <= int(aabb.max.y/spatial_hash.cell_size); y++)
                        {
                            for(int z = int(aabb.min.z/spatial_hash.cell_size); z <= int(aabb.max.z/spatial_hash.cell_size); z++)
                            {
                                string hash = spatial_hash.posToHash(Vec3f(x,y,z));
                                SHCell@ cell;
                                if(spatial_hash.sh.get(hash, @cell))
                                {
                                    for(int i = 0; i < cell.ids.size(); i++)
                                    {
                                        int id = cell.ids[i];
                                        if(id == body_a.physics_id) continue;
                                        if(!already_added.exists("id:"+id))
                                        {
                                            already_added.set("id:"+id, true);
                                            possible_collisions.push_back(physicals[id]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
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
            spatial_hash.Move(result.id, body.getAABB());
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

class SpatialHash
{
    int cell_size;
    dictionary sh;
    dictionary ids;

    SpatialHash(int _cell_size)
    {
        cell_size = _cell_size;
    }

    void Add(int id, AABB aabb)
    {
        string[] cells;
        cells.clear();
        for(int x = int(aabb.min.x/cell_size); x <= int(aabb.max.x/cell_size); x++)
		{
			for(int y = int(aabb.min.y/cell_size); y <= int(aabb.max.y/cell_size); y++)
			{
				for(int z = int(aabb.min.z/cell_size); z <= int(aabb.max.z/cell_size); z++)
				{
                    string hash = posToHash(Vec3f(x,y,z));
                    SHCell@ cell;
                    if(sh.get(hash, @cell))
                    {
                        cell.Add(id);
                        cells.push_back(hash);
                    }
                    else
                    {
                        SHCell _cell = SHCell();
                        _cell.Add(id);
                        sh.set(hash, @_cell);
                        cells.push_back(hash);
                    }
                }
            }
        }
        ids.set("id:"+id, cells);
    }

    void Remove(int id)
    {
        string[] cells;
        ids.get("id:"+id, cells);
        for(int i = 0; i < cells.size(); i++)
        {
            string hash = cells[i];
            SHCell@ cell;
            if(sh.get(hash, @cell))
            {
                cell.Remove(id);
            }
        }
        cells.clear();
        ids.set("id:"+id, cells);
    }

    void Move(int id, AABB aabb)
    {
        Remove(id);
        Add(id, aabb);
    }

    string posToHash(Vec3f pos)
    {
        return int(pos.x/cell_size)+":"+int(pos.y/cell_size)+":"+int(pos.z/cell_size);
    }
}

class SHCell
{
    int[] ids;

    SHCell(){ids.clear();}

    void Add(int id)
    {
        if(has(id) == -1)
            ids.push_back(id);
    }

    int has(int id)
    {
        for(int i = 0; i < ids.size(); i++)
            if(ids[i] == id)
                return i;
        return -1;
    }

    void Remove(int id)
    {
        int index = has(id);
        if(index != -1)
            ids.removeAt(index);
    }
}