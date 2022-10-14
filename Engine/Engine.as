
#include "Maths.as"
#include "DefaultModels.as"
#include "Transform.as"
#include "Camera.as"
#include "EntityManager.as"
#include "RenderEngine.as"
#include "PhysicsEngine.as"
#include "Component.as"
#include "Scene.as"
//#include "PhysicsCommon.as"
#include "Game.as"

namespace GoldEngine
{
	float render_delta;
	
	Game@ game;
	
	void Init()
	{
		Game newgame = Game();
		@game = @newgame;
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
			if(Menu::getMainMenu() is null)
            	render_delta += getRenderApproximateCorrectionFactor();
			game.Render();
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