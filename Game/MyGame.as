#include "Engine.as"

#include "BoxEntity.as"
#include "PlayerEntity.as"

IGame@ game = MyGame();

class MyGame : IGame
{
    Scene main_scene;
    
    void Init() // init only happens on server, client should handle it differently!!!
    {
        main_scene = Scene();
        for(int i = 0; i < 10; i++)
        {
            // create 10 box entities
            Entity@ box = BoxEntity();
            box.name = "Box";
            box.transform.SetPosition(Vec3f(XORRandom(500)+100, XORRandom(500)+100, 0.0f));
            main_scene.AddEntity(@box);
        }
        main_scene.Init();
    }

    void Tick()
    {
        main_scene.Tick();
    }

    void Render()
    {
        main_scene.Render(); // hmm
    }

    void SendFullData(CBitStream@ stream)
    {
        main_scene.SendFullData(stream);
    }

    void CreateFromData(CBitStream@ stream)
    {
        Print("Creating game", PrintColor::YLW);
        main_scene = Scene();
        main_scene.CreateFromData(stream);
        main_scene.Init();
    }

    void Serialize(CBitStream@ stream)
    {
        main_scene.Serialize(stream);
    }

    void Deserialize(CBitStream@ stream)
    {
        main_scene.Deserialize(stream);
    }
}

namespace MyGame
{
    enum entity_types
    {
        box_entity = 1,
        player_entity,
    }
}

Entity@ CreateEntityFromType(u16 type)
{
    switch(type)
    {
        case 0:
            return Entity();
        case MyGame::box_entity:
            return BoxEntity();
        case MyGame::player_entity:
            return PlayerEntity();
    }
    return null;
}