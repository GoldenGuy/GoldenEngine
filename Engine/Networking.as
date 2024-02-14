
//const u8 GOLDENGINE_CMD = 69; // : )

namespace NetCommands
{
	shared enum cmds
	{
		// server commands
		s_send_game = 64,
		s_send_delta,
		s_remove_entity,

		// client commands
		c_need_game,
	}
}

uint16[] new_players;

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
	if(isServer())
	{
		switch(cmd)
		{
			case NetCommands::c_need_game:
			{
				uint16 netid = params.read_u16();
				//getPlayerByNetworkId(netid);
				new_players.push_back(netid);
				return;
			}
			break;
		}
	}

	if(isClient())
	{
		switch(cmd)
		{
			case NetCommands::s_send_game:
			{
				game.CreateFromData(params);
				Print("Game created", PrintColor::GRN);
				game_created = true;
				return;
			}
			break;

			case NetCommands::s_send_delta:
			{
				
				if(!game_created)
					return;
				game.ReadDelta(params);
				return;
			}
			break;

			case NetCommands::s_remove_entity:
			{
				if(!game_created)
					return;
				u16 id;
				if (!params.saferead_u16(id)) return;
				game.entities.Remove(id);
				return;
			}
			break;
		}
	}
	
	game.ProcessCommand(cmd, params);
}

class NetVar
{
	private uint edited_gametime;
	void Edited() { edited_gametime = getGameTime(); }

	void Write(CBitStream@ stream) { Print("NetVar WriteCreate not implemented", PrintColor::RED); }
	void Read(CBitStream@ stream) { Print("NetVar ReadCreate not implemented", PrintColor::RED); }
	
	bool should_write(CBitStream@ stream)
	{
		bool write = getGameTime() == edited_gametime;
		stream.write_bool(write);
		return write;
	}

	bool should_read(CBitStream@ stream)
	{
		bool read = stream.read_bool();
		return read;
	}

	void WriteDelta(CBitStream@ stream)
	{
		if(should_write(stream))
			Write(stream);
	}

	void ReadDelta(CBitStream@ stream)
	{
		if(should_read(stream))
			Read(stream);
	}
}

class net_bool : NetVar
{
	bool v;

	void opAssign(bool _value)
	{
		v = _value;
		Edited();
	}

	void Write(CBitStream@ stream)
	{
		stream.write_bool(v);
	}

	void Read(CBitStream@ stream)
	{
		v = stream.read_bool();
	}
}

class net_u32 : NetVar
{
	u32 v;

	void opAssign(u32 _value)
	{
		v = _value;
		Edited();
	}

	void Write(CBitStream@ stream)
	{
		stream.write_u32(v);
	}

	void Read(CBitStream@ stream)
	{
		v = stream.read_u32();
	}
}

class net_string : NetVar
{
	string v;

	void opAssign(string _value)
	{
		v = _value;
		Edited();
	}

	void Write(CBitStream@ stream)
	{
		stream.write_string(v);
	}

	void Read(CBitStream@ stream)
	{
		v = stream.read_string();
	}
}