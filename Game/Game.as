
class Game
{
	Camera camera;
	EntityManager entities;

	Game()
	{
		camera = Camera();
		entities = EntityManager();
	}

	// world class TODO
	// ---

	// some netvars also
	// ---
	
	void Init()
	{
		// init runs on server only, client will only get create command
		/*for(int i = 0; i < 10; i++)
		{
			Entity@ ent = BoxEntity();
			ent.SetPosition(Vec3f(XORRandom(255), XORRandom(255), 0));
			entities.Add(ent);
		}*/
	}

	void Tick()
	{
		entities.Tick();

		if(isServer() && getGameTime() % 200 == 0)
		{
			Entity@ ent = BoxEntity();
			ent.SetPosition(Vec3f(XORRandom(255), XORRandom(255), 0));
			entities.Add(ent);
		}
	}

	void Render()
	{
		entities.Render();
	}

	void ProcessCommand( uint cmd, CBitStream@ stream )
	{
		
	}

	void SendCreate(CBitStream@ stream)
	{
		entities.SendCreateEntities(stream);
	}

	void CreateFromData(CBitStream@ stream)
	{
		entities.CreateEntities(stream);
	}

	void SendDelta(CBitStream@ stream)
	{
		entities.SendDelta(stream);
	}

	void ReadDelta(CBitStream@ stream)
	{
		entities.ReadDelta(stream);
	}

	/*Entity@ server_CreateEntity(u16 type)
	{
		if(!isServer())
		{
			Print("are you stupid? are you insane? it says server_, dont run it on client", PrintColor::RED);
			return null;
		}
		Entity@ entity = CreateEntityFromType(type);
		bool added = false;
		for(int i = 0; i < MAX_ENTITIES; i++)
		{
			if(entities[i] == null) // a free spot
			{
				@entities[i] = @entity;
				entity.id = i; // woops haha i forgor :)
				entity.just_created = true;
				entity.Init();
				added = true;
				print("entity "+entity.name+" created");
				break;
			}
		}
		if(!added)
		{
			Print("Too many entities!!!", PrintColor::RED);
			return null;
		}
		return entity;
	}

	bool server_CreateEntity(Entity@ ent)
	{
		if(!isServer())
		{
			Print("are you stupid? are you insane? it says server_, dont run it on client", PrintColor::RED);
			return false;
		}
		bool added = false;
		for(int i = 0; i < MAX_ENTITIES; i++)
		{
			if(entities[i] == null) // a free spot
			{
				@entities[i] = @ent;
				ent.id = i;
				ent.just_created = true;
				ent.Init();
				added = true;
				print("entity "+ent.name+" created");
				break;
			}
		}
		if(!added)
		{
			Print("Too many entities!!!", PrintColor::RED);
			return false;
		}
		return true;
	}*/

	Entity@ CreateEntityFromType(u16 type)
	{
		// Example
		switch(type)
		{
			case 0:
				return Entity();
			case 1:
				return BoxEntity();
			//case 2:
			//	return PlayerEntity();
		}

		return null;
	}
}

class BoxEntity : Entity
{
	BoxEntity()
	{
		super(); // dont forget!
		type = 1;
	}

	void Tick()
	{
		Vec3f pos = transform.position;
		pos.y += 5.0f;
		if(pos.y > 500.0f)
		{
			pos.y = 100.0f;
		}
		SetPosition(pos);
	}
	
	void Render()
	{
		Vec2f pos = Vec2f_lerp(Vec2f(transform.old_position.x, transform.old_position.y), Vec2f(transform.position.x, transform.position.y), render_delta);
		GUI::DrawRectangle(pos, pos+Vec2f(100,100));
	}
}

/*class Game
{
	void Init()
	{
		Random _r(Time_Local());

		// create 10 template entities
		for(int i = 0; i < 5; i++)
		{
			Entity@ ent = server_CreateEntity(1);
			ent.transform.SetPosition(Vec3f(_r.NextRanged(500)+100, _r.NextRanged(500)+100, 0.0f));
		}
	}

	void Tick()
	{
		Game::Tick();

		if(isClient())
		{
			CControls@ controls = getControls();
			if(controls != null)
			{
				if(controls.isKeyJustPressed(KEY_RBUTTON))
				{
					CBitStream stream;
					stream.write_Vec2f(controls.getMouseScreenPos());
					getRules().SendCommand(GameCommands::c_create_entity, stream, false);
				}
				
			}
		}
	}

	Entity@ CreateEntityFromType(u16 type)
	{
		switch(type)
		{
			case 0:
				return Entity();
			case 1:
				return TemplateEntity();
		}

		return null;
	}

	void ProcessCommand( uint cmd, CBitStream@ stream )
	{
		if(isServer())
		{
			switch(cmd) 
			{
				case GameCommands::c_create_entity:
				{
					TemplateEntity@ ent = TemplateEntity();
					Vec2f pos = stream.read_Vec2f();
					ent.transform.SetPosition(Vec3f(pos.x, pos.y, 0.0f));
					server_CreateEntity(ent);
				}
			}
		}
	}
}

class TemplateEntity : Entity
{
	TemplateEntity()
	{
		name = "template";
		type = 1;
	}

	void Init()
	{
		print("bomba");
	}

	void Tick()
	{
		Entity::Tick();
		//if(!isServer()) return;
		Vec3f pos = transform.position;
		pos.y += 5.0f;
		if(pos.y > 500.0f)
		{
			pos.y = 100.0f;
		}
		SetPosition(pos);
	}
	
	void Render()
	{
		Vec2f pos = Vec2f_lerp(Vec2f(transform.old_position.x, transform.old_position.y), Vec2f(transform.position.x, transform.position.y), render_delta);
		GUI::DrawRectangle(pos, pos+Vec2f(100,100));
	}
}

namespace GameCommands
{
	enum cmds
	{
		c_create_entity = 100,
	}
}*/