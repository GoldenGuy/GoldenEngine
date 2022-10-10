

class ComponentRegistrator
{
    uint comp_id_tracker = 0;
    dictionary name_ids;

    void RegisterComponent(Component@ comp)
    {
        if(!name_ids.exists(comp.name))
        {
            name_ids.set(comp.name, comp_id_tracker++);
        }
        name_ids.get(comp.name, comp.comp_id);
    }
}