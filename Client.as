
#define CLIENT_ONLY

#include "Engine.as"
#include "LevelCreator.as" // Your game class script.

void onReload(CRules@ this)
{
	GoldEngine::Init(LevelCreator()); // Your game class.

	int id = this.get_u32("render_id");
	if(id != -1) Render::RemoveScript(id);
	id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	this.set_u32("render_id", id);
}

void onInit(CRules@ this)
{
	Print("Client Engine Init", PrintColor::YLW);
	this.set_u32("render_id", -1);
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