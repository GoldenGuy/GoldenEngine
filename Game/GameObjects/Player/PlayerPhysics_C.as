
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
		/*const float very_close_dist = 0.005f;

		Vec3f pos = entity.transform.position;
		Vec3f vel = velocity;
		vel += gravity_force;
		//vel.Print();
		Vec3f orig_vel = vel;

		ComponentBodyPair@[]@ colliders = @entity.scene.physics.getNearbyColliders(@this);
		int colliders_size = colliders.size();

		int collision_depth = 0;

		Vec3f final_pos;

		while(true)
		{
			if(collision_depth > 5)
			{
				final_pos = pos;
				break;
			}
			//print("step ["+collision_depth+"]");

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
				final_pos = pos + vel;
				break;
			}

			Vec3f dest = pos + vel;
			Vec3f new_base = pos;

			float dist_to_coll = vel.Length() * data.t;
			if(dist_to_coll > very_close_dist)
			{
				Vec3f vel_normal = vel.Normal();
				//Vec3f v = vel.Normal();
				//v *= (dist_to_coll - very_close_dist);
				//new_base += v;
				new_base += vel_normal * (dist_to_coll - very_close_dist);

				//data.intersect_point -= vel_normal * 0.1f;
			}

			Plane plane = data.slidingPlane();

			Vec3f new_dest = dest - plane.normal * (plane.signedDistanceTo(dest) + very_close_dist);

			Vec3f new_vel = new_dest - data.intersect_point;
			//new_vel.Print();
			//print("new_vel.Length(): "+new_vel.Length());

			if(new_vel.Length() < very_close_dist)
			{
				final_pos = new_base;
				vel = new_vel;//Vec3f(0, -1, 0);
				//print("breaks here");
				break;
			}

			pos = new_base;
			vel = new_vel;
			collision_depth++;
		}

		result.needed = true;
		result.new_position = final_pos;
		result.new_velocity = vel.Normal() * orig_vel.Length();
		result.new_velocity.x *= 0.8f;
		result.new_velocity.z *= 0.8f;*/
		
		const float very_close_dist = 0.005f;

		Vec3f pos = entity.transform.position;
		Vec3f vel = velocity;
		vel += gravity_force;
		float orig_vel_len = vel.Length();

		Vec3f final_pos;

		ComponentBodyPair@[]@ colliders = @entity.scene.physics.getNearbyColliders(@this);
		int colliders_size = colliders.size();

		Vec3f dest = pos + vel;
		Plane first_plane;
		for (int i = 0; i < 3; i++)
		{
			float vel_len = vel.Length();
			if(vel_len < very_close_dist)
			{
				break;
			}
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
					if(_data.t <= data.t)
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

			float dist = vel_len * data.t;
			float short_dist = Maths::Max(dist - very_close_dist, 0.0f);
			pos += vel.Normal() * short_dist;
			if (i == 0)
			{
				Vec3f touch_point = pos;//data.start_pos + (vel * data.t);
                float long_radius = (touch_point - data.intersect_point).Length() + very_close_dist;
				//print("long_radius "+long_radius);
				data.intersect_point.Print();
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
		result.new_velocity = vel;//.Normal() * orig_vel_len;
		//result.new_velocity.x *= 0.8f;
		//result.new_velocity.z *= 0.8f;
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