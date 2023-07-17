
namespace NetCommands
{
	shared enum cmds
	{
		send_game = 0,
		update_game,
		game_event
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if(cmd == 69) // nice B)
    {
        int actual_cmd = params.read_u32();
        switch(actual_cmd)
        {
            case NetCommands::send_game:
            {
                if(isClient())
                {
                    game.CreateFromData(params);
                }
            }
            break;

            case NetCommands::update_game:
            {
                if(isClient())
                {
                    game.Deserialize(params);
                }
            }
            break;
        }
    }
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
    if(isServer() && !localhost)
    {
        CBitStream stream;
        stream.write_u32(NetCommands::send_game);
        game.SendFullData(stream);
        this.SendCommand(69, stream, player);
    }
}