
#include "ComponentRegistrator.as"

// defaults
#include "ObjRender_C.as"
#include "MeshRenderer_C.as"
#include "Move_C.as"
//#include "DynamicBody_C.as"
//#include "StaticBody_C.as"
#include "FPSCameraController_C.as"
#include "FreeFlyMovement_C.as"

// custom
#include "Components.as"

enum CompHooks
{
    TICK = 1,
    RENDER = 2,
    PHYSICS = 4 //8, 16, 32
}

class Component
{
    uint hooks = 0;
    uint comp_id = 0;
    string name = "temp";
    Entity@ entity;
    bool remove = false;

    bool opEquals(const Component&in other) const { return comp_id == other.comp_id; }

    void Init(){}
    void Tick(){}
    void Render(){}
    void Destroy(){}

    void SetEntity(Entity@ _e)
    {
        @entity = @_e;
    }

    bool hasFlag(uint flag)
    {
        return (hooks & flag) != 0;
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