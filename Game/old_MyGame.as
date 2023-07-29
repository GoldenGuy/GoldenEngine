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
            Entity@ box = server_CreateEntity(MyGame::box_entity, main_scene);
            box.name = "Box";
            box.transform.SetPosition(Vec3f(XORRandom(500)+100, XORRandom(500)+100, 0.0f));
            //main_scene.AddEntity(@box);
        }
        main_scene.Init();
        game_created = true;
    }

    void Tick()
    {
        if(!game_created)
            return;

        main_scene.Tick();

        if(isServer() && getGameTime() % 10 == 0)
        {
            Entity@ box = server_CreateEntity(MyGame::box_entity, main_scene);
            box.name = "Box";
            box.transform.SetPosition(Vec3f(XORRandom(500)+100, XORRandom(500)+100, 0.0f));
        }
    }

    void Render()
    {
        if(!game_created)
            return;
        
        main_scene.Render(); // hmm
    }

    void ProcessCommand( uint cmd, CBitStream@ stream )
    {
        if(isServer())
        {
            if(cmd == 106)
            {
                u32 game_time = stream.read_u32();
                Print("[" + getGameTime() + "]" + "Game creation confirmed (" + game_time + ")", PrintColor::BLU);
            }
        }
        
        if(isClient())
        {
            switch(cmd)
            {
                case NetCommands::s_send_game:
                {
                    game.FromData(stream);
                    game_created = true;

                    Print("[" + getGameTime() + "]" + "Game creation received", PrintColor::BLU);
                    CBitStream _stream;
                    _stream.write_u32(getGameTime());
		            getRules().SendCommand(106, _stream, false);
                }
                break;

                case NetCommands::s_update_game:
                {
                    if(game_created)
                        game.Deserialize(stream);
                }
                break;

                case NetCommands::s_create_entity:
                {
                    u16 entity_type = stream.read_u16();
                    Entity@ entity = CreateEntityFromType(entity_type);
                    entity.FromData(stream);
                    main_scene.AddEntity(entity);
                    Print("[" + getGameTime() + "]" + "Entity created \""+entity.name+"\"", PrintColor::BLU);
                }
                break;
            }
        }
    }

    void ToData(CBitStream@ stream)
    {
        main_scene.ToData(stream);
    }

    void FromData(CBitStream@ stream)
    {
        Print("Creating game", PrintColor::YLW);
        main_scene = Scene();
        main_scene.FromData(stream);
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