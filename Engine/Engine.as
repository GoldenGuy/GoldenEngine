
#include "Maths.as"
#include "Entity.as"
#include "Debug.as"
#include "DefaultModels.as"
#include "Camera.as"
#include "Scene.as"
#include "Game.as"

namespace GoldEngine
{
	float render_delta = 0.0f;

	bool localhost = false;
	
	void Init()
	{
		Print("Init", PrintColor::GRN);
		SaveToRules();
		game.Init();
	}

	void Tick()
	{
		render_delta = 0.0f;
		game.Tick();
	}

	void Render()
	{
		if(game is null)
		{
			getFromRules();
			if(game is null)
			{
				error("Game not initialized");
			}
		}
		else
		{
			game.Render();

			if(Menu::getMainMenu() is null)
            	//render_delta += getRenderApproximateCorrectionFactor();
				render_delta += getRenderExactDeltaTime() * getTicksASecond();
		}
	}

	void SaveToRules()
	{
		getRules().set("Game", @game);
	}

	void getFromRules()
	{
		getRules().get("Game", @game);
	}
}

void onReload(CRules@ this)
{
	GoldEngine::Init();

	if(isClient())
	{
		int id = this.get_s32("render_id");
		if(id != -1) Render::RemoveScript(id);
		id = Render::addScript(Render::layer_postworld, getCurrentScriptName(), "Render", 0);
		this.set_s32("render_id", id);
	}
}

void onInit(CRules@ this)
{
	if(isClient())
	{
		this.set_s32("render_id", -1);
		if(isServer())
		{
			Print("LocalHost Engine Init", PrintColor::YLW);
			GoldEngine::localhost = true;
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

void onTick(CRules@ this)
{
	GoldEngine::Tick();
}

void Render(int id)
{
	GoldEngine::Render();
}

void ShowTeamMenu( CRules@ this ) // overrides team menu if the hook exists
{
	
}