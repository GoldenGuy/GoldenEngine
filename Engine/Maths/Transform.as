
class Transform
{
    Vec3f position;
    Vec3f old_position;
    bool pos_changed;
    Vec3f rotation;
    Vec3f old_rotation;
    bool rot_changed;
    Vec3f scale;
    Vec3f old_scale;
    bool scale_changed;

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
        pos_changed = true;
    }

    void SetRotation(Vec3f rot)
    {
        rotation = rot;
        rot_changed = true;
    }

    void SetScale(Vec3f scale)
    {
        scale = scale;
        scale_changed = true;
    }

    void UpdateOld()
    {
        if(!NeedsUpdate())
            return;
        
        if(pos_changed)
        {
            old_position = position;
            pos_changed = false;
        }
        if(rot_changed)
        {
            old_rotation = rotation;
            rot_changed = false;
        }
        if(scale_changed)
        {
            old_scale = scale;
            scale_changed = false;
        }
    }

    bool NeedsUpdate()
    {
        return pos_changed || rot_changed || scale_changed;
    }

    void Serialize(CBitStream@ stream)
    {
        //stream.write_bool(pos_changed);
        //stream.write_bool(rot_changed);
        //stream.write_bool(scale_changed);

        //if(pos_changed)
        {
            stream.write_f32(position.x);
            stream.write_f32(position.y);
            stream.write_f32(position.z);
        }
        //if(rot_changed)
        {
            stream.write_f32(rotation.x);
            stream.write_f32(rotation.y);
            stream.write_f32(rotation.z);
        }
        //if(scale_changed)
        {
            stream.write_f32(scale.x);
            stream.write_f32(scale.y);
            stream.write_f32(scale.z);
        }
    }

    void Deserialize(CBitStream@ stream)
    {
        //pos_changed = stream.read_bool();
        //rot_changed = stream.read_bool();
        //scale_changed = stream.read_bool();

        //if(pos_changed)
        {
            position.x = stream.read_f32();
            position.y = stream.read_f32();
            position.z = stream.read_f32();
        }
        //if(rot_changed)
        {
            rotation.x = stream.read_f32();
            rotation.y = stream.read_f32();
            rotation.z = stream.read_f32();
        }
        //if(scale_changed)
        {
            scale.x = stream.read_f32();
            scale.y = stream.read_f32();
            scale.z = stream.read_f32();
        }
    }
}