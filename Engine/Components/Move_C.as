
class MoveComponent : Component
{
    uint spawn_time = 0;
    
    MoveComponent()
    {
        hooks = CompHooks::TICK;
        name = "MoveComponent";
    }

    void Init()
    {
        spawn_time = getGameTime();
    }

    void Tick()
    {
        Vec3f new_pos;
        uint val = getGameTime()-spawn_time;
        //print("getGameTime(): "+getGameTime());
        new_pos.x = Maths::Sin(dtr(val) * 2.7f) * 5.0f;
        new_pos.y = Maths::Cos(dtr(val) * 3.7f) * 3.0f + 6.0f;
        new_pos.z = 0.0f;
        entity.SetPosition(new_pos);
    }
}