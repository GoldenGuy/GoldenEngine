
#include "Scenes.as"

class Scene
{
	Camera camera;

	EntityManager ent_manager;
	RenderEngine renderer;
	PhysicsEngine physics;

	dictionary data;

	void PreInit() // cant do this in constructor because sublcasses need this class already instanced
	{
		camera = Camera(this);
		ent_manager = EntityManager(this);
		renderer = RenderEngine(this);
		physics = PhysicsEngine(this);
	}

	void Init()
	{
		ent_manager.Init();
	}

	void Tick()
	{
		ent_manager.UpdateTransforms();
		
		physics.Physics();

		ent_manager.Tick();
	}

	void Render()
	{
		Render::ClearZ();
		Render::SetZBuffer(true, true);
		Render::SetAlphaBlend(false);
		Render::SetBackfaceCull(true);
		//Render::SetAmbientLight(color_white);

		float[] proj;
		Matrix::MakePerspective(proj, dtr(75.0f), float(getScreenWidth())/float(getScreenHeight()), 0.01f, 100.0f);
		Render::SetProjectionTransform(proj);

		Render::SetViewTransform(camera.getViewMatrix());

		renderer.Render();
	}

	Entity@ CreateEntity(string name)
	{
		return @ent_manager.CreateEntity(name);
	}

	void AddComponent(Component@ component)
	{
		if(component.hasFlag(CompHooks::TICK))
        {
            ent_manager.AddComponent(@component);
        }
        if(component.hasFlag(CompHooks::RENDER))
        {
            renderer.AddComponent(@component);
        }
        if(component.hasFlag(CompHooks::PHYSICS))
        {
            physics.AddComponent(@component);
        }
	}
}

Scene NewScene() // haha :)
{
	Scene output = Scene();
	output.PreInit();
	return output;
}