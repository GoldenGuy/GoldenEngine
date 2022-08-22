
#include "Components.as"
#include "Scenes.as"

class Game
{
    Scene scene;
    float render_delta;
    
    void Init()
    {
        scene = Scene();

        scene.PreInit();

        CreateTestLevel(@scene);

        scene.Init();
    }

    void Tick()
    {
        render_delta = 0.0f;
        scene.Tick();
    }

    void Render()
    {
        if(scene is null) return;

        if(Menu::getMainMenu() is null)
            render_delta += getRenderApproximateCorrectionFactor();

        scene.Render();

        /*string names = "";
        for(uint i = 0; i < current_scene.entities.size(); i++)
        {
            names += scene.entities[i].name;
        }
        GUI::DrawText("ents: "+names, Vec2f(6,200), color_white);*/
    }
}