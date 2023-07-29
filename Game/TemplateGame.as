#include "Engine.as"

Game@ game = TemplateGame();

class TemplateGame : Game
{
    void Init()
    {
        Entity@ ent = server_CreateEntity(1);
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
}

class TemplateEntity : Entity
{
    TemplateEntity()
    {
        name = "template";
        type = 1;
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