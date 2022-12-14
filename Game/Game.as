
class Game
{
    ComponentRegistrator comp_register; // here instead of inside scene, since they will be global in game
    Scene scene;
    
    void Init()
    {
        scene.PreInit();
        // edit after this

        CreateTestLevel(@scene);

        RenderPrimitives::orientation_guide_setup();

        scene.Init();
    }

    void Tick()
    {
        scene.Tick();
        // edit after this
        // or above, i dont care

        if(getControls().isKeyJustPressed(KEY_RSHIFT))
        {
            /*Entity@ ent = scene.CreateEntity("fymo");
            ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
            ent.AddComponent(MoveComponent());
            ent.Init();*/
            for(int i = 0; i < 25; i++)
            {
                Entity@ ent = scene.CreateEntity("ball");
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
            for(uint i = 0; i < scene.ent_manager.entities.size(); i++)
            {
                if(scene.ent_manager.entities[i] !is null && scene.ent_manager.entities[i].name == "ball")
                {
                    scene.ent_manager.entities[i].Destroy();
                }
            }
        }
    }

    void Render()
    {
        if(scene is null) return;

        Render::SetBackfaceCull(false);
        scene.Render();
        // edit after this

        Render::ClearZ();

        GUI::SetFont("menu");
        GUI::DrawText("Massive WIP\n\nR - teleport to start", Vec2f(getScreenWidth()-180, 10), SColor(255, 100, 225, 100));

        float[] model;
		Matrix::MakeIdentity(model);
        Render::SetModelTransform(model);

        RenderPrimitives::orientation_guide.RenderMeshWithMaterial();

        //Vec2f start = Vec2f(6,6);

        //GUI::SetFont("none");
        //string debug = "Fps: "+(1000.0f / getRenderApproximateCorrectionFactor());

        //Vec2f dim;
        //GUI::GetTextDimensions(debug, dim);
        //dim.y *= 0.76f;
        //dim.x += 6;
        //GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        //GUI::DrawText(debug, start, SColor(190, 0, 70, 0));

        /*Vec2f start = Vec2f(6,6);

        GUI::SetFont("none");
        string debug = "entities ("+scene.ent_manager.ents_size+"):\n";
        for(int i = 0; i < scene.ent_manager.ents_size; i++)
        {
            debug += "  ["+i+"] \""+scene.ent_manager.entities[i].name+"\"\n";
            debug += "  components:\n";
            for(int j = 0; j < scene.ent_manager.entities[i].components.size(); j++)
            {
                debug += "    ["+scene.ent_manager.entities[i].components[j].name+"]\n";
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
        debug += "  tick ("+scene.ent_manager.tick_components.size()+"):\n";
        for(int i = 0; i < scene.ent_manager.tick_components.size(); i++)
        {
            debug += "    ["+scene.ent_manager.tick_components[i].name+"]\n";
        }
        debug += "\n  render ("+scene.renderer.render_components.size()+"):\n";
        for(int i = 0; i < scene.renderer.render_components.size(); i++)
        {
            debug += "    ["+scene.renderer.render_components[i].name+"]\n";
        }
        debug += "\n  physics ("+scene.physics.physics_components.size()+"):\n";
        for(int i = 0; i < scene.physics.physics_components.size(); i++)
        {
            debug += "    ["+scene.physics.physics_components[i].name+"]\n";
        }

        start.x += dim.x + 12;

        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));*/
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