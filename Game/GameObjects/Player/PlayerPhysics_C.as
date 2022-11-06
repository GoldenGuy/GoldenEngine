
class PlayerPhysicsComponent : PhysicsComponent
{
    PhysicsEngine@ physics;

    PlayerPhysicsComponent(PhysicsBody@ _body)
	{
		super(PhysicsComponentType::DYNAMIC, _body);
		name = "PlayerPhysicsComponent";
        hooks |= CompHooks::TICK;
	}

	void Init()
	{
		@physics = @entity.scene.physics;
	}

	void Physics(ResponseResult&out result)
	{
		const float very_close_dist = 0.0001f;

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
				Vec3f touch_point = data.start_pos + (vel * data.t);
                float long_radius = (touch_point - data.intersect_point).Length() + very_close_dist;
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
		vel.x *= 0.8f;
		vel.z *= 0.8f;

		result.needed = true;
		result.new_position = final_pos;
		result.new_velocity = vel;
	}

    void Tick()
    {
        Vec3f forward = Vec3f(0,0,1);
		Vec3f right = Vec3f(1,0,0);
        forward = entity.scene.camera.angle * forward;
		forward.y = 0;
		forward.Normalize();
		right = entity.scene.camera.angle * right;
		right.y = 0;
		right.Normalize();
        if(getControls().isKeyPressed(KEY_KEY_W))
        {
            velocity += forward*0.05f;
        }
        if(getControls().isKeyPressed(KEY_KEY_S))
        {
            velocity -= forward*0.05f;
        }
		if(getControls().isKeyPressed(KEY_KEY_D))
        {
            velocity += right*0.05f;
        }
        if(getControls().isKeyPressed(KEY_KEY_A))
        {
            velocity -= right*0.05f;
        }
		if(getControls().isKeyJustPressed(KEY_SPACE))
		{
			velocity.y = 0.12f;
		}
    }
}