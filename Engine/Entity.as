
class Entity
{
	Scene@ scene;
    uint id = 0;
    string name = "temp";
	Transform transform;
    //bool update_transforms;
    Component@[] components;
	dictionary data;
    bool dead = false;
	
	Entity(string _name, Scene@ _scene)
    {
        name = _name;
        @scene = @_scene;
        transform = Transform();
        components.clear();
    }

	void Init()
    {
        //update_transforms = false;
        for (uint i = 0; i < components.size(); i++)
        {
            components[i].Init();
        }
    }

    bool HasComponent(Component@ component)
    {
        for (uint i = 0; i < components.size(); i++)
        {
            if(component == components[i])
                return true;
        }
        return false;
    }

    void AddComponent(Component@ component, bool init = false)
    {
        GoldEngine::game.comp_register.RegisterComponent(@component);
        
        if(HasComponent(component))
        {
            print("entity ["+name+"] already has component ["+component.name+"] !!!");
            return;
        }

        @component.entity = @this;

        components.push_back(component);

        scene.AddComponent(component);

        if(init) component.Init();
    }

    void SetPosition(Vec3f _position)
    {
        transform.position = _position;
        scene.ent_manager.EntityChanged(@this);
    }

    void SetRotation(Quaternion _rotation)
    {
        transform.rotation = _rotation;
        scene.ent_manager.EntityChanged(@this);
    }

    void SetScale(Vec3f _scale)
    {
        transform.scale = _scale;
        scene.ent_manager.EntityChanged(@this);
    }

    void SetPositionImmediate(Vec3f _position)
    {
        transform.position = _position;
        transform.old_position = _position;
    }

    void SetRotationImmediate(Quaternion _rotation)
    {
        transform.rotation = _rotation;
        transform.old_rotation = _rotation;
    }

    void SetScaleImmediate(Vec3f _scale)
    {
        transform.scale = _scale;
        transform.old_scale = _scale;
    }

    void UpdateTransforms()
    {
        transform.old_position = transform.position;
        transform.old_rotation = transform.rotation;
        transform.old_scale = transform.scale;
    }
}