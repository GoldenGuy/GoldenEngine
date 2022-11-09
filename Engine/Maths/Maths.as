
#include "Vec3f.as"
#include "Dictionary.as"
#include "AABB.as"
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

bool equals(float a, float b, float tolerance = 0.000001f)
{
    return (a + tolerance >= b) && (a - tolerance <= b);
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

bool checkPointInTriangle(Vec3f p, Vec3f a, Vec3f b, Vec3f c)
{
	a -= p;
	b -= p;
	c -= p;

	// The point should be moved too, so they are both
	// relative, but because we don't use p in the
	// equation anymore, we don't need it!
	// p -= p;

	// Compute the normal vectors for triangles:
	// u = normal of PBC
	// v = normal of PCA
	// w = normal of PAB

	Vec3f u = b.Cross(c);
	Vec3f v = c.Cross(a);
	Vec3f w = a.Cross(b);

	// Test to see if the normals are facing 
	// the same direction, return false if not
	if (u.Dot(v) < 0.0f)
	{
		return false;
	}
	if (u.Dot(w) < 0.0f)
	{
		return false;
	}

	// All normals facing the same way, return true
	return true;
	
	/*Vec3f u, v, w, vw, vu, uw, uv;

	u = p2 - p1;
	v = p3 - p1;
	w = point - p1;

	vw = v.Cross(w);
	vu = v.Cross(u);

	if (vw.Dot(vu) < 0.0f)
	{
		return false;
	}

	uw = u.Cross(w);
	uv = u.Cross(v);

	if (uw.Dot(uv) < 0.0f)
	{
		return false;
	}

	float d = uv.Length();
	float r = vw.Length() / d;
	float t = uw.Length() / d;

	return ((r + t) <= 1.0f);*/
}

bool getLowestRoot(float a, float b, float c, float maxR, float&out root)
{
	if(a == 0)
	{
		root = (-c)/b;
	}
	
	// Check if a solution exists
	float determinant = (b * b) - (4.0f * a * c);

	// If determinant is negative it means no solutions.
	if (determinant < 0.0f) return false;

	// calculate the two roots: (if determinant == 0 then
	// x1==x2 but let’s disregard that slight optimization)
	float sqrtD = Maths::Sqrt(determinant);

	// fix divide by null
	//if(a == 0) a = 0.0000001f;

	float r1 = (-b - sqrtD) / (2.0f * a);
	float r2 = (-b + sqrtD) / (2.0f * a);

	// Sort so x1 <= x2
	if (r1 > r2)
	{
		float temp = r2;
		r2 = r1;
		r1 = temp;
	}
	// Get lowest root:
	if (r1 > 0 && r1 < maxR)
	{
		root = r1;
		return true;
	}
	// It is possible that we want x2 - this can happen
	// if x1 < 0
	if (r2 > 0 && r2 < maxR)
	{
		root = r2;
		return true;
	}
	// No (valid) solutions
	return false;
}

/*float get_lowest_root(float a, float b, float c, float max)
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
}*/