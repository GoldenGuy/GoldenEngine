
#define SERVER_ONLY

#include "Engine.as"

void onInit(CRules@ this)
{
	Print("Server Engine Init", PrintColor::YLW);
	server_CreateBlob("blob");

	//CFileMatcher@ component_files = CFileMatcher("Entity");
	//component_files.search("Entity");
	//component_files.printMatches();
}