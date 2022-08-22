
#define SERVER_ONLY

void onInit(CRules@ this)
{
	print("Server init");
	server_CreateBlob("blob");

	CFileMatcher@ component_files = CFileMatcher("Entity");
	component_files.search("Entity");
	component_files.printMatches();
}