
class Transform
{
    Vec3f position;
    Vec3f old_position;
    Quaternion rotation;
    Quaternion old_rotation;
    Vec3f scale;
    Vec3f old_scale;

    bool dirty;

    Transform()
    {
        position = Vec3f(0.0f, 0.0f, 0.0f);
        rotation = Quaternion(0.0f, 0.0f, 0.0f, 1.0f);
        scale = Vec3f(1.0f, 1.0f, 1.0f);
    }

    void UpdateOld()
    {
        old_position = position;
        old_rotation = rotation;
        old_scale = scale;
    }
}