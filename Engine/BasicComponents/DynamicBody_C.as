
class DynamicBodyComponent : Physical
{
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

		//if(!grounded)
			velocity += physics_scene.gravity_force;

		grounded = false;

		//velocity.y -= 0.002f;
		
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
			if(stop > 3)
			{
				//print("frick");
				done = true;
				break;
			}
			//print("vel.Length() "+vel.Length());
			if(vel.Length() < 0.001f)
			{
				dest = source_pos;
				new_vel = Vec3f();
				done = true;
				break;
			}
			
			CollisionData data = CollisionData(pos, vel);// = FindClosestIntersection(pos, vel);
			for(int i = 0; i < colliders.size(); i++)
			{
				//if(colliders[i].physics_id == physics_id)
				//	continue;
				
				Physical@ other = colliders[i];
				CollisionData _data = data;
				_data.start_pos -= other.entity.transform.position;
				/*if(other.body_type == BodyType::DYNAMIC)
				{
					DynamicBodyComponent@ dyn_body_a = cast<DynamicBodyComponent>(other);
					_data.start_pos -= dyn_body_a.velocity;
				}*/
				
				body.Collide(@other.body, @_data);

				if(_data.t < data.t)
				{
					//print("pogres");
					data = _data;
					data.start_pos += other.entity.transform.position;
					data.intersect_point += other.entity.transform.position;
				}
			}

            //body.Collide(@physics_scene.floor, @data);

			if(data.intersect)
			{
				if(data.inside)
				{
					//print("aaaaaaaaaaa");
					// push out
					vel = (pos - data.intersect_point) * (0.0f - data.t);
					dest = pos + vel;
					vel *= 2.0f;
					//new_vel = vel;
					//break;
					//vel = (pos - data.intersect_point) * (velocity.Length() * (1.0f - data.t));
				}
				else
				{
					float dist = vel.Length() * data.t;
					float short_dist = Maths::Max(dist - small_number, 0.0f);
					source_pos = pos;
					//pos += vel.Normal() * short_dist;

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
						if(vel_dot < -0.65f) // we should bounce
						{
							if(vel.Length() >= 0.02f) // ye we bounce
							{
								vel = vel.Reflect(plane_normal)*bounce;
								new_vel = vel.Normal()*velocity.Length()*bounce;
								//grounded = false;
							}
							else // speed is too low to bounce, slide
							{
								slide = true;
							}
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
								if(vel_dot < -0.65f) // if we are moving down
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
								//print("aaaaa");
								new_vel = vel.Normal() * velocity.Length();
								//grounded = false;
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
			}
			else
			{
				done = true;
				//pos = dest;
			}
		}
		//if(!grounded)print("a");
		result.needed = true;
		result.id = physics_id;
		result.new_position = dest;
		result.new_velocity = new_vel;

		return result;
	}
}