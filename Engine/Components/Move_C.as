
class MoveComponent : Component
{
    MoveComponent()
    {
        hooks = CompHooks::TICK;
        name = "MoveComponent";
    }

    void Tick()
    {
        Vec3f new_pos;
        new_pos.x = Maths::Sin(dtr(getGameTime()) * 2.7f) * 5.0f;
        new_pos.y = Maths::Cos(dtr(getGameTime()) * 3.7f) * 3.0f + 6.0f;
        new_pos.z = 0.0f;
        entity.SetPosition(new_pos);
    }
}