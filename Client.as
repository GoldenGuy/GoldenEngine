
#define CLIENT_ONLY

#include "Engine.as"

void onInit(CRules@ this)
{
	print("Client init");
	this.set_u32("render_id", -1);
	onReload(this);
}

void onReload(CRules@ this)
{
	GoldEngine::Init();
	int id = this.get_u32("render_id");
	if(id != -1)
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