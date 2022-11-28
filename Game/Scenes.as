
void CreateTestLevel(Scene@ scene)
{
    //                             (float roll, float pitch, float yaw)
    //scene.camera.angle = Quaternion(dtr(10), 0, 0);
    scene.camera.angle = Quaternion(dtr(45), 0, 0);

    AABB[] boxez = {
        //AABB(Vec3f(-10, -2, -10), Vec3f(10, 1, 10)),
        AABB(Vec3f(-10, 1, -11), Vec3f(10, 6, -10)),

        AABB(Vec3f(5, 1, -6), Vec3f(6, 2, -5)),
        AABB(Vec3f(4, 2, -6), Vec3f(5, 3, -5)),
        AABB(Vec3f(4, 1, -5), Vec3f(5, 2, -4))
    };
    Vec3f ladder_start = Vec3f(-5, 1, -6);
    for(int i = 0; i < 16; i++)
    {
        AABB step = i == 15 ? AABB(ladder_start, ladder_start+Vec3f(2,0.1,1)) : AABB(ladder_start, ladder_start+Vec3f(0.2,0.1,1));
        ladder_start += Vec3f(0.2,0.1,0);
        boxez.push_back(step);
    }
    for(int i = 0; i < boxez.size(); i++)
    {
        Entity@ ent = scene.CreateEntity("box_"+i);
        //AABB box = AABB(Vec3f(-10, -2, -10), Vec3f(10, 1, 10));
        ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, BoxBody(boxez[i])));
        ent.AddComponent(AABBRendererComponent(boxez[i]));
        //ent.AddComponent(MeshRendererComponent(leveltest));
        //ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, MeshBody(leveltest)));
    }

    {
        Entity@ ent = scene.CreateEntity("triangle");
        //AABB box = AABB(Vec3f(-10, -2, -10), Vec3f(10, 1, 10));
        ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, TriangleBody(Vec3f(-10, 1, -10), Vec3f(0, 2, 10), Vec3f(10, 1, -10))));
        //ent.AddComponent(AABBRendererComponent(boxez[i]));
        Vertex[] verts = {
            Vertex(-10, 1, -10, 0, 0),
            Vertex(0, 2, 10, 1, 1),
            Vertex(10, 1, -10, 1, 0)
        };
        ent.AddComponent(MeshRendererComponent(verts));
        //ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, MeshBody(leveltest)));
    }

    {
        Entity@ ent = scene.CreateEntity("obb");
        ent.SetPositionImmediate(Vec3f(0, 1.5f, -2));
        AABB box = AABB(Vec3f(-0.5f), Vec3f(0.5f));
        Transform transform;
        transform.rotation = Quaternion(dtr(36.0f), 0.0f, 0.0f);
        transform.scale = Vec3f(1.0f, 0.2f, 8.0f);
        ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, OBBBody(box, transform)));
        ent.AddComponent(OOBRendererComponent(box, transform));
    }

    /*for(int i = 0; i < 25; i++)
    {
        Entity@ ent = scene.CreateEntity("ball");
        //ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
        ent.AddComponent(MeshRendererComponent(RenderPrimitives::sphere));
        ent.AddComponent(DynamicBodyComponent(SphereBody(1)));
        float x = (float(i % 5) - 2.5f) * 2.5f;
        float z = (float(int(i / 5)) - 2.5f) * 2.5f;
        ent.SetPositionImmediate(Vec3f(x, 10, z));
    }*/

    {
        Entity@ ent = scene.CreateEntity("mapo");
        ent.AddComponent(ObjRendererComponent("mapo.obj"));
        ent.AddComponent(PhysicsComponent(PhysicsComponentType::STATIC, MeshBody("mapo_collision.cfg")));
        //ent.AddComponent(MeshRendererComponent(mapo));
        //ent.AddComponent(DynamicBodyComponent(SphereBody(1)));
        //float x = (float(i % 5) - 2.5f) * 2.5f;
        //float z = (float(int(i / 5)) - 2.5f) * 2.5f;
        //ent.SetPositionImmediate(Vec3f(x, 10, z));
    }

    {
        Entity@ ent = scene.CreateEntity("player camera");
        ent.AddComponent(FPSCameraController());
        //ent.AddComponent(FreeFlyMovement());
        //ent.AddComponent(PlayerPhysicsComponent(EllipsoidBody(Vec3f(1.0f, 1.0f, 1.0f))));
        //ent.AddComponent(PlayerPhysicsComponent(EllipsoidBody(Vec3f(0.4f, 0.86f, 0.4f)*0.5f)));
        ent.AddComponent(PlayerPhysicsComponent(SphereBody(0.86f*0.5f)));
        ent.AddComponent(MeshRendererComponent(RenderPrimitives::sphere));
        ent.SetPositionImmediate(Vec3f(0, 5, 0));
        ent.SetScaleImmediate(Vec3f(0.86f*0.5f));
    }
}

// fuckit fucking finally