
class RenderComponent : Component, IRenderable
{
    
    // cube mesh with 8 vertices
    /*Vertex[] vertices = 
    {
        Vertex(-0.5f, -0.5f, -0.5f, 0.0f, 0.0f, color_white),
        Vertex(-0.5f, 0.5f, -0.5f, 0.0f, 1.0f, color_white),
        Vertex(0.5f, 0.5f, -0.5f, 1.0f, 1.0f, color_white),
        Vertex(0.5f, -0.5f, -0.5f, 1.0f, 0.0f, color_white),
        Vertex(-0.5f, -0.5f, 0.5f, 0.0f, 0.0f, color_white),
        Vertex(-0.5f, 0.5f, 0.5f, 0.0f, 1.0f, color_white),
        Vertex(0.5f, 0.5f, 0.5f, 1.0f, 1.0f, color_white),
        Vertex(0.5f, -0.5f, 0.5f, 1.0f, 0.0f, color_white)
    };

    u16[] indices = 
    {
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        4, 5, 1, 1, 0, 4,
        6, 7, 3, 3, 2, 6,
        5, 6, 2, 2, 1, 5,
        7, 4, 0, 0, 3, 7
    };*/

    void Init()
    {
        
    }
    
    void Render()
    {
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::game.render_delta);
        
        float[] model;
		Matrix::MakeIdentity(model);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Render::SetModelTransform(model);
        
        //Render::RawTrianglesIndexed("default.png", vertices, indices);
        Render::RawTriangles("default.png", RenderPrimitives::sphere);
    }
}