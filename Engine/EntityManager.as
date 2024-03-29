#include "Entity.as"

const uint MAX_ENTITIES = 1000;

class EntityManager
{
    Scene@ scene;
    Entity@[] entities;
    uint ents_size;
    uint[] transform_update;
    Component@[] tick_components;

    EntityManager(Scene@ _s)
    {
        @scene = @_s;
        ents_size = 0;
        entities.clear();
        entities.resize(MAX_ENTITIES);
        transform_update.clear();
    }

    void Init()
    {
        for(uint i = 0; i < ents_size; i++)
		{
			entities[i].Init();
		}
    }

    void Tick()
    {
        for(uint i = 0; i < ents_size; i++)
        {
            if(entities[i].dead)
            {
                RemoveEntity(@entities[i]);
                i--;
            }
        }

        for(uint i = 0; i < tick_components.size(); i++)
		{
			if(tick_components[i].remove)
            {
                tick_components.removeAt(i);
                i--;
            }
            else
                tick_components[i].Tick();
		}
    }

    void AddComponent(Component@ component)
	{
        tick_components.push_back(@component);
    }

    void UpdateTransforms()
    {
        for(uint i = 0; i < transform_update.size(); i++)
		{
			entities[transform_update[i]].UpdateTransforms();
		}
        transform_update.clear();
    }

    void EntityChanged(Entity@ ent)
    {
        transform_update.push_back(ent.id);
    }

    Entity@ CreateEntity(string name)
    {
        if(ents_size == MAX_ENTITIES)
        {
            Print("Cannot create any more entities, limit ["+MAX_ENTITIES+"] is reached!", PrintColor::RED);
            return null;
        }
        Entity entity = Entity(name, @scene);
		entity.id = ents_size;
		@entities[ents_size] = @entity;
        ents_size++;
		return @entity;
    }

    void RemoveEntity(Entity@ ent)
    {
        uint index = ent.id;
        @entities[index] = @entities[ents_size - 1];
        ent.dead = true;
        entities[index].id = index;
        ents_size--;
    }
}