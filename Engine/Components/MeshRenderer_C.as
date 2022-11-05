
class MeshRendererComponent : Component
{
    Vertex[] vertices;

    MeshRendererComponent(Vertex[] _vertices)
    {
        hooks = CompHooks::RENDER;
        name = "MeshRendererComponent";
        
        vertices = _vertices;
    }

    void Render()
    {
        //print("run");
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);

        float[] model;
		Matrix::MakeIdentity(model);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Render::SetModelTransform(model);

        Render::RawTriangles("default.png", vertices);
    }
}