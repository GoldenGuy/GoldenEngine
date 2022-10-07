#include "Entity.as"

class EntityManager
{
    uint ent_id_tracker = 0;
    Scene@ scene;

    EntityManager(Scene@ _s)
    {
        @scene = @_s;
    }

    void Init()
    {

    }

    void Tick()
    {

    }

    void Render()
    {

    }

    Entity@ CreateEntity(string name)
    {
        return null;
    }

    void AddComponent(Component@ component)
    {

    }
}