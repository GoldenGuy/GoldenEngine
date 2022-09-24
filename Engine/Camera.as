
class Camera
{
    Scene@ scene;
    
    Vec3f position;
    Quaternion angle;

    Camera(Scene@ _scene)
    {
        @scene = @_scene;
        position = Vec3f();
        angle = Quaternion(Vec3f(-1, 1, 0), 12);
    }

    float[] getViewMatrix()
    {
        float[] view;
        Matrix::MakeIdentity(view);

        /*float[] temp_mat;
		Matrix::MakeIdentity(temp_mat);
		float[] another_temp_mat;
		Matrix::MakeIdentity(another_temp_mat);
		
		Matrix::SetRotationDegrees(temp_mat, 0, yaw, 0);
		Matrix::SetRotationDegrees(another_temp_mat, pitch, 0, 0);
		temp_mat = Matrix_Multiply(another_temp_mat, temp_mat);
		
		Matrix::MakeIdentity(another_temp_mat);
		Matrix::SetTranslation(another_temp_mat, -position.x, -position.y, -position.z);
		
		Matrix::Multiply(temp_mat, another_temp_mat, view);*/

        Matrix::FromQuaternion(view, angle);

        float[] temp_mat;
		Matrix::MakeIdentity(temp_mat);
        Matrix::SetTranslation(temp_mat, -position.x, -position.y, -position.z);

        Matrix::MultiplyImmediate(view, temp_mat);

        return view;
    }
}