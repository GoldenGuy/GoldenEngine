
class PhysicsEngine
{
    Scene@ scene;
    Component@[] physics_components;

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
    }

    void Physics()
    {
        for(uint i = 0; i < physics_components.size(); i++)
		{
			if(physics_components[i].remove)
            {
                physics_components.removeAt(i);
                i--;
            }
            //else
            //    physics_components[i].Physics();
		}
    }

    void AddComponent(Component@ component)
	{
        physics_components.push_back(@component);
    }
}