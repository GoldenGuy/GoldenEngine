
class RenderEngine
{
    Scene@ scene;
    Component@[] render_components;

    RenderEngine(Scene@ _s)
    {
        @scene = @_s;
    }

    void Render()
    {
        for(uint i = 0; i < render_components.size(); i++)
		{
			if(render_components[i].remove)
            {
                render_components.removeAt(i);
                i--;
            }
            else
                render_components[i].Render();
		}
    }

    void AddComponent(Component@ component)
	{
        render_components.push_back(@component);
    }
}