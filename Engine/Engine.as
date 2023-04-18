
#include "Maths.as"
#include "Debug.as"
#include "DefaultModels.as"
#include "Transform.as"
#include "Camera.as"
#include "EntityManager.as"
#include "RenderEngine.as"
#include "PhysicsEngine.as"
#include "Component.as"
#include "Scene.as"
#include "Game.as"

namespace GoldEngine
{
	float render_delta = 0.0f;

	ComponentRegistrator comp_register;
	
	Game@ game;
	
	void Init(Game@ _game)
	{
		Print("Init", PrintColor::GRN);
		@game = @_game;
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