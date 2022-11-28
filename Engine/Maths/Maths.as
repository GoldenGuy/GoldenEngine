
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

Vec3f ClosestPtPointAABB(Vec3f p, AABB b)
{
	Vec3f q;
	float v;

	v = p.x;
	if (v < b.min.x) v = b.min.x;
	else if (v > b.max.x) v = b.max.x;
	q.x = v;

	v = p.y;
	if (v < b.min.y) v = b.min.y;
	else if (v > b.max.y) v = b.max.y;
	q.y = v;

	v = p.z;
	if (v < b.min.z) v = b.min.z;
	else if (v > b.max.z) v = b.max.z;
	q.z = v;

	return q;
}

float SqDistPointAABB(Vec3f p, AABB b)
{
	float sqDist = 0.0f;
	float v;
	// For each axis count any excess distance outside box extents

	v = p.x;
	if (v < b.min.x) sqDist += (v - b.min.x) * (v - b.min.x);
	else if (v > b.max.x) sqDist += (v - b.max.x) * (v - b.max.x);

	v = p.y;
	if (v < b.min.y) sqDist += (v - b.min.y) * (v - b.min.y);
	else if (v > b.max.y) sqDist += (v - b.max.y) * (v - b.max.y);

	v = p.z;
	if (v < b.min.z) sqDist += (v - b.min.z) * (v - b.min.z);
	else if (v > b.max.z) sqDist += (v - b.max.z) * (v - b.max.z);

	return sqDist;
}

Vec3f ClosestPtPointTriangle(Vec3f p, Vec3f a, Vec3f b, Vec3f c)
{
	// Check if P in vertex region outside A
	Vec3f ab = b - a;
	Vec3f ac = c - a;
	Vec3f ap = p - a;
	float d1 = ab.Dot(ap);
	float d2 = ac.Dot(ap);

	if (d1 <= 0.0f && d2 <= 0.0f)
		return a; // barycentric coordinates (1,0,0)

	// Check if P in vertex region outside B
	Vec3f bp = p - b;
	float d3 = ab.Dot(bp);
	float d4 = ac.Dot(bp);

	if (d3 >= 0.0f && d4 <= d3)
		return b; // barycentric coordinates (0,1,0)

	// Check if P in edge region of AB, if so return projection of P onto AB
	float vc = d1*d4 - d3*d2;
	if (vc <= 0.0f && d1 >= 0.0f && d3 <= 0.0f)
	{
		float v = d1 / (d1 - d3);
		return a + ab * v; // barycentric coordinates (1-v,v,0)
	}

	// Check if P in vertex region outside C
	Vec3f cp = p - c;
	float d5 = ab.Dot(cp);
	float d6 = ac.Dot(cp);

	if (d6 >= 0.0f && d5 <= d6)
		return c; // barycentric coordinates (0,0,1)

	// Check if P in edge region of AC, if so return projection of P onto AC
	float vb = d5*d2 - d1*d6;
	if (vb <= 0.0f && d2 >= 0.0f && d6 <= 0.0f)
	{
		float w = d2 / (d2 - d6);
		return a + ac * w; // barycentric coordinates (1-w,0,w)
	}

	// Check if P in edge region of BC, if so return projection of P onto BC
	float va = d3*d6 - d5*d4;
	if (va <= 0.0f && (d4 - d3) >= 0.0f && (d5 - d6) >= 0.0f)
	{
		float w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
		return b + (c - b) * w; // barycentric coordinates (0,1-w,w)
	}

	// P inside face region. Compute Q through its barycentric coordinates (u,v,w)
	float denom = 1.0f / (va + vb + vc);
	float v = vb * denom;
	float w = vc * denom;

	return a + ab * v + ac * w; // = u*a + v*b + w*c, u = va * denom = 1.0f - v - w
}