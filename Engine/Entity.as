
class Entity
{
	//Scene@ scene;
    u8 id = 0;
    uint player_netid = -1;
    u16 type = 0;
    string name = "none";
	Transform transform = Transform();
    bool dead = false;
    bool net_update = false;
    bool just_created = false;

    /*void SetScene(Scene@ scene)
    {
        @scene = @scene;
    }*/

	void Init() // i actually dont know when to call this, and if its even needed
    {
        
    }

    void Tick()
    {
        transform.UpdateOld();
    }

    void Render()
    {

    }

    void SetPosition(Vec3f pos)
    {
        transform.SetPosition(pos);
        net_update = true;
    }

    void SendCreate(CBitStream@ stream)
    {
        stream.write_string(name);
        transform.SendCreate(stream);
    }

    void CreateFromData(CBitStream@ stream)
    {
        name = stream.read_string();
        transform.CreateFromData(stream);
    }

    void SendDelta(CBitStream@ stream) // every tick
    {
        transform.SendDelta(stream);
    }

    void ReadDelta(CBitStream@ stream)
    {
        transform.ReadDelta(stream);
    }

    void Destroy()
    {
        dead = true;
    }
}