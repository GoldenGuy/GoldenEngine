
class FPSCameraController : Component, IRenderable, ITickable
{
    float sens = 50.0f; // 1-100
    float old_pitch, pitch, old_yaw, yaw;
    Quaternion angle;
    
    void Init()
    {
        old_pitch = pitch = old_yaw = yaw = 0;
        angle = entity.scene.camera.angle;
        getControls().setMousePosition(Vec2f(getScreenWidth(), getScreenHeight())/2.0f);
    }

    void Tick()
    {
        if(Menu::getMainMenu() is null && isWindowActive() && isWindowFocused())
        {
            Vec2f scr_center = Vec2f(getScreenWidth(), getScreenHeight())/2.0f;
            Vec2f diff = getControls().getMouseScreenPos() - scr_center;
            getControls().setMousePosition(scr_center);

            diff *= 0.005f;
            diff *= sens;

            old_pitch = pitch;
            pitch = Maths::Clamp(pitch + diff.y, -90, 90);
            old_yaw = yaw;
            yaw += diff.x;
            if(yaw >= 360)
            {
                old_yaw -= 360;
                yaw -= 360;
            }
            else if(yaw < 0)
            {
                old_yaw += 360;
                yaw += 360;
            }
        }
        
    }

    void Render()
    {
        float interp_pitch = Maths::Lerp(old_pitch, pitch, GoldEngine::game.render_delta);
        float interp_yaw = Maths::Lerp(old_yaw, yaw, GoldEngine::game.render_delta);
        angle = EulerToQuaternion(0, dtr(interp_yaw), dtr(interp_pitch));
        entity.scene.camera.angle = angle;
    }
}