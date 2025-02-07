
Game@ StartGame()
{
	TestGame game = TestGame();
	return @game;
}

class TestGame : Game
{
	EntityManager entities;
	Camera camera;
	
	TestGame()
	{
		entities = EntityManager();
		camera = Camera();

		Texture::createFromFile("hiii", CFileMatcher("portrait1.png").getFirst());
	}

	void Init()
	{
		// create our world
	}

	void Tick()
	{
		/*if(isServer() && getGameTime() % 100 == 1)
		{
			Entity@ ent = TestEntity();
			entities.Add(ent);
		}*/
	}

	void Render()
	{
		ImGui::SetNextWindowPos(Vec2f(getScreenWidth() - 210,10), 1);
		ImGui::SetNextWindowSize(Vec2f(200, getScreenHeight() - 20), 1);
		if(ImGui::Begin("Entities", 2 | 4 | 32 | 64 | 256))
		{
			Entity@[]@ _entities = entities.getAllEntities();
			for(int i = 0; i < _entities.size(); i++)
			{
				ImGui::Button(_entities[i].name, Vec2f(100, 20));
				ImGui::SameLine(0.0, 0.0);
				ImGui::Button("\\/", Vec2f(20, 20));
				if(ImGui::IsItemHovered())
				{
					ImGui::Text("hi");
					ImGui::Image("hiii");
				}
				ImGui::Separator();
			}
			
			ImGui::End();
		}
	}

	void ProcessCommand( uint cmd, CBitStream@ stream )
	{

	}

	void SendGame(CBitStream@ stream)
	{
		entities.SendEntities(stream);
	}

	void CreateGame(CBitStream@ stream)
	{
		entities.CreateEntities(stream);
	}

	void SendUpdate(CBitStream@ stream)
	{
		entities.SendUpdate(stream);
	}

	void ReadUpdate(CBitStream@ stream)
	{
		entities.ReadUpdate(stream);
	}

	void PlayerJoin(CPlayer@ player)
	{
		Entity@ ent = Entity();
		ent.player_netid = player.getNetworkID();
		ent.name = player.getUsername();
		entities.Add(ent);
	}

	void PlayerLeave(CPlayer@ player)
	{
		Entity@ ent = entities.getPlayerEntity(player.getNetworkID());
		if(ent !is null)
		{
			entities.Remove(ent.id);
		}
	}

	Entity@ CreateEntityFromType(u16 type)
	{
		return TestEntity();
	}
}

class TestEntity : Entity
{
	TestEntity()
	{
		name = "frog"+getGameTime();
		Random r(name.getHash());
		CBitStream st;
		st.write_u16(12);
		u8 sym = 0;
		for(int i = 0; i < 12; i++)
		{
			sym = u8(r.NextRanged(92)+32);
			st.write_u8(sym);
		}
		st.ResetBitIndex();
		if(!st.saferead_string(name))
			Print("WHAT");
	}

	void Init()
	{
		Print("Name: "+name);
	}
}