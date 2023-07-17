
#include "Debug.as"
#include "Maths.as"

#include "Networking.as"

#include "Game.as"
#include "Scene.as"
#include "Entity.as"
#include "Camera.as"

#include "DefaultModels.as"


bool localhost = false;
float render_delta = 0.0f;

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
		Print("Game Init", PrintColor::GRN);
		game.Init();
	}
	else
	{
		Print("Waiting for game", PrintColor::BLU);
	}
	//getRules().set("Game", @game); // crash
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
	game.Tick();

	if(isServer() && !localhost)
	{
		CBitStream stream;
		stream.write_u32(NetCommands::update_game);
		game.Serialize(stream);
		this.SendCommand(69, stream, true);
	}
}

void Render(int id)
{
	if(game is null)
	{
		//getRules().get("Game", @game); // looks like i dont need this
		//if(game is null)
			Print("Game not initialized", PrintColor::RED);
	}
	else
	{
		game.Render();

		if(Menu::getMainMenu() is null) // if we are in menu (or other checks to prevent delta time updates, todo)
			render_delta += getRenderExactDeltaTime() * getTicksASecond();
			//render_delta += getRenderApproximateCorrectionFactor();
	}
}

// disable Tab functionality
void ShowTeamMenu( CRules@ this ) {}