
class EntityDatabase
{
    dictionary names;

    void AddEntity(string name, Entity entity)
    {
        names.set(name, entity);
    }

    Entity GetEntity(string name)
    {
        Entity entity;
        if(names.get(name, entity))
            return entity;
        else
        {
            error("Entity not found: " + name);
            return entity;
        }
    }
}