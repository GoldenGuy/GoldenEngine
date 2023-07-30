
/*interface IGame
{
    void Init(); // happens only on server, client will only get syncs
    void Tick();
    void Render();

    // networking
    void ProcessCommand( uint cmd, CBitStream@ stream );
    // sync whole game to new ppl
    void ToData(CBitStream@ stream);
    void FromData(CBitStream@ stream);
    // this sends stuff every tick, after the Tick logic
    // will just loop trough all entities that need update
    void Serialize(CBitStream@ stream);
    void Deserialize(CBitStream@ stream);
}*/

const u8 MAX_ENTITIES = 255; // for test, will increase if needed

class Game
{
    Camera camera;
    Entity@[] entities(MAX_ENTITIES, null);

    // world class TODO
    // ---

    // some netvars also
    // ---
    
    void Init()
    {
        // init runs on server only, client will only get create command
        camera = Camera();
        Entity@[] _entities(MAX_ENTITIES, null);
        entities = _entities;
    }

    void Tick()
    {
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null)
                continue;
            
            if(entities[i].dead)
            {
                @entities[i] = null;
                continue;
            }

            /*if(entities[i].just_created)
            {
                //entities[i].just_created = false;
                entities[i].Init();
            }*/
            
            entities[i].Tick();
        }
    }

    void Render()
    {
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null)
                continue;

            entities[i].Render();
        }
    }

    void ProcessCommand( uint cmd, CBitStream@ stream )
    {
        
    }

    void SendCreate(CBitStream@ stream)
    {
        // only runs when new player joins, or in situations when you need to change "map"
        uint index = stream.getBitIndex();
        stream.write_u8(0);
        u8 ents = 0;
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null)
                continue;
            
            stream.write_u8(i);
            stream.write_u16(entities[i].type);
            entities[i].SendCreate(stream);
            ents++;
        }
        stream.overwrite_at_bit_u8(index, ents);
    }

    void CreateFromData(CBitStream@ stream)
    {
        u8 ents = stream.read_u8();
        for(int i = 0; i < ents; i++)
        {
            u8 id = stream.read_u8();
            u16 type = stream.read_u16();
            Entity@ ent = CreateEntityFromType(type);
            ent.CreateFromData(stream);
            @entities[id] = @ent;
        }
        game_created = true;
    }

    void SendDelta(CBitStream@ stream)
    {
        // runs every tick, send only data that is changed!!!
        // (i think for better design entities should be sent after all the net vars, so do "super" after)

        uint index = stream.getBitIndex();
        stream.write_u8(0);
        u8 ents = 0;
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null)
                continue;
            
            if(entities[i].just_created) // if just created
            {
                stream.write_bool(true); // create or update
                stream.write_u8(i);
                stream.write_u16(entities[i].type);
                entities[i].SendCreate(stream);
                entities[i].net_update = false;
                entities[i].just_created = false;
                ents++;
            }
            else if(entities[i].net_update) // if it was changed
            {
                stream.write_bool(false);
                stream.write_u8(i);
                entities[i].SendDelta(stream);
                entities[i].net_update = false;
                ents++;
            }
        }
        stream.overwrite_at_bit_u8(index, ents);
    }

    void ReadDelta(CBitStream@ stream)
    {
        u8 ents = stream.read_u8();
        for(int i = 0; i < ents; i++)
        {
            bool create_or_update = stream.read_bool();
            u8 id = stream.read_u8();
            if(create_or_update) // if true, then create
            {
                u16 type = stream.read_u16();
                Entity@ ent = CreateEntityFromType(type);
                ent.CreateFromData(stream);
                @entities[id] = @ent;
            }
            else // just update then
            {
                Entity@ ent = entities[id];
                if(ent == null)
                {
                    Print("entity not found id: "+id, PrintColor::RED);
                    return;
                }
                ent.ReadDelta(stream);
            }
        }
    }

    Entity@ server_CreateEntity(u16 type)
    {
        if(!isServer())
        {
            Print("are you stupid? are you insane? it says server_, dont run it on client", PrintColor::RED);
            return null;
        }
        Entity@ entity = CreateEntityFromType(type);
        bool added = false;
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null) // a free spot
            {
                @entities[i] = @entity;
                entity.id = i; // woops haha i forgor :)
                entity.just_created = true;
                added = true;
                print("entity "+entity.name+" created");
                break;
            }
        }
        if(!added)
        {
            Print("Too many entities!!!", PrintColor::RED);
            return null;
        }
        return entity;
    }

    bool server_CreateEntity(Entity@ ent)
    {
        if(!isServer())
        {
            Print("are you stupid? are you insane? it says server_, dont run it on client", PrintColor::RED);
            return false;
        }
        bool added = false;
        for(int i = 0; i < MAX_ENTITIES; i++)
        {
            if(entities[i] == null) // a free spot
            {
                @entities[i] = @ent;
                ent.id = i;
                ent.just_created = true;
                added = true;
                print("entity "+ent.name+" created");
                break;
            }
        }
        if(!added)
        {
            Print("Too many entities!!!", PrintColor::RED);
            return false;
        }
        return true;
    }

    Entity@ CreateEntityFromType(u16 type)
    {
        // Example
        /*switch(type)
        {
            case 0:
                return Entity();
            case MyGame::box_entity:
                return BoxEntity();
            case MyGame::player_entity:
                return PlayerEntity();
        }*/

        return null;
    }
}