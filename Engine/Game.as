
class Game
{
    ComponentRegistrator comp_register; // here instead of inside main_scene, since they will be global in game
    Scene main_scene;
    
    void Init()
    {
        main_scene.PreInit();
        // edit after this

        //CreateTestLevel(@main_scene);

        //RenderPrimitives::orientation_guide_setup();

        //main_scene.Init();
    }

    void Tick()
    {
        main_scene.Tick();
        // edit after this
        // or above, i dont care

        /*if(getControls().isKeyJustPressed(KEY_RSHIFT))
        {
            //Entity@ ent = main_scene.CreateEntity("fymo");
            //ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
            //ent.AddComponent(MoveComponent());
            //ent.Init();
            for(int i = 0; i < 25; i++)
            {
                Entity@ ent = main_scene.CreateEntity("ball");
                //ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
                ent.AddComponent(MeshRendererComponent(RenderPrimitives::sphere));
                //ent.AddComponent(DynamicBodyComponent(SphereBody(1.0f)));
                float x = (float(i % 5) - 2.5f) * 2.5f;
                float z = (float(int(i / 5)) - 2.5f) * 2.5f;
                ent.SetPositionImmediate(Vec3f(x, 10, z));
                //ent.SetScaleImmediate(Vec3f(0.5f));
                ent.Init();
            }
        }

        if(getControls().isKeyJustPressed(KEY_RCONTROL))
        {
            for(uint i = 0; i < main_scene.ent_manager.entities.size(); i++)
            {
                if(main_scene.ent_manager.entities[i] !is null && main_scene.ent_manager.entities[i].name == "ball")
                {
                    main_scene.ent_manager.entities[i].Destroy();
                }
            }
        }*/
    }

    void Render()
    {
        main_scene.Render();
        /*if(main_scene is null) return;

        Render::SetBackfaceCull(false);
        main_scene.Render();
        // edit after this

        Render::ClearZ();

        GUI::SetFont("menu");
        GUI::DrawText("Massive WIP\n\nR - teleport to start", Vec2f(getScreenWidth()-180, 10), SColor(255, 100, 225, 100));

        float[] model;
		Matrix::MakeIdentity(model);
        Render::SetModelTransform(model);

        RenderPrimitives::orientation_guide.RenderMeshWithMaterial();*/

        //Vec2f start = Vec2f(6,6);

        //GUI::SetFont("none");
        //string debug = "Fps: "+(1000.0f / getRenderApproximateCorrectionFactor());

        //Vec2f dim;
        //GUI::GetTextDimensions(debug, dim);
        //dim.y *= 0.76f;
        //dim.x += 6;
        //GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        //GUI::DrawText(debug, start, SColor(190, 0, 70, 0));

    }
}

/*void traverse_octree_and_draw_box(AABBOctreeNode@ node)
{
    if(node.empty)
        return;

    if(node.leaf)
    {
        DrawAABB(node.box, SColor(0xFFFF00FF));
        return;
    }
    else
    {
        for(int i = 0; i < 8; i++)
        {
            traverse_octree_and_draw_box(node.children[i]);
        }
    }
}*/