
class Entity
{
	u16 id = 0;
	uint player_netid = -1;
	u16 type = 0;
	string name = "none";
	//Transform transform = Transform();
	bool dead = false;
	//bool net_update = false;
	uint just_created = 0;

	Entity(){}

	void Init() // i actually dont know when to call this, and if its even needed
	{
		
	}

	void Tick()
	{
		//transform.UpdateOld();
	}

	void Render()
	{

	}

	void SetPosition(Vec3f pos)
	{
		//transform.SetPosition(pos);
		//net_update = true;
	}

	void SendEntity(CBitStream@ stream)
	{
		stream.write_string(name);
		//transform.SendCreate(stream);
	}

	void CreateEntity(CBitStream@ stream)
	{
		name = stream.read_string();
		//transform.CreateFromData(stream);
	}

	void SendUpdate(CBitStream@ stream) // every tick
	{
		//transform.SendDelta(stream);
	}

	void ReadUpdate(CBitStream@ stream)
	{
		//transform.ReadDelta(stream);
	}

	void Destroy()
	{
		dead = true;
	}

	Entity@ Copy()
	{
		return @Entity();
	}
}

class EntityManager
{
	private Entity@[] entities;
	private dictionary entity_map;

	private u16 id = 0;

	EntityManager(){}

	void Add(Entity@ entity)
	{
		if (isServer())
		{
			if(entity.id == 0)
			{
				entity.id = generateUniqueId();
				entity.just_created = getGameTime();
			}
		}
		
		if (exists(entity.id))
		{
			error("Attempted to add an entity with an existing ID: " + entity.id);
			return;
		}

		entities.push_back(entity);
		entity_map.set("" + entity.id, @entity);

		print("Added entity: " + entity.id);

		if (entity.just_created == getGameTime())
		{
			entity.Init();
		}
	}

	void Remove(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].id == id)
			{
				entities.removeAt(i);
				entity_map.delete("" + id);

				print("Removed entity: " + id);

				if (isServer())
				{
					CBitStream stream;
					stream.write_u16(id);
					getRules().SendCommand(NetCommands::s_remove_entity, stream, true);
				}

				return;
			}
		}

		error("Attempted to remove an entity that does not exist: " + id);
	}

	bool exists(u16 id)
	{
		return entity_map.exists("" + id);
	}

	Entity@ get(u16 id)
	{
		Entity@ entity;
		entity_map.get("" + id, @entity);
		return entity;
	}

	Entity@[]@ getAllEntities()
	{
		return @entities;
	}

	void Tick()
	{
		for(int i = 0; i < entities.size(); i++)
		{
			if(entities[i].dead)
			{
				Remove(entities[i].id);
				i--;
				continue;
			}
			
			entities[i].Tick();
		}
	}

	void Render()
	{
		for(int i = 0; i < entities.size(); i++)
		{
			entities[i].Render();
		}
	}

	void SendEntities(CBitStream@ stream)
	{
		stream.write_u16(entities.size());
		for(int i = 0; i < entities.size(); i++)
		{
			Entity@ ent = entities[i];
			stream.write_bool(ent.just_created == getGameTime()); // should init or not
			stream.write_u16(ent.id);
			stream.write_u16(ent.type);
			ent.SendEntity(stream);
		}
	}

	void CreateEntities(CBitStream@ stream)
	{
		u16 amount = stream.read_u16();
		for(int i = 0; i < amount; i++)
		{
			bool init = stream.read_bool();
			u16 id = stream.read_u16();
			u16 type = stream.read_u16();
			Entity@ ent = game.CreateEntityFromType(type);
			ent.just_created = init ? getGameTime() : 0;
			ent.id = id;
			ent.CreateEntity(stream);
			Add(ent);
		}
	}

	void SendUpdate(CBitStream@ stream)
	{
		stream.write_u16(entities.size());
		for(int i = 0; i < entities.size(); i++)
		{
			Entity@ ent = entities[i];

			bool create_or_update = ent.just_created == getGameTime();
			stream.write_bool(create_or_update);
			stream.write_u16(ent.id);
			
			if(create_or_update) // if just created
			{
				stream.write_u16(ent.type);
				ent.SendEntity(stream);
			}
			else// if(ent.net_update) // if it was changed
			{
				ent.SendUpdate(stream);
			}
		}
	}

	void ReadUpdate(CBitStream@ stream)
	{
		u16 amount = stream.read_u16();
		for(int i = 0; i < amount; i++)
		{
			bool create_or_update = stream.read_bool();
			u16 id = stream.read_u16();
			if(create_or_update) // if true, then create
			{
				if(this.exists(id))
				{
					Print("entity with id: "+id+" already existed, deleting it...", PrintColor::RED);
					Remove(id);
				}
				u16 type = stream.read_u16();
				Entity@ ent = game.CreateEntityFromType(type);
				ent.id = id;
				ent.just_created = getGameTime();
				ent.CreateEntity(stream);
				this.Add(ent);
			}
			else // just update then
			{
				Entity@ ent = this.get(id);
				if(ent == null)
				{
					Print("entity not found id: "+id, PrintColor::RED);
					return; //mwahahahahahah
				}
				ent.ReadUpdate(stream);
			}
		}
	}

	private u16 generateUniqueId()
	{
		// 0 is reserved for uninitialized entities
		// Does not account for ID collisions when it wraps around
		// Surely by then, older entities will no longer exist

		id = id == 65535 ? 1 : id + 1;
		return id;
	}
}

