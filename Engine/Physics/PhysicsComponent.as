
enum PhysicsComponentType
{
    STATIC,
    DYNAMIC
}

class PhysicsComponent : Component
{
    uint phy_id;
    
    PhysicsComponentType type;
    PhysicsBody@ body;

    Vec3f velocity;

    PhysicsComponent(PhysicsComponentType _type, PhysicsBody@ _body)
    {
        hooks = CompHooks::PHYSICS;// | CompHooks::RENDER;
        name = "PhysicsComponent";
        
        type = _type;
        @body = @_body;

        /*if(body.type == BodyType::MESH)
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
        }*/

        velocity = Vec3f_ZERO;
    }

    void Physics(ResponseResult&out result) // only happens when dynamic
    {
        
    }

    AABB getBounds()
    {
        AABB aabb = body.getBounds() * entity.transform;
        return aabb;
    }

    /*void Render()
    {
        AABB box = getBounds();
        Vertex[] verts = {
            Vertex(box.min.x, box.min.y, box.min.z, 0, 0), // front
            Vertex(box.min.x, box.max.y, box.min.z, 0, 1),
            Vertex(box.max.x, box.max.y, box.min.z, 1, 1),
            Vertex(box.max.x, box.min.y, box.min.z, 1, 0),

            Vertex(box.max.x, box.min.y, box.max.z, 0, 0), // back
            Vertex(box.max.x, box.max.y, box.max.z, 0, 1),
            Vertex(box.min.x, box.max.y, box.max.z, 1, 1),
            Vertex(box.min.x, box.min.y, box.max.z, 1, 0),

            Vertex(box.min.x, box.min.y, box.max.z, 0, 0), // right
            Vertex(box.min.x, box.max.y, box.max.z, 0, 1),
            Vertex(box.min.x, box.max.y, box.min.z, 1, 1),
            Vertex(box.min.x, box.min.y, box.min.z, 1, 0),

            Vertex(box.max.x, box.min.y, box.min.z, 0, 0), // left
            Vertex(box.max.x, box.max.y, box.min.z, 0, 1),
            Vertex(box.max.x, box.max.y, box.max.z, 1, 1),
            Vertex(box.max.x, box.min.y, box.max.z, 1, 0),

            Vertex(box.min.x, box.max.y, box.min.z, 0, 0), // up
            Vertex(box.min.x, box.max.y, box.max.z, 0, 1),
            Vertex(box.max.x, box.max.y, box.max.z, 1, 1),
            Vertex(box.max.x, box.max.y, box.min.z, 1, 0),

            Vertex(box.min.x, box.min.y, box.max.z, 0, 0), // down
            Vertex(box.min.x, box.min.y, box.min.z, 0, 1),
            Vertex(box.max.x, box.min.y, box.min.z, 1, 1),
            Vertex(box.max.x, box.min.y, box.max.z, 1, 0)
        };

        float[] model;
		Matrix::MakeIdentity(model);
        Render::SetModelTransform(model);

        Render::RawQuads("frame.png", verts);
    }*/
}