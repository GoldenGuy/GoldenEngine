
Game@ StartGame()
{
	TestGame game = TestGame();
	return @game;
}

class TestGame : Game
{
	Camera camera;
	
	TestGame()
	{
		super();
		camera = Camera();
	}

	void Init()
	{
		// create our world
	}

	void Tick()
	{
		if(isServer() && getGameTime() % 100 == 1)
		{
			Entity@ ent = TestEntity();
			entities.Add(ent);
		}
	}

	void Render()
	{
		
	}

	void ProcessCommand( uint cmd, CBitStream@ stream )
	{

	}

	/*void SendGame(CBitStream@ stream)
	{

	}

	void CreateGame(CBitStream@ stream)
	{

	}

	void SendUpdate(CBitStream@ stream)
	{

	}

	void ReadUpdate(CBitStream@ stream)
	{

	}*/

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