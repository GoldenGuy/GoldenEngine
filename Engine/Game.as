
interface Game
{
	void Init();
	void Tick();
	void Render();
	void ProcessCommand(uint cmd, CBitStream@ stream);
	void SendGame(CBitStream@ stream);
	void CreateGame(CBitStream@ stream);
	void SendUpdate(CBitStream@ stream);
	void ReadUpdate(CBitStream@ stream);
	void PlayerJoin(CPlayer@ player);
	void PlayerLeave(CPlayer@ player);
	Entity@ CreateEntityFromType(u16 type);
}