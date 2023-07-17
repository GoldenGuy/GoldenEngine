
interface IGame
{
    void Init(); // happens only on server, client will only get syncs
    void Tick();
    void Render();

    // networking
    // sync whole game to new ppl
    void SendFullData(CBitStream@ stream);
    void CreateFromData(CBitStream@ stream);
    // this sends stuff every tick, after the Tick logic
    // will just loop trough all entities that need update
    void Serialize(CBitStream@ stream);
    void Deserialize(CBitStream@ stream);
}