
#include "Debug.as"
#include "Maths.as"

#include "Networking.as"

#include "Game.as"
//#include "Scene.as"
#include "Entity.as"
#include "Camera.as"

#include "DefaultModels.as"


bool localhost = false;
float render_delta = 0.0f;
bool game_created = false;
bool asked = false;

void onInit(CRules@ this)
{
	if(isClient())
	{
		this.set_s32("render_id", -1);

		if(isServer())
		{
			Print("LocalHost Engine Init", PrintColor::YLW);
			localhost = true;
		}
		else
		{
			Print("Client Engine Init", PrintColor::YLW);
		}
	}
	else
	{
		Print("Server Engine Init", PrintColor::YLW);
		server_CreateBlob("blob"); // need this to avoid that "Connecting..." message bs
	}
	onReload(this);
}

void onReload(CRules@ this) // in case you use rebuild, since onInit wont run again
{
	if(isClient()) // remove old render script
	{
		int id = this.get_s32("render_id");
		if(id != -1) Render::RemoveScript(id);
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
	else
	{
		Print("[" + getGameTime() + "]" + "Waiting for game...", PrintColor::GRY);
		game_created = false;
	}
	// end game init

	if(isClient()) // create new render script
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

	// if we have new entities created previously
	/*if(isServer() && new_entities.size() > 0)
	{
		// add them to the scene, init themand send them to everyone
		for(int i = 0; i < new_entities.size(); i++)
		{
			Entity@ ent = new_entities[i];
			Print("[" + getGameTime() + "]" + "Added new entity \""+ent.name+"\"", PrintColor::GRN);
			//ent.scene.AddEntity(ent);
			ent.Init();

			if(!localhost)
			{
				CBitStream stream;
				//ent.ToData(stream);
				server_SendCommand(NetCommands::s_create_entity, stream);
			}
		}
		new_entities.clear();
	}*/

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
				}
			}
			new_players.clear();
		}

		// send deltas
		CBitStream stream;
		game.SendDelta(stream);
		this.SendCommand(NetCommands::s_send_delta, stream, true);
	}

	// network update stuff
	/*if(isServer() && game_created && !localhost)
	{
		// send game update to everyone (make separate deltas for everryone TODO)
		if(getPlayerCount() > 0)
		{
			CBitStream stream;
			//game.Serialize(stream);
			server_SendCommand(NetCommands::s_update_game, stream);
		}

		// send game create data to new players
		if(new_players.size() > 0)
		{
			Print("[" + getGameTime() + "]" + "Sending game create data to new players:", PrintColor::GRN);
			CBitStream stream;
			//game.ToData(stream);

			for(int i = 0; i < new_players.size(); i++)
			{
				CPlayer@ player = getPlayer(new_players[i]);
				if(player != null)
				{
					Print("   "+player.getUsername(), PrintColor::GRN);
					server_SendCommand(NetCommands::s_send_game, stream, player);
				}
			}

			new_players.clear();
		}
	}*/
}

void Render(int id)
{
	if(game is null)
	{
		Print("Game not initialized", PrintColor::RED);
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