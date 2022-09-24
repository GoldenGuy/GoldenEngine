
funcdef void comp_func();

class Component
{
    Entity@ entity;

    void Init(){}
}

interface ITickable
{
    void Tick();
}

interface IRenderable
{
    void Render();
}

class Physical : Component // can only be one in an entity
{
    uint physics_id;
    PhysicsScene@ physics_scene;
    ColliderBody@ body;
    BodyType body_type = BodyType::STATIC;

    Physical(PhysicsScene@ _physics_scene, ColliderBody@ _body)
    {
        @physics_scene = @_physics_scene;
        @body = @_body;
    }

    AABB getAABB()
    {
        AABB aabb = body.getAABB();
        aabb.min += entity.transform.position;
        aabb.max += entity.transform.position;
        return aabb;
    }

    //ResolutionResult Physics(Physical@[] colliders){}
    //bool doesCollideWith(Entity@ other);
    //void onCollideWith(Entity@ other);
}