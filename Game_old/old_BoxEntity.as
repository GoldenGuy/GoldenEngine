
class BoxEntity : Entity
{
    BoxEntity()
    {
        type = 1;
    }

    void Tick()
    {
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

    void Serialize(CBitStream@ stream)
    {
        transform.position.Serialize(stream);
    }

    void Deserialize(CBitStream@ stream)
    {
        Vec3f pos;
        pos.Deserialize(stream);
        SetPosition(pos);
    }
}