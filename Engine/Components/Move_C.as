
class MoveComponent : Component, ITickable
{
    void Tick()
    {
        //entity.position.x = Maths::Sin(dtr(getGameTime()) * 2.7f) * 4.0f;
        //entity.position.y = Maths::Cos(dtr(getGameTime()) * 1.7f * 2.0f) * 2.0f;
        //entity.position.z = 4.0f;
        Vec3f new_pos;
        new_pos.x = Maths::Sin(dtr(getGameTime()) * 3.7f) * 5.0f;
        new_pos.y = Maths::Cos(dtr(getGameTime()) * 3.7f) * 3.0f - 3.0f;
        new_pos.z = 4.0f;
        entity.SetPosition(new_pos);
    }
}