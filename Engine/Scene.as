
class Scene
{
	Camera camera;
	Entity@[] entities;

	void Init()
	{
		for (int i = 0; i < entities.size(); i++)
		{
			entities[i].Init();
		}
	}

	void Tick()
	{
		for (int i = 0; i < entities.size(); i++)
		{
			if(entities[i].transform.dirty)
			{
				entities[i].transform.UpdateOld();
			}
			entities[i].Tick();
		}
	}

	void Render()
	{
		for (int i = 0; i < entities.size(); i++)
		{
			entities[i].Render();
		}
	}

	void AddEntity(Entity@ entity)
	{
		entity.id = entities.size();
		entities.push_back(entity);
		entity.SetScene(this);
	}

	void SendFullData(CBitStream@ stream)
    {
        // send all entities
		stream.write_u32(entities.size());
		for (int i = 0; i < entities.size(); i++)
		{
			stream.write_u16(entities[i].type);
			entities[i].SendFullData(stream);
		}
    }

    void CreateFromData(CBitStream@ stream)
    {
        // create scene from data
		Print("Creating scene", PrintColor::YLW);
		entities.clear();
		uint size = stream.read_u32();
		Print("Entities: "+size, PrintColor::YLW);
		for (int i = 0; i < size; i++)
		{
			u16 entity_type = stream.read_u16();
			Entity@ entity = CreateEntityFromType(entity_type);
			entity.CreateFromData(stream);
			AddEntity(entity);
		}
    }

	void Serialize(CBitStream@ stream)
	{
		u32 entities_sent = 0;
		uint curr_bit_index = stream.getBitIndex();
		stream.write_u32(5);
		for (int i = 0; i < entities.size(); i++)
		{
			if(entities[i].net_update)
			{
				stream.write_u32(entities[i].id);
				entities[i].Serialize(stream);
				entities[i].net_update = false;
				entities_sent++;
			}
		}
		// now replace that first u32 by entities_sent
		stream.overwrite_at_bit_u32(curr_bit_index, entities_sent);
	}

	void Deserialize(CBitStream@ stream)
	{
		u32 entities_sent = stream.read_u32();
		//print("entities sent: "+entities_sent);
		int ent_index = 0;
		for (int i = 0; i < entities_sent; i++)
		{
			int entity_id = stream.read_u32();
			for(int j = ent_index; j < entities.size(); j++)
			{
				if(entities[j].id == entity_id)
				{
					entities[j].Deserialize(stream);
					ent_index = j;
				}
			}
		}
	}
}
/*class Scene
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
}*/