#include "Engine.as"

Game@ game = TemplateGame();

class TemplateGame : Game
{
    void Init()
    {
        Random _r(Time_Local());

        // create 10 template entities
        for(int i = 0; i < 10; i++)
        {
            Entity@ ent = server_CreateEntity(1);
            ent.transform.SetPosition(Vec3f(_r.NextRanged(500)+100, _r.NextRanged(500)+100, 0.0f));
        }

        TemplateEntityLOL@ ent = TemplateEntityLOL();
        ent.transform.SetPosition(Vec3f(_r.NextRanged(500)+100, _r.NextRanged(500)+100, 0.0f));
        ent.word_of_our_sponsor = "Raid SHADOW LEGENDS";
        server_CreateEntity(ent);
    }

    Entity@ CreateEntityFromType(u16 type)
    {
        switch(type)
        {
            case 0:
                return Entity();
            case 1:
                return TemplateEntity();
            case 2:
                return TemplateEntityLOL();
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

class TemplateEntityLOL : Entity
{
    net_string word_of_our_sponsor;
    
    TemplateEntityLOL()
    {
        name = "template but red";
        type = 2;
        word_of_our_sponsor = "none";
    }
    
    void Render()
    {
        Vec2f pos = Vec2f_lerp(Vec2f(transform.old_position.x, transform.old_position.y), Vec2f(transform.position.x, transform.position.y), render_delta);
        GUI::DrawRectangle(pos, pos+Vec2f(100,20), SColor(255,255,0,0));
        GUI::DrawText(word_of_our_sponsor.value, pos, color_white);
    }

    void SendCreate(CBitStream@ stream)
    {
        Entity::SendCreate(stream);
        word_of_our_sponsor.WriteCreate(stream);
    }

    void CreateFromData(CBitStream@ stream)
    {
        Entity::CreateFromData(stream);
        word_of_our_sponsor.ReadCreate(stream);
    }

    void SendDelta(CBitStream@ stream)
    {
        Entity::SendDelta(stream);
        word_of_our_sponsor.WriteDelta(stream);
    }

    void ReadDelta(CBitStream@ stream)
    {
        Entity::ReadDelta(stream);
        word_of_our_sponsor.ReadDelta(stream);
    }
}