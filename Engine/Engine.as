
#include "Maths.as"
#include "DefaultModels.as"
#include "Component.as"
#include "ComponentIncludes.as"
#include "Transform.as"
#include "Camera.as"
#include "Entity.as"
#include "Scene.as"
#include "PhysicsCommon.as"
#include "Game.as"

namespace GoldEngine
{
	Game game;
	
	void Init()
	{
		game = Game();
		SaveToRules();
		game.Init();
	}

	void Tick()
	{
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