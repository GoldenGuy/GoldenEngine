
class FreeFlyMovement : Component
{
    FreeFlyMovement()
    {
        hooks = CompHooks::TICK | CompHooks::RENDER;
        name = "FreeFlyMovement";
    }
    
    void Tick()
    {
        Vec3f new_pos;

        Vec3f forward = Vec3f(0, 0, 1).Rotate(entity.scene.camera.angle) * 0.4f;
        Vec3f strafe = Vec3f(1, 0, 0).Rotate(entity.scene.camera.angle) * 0.4f;

        if(getControls().isKeyPressed(KEY_KEY_W))
        {
            new_pos += forward;
        }

        if(getControls().isKeyPressed(KEY_KEY_S))
        {
            new_pos -= forward;
        }

        if(getControls().isKeyPressed(KEY_KEY_A))
        {
            new_pos -= strafe;
        }

        if(getControls().isKeyPressed(KEY_KEY_D))
        {
            new_pos += strafe;
        }

        if(getControls().isKeyPressed(KEY_LSHIFT))
        {
            new_pos -= Vec3f_UP*0.4f;
        }

        if(getControls().isKeyPressed(KEY_SPACE))
        {
            new_pos += Vec3f_UP*0.4f;
        }

        entity.SetPosition(entity.transform.position + new_pos);
    }

    void Render()
    {
        entity.scene.camera.position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);
    }
}