
class DynamicBodyComponent : Physical
{
    string getName() const {return "dynamic_body";}
	
	Vec3f velocity;
	float friction;
	float bounce;
    bool sleeping;
	bool grounded;
	Physical@ floor;

    DynamicBodyComponent(PhysicsScene@ _physics_scene, ColliderBody@ _body, float _friction = 0.7f, float _bounce = 0.5f)
	{
		super(_physics_scene, _body);
		friction = _friction;
		bounce = _bounce;
		velocity = Vec3f(0,0,0);
		sleeping = false;
		grounded = false;
		body_type = BodyType::DYNAMIC;
	}

	ResolutionResult Physics(Physical@[] colliders)
	{
		ResolutionResult result = ResolutionResult();

		bool do_push = false;
		Vec3f push_amount = Vec3f();

		grounded = false;
		
		Vec3f pos = entity.transform.position;
		Vec3f source_pos = pos;
		Vec3f vel = velocity;
		Vec3f new_vel = vel;
		Vec3f dest = pos + vel;
		Plane first_plane();
		float small_number = 0.001f;

		bool done = false;
		int stop = 0;

		while(!done)
		{
			stop++;
			if(stop > DYNAMIC_ITERATIONS)
			{
				done = true;
				break;
			}
			

			// also keep track of what Physical we hit, if its trigger we remove it from colliders aray for next check and do -1 to stop counter
			CollisionData data = CollisionData(pos, vel);
			for(int i = 0; i < colliders.size(); i++)
			{
				Physical@ other = colliders[i];
				CollisionData _data = data;
				_data.start_pos -= other.entity.transform.position;
				
				body.Collide(@other.body, @_data);

				if(_data.t < data.t)
				{
					data = _data;
					data.start_pos += other.entity.transform.position;
					data.intersect_point += other.entity.transform.position;
				}

				if(_data.inside)
				{
					do_push = true;
					push_amount += _data.push_out;
				}
			}

			if(vel.Length() < 0.001f)
			{
				dest = source_pos;
				new_vel = Vec3f();
				done = true;
				break;
			}

			if(data.intersect)
			{
				float dist = vel.Length() * data.t;
				float short_dist = Maths::Max(dist - small_number, 0.0f);
				source_pos = pos;
				pos += vel.Normal() * short_dist;

				//if (i == 0 || i == 1)
				{
					//float long_radius = 1.0f + small_number;
					Vec3f touch_point = source_pos + vel * data.t;
					Vec3f intersect_point = data.intersect_point;
					Vec3f plane_normal = (touch_point - intersect_point).Normal();
					first_plane = Plane(data.intersect_point, plane_normal);

					float long_radius = first_plane.signedDistanceTo(touch_point) + small_number;

					float vel_dot = vel.Normal().Dot(plane_normal);
					bool slide = false;
					if(vel_dot < -0.65f && vel.Length() >= 0.02f)
					{
						vel = vel.Reflect(plane_normal)*bounce;
						new_vel = vel.Normal()*velocity.Length()*bounce;
					}
					else
					{
						slide = true;
					}
					if(slide)
					{
						dest -= plane_normal * (first_plane.signedDistanceTo(dest) - long_radius);
						vel = dest - touch_point;
						float ground_dot = plane_normal.Dot(Vec3f_UP);
						if (ground_dot > 0.85f) // floor
						{
							if(vel_dot < -0.65f) // if we are moving down or it means that gravity vel is higher than our movement
							{
								//print("here");
								dest = touch_point;
								new_vel = Vec3f();
								grounded = true;
								done = true;
							}
							else
							{
								new_vel = vel.Normal() * velocity.Length() * friction;
								grounded = true;
							}
						}
						else
						{
							new_vel = vel.Normal() * velocity.Length();
						}
					}
				}
				/*else if (i == 1)
				{
					//print("why");
					Vec3f touch_point = source_pos + vel * data.t;
					Vec3f intersect_point = data.intersect_point;
					Vec3f plane_normal = (touch_point - intersect_point).Normal();
					Plane second_plane = Plane(data.intersect_point, plane_normal);

					Vec3f crease = first_plane.normal.Cross(second_plane.normal).Normal();
					float dis = (dest - pos).Dot(crease);
					vel = crease * dis;
					dest = pos + vel;
				}*/
			}
			else
			{
				done = true;
			}
		}

		new_vel += push_amount*0.005f;
		//new_vel += push_amount.Normal()*0.01f;

		if(!grounded)
			new_vel += physics_scene.gravity_force;

		result.needed = true;
		result.id = physics_id;
		result.new_position = dest;
		result.new_velocity = new_vel;

		return result;
	}
}