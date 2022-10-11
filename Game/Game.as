
class Game
{
    ComponentRegistrator@ comp_register; // here instead of inside scene, since they will be global in game
    Scene@ scene = null;
    
    void Init()
    {
        @comp_register = @ComponentRegistrator();
        @scene = @NewScene();
        // edit after this

        CreateTestLevel(@scene);
    }

    void Tick()
    {
        scene.Tick();
        // edit after this
        // or above, i dont care
        
        if(getGameTime() % 10 == 1)
        {
            Entity@ ent = scene.CreateEntity("fymo");
            ent.AddComponent(ObjRendererComponent("improved_fumo.obj"));//MeshRendererComponent(RenderPrimitives::sphere));
            ent.AddComponent(MoveComponent());
            ent.Init();
        }
    }

    void Render()
    {
        if(scene is null) return;

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
        debug += "  tick ("+scene.comp_manager.tick.size()+"):\n";
        for(int i = 0; i < scene.comp_manager.tick.size(); i++)
        {
            debug += "    ["+scene.comp_manager.tick[i].name+"]\n";
        }
        debug += "\n  render ("+scene.comp_manager.render.size()+"):\n";
        for(int i = 0; i < scene.comp_manager.render.size(); i++)
        {
            debug += "    ["+scene.comp_manager.render[i].name+"]\n";
        }
        debug += "\n  physics ("+scene.comp_manager.physics.size()+"):\n";
        for(int i = 0; i < scene.comp_manager.physics.size(); i++)
        {
            debug += "    ["+scene.comp_manager.physics[i].name+"]\n";
        }

        start.x += dim.x + 12;

        GUI::GetTextDimensions(debug, dim);
        dim.y *= 0.76f;
        dim.x += 6;
        GUI::DrawRectangle(start, start+dim, SColor(190, 100, 100, 100));
        GUI::DrawText(debug, start, SColor(190, 0, 70, 0));
    }
}