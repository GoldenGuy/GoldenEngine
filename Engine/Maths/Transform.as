
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

    void SetPosition(Vec3f pos)
    {
        position = pos;
        dirty = true;
    }

    void SetRotation(Vec3f rot)
    {
        rotation = rot;
        dirty = true;
    }

    void SetScale(Vec3f scale)
    {
        scale = scale;
        dirty = true;
    }

    void UpdateOld()
    {
        old_position = position;
        old_rotation = rotation;
        old_scale = scale;

        dirty = false;
    }

    void Serialize(CBitStream@ stream)
    {
        stream.write_f32(position.x);
        stream.write_f32(position.y);
        stream.write_f32(position.z);
        stream.write_f32(rotation.x);
        stream.write_f32(rotation.y);
        stream.write_f32(rotation.z);
        stream.write_f32(scale.x);
        stream.write_f32(scale.y);
        stream.write_f32(scale.z);
    }

    void Deserialize(CBitStream@ stream)
    {
        position.x = stream.read_f32();
        position.y = stream.read_f32();
        position.z = stream.read_f32();
        rotation.x = stream.read_f32();
        rotation.y = stream.read_f32();
        rotation.z = stream.read_f32();
        scale.x = stream.read_f32();
        scale.y = stream.read_f32();
        scale.z = stream.read_f32();

        dirty = true;
    }
}