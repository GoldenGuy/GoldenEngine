
enum CompHooks
{
    TICK = 0x000001,
    RENDER = 0x000010,
    PHYSICS = 0x000100
}

class Component
{
    u8 hooks;
    uint comp_id;
    string name;
    Entity@ entity;

    bool opEquals(const Component&in other) const { return comp_id == other.comp_id; }

    void Init(){}
    void Tick(){}
    void Render(){}

    void SetEntity(Entity@ _e)
    {
        @entity = @_e;
    }
}

/*class Physical : Component
{
    uint physics_id;
    PhysicsScene@ physics_scene;
    ColliderBody@ body;
    BodyType body_type = BodyType::STATIC;

    Physical(PhysicsScene@ _physics_scene, ColliderBody@ _body)
    {
        @physics_scene = @_physics_scene;
        @body = @_body;
        hooks |= CompHooks::PHYSICS;
    }

    AABB getAABB()
    {
        AABB aabb = body.getAABB();
        aabb.min += entity.transform.position;
        aabb.max += entity.transform.position;
        return aabb;
    }
}*/



/*funcdef void comp_func();

class Component
{
    Entity@ entity;

    bool opEquals(const Component&in other) const { return getName() == other.getName(); }

    void Init(){}
    string getName() const {return "none";} // this is ass
}

interface ITickable
{
    void Tick();
}

interface IRenderable
{
    void Render();
}

class Physical : Component
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
}*/