
class FreeFlyMovement : Component, ITickable
{
    void Tick()
    {
        entity.scene.camera.position = entity.transform.position;
    }
}