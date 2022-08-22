
#include "Vec3f.as"
#include "Quaternion.as"
#include "Plane.as"

float dtr(float deg)
{
	return deg * Maths::Pi / 180.0f;
}

float rtd(float rad)
{
	return rad * 180.0f / Maths::Pi;
}

float sin(float deg)
{
	return Maths::Sin(dtr(deg));
}

float cos(float deg)
{
	return Maths::Cos(dtr(deg));
}

float[] Matrix_Multiply(const float[]&in first, const float[]&in second) // inbuilt function is retarded
{
	float[] new(16);
	for(int i = 0; i < 4; i++)
		for(int j = 0; j < 4; j++)
			for(int k = 0; k < 4; k++)
				new[i+j*4] += first[i+k*4] * second[j+k*4];
	return new;
}

namespace Matrix
{
	void MakeLookAt(float[]&inout a, Vec3f position, Vec3f target, Vec3f upVector)
	{
		Matrix::MakeIdentity(a);
		Vec3f zaxis = position - target;
		zaxis.Normalize();

		Vec3f xaxis = upVector.Cross(zaxis);
		xaxis.Normalize();

		Vec3f yaxis = zaxis.Cross(xaxis);

		a[0] = xaxis.x;
		a[1] = yaxis.x;
		a[2] = zaxis.x;
		a[3] = 0;

		a[4] = xaxis.y;
		a[5] = yaxis.y;
		a[6] = zaxis.y;
		a[7] = 0;

		a[8] = xaxis.z;
		a[9] = yaxis.z;
		a[10] = zaxis.z;
		a[11] = 0;

		a[12] = -xaxis.Dot(position);
		a[13] = -yaxis.Dot(position);
		a[14] = -zaxis.Dot(position);
		a[15] = 1;
	}
}

float get_lowest_root(float a, float b, float c, float max)
{
	float determinant = b*b - 4.0*a*c;

    // if negative there is no solution
    if (determinant < 0.0) {
        return -1.0f;
    }

    // calculate two roots
    float sqrtD = Maths::Sqrt(determinant);
    float r1 = (-b - sqrtD) / (2.0f*a);
    float r2 = (-b + sqrtD) / (2.0f*a);

    // set x1 <= x2
    if (r1 > r2) {
        float temp = r2;
        r2 = r1;
        r1 = temp;
    }

    // get lowest root
    if (r1 > 0.0f && r1 < max) {
        return r1;
    }

    if (r2 > 0.0f && r2 < max) {
        return r2;
    }

    // no solutions
    return -1.0f;
}

class Triangle
{
	Vec3f a, b, c;

	Triangle(Vec3f _a, Vec3f _b, Vec3f _c)
	{
		a = _a;
		b = _b;
		c = _c;
	}
}