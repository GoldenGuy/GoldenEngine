// default startup functions for autostart scripts

void RunServer()
{
	if (getNet().CreateServer())
	{
		LoadRules("CRules.cfg");
		LoadMapCycle("CMap.cfg");
		LoadNextMap();
	}
}

void ConnectLocalhost()
{
	getNet().Connect("localhost", sv_port);
}

void RunLocalhost()
{
	RunServer();
	ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
	
}