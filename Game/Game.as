
class Game
{
    ComponentRegistrator comp_register; // here instead of inside scene, since they will be global in game
    Scene scene;
    
    void Init()
    {
        scene.PreInit();
        // edit after this

        CreateTestLevel(@scene);

        scene.Init();
    }

    void Tick()
    {
        scene.Tick();
        // edit after this
        // or above, i dont care

        if(getControls().isKeyJustPressed(KEY_RSHIFT))
        {
            Entity@ ent = scene.CreateEntity("fymo");
            ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));
            ent.AddComponent(MoveComponent());
            ent.Init();
        }

        if(getControls().isKeyJustPressed(KEY_RCONTROL))
        {
            for(uint i = 0; i < scene.ent_manager.entities.size(); i++)
            {
                if(scene.ent_manager.entities[i] !is null && scene.ent_manager.entities[i].name == "fymo")
                {
                    scene.ent_manager.entities[i].Destroy();
                }
            }
        }
    }

    void Render()
    {
        if(scene is null) return;

        Render::SetBackfaceCull(true);
        scene.Render();
        // edit after this

        Render::ClearZ();

        Vec2f start = Vec2f(6,6);

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
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));
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