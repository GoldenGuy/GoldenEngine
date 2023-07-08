
class Entity
{
	Scene@ scene;
    uint id = 0;
    string name = "none";
	Transform transform;
    bool dead = false;
	
	Entity(string _name, Scene@ _scene)
    {
        name = _name;
        @scene = @_scene;
        transform = Transform();
    }

	void Init()
    {
        
    }

    void Destroy()
    {
        dead = true;
    }
}