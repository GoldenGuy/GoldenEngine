#include "Entity.as"

const uint MAX_ENTITIES = 1000;

class EntityManager
{
    //uint ent_id_tracker = 0;
    Scene@ scene;
    Entity@[] entities;
    uint ents_size;
    Entity@[] transform_update;

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

    void UpdateTransforms()
    {
        for(uint i = 0; i < transform_update.size(); i++)
		{
			if(!transform_update[i].dead)
                transform_update[i].UpdateTransforms();//transform.UpdateOld();
		}
        transform_update.clear();
    }

    void EntityChanged(Entity@ ent)
    {
        transform_update.push_back(@ent);
    }

    Entity@ CreateEntity(string name)
    {
        Entity entity = Entity(name, @scene);
		entity.id = ents_size;
		@entities[ents_size] = @entity;
        ents_size++;
        print("ent ["+name+"]");
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