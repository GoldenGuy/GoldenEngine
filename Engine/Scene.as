
#include "Scenes.as"

class Scene
{
	Camera@ camera;

	EntityManager@ ent_manager;
	RenderEngine@ renderer;
	PhysicsEngine@ physics;
	
	//ComponentManager@ comp_manager; //nope, separate classes for each component type instead

	//PhysicsScene physics_scene;

	dictionary data;

	void PreInit() // cant do this in constructor because sublcasses need this class already instanced
	{
		@camera = @Camera(this);
		@ent_manager = @EntityManager(this);
		@renderer = @RenderEngine(this);
		@physics = @PhysicsEngine(this);
		//@comp_manager = @ComponentManager();
		//physics_scene = PhysicsScene(this);
	}

	void Init()
	{
		ent_manager.Init();
	}

	void Tick()
	{
		ent_manager.Tick();
		//ent_manager.UpdateTransforms();
		//comp_manager.Tick();

		//print("count: "+comp_manager.tick.size());
	}

	void Render()
	{
		Render::ClearZ();
		Render::SetZBuffer(true, true);
		Render::SetAlphaBlend(false);
		Render::SetBackfaceCull(true);
		Render::SetAmbientLight(color_white);

		float[] proj;
		Matrix::MakePerspective(proj, dtr(75.0f), float(getScreenWidth())/float(getScreenHeight()), 0.01f, 400.0f);
		Render::SetProjectionTransform(proj);

		Render::SetViewTransform(camera.getViewMatrix());

		renderer.Render();
		//comp_manager.Render();
	}

	Entity@ CreateEntity(string name)
	{
		return @ent_manager.CreateEntity(name);
	}

	void AddComponent(Component@ component)
	{
		print("  comp ["+component.name+"]");
        if(component.hasFlag(CompHooks::TICK))
        {
            print("    tick");
            ent_manager.AddComponent(@component);
        }
        if(component.hasFlag(CompHooks::RENDER))
        {
            print("    render");
            renderer.AddComponent(@component);
        }
        if(component.hasFlag(CompHooks::PHYSICS))
        {
            print("    physics");
            physics.AddComponent(@component);
        }
		//comp_manager.AddComponent(@component);
	}
}

Scene NewScene() // haha :)
{
	Scene output = Scene();
	output.PreInit();
	return output;
}