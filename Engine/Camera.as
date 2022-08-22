
class Camera
{
    Scene@ scene;
    
    Vec3f position;
    float pitch, yaw;

    Camera(Scene@ _scene)
    {
        @scene = @_scene;
        position = Vec3f();
        pitch = 0;
        yaw = 0;
    }

    float[] getViewMatrix()
    {
        float[] view;
        Matrix::MakeIdentity(view);

        float[] temp_mat;
		Matrix::MakeIdentity(temp_mat);
		float[] another_temp_mat;
		Matrix::MakeIdentity(another_temp_mat);
		
		Matrix::SetRotationDegrees(temp_mat, 0, yaw, 0);
		Matrix::SetRotationDegrees(another_temp_mat, pitch, 0, 0);
		temp_mat = Matrix_Multiply(another_temp_mat, temp_mat);
		
		Matrix::MakeIdentity(another_temp_mat);
		Matrix::SetTranslation(another_temp_mat, -position.x, -position.y, -position.z);
		
		Matrix::Multiply(temp_mat, another_temp_mat, view);

        return view;
    }
}