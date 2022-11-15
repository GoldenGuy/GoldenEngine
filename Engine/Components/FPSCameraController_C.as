
class FPSCameraController : Component
{
    FPSCameraController()
    {
        hooks = CompHooks::TICK | CompHooks::RENDER;
        name = "FPSCameraController";
    }
    
    float sens = 50.0f; // 1-100
    float pitch, yaw = 0;
    Quaternion old_angle;
    Quaternion angle;
    
    void Init()
    {
        angle = old_angle = entity.scene.camera.angle;
        getControls().setMousePosition(Vec2f(getScreenWidth(), getScreenHeight())/2.0f);
    }

    void Tick()
    {
        old_angle = angle;
        if(Menu::getMainMenu() is null && isWindowActive() && isWindowFocused())
        {
            Vec2f scr_center = Vec2f(getScreenWidth(), getScreenHeight())/2.0f;
            Vec2f diff = getControls().getMouseScreenPos() - scr_center;
            getControls().setMousePosition(scr_center);

            diff *= 0.005f;
            diff *= sens;

            float old_pitch = pitch;
            float old_yaw = yaw;
            pitch = Maths::Clamp(pitch + diff.y, -89, 89);
            yaw += diff.x;
            bool change_old = false;
            if(yaw >= 360)
            {
                yaw -= 360;
                old_yaw -= 360;
                change_old = true;
            }
            else if (yaw < 0)
            {
                yaw += 360;
                old_yaw += 360;
                change_old = true;
            }
            if(change_old)
            {
                old_angle = Quaternion(dtr(old_pitch), dtr(old_yaw), 0);
            }

            angle = Quaternion(dtr(pitch), dtr(yaw), 0);
        }
    }

    void Render()
    {
        getHUD().ShowCursor();
        if(Menu::getMainMenu() is null) getHUD().HideCursor();
        
        Quaternion new_angle = old_angle.Lerp(angle, GoldEngine::render_delta);
        entity.scene.camera.angle = new_angle;

        entity.scene.camera.position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta) - (new_angle*Vec3f(0,0,2));
    }
}