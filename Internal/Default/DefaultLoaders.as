
void LoadDefaultMapLoaders()
{
	RegisterFileExtensionScript("DefaultLoaders.as", "cfg");
}

bool LoadMap( CMap@ map, const string &in fileName )
{
	map.topBorder = map.bottomBorder = map.leftBorder = map.rightBorder = false;
	map.legacyTileVariations = map.legacyTileEffects = map.legacyTileDestroy = map.legacyTileMinimap = false;
	if(!isServer())
		map.CreateTileMap(0, 0, 1.0f, "Sprites/default.png");
	else
		map.CreateTileMap(298, 105, 1.0f, "Sprites/default.png");
	
	SetScreenFlash(255, 0, 0, 0, 1.0f);
	return true;
}

// you can create minimap icon here