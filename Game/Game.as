
class Game
{
    ComponentManager comp_manager; // here instead of inside scene, since they will be global in game
    Scene scene;
    
    void Init()
    {
        comp_manager = ComponentManager();
        scene = NewScene();
        // edit after this

        CreateTestLevel(@scene);
    }

    void Tick()
    {
        scene.Tick();
        // edit after this
        // or above, i dont care
        
    }

    void Render()
    {
        if(scene is null) return;

        scene.Render();
        // edit after this

    }
}