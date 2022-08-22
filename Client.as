
#define CLIENT_ONLY

#include "Engine.as"

void onInit(CRules@ this)
{
	print("Client init");
	int id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	this.set_u32("render_id", id);
	onReload(this);
}

void onReload(CRules@ this)
{
	GoldEngine::Init();
	int id = this.get_u32("render_id");
	Render::RemoveScript(id);
	id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	this.set_u32("render_id", id);
}

void onTick(CRules@ this)
{
	GoldEngine::Tick();
}

void Render(int id)
{
	GoldEngine::Render();
}

void ShowTeamMenu( CRules@ this )
{
	
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	Menu::addContextItem(menu, "Escape", "Exit.as", "void Exit()");
	for(int i = 0; i < 20; i++) Menu::addSeparator(menu);
}