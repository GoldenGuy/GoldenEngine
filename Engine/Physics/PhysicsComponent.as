
enum PhysicsComponentType
{
    STATIC,
    DYNAMIC
}

class PhysicsComponent : Component
{
    uint phy_id;
    
    //ComponentBodyPair@[]@[] buckets_occupied; // for dynamics only
    
    PhysicsComponentType type;
    PhysicsBody@ body;

    Vec3f velocity;

    PhysicsComponent(PhysicsComponentType _type, PhysicsBody@ _body)
    {
        hooks = CompHooks::PHYSICS;
        name = "PhysicsComponent";
        
        type = _type;
        @body = @_body;

        if(body.type == BodyType::MESH)
        {
            MeshBody@ mesh = cast<MeshBody>(_body);
            if(mesh is null)
            {
                print("mesh isnt mesh!");
                return;
            }
            for(int i = 0; i < mesh.tris.size(); i++)
            {
                mesh.tris[i].bod_id = i;
            }
        }

        velocity = Vec3f_ZERO;
    }

    void Physics(ResponseResult@ result) // only happens when dynamic
    {
        
    }

    AABB getBounds()
    {
        AABB aabb = body.getBounds() * entity.transform;
        return aabb;
    }
}