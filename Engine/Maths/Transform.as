
class Transform
{
    Vec3f position;
    Vec3f old_position;
    Vec3f rotation;
    Vec3f old_rotation;
    Vec3f scale;
    Vec3f old_scale;

    bool dirty;

    Transform()
    {
        position = Vec3f(0.0f, 0.0f, 0.0f);
        rotation = Vec3f(0.0f, 0.0f, 0.0f);
        scale = Vec3f(1.0f, 1.0f, 1.0f);

        old_position = Vec3f(0.0f, 0.0f, 0.0f);
        old_rotation = Vec3f(0.0f, 0.0f, 0.0f);
        old_scale = Vec3f(1.0f, 1.0f, 1.0f);
    }

    void UpdateOld()
    {
        old_position = position;
        old_rotation = rotation;
        old_scale = scale;
    }
}