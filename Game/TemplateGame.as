#include "Engine.as"

Game@ game = TemplateGame();

class TemplateGame : Game
{
    void Init()
    {
        Random _r(Time_Local());

        // create 10 template entities
        for(int i = 0; i < 5; i++)
        {
            Entity@ ent = server_CreateEntity(1);
            ent.transform.SetPosition(Vec3f(_r.NextRanged(500)+100, _r.NextRanged(500)+100, 0.0f));
        }
    }

    void Tick()
    {
        Game::Tick();

        if(isClient())
        {
            CControls@ controls = getControls();
            if(controls != null)
            {
                if(controls.isKeyJustPressed(KEY_RBUTTON))
                {
                    CBitStream stream;
                    stream.write_Vec2f(controls.getMouseScreenPos());
                    getRules().SendCommand(GameCommands::c_create_entity, stream, false);
                }
                
            }
        }
    }

    Entity@ CreateEntityFromType(u16 type)
    {
        switch(type)
        {
            case 0:
                return Entity();
            case 1:
                return TemplateEntity();
        }

        return null;
    }

    void ProcessCommand( uint cmd, CBitStream@ stream )
    {
        if(isServer())
        {
            switch(cmd) 
            {
                case GameCommands::c_create_entity:
                {
                    TemplateEntity@ ent = TemplateEntity();
                    Vec2f pos = stream.read_Vec2f();
                    ent.transform.SetPosition(Vec3f(pos.x, pos.y, 0.0f));
                    server_CreateEntity(ent);
                }
            }
        }
    }
}

class TemplateEntity : Entity
{
    TemplateEntity()
    {
        name = "template";
        type = 1;
    }

    void Init()
    {
        print("bomba");
    }

    void Tick()
    {
        Entity::Tick();
        //if(!isServer()) return;
        Vec3f pos = transform.position;
        pos.y += 5.0f;
        if(pos.y > 500.0f)
        {
            pos.y = 100.0f;
        }
        SetPosition(pos);
    }
    
    void Render()
    {
        Vec2f pos = Vec2f_lerp(Vec2f(transform.old_position.x, transform.old_position.y), Vec2f(transform.position.x, transform.position.y), render_delta);
        GUI::DrawRectangle(pos, pos+Vec2f(100,100));
    }
}

namespace GameCommands
{
    enum cmds
    {
        c_create_entity = 100,
    }
}