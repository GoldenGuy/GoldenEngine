
class Camera
{
    //Scene@ scene;
    
    Vec3f position;
    Quaternion angle;

    Camera()//Scene@ _scene)
    {
        //@scene = @_scene;
        position = Vec3f();
        angle = Quaternion();//Vec3f(0, 0, 0), 1);
    }

    float[] getViewMatrix()
    {
        float[] view;
        Matrix::MakeIdentity(view);

        angle.getMatrixTransposed(view); // negative since we need to actually move objects away

        float[] temp_mat;
		Matrix::MakeIdentity(temp_mat);
        Matrix::SetTranslation(temp_mat, -position.x, -position.y, -position.z);

        Matrix::MultiplyImmediate(view, temp_mat);

        return view;
    }
}