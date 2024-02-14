
#include "Debug.as"
#include "Maths.as"

#include "Networking.as"

#include "Entity.as"
#include "Camera.as"

#include "Game.as" // IMPORTANT

#include "DefaultModels.as"

Game@ game = Game();

float render_delta = 0.0f;

bool localhost = false;
bool game_created = false;
bool asked = false;
//const u8 MAX_ENTITIES = 255; // for test, will increase if needed

void onInit(CRules@ this)
{
	if(isClient())
	{
		this.set_s32("render_id", -1);
	}
	if(isServer())
	{
		server_CreateBlob("blob"); // need this to avoid that "Connecting..." message bs
	}
	onReload(this);
}

void onReload(CRules@ this) // in case you use rebuild, since onInit wont run again
{
	if(isClient())
	{
		if(isServer())
		{
			Print("---LocalHost Engine Init---", PrintColor::GRN);
			localhost = true;
		}
		else
		{
			Print("---Client Engine Init---", PrintColor::GRN);
		}

		int id = this.get_s32("render_id");
		if(id != -1) Render::RemoveScript(id);
	}
	else if(isServer())
	{
		Print("---Server Engine Init---", PrintColor::GRN);
	}

	// game init
	if(isServer())
	{
		new_players.clear();
		for(int i = 0; i < getPlayersCount(); i++)
		{
			new_players.push_back(getPlayer(i).getNetworkID());
		}
		Print("[" + getGameTime() + "]" + "Game Init", PrintColor::GRN);
		game.Init();
	}
	else // if not server means not localhost too
	{
		Print("[" + getGameTime() + "]" + "Waiting for game...", PrintColor::GRY);
		game_created = false;
	}
	// end game init

	if(isClient()) // create new render script, at the end of everything to not cause null error cuz game not created yet 
	{
		int id = Render::addScript(Render::layer_background, getCurrentScriptName(), "Render", 0);
		this.set_s32("render_id", id);
	}
}

void onTick(CRules@ this)
{
	render_delta = 0.0f;

	if(isClient() && !localhost && !asked)
	{
		CPlayer@ my_player = getLocalPlayer();
		if(my_player != null)
		{
			// tell server that we are ready to start
			CBitStream stream;
			stream.write_netid(my_player.getNetworkID());
			this.SendCommand(NetCommands::c_need_game, stream, false);
			asked = true;
		}
	}

	// game tick duh
	game.Tick();

	// network update stuff
	if(isServer() && !localhost)
	{
		// send create to new ppl
		if(new_players.size() > 0)
		{
			CBitStream stream;
			game.SendCreate(stream);
			for(int i = 0; i < new_players.size(); i++)
			{
				uint16 netid = new_players[i];
				CPlayer@ player = getPlayerByNetworkId(netid);
				if(player != null)
				{
					this.SendCommand(NetCommands::s_send_game, stream, player);
					Print("Sent game to "+player.getUsername(), PrintColor::YLW);
				}
			}
			new_players.clear();
		}

		// send deltas
		CBitStream stream;
		game.SendDelta(stream);
		this.SendCommand(NetCommands::s_send_delta, stream, true);
	}
}

void Render(int id)
{
	if(game is null)
	{
		Print("Render: Game not initialized", PrintColor::RED);
	}
	else
	{
		game.Render();

		//if(Menu::getMainMenu() is null) // if we are in menu (or other checks to prevent delta time updates, todo)
			render_delta += getRenderExactDeltaTime() * getTicksASecond();
			//render_delta += getRenderApproximateCorrectionFactor();
	}
}

// disable Tab functionality
void ShowTeamMenu( CRules@ this ) {}