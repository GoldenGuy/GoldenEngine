
const float very_close_dist = 0.005f;

class DynamicBodyComponent : PhysicsComponent
{
    //float friction;
	//float bounce;
    //bool sleeping;
	//bool grounded;
	//Physical@ floor;
	PhysicsEngine@ physics;

    DynamicBodyComponent(PhysicsBody@ _body, float _friction = 0.7f, float _bounce = 0.5f)
	{
		super(PhysicsComponentType::DYNAMIC, _body);
		name = "DynamicBodyComponent";

		//friction = _friction;
		//bounce = _bounce;
		//velocity = Vec3f(0,0,0);
		//sleeping = false;
		//grounded = false;
	}

	void Init()
	{
		@physics = @entity.scene.physics;
	}

	void Physics(ResponseResult@ result)
	{
		//bool do_push = false;
		//Vec3f push_amount = Vec3f();

		//grounded = false;
		
		//Vec3f pos = entity.transform.position;
		//Vec3f source_pos = pos;
		//Vec3f vel = velocity;
		//Vec3f new_vel = vel;
		//Vec3f dest = pos + vel;
		//Plane first_plane();
		//float small_number = 0.001f;

		//bool done = false;
		//int stop = 0;

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
				//return dest;
				//final_pos = dest;
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
				//dest -= (plane_dist(first_plane, dest) - long_radius) * first_plane.n;
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
		//return pos;
		final_pos = pos;
		//print("2 ("+pos.x+", "+pos.y+", "+pos.z+")\n");

		result.needed = true;
		result.new_position = final_pos;
		result.new_velocity = vel;

		/*while(!done)
		{
			stop++;
			if(stop > 3)
			{
				done = true;
				break;
			}

			// also keep track of what Physical we hit, if its trigger we remove it from colliders aray for next check and do -1 to stop counter
			CollisionData data = CollisionData(pos, vel);
			AABB bounds = body.getBounds();
			bounds += pos;
			for(int i = 0; i < colliders.size(); i++)
			{
				//Physical@ other = colliders[i];
				PhysicsComponent@ other = @colliders[i].comp;
				//if(!bounds.Intersects(colliders[i].bounds))
				//	continue;
				CollisionData _data = data;
				_data.start_pos -= other.entity.transform.position;
				_data.other_vel = other.velocity;
				
				entity.scene.physics.Collide(@body, @colliders[i].body, @_data);

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
				//else if (i == 1)
				//{
				//	//print("why");
				//	Vec3f touch_point = source_pos + vel * data.t;
				//	Vec3f intersect_point = data.intersect_point;
				//	Vec3f plane_normal = (touch_point - intersect_point).Normal();
				//	Plane second_plane = Plane(data.intersect_point, plane_normal);
//
				//	Vec3f crease = first_plane.normal.Cross(second_plane.normal).Normal();
				//	float dis = (dest - pos).Dot(crease);
				//	vel = crease * dis;
				//	dest = pos + vel;
				//}
			}
			else
			{
				done = true;
			}
		}*/

		//new_vel += push_amount*0.002f;
		//new_vel += push_amount.Normal()*0.01f;

		//if(!grounded)
		//	new_vel += gravity_force;

		//result.needed = true;
		//result.id = physics_id;
		//result.new_position = dest;
		//result.new_velocity = new_vel;

		//return result;
		//entity.SetPosition(dest);
		//velocity = new_vel;
	}
}