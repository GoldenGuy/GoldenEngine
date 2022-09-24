
class FreeFlyMovement : Component, ITickable
{
    void Tick()
    {
        entity.scene.camera.position = entitiy.transform.position;
    }
}