
const Vec3f Vec3f_UP = Vec3f(0, 1, 0);
const Vec3f Vec3f_ZERO = Vec3f(0, 0, 0);

class Vec3f
{
	float x;
	float y;
	float z;
	
	Vec3f()
	{
		x = 0;
		y = 0;
		z = 0;
	}
	
	Vec3f(float _x, float _y, float _z)
	{
		x = _x;
		y = _y;
		z = _z;
	}
	
	Vec3f(float num)
	{
		x = num;
		y = num;
		z = num;
	}
	
	Vec3f(Vec3f&in vec, float len)
	{
		vec.Normalize();
		if(len == 0.0f)
			print("invalid vector");
		x = len * vec.x;
		y = len * vec.y;
		z = len * vec.z;
	}
	
	Vec3f opNeg() const { return Vec3f(x, y, z) * (-1); }
	
	Vec3f opAdd(const Vec3f&in oof) const { return Vec3f(x + oof.x, y + oof.y, z + oof.z); }
	
	Vec3f opAdd(float oof) const { return Vec3f(x + oof, y + oof, z + oof); }

	void opAddAssign(const Vec3f&in oof) { x += oof.x; y += oof.y; z += oof.z; }

	void opAddAssign(float oof) { x += oof; y += oof; z += oof; }

	Vec3f opSub(const Vec3f&in oof) const { return Vec3f(x - oof.x, y - oof.y, z - oof.z); }
	
	Vec3f opSub(float oof) const { return Vec3f(x - oof, y - oof, z - oof); }

	void opSubAssign(const Vec3f&in oof) { x -= oof.x; y -= oof.y; z -= oof.z; }

	Vec3f opMul(const Vec3f&in oof) { return Vec3f(x * oof.x, y * oof.y, z * oof.z); }

	Vec3f opMul(float oof) const { return Vec3f(x * oof, y * oof, z * oof); }

	void opMulAssign(float oof) { x *= oof; y *= oof; z *= oof; }

	void opMulAssign(const Vec3f&in oof) { x *= oof.x; y *= oof.y; z *= oof.z; }

	Vec3f opDiv(const Vec3f&in oof) const { return Vec3f(x / oof.x, y / oof.y, z / oof.z); }

	Vec3f opDiv(float oof) { return Vec3f(x / oof, y / oof, z / oof); }

	void opDivAssign(float oof) { x /= oof; y /= oof; z /= oof; }

	void opDivAssign(const Vec3f&in oof) { x /= oof.x; y /= oof.y; z /= oof.z; }

	bool opEquals(const Vec3f&in oof) const { return x == oof.x && y == oof.y && z == oof.z; }

#ifdef STAGING
	void opAssign(const Vec3f &in oof){ x=oof.x;y=oof.y;z=oof.z; }
#endif
	
	Vec3f Lerp(const Vec3f&in desired, float t)
	{
		return Vec3f(x + (desired.x - x) * t, y + (desired.y - y) * t, z + (desired.z - z) * t);
	}

	void Clamp(const Vec3f&in min, const Vec3f&in max)
	{
		x = Maths::Clamp(x, min.x, max.x);
		y = Maths::Clamp(y, min.y, max.y);
		z = Maths::Clamp(z, min.z, max.z);
	}
	
	void Print()
	{
		print("x: "+x+"; y: "+y+"; z: "+z);
	}

	string ToString()
	{
		return "x: "+x+"; y: "+y+"; z: "+z;
	}

	Vec3f Cross(const Vec3f&in vec)
	{
		return Vec3f(y * vec.z - z * vec.y, z * vec.x - x * vec.z, x * vec.y - y * vec.x);
	}

	float Dot(const Vec3f&in vec)
	{
		return x * vec.x + y * vec.y + z * vec.z;
	}
	
	void Normalize()
	{
		float length = this.SquaredLength();
		if(length <= 0.00000f)
		{
			return;
		}
		length = 1.0000000f / Maths::Sqrt(length);
		x *= length;
		y *= length;
		z *= length;
	}

	Vec3f Normal()
	{
		float length = this.SquaredLength();
		if(length <= 0.00000f)
		{
			return Vec3f(0, 0, 0);
		}
		length = 1.0000000f / Maths::Sqrt(length);
		return Vec3f(x * length, y * length, z * length);
	}

	int Angle(const Vec3f&in vec)
	{
		float rads = Maths::ACos(this.Dot(vec) / (this.Length() * vec.Length()));
		int degr = rads * (180.0f / Maths::Pi);
		if(degr < 0) degr = 0;
		return degr;
	}
	
	float Length() const
	{
		return Maths::Sqrt(x*x + y*y + z*z);
	}

	float SquaredLength() const
	{
		return x*x + y*y + z*z;
	}

	void SetLength(float length)
	{
		Normalize();
		x *= length;
		y *= length;
		z *= length;
	}

	void Trim(float max_length)
	{
		float length = Maths::Sqrt(x * x + y * y + z * z);
		if (length > max_length) {
			x /= length;
			y /= length;
			z /= length;
			x *= max_length;
			y *= max_length;
			z *= max_length;
		}
	}

	float Distance(Vec3f vec)
	{
		return Maths::Sqrt(Maths::Pow(x - vec.x, 2) + Maths::Pow(y - vec.y, 2) + Maths::Pow(z - vec.z, 2));
	}

	Vec3f Rotate(Quaternion q)
	{
		Quaternion vq = q * Quaternion(x, y, z, 0) * q.Inverse();
		return Vec3f(vq.x, vq.y, vq.z);
	}

	void RotateYZ(float degr)
	{
		Vec2f new = Vec2f(y,z);
		new.RotateByDegrees(degr);
		y = new.x; z = new.y;
	}

	void RotateXZ(float degr)
	{
		Vec2f new = Vec2f(x,z);
		new.RotateByDegrees(degr);
		x = new.x; z = new.y;
	}

	string IntString()
	{
		return int(x)+", "+int(y)+", "+int(z);
	}

	string FloatString()
	{
		return x+", "+y+", "+z;
	}

	Vec3f Reflect(const Vec3f&in normal)
	{
		return this - (normal * (2.0f * this.Dot(normal)));
	}
}