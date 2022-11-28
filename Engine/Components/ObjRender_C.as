
class ObjRendererComponent : Component
{
    string obj_name;
    SMesh mesh;

    ObjRendererComponent(string _obj_name)
    {
        hooks = CompHooks::RENDER;
        name = "ObjRendererComponent";

        obj_name = _obj_name;
    }

    void Init()
    {
        mesh.LoadObjIntoMesh(CFileMatcher(obj_name).getFirst());
        mesh.GetMaterial().SetFlag(SMaterial::LIGHTING, false);
        mesh.GetMaterial().SetFlag(SMaterial::LIGHTING, false);
        mesh.GetMaterial().SetFlag(SMaterial::ANISOTROPIC_FILTER, false);
        mesh.GetMaterial().SetFlag(SMaterial::BILINEAR_FILTER, false);
        mesh.GetMaterial().SetFlag(SMaterial::TRILINER_FILTER, false);
    }
    
    void Render()
    {
        Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);
        
        float[] model;
		Matrix::MakeIdentity(model);
        //Matrix::SetScale(model, 0.1f, 0.1f, 0.1f);
        Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
        Render::SetModelTransform(model);
        
        //Render::RawTriangles("default.png", RenderPrimitives::sphere);
        mesh.RenderMeshWithMaterial();
    }

    void Destroy()
    {
        mesh.DropMesh();
        mesh.Clear();
    }
}