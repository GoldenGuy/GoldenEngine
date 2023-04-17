
class MeshRendererComponent : Component
{
    Vertex[] vertices;
    string texture = "default.png";

    MeshRendererComponent(Vertex[] _vertices, string _tex = "default.png")
    {
        hooks = CompHooks::RENDER;
        name = "MeshRendererComponent";
        
        vertices = _vertices;
        texture = _tex;
    }

    void Render()
    {
        //print("run");
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);

        float[] model;
		Matrix::MakeIdentity(model);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Matrix::SetScale(model, entity.transform.scale.x, entity.transform.scale.y, entity.transform.scale.z);
        Render::SetModelTransform(model);

        Render::RawTriangles(texture, vertices);
    }
}

class AABBRendererComponent : Component
{
    Vertex[] vertices;

    AABBRendererComponent(AABB box)
    {
        hooks = CompHooks::RENDER;
        name = "AABBRendererComponent";
        
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
        vertices = verts;
    }

    void Render()
    {
        //print("run");
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);

        float[] model;
		Matrix::MakeIdentity(model);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Render::SetModelTransform(model);

        Render::RawQuads("default.png", vertices);
    }
}

class OOBRendererComponent : Component
{
    Vertex[] vertices;

    OOBRendererComponent(AABB box, Transform transform)
    {
        hooks = CompHooks::RENDER;
        name = "OOBRendererComponent";
        
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
        for(int i = 0; i < verts.size(); i++)
        {
            Vec3f vert = Vec3f(verts[i].x, verts[i].y, verts[i].z);
            vert *= transform.scale;
            vert = transform.rotation * vert;
            verts[i].x = vert.x;
            verts[i].y = vert.y;
            verts[i].z = vert.z;
        }
        vertices = verts;
    }

    void Render()
    {
        //print("run");
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);

        float[] model;
		Matrix::MakeIdentity(model);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Render::SetModelTransform(model);

        Render::RawQuads("default.png", vertices);
    }
}