
#include "Scenes.as"

class Scene
{
	Camera camera;

	EntityManager ent_manager;
	//Entity@[] entities;
	//uint entity_id_tracker = 0;

	//comp_func@[] tickables;
	//comp_func@[] renderables; // make a custom class instead

	//uint[] update_transforms;

	//PhysicsScene physics_scene;

	dictionary data;

	void PreInit() // cant do this in constructor because of camera and phys world
	{
		//entities.clear();
		//tickables.clear();
		//renderables.clear();
		ent_manager = EntityManager(this);
		camera = Camera(this);
		//physics_scene = PhysicsScene(this);
	}

	void Init()
	{
		ent_manager.Init();
		/*for(uint i = 0; i < entities.size(); i++)
		{
			entities[i].Init();
		}*/
	}

	void Tick()
	{
		ent_manager.Tick();
		/*for(int i = 0; i < update_transforms.size(); i++)
		{
			entities[update_transforms[i]].UpdateTransforms();
		}
		update_transforms.clear();

		physics_scene.Tick();

		for(uint i = 0; i < tickables.size(); i++)
		{
			tickables[i]();
		}*/
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

		ent_manager.Render();

		//physics_scene.DebugDraw();

		//Render::SetFog(color_black, SMesh::LINEAR, 0, 200, 0.5, true, true);

		/*for(uint i = 0; i < renderables.size(); i++)
		{
			renderables[i]();
		}*/
	}

	Entity@ CreateEntity(string name)
	{
		return @ent_manager.CreateEntity(name);
		/*Entity entity = Entity(name, this);
		entity.id = entity_id_tracker++;
		entities.push_back(@entity);
		return @entity;*/
	}

	/*void UpdateTransforms(Entity@ entity)
	{
		update_transforms.push_back(entity.id);
	}*/

	void AddComponent(Component@ component)
	{
		ent_manager.AddComponent(@component);
		/*ITickable@ tickable = cast<ITickable>(component);
		if(tickable !is null)
		{
			tickables.push_back(@comp_func(tickable.Tick));
		}

		IRenderable@ renderable = cast<IRenderable>(component);
		if(renderable !is null)
		{
			renderables.push_back(@comp_func(renderable.Render));
		}

		Physical@ physical = cast<Physical>(component);
		if(physical !is null)
		{
			physics_scene.AddPhysicsBody(@physical);
		}*/
	}
}

Scene NewScene() // haha :)
{
	Scene output = Scene();
	output.PreInit();
	return output;
}