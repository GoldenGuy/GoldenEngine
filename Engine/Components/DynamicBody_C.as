
const float very_close_dist = 0.005f;

class DynamicBodyComponent : PhysicsComponent
{
    PhysicsEngine@ physics;

    DynamicBodyComponent(PhysicsBody@ _body, float _friction = 0.7f, float _bounce = 0.5f)
	{
		super(PhysicsComponentType::DYNAMIC, _body);
		name = "DynamicBodyComponent";
	}

	void Init()
	{
		@physics = @entity.scene.physics;
	}

	void Physics(ResponseResult&out result)
	{
		Vec3f pos = entity.transform.position;
		Vec3f vel = velocity;
		vel += gravity_force;

		Vec3f final_pos;

		ComponentBodyPair@[]@ colliders = @entity.scene.physics.getNearbyColliders(@this);
		int colliders_size = colliders.size();

		Vec3f dest = pos + vel;
		Plane first_plane;
		for (int i = 0; i < 3; i++)
		{
			CollisionData data = CollisionData(pos, vel);

			for(int j = 0; j < colliders_size; j++)
			{
				CollisionData _data = data;
				PhysicsComponent@ comp = @colliders[j].comp;
				if(comp.type == PhysicsComponentType::DYNAMIC)
					_data.vel -= comp.velocity;
				
				_data.start_pos -= comp.entity.transform.position;

				if(physics.Collide(@body, @colliders[j].body, @_data))
				{
					if(_data.t < data.t)
					{
						data.intersect = true;
						data.intersect_point = _data.intersect_point;
						data.t = _data.t;
					}
				}
			}

			if(!data.intersect) // no collision
			{
				pos = dest;
				break;
			}

			float dist = vel.Length() * data.t;
			float short_dist = Maths::Max(dist - very_close_dist, 0.0f);
			pos += vel.Normal() * short_dist;
			if (i == 0)
			{
				float long_radius = 1.0f + very_close_dist;
				first_plane = data.slidingPlane();
				dest -= first_plane.normal * (first_plane.signedDistanceTo(dest) - long_radius);
				vel = dest - pos;
			}
			else if (i == 1)
			{
				Plane second_plane = data.slidingPlane();
				Vec3f crease = first_plane.normal.Cross(second_plane.normal).Normal();
				float dis = (dest - pos).Dot(crease);
				vel = crease * dis;
				dest = pos + vel;
			}
		}
		final_pos = pos;

		result.needed = true;
		result.new_position = final_pos;
		result.new_velocity = vel;
	}
}