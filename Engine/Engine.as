
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
	
	Game@ game;
	
	void Init()
	{
		Print("Init", PrintColor::GRN);
		@game = @Game();
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
            	render_delta += getRenderApproximateCorrectionFactor();
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