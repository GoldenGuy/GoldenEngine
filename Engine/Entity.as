
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

	void Init()
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
        stream.write_bool(true); // create or update
        stream.write_u8(id);
        stream.write_u16(type);
        stream.write_string(name);
        transform.Serialize(stream);
    }

    void CreateFromData(CBitStream@ stream)
    {
        //type = stream.read_u16(); // nope, type is read in scene, because we need to know it before we create an actual entity
        //id = stream.read_u16();
        name = stream.read_string();
        transform.Deserialize(stream);

    }

    void SendDelta(CBitStream@ stream) // every tick
    {
        stream.write_bool(false);
        stream.write_u8(id);
        transform.Serialize(stream);
    }

    void ReadDelta(CBitStream@ stream)
    {
        transform.Deserialize(stream);
    }

    void Destroy()
    {
        dead = true;
    }
}