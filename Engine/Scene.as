
#include "Scenes.as"

class Scene
{
	Camera@ camera;

	EntityManager@ ent_manager;
	ComponentManager@ comp_manager;

	//PhysicsScene physics_scene;

	dictionary data;

	void PreInit() // cant do this in constructor because of camera and phys world
	{
		@ent_manager = @EntityManager(this);
		@camera = @Camera(this);
		@comp_manager = @ComponentManager();
		//physics_scene = PhysicsScene(this);
	}

	void Init()
	{
		ent_manager.Init();
	}

	void Tick()
	{
		ent_manager.UpdateTransforms();
		comp_manager.Tick();

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

		comp_manager.Render();
	}

	Entity@ CreateEntity(string name)
	{
		return @ent_manager.CreateEntity(name);
	}

	void AddComponent(Component@ component)
	{
		comp_manager.AddComponent(@component);
	}
}

Scene NewScene() // haha :)
{
	Scene output = Scene();
	output.PreInit();
	return output;
}