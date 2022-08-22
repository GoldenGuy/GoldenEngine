
class PhysicsScene
{
    Scene@ scene;

    Vec3f gravity = Vec3f(0.0, -9.81, 0.0);
    Vec3f gravity_force = gravity / 1080.0f; // 1440

    Physical@[] physicals;
    ResolutionResult[] results;
    uint[] dynamics_to_wakeup;

    //TriangleBody floor;
    
    PhysicsScene(Scene@ _scene)
    {
        @scene = @_scene;
        physicals.clear();
        //floor = TriangleBody(Vec3f(-10, 3, 0), Vec3f(1, -3.5, 3), Vec3f(1, -3.5, -3));//Vec3f(-5, -1, 5), Vec3f(5, -6, 5), Vec3f(-5, -1, -5));
    }

    void AddPhysicsBody(Physical@ physical)
    {
        physical.physics_id = physicals.size();
        physicals.push_back(physical);
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
                    for(int i = 0; i < physicals.size(); i++)
                    {
                        if(body_a.physics_id == physicals[i].physics_id)
                            continue;
                        possible_collisions.push_back(physicals[i]); // for now no broadphase
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