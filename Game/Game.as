
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
    }
}