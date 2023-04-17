
class LevelCreator : Game
{
    void Init()
    {
        Game::Init();

        CreateTestScene(main_scene);
        main_scene.Init();
    }

    void Tick()
    {
        Game::Tick();

        if(getControls().isKeyJustPressed(KEY_RSHIFT))
        {
            //Entity@ ent = main_scene.CreateEntity("fymo");
            //ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
            //ent.AddComponent(MoveComponent());
            //ent.Init();
            for(int i = 0; i < 25; i++)
            {
                Entity@ ent = main_scene.CreateEntity("ball");
                if(ent !is null) // only when limit is reached
                {
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
        }
    }

    void Render()
    {
        Game::Render();

        Vec2f start = Vec2f(6,28);

        GUI::SetFont("none");
        string debug = "entities ("+main_scene.ent_manager.ents_size+"):\n";
        for(int i = 0; i < main_scene.ent_manager.ents_size; i++)
        {
            debug += "  ["+i+"] \""+main_scene.ent_manager.entities[i].name+"\"\n";
            debug += "  components:\n";
            for(int j = 0; j < main_scene.ent_manager.entities[i].components.size(); j++)
            {
                debug += "    ["+main_scene.ent_manager.entities[i].components[j].name+"]\n";
            }
            debug += "\n";
        }

        Vec2f dim;
        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));

        /*
        Vec2f start = Vec2f(6,6);

        GUI::SetFont("none");
        string debug = "entities ("+main_scene.ent_manager.ents_size+"):\n";
        for(int i = 0; i < main_scene.ent_manager.ents_size; i++)
        {
            debug += "  ["+i+"] \""+main_scene.ent_manager.entities[i].name+"\"\n";
            debug += "  components:\n";
            for(int j = 0; j < main_scene.ent_manager.entities[i].components.size(); j++)
            {
                debug += "    ["+main_scene.ent_manager.entities[i].components[j].name+"]\n";
            }
            debug += "\n";
        }

        Vec2f dim;
        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));

        debug = "components:\n";
        debug += "  tick ("+main_scene.ent_manager.tick_components.size()+"):\n";
        for(int i = 0; i < main_scene.ent_manager.tick_components.size(); i++)
        {
            debug += "    ["+main_scene.ent_manager.tick_components[i].name+"]\n";
        }
        debug += "\n  render ("+main_scene.renderer.render_components.size()+"):\n";
        for(int i = 0; i < main_scene.renderer.render_components.size(); i++)
        {
            debug += "    ["+main_scene.renderer.render_components[i].name+"]\n";
        }
        debug += "\n  physics ("+main_scene.physics.physics_components.size()+"):\n";
        for(int i = 0; i < main_scene.physics.physics_components.size(); i++)
        {
            debug += "    ["+main_scene.physics.physics_components[i].name+"]\n";
        }

        start.x += dim.x + 12;

        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));*/

        /*debug = "components:\n";
        debug += "  tick ("+main_scene.ent_manager.tick_components.size()+"):\n";
        for(int i = 0; i < main_scene.ent_manager.tick_components.size(); i++)
        {
            debug += "    ["+main_scene.ent_manager.tick_components[i].name+"]\n";
        }
        debug += "\n  render ("+main_scene.renderer.render_components.size()+"):\n";
        for(int i = 0; i < main_scene.renderer.render_components.size(); i++)
        {
            debug += "    ["+main_scene.renderer.render_components[i].name+"]\n";
        }
        debug += "\n  physics ("+main_scene.physics.physics_components.size()+"):\n";
        for(int i = 0; i < main_scene.physics.physics_components.size(); i++)
        {
            debug += "    ["+main_scene.physics.physics_components[i].name+"]\n";
        }

        start.x += dim.x + 12;

        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));*/
    }
}

void CreateTestScene(Scene@ scene)
{
    scene.camera.angle = Quaternion(dtr(45), 0, 0);

    {
        Entity@ ent = scene.CreateEntity("player camera");
        ent.AddComponent(FPSCameraController());
        ent.AddComponent(FreeFlyMovement());

        ent.SetPositionImmediate(Vec3f(0, 0, 0));
        ent.SetScaleImmediate(Vec3f(0.86f*0.5f));
    }

    // sky
    {
        Vertex[] sphere_new = RenderPrimitives::sphere;
        for(int i = 0; i < sphere_new.size(); i++)
        {
            //if(sphere_new[i].y > 0.1f)
            float colr = sphere_new[i].y;
            if(colr < 0.1)
                sphere_new[i].col = SColor(255, 134, 155, 216);
            else
                sphere_new[i].col = SColor(255, 204, 182, 216);
            //sphere_new[i].col.setAlpha(255);
        }
        
        Entity@ ent = scene.CreateEntity("sky sphere");
        //ent.AddComponent(FPSCameraController());
        //ent.AddComponent(FreeFlyMovement());
        ent.AddComponent(MeshRendererComponent(sphere_new, "pixel.png"));

        ent.SetPositionImmediate(Vec3f(0, 0, 0));
        ent.SetScaleImmediate(Vec3f(-1.0f));

    }
}