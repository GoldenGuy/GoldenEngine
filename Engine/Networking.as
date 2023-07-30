
//const u8 GOLDENGINE_CMD = 69; // : )

namespace NetCommands
{
	shared enum cmds
	{
		// server commands
        s_send_game = 64,
		s_send_delta,

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
        }
    }
    
    game.ProcessCommand(cmd, params);
}

class NetVar
{
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
    
    uint edited_gametime;

    void Edited()
    {
        edited_gametime = getGameTime();
    }
}

class net_bool : NetVar
{
    bool value;

    void opAssign(bool _value)
    {
        value = _value;
        Edited();
    }

    void WriteCreate(CBitStream@ stream)
    {
        stream.write_bool(value);
    }

    void ReadCreate(CBitStream@ stream)
    {
        value = stream.read_bool();
    }

    void WriteDelta(CBitStream@ stream)
    {
        if(should_write(stream))
            stream.write_bool(value);
    }

    void ReadDelta(CBitStream@ stream)
    {
        if(should_read(stream))
            value = stream.read_bool();
    }
}

class net_u32 : NetVar
{
    u32 value;

    void opAssign(u32 _value)
    {
        value = _value;
        Edited();
    }

    void WriteCreate(CBitStream@ stream)
    {
        stream.write_u32(value);
    }

    void ReadCreate(CBitStream@ stream)
    {
        value = stream.read_u32();
    }

    void WriteDelta(CBitStream@ stream)
    {
        if(should_write(stream))
            stream.write_u32(value);
    }

    void ReadDelta(CBitStream@ stream)
    {
        if(should_read(stream))
            value = stream.read_u32();
    }
}

class net_string : NetVar
{
    string value;

    void opAssign(string _value)
    {
        value = _value;
        Edited();
    }

    void WriteCreate(CBitStream@ stream)
    {
        stream.write_string(value);
    }

    void ReadCreate(CBitStream@ stream)
    {
        value = stream.read_string();
    }

    void WriteDelta(CBitStream@ stream)
    {
        if(should_write(stream))
            stream.write_string(value);
    }

    void ReadDelta(CBitStream@ stream)
    {
        if(should_read(stream))
            value = stream.read_string();
    }
}