
class Entity
{
	Scene@ scene;
    uint id = 0;
    string name = "none";
    u16 type;
	Transform transform;
    bool dead, net_update = false;

    Entity()
    {
        type = 0;
        transform = Transform();
    }

    void SetScene(Scene@ scene)
    {
        @scene = @scene;
    }

	void Init()
    {
        
    }

    void Tick()
    {

    }

    void Render()
    {

    }

    void SetPosition(Vec3f pos)
    {
        transform.SetPosition(pos);
        if(!isClient()) // only on server
        {
            net_update = true;
        }
    }

    void SendFullData(CBitStream@ stream)
    {
        stream.write_u32(id);
        stream.write_string(name);
        transform.Serialize(stream);
    }

    void CreateFromData(CBitStream@ stream)
    {
        id = stream.read_u32();
        name = stream.read_string();
        transform.Deserialize(stream);
    }

    void Serialize(CBitStream@ stream) // every tick
    {
        // up to you to implement
    }

    void Deserialize(CBitStream@ stream)
    {
        // up to you to implement
    }

    void Destroy()
    {
        dead = true;
    }
}