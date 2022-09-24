
class StaticBodyComponent : Physical
{
    StaticBodyComponent(PhysicsScene@ _physics_scene, ColliderBody@ _body)
    {
        super(_physics_scene, _body);
    }
}