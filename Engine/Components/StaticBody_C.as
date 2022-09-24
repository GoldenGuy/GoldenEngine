
class StaticBodyComponent : Physical
{
    string getName() const {return "static_body";}
    
    StaticBodyComponent(PhysicsScene@ _physics_scene, ColliderBody@ _body)
    {
        super(_physics_scene, _body);
    }
}