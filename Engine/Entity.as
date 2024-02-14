
class Entity
{
	//Scene@ scene;
	u16 id = 0;
	uint player_netid = -1;
	u16 type = 0;
	string name = "none";
	Transform transform = Transform();
	bool dead = false;
	bool net_update = false;
	bool just_created = false;

	/*void SetScene(Scene@ scene)
	{
		@scene = @scene;
	}*/

	Entity()
	{
		if(isServer()) id = generateUniqueId();
	}

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
		transform.SetPosition(pos);
		net_update = true;
	}

	void SendCreate(CBitStream@ stream)
	{
		stream.write_string(name);
		transform.SendCreate(stream);
	}

	void CreateFromData(CBitStream@ stream)
	{
		name = stream.read_string();
		transform.CreateFromData(stream);
	}

	void SendDelta(CBitStream@ stream) // every tick
	{
		transform.SendDelta(stream);
	}

	void ReadDelta(CBitStream@ stream)
	{
		transform.ReadDelta(stream);
	}

	void Destroy()
	{
		dead = true;
	}
}

class EntityManager
{
	private Entity@[] entities;
	private dictionary entity_map;

	EntityManager()
	{
		getRules().set_u16("_id", 0);
	}

	void Add(Entity@ entity)
	{
		if (exists(entity.id))
		{
			error("Attempted to add an entity with an existing ID: " + entity.id);
			return;
		}

		entity.just_created = true;

		entities.push_back(entity);
		entity_map.set("" + entity.id, @entity);

		print("Added entity: " + entity.id);
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

	void Tick()
	{
		for(int i = 0; i < entities.size(); i++)
		{
			//if(entities[i] == null)
			//	continue;
			
			if(entities[i].dead)
			{
				Remove(entities[i].id);
				i--;
				continue;
			}

			/*if(entities[i].just_created)
			{
				//entities[i].just_created = false;
				entities[i].Init();
			}*/

			entities[i].transform.UpdateOld();
			
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

	void SendCreateEntities(CBitStream@ stream)
	{
		stream.write_u16(entities.size());
		for(int i = 0; i < entities.size(); i++)
		{
			Entity@ ent = entities[i];
			stream.write_u16(ent.id);
			stream.write_u16(ent.type);
			ent.SendCreate(stream);
		}
	}

	void CreateEntities(CBitStream@ stream)
	{
		u16 amount = stream.read_u16();
		for(int i = 0; i < amount; i++)
		{
			u16 id = stream.read_u16();
			u16 type = stream.read_u16();
			Entity@ ent = game.CreateEntityFromType(type);
			ent.id = id;
			ent.CreateFromData(stream);
			Add(ent);
			//@entities[id] = @ent;
		}
	}

	void SendDelta(CBitStream@ stream)
	{
		stream.write_u16(entities.size());
		for(int i = 0; i < entities.size(); i++)
		{
			Entity@ ent = entities[i];
			
			if(ent.just_created) // if just created
			{
				stream.write_bool(true); // create
				stream.write_u16(ent.id);
				stream.write_u16(ent.type);
				ent.SendCreate(stream);
				ent.net_update = false;
				ent.just_created = false;
			}
			else if(ent.net_update) // if it was changed
			{
				stream.write_bool(false); // update
				stream.write_u16(ent.id);
				ent.SendDelta(stream);
				ent.net_update = false;
			}
		}
	}

	void ReadDelta(CBitStream@ stream)
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
				ent.CreateFromData(stream);
				this.Add(ent);
				//@entities[id] = @ent;
				// if entity is created in delta update, then that means that entity was just created
				// unlike in CreateFromData, where we dont know if it was just created or we are just joined
				ent.Init();
			}
			else // just update then
			{
				Entity@ ent = this.get(id);//entities[id];
				if(ent == null)
				{
					Print("entity not found id: "+id, PrintColor::RED);
					return; //mwahahahahahah
				}
				ent.ReadDelta(stream);
			}
		}
	}
}

shared u16 generateUniqueId()
{
	// 0 is reserved for uninitialized entities
	// Does not account for ID collisions when it wraps around
	// Surely by then, older entities will no longer exist

	u16 id = getRules().get_u16("_id");
	id = id == 65535 ? 1 : id + 1;
	getRules().set_u16("_id", id);
	return id;
}