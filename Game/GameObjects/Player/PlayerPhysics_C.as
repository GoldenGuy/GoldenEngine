
int precission_steps = 8;

class PlayerPhysicsComponent : PhysicsComponent
{
    PhysicsEngine@ physics;

    PlayerPhysicsComponent(PhysicsBody@ _body)
	{
		super(PhysicsComponentType::DYNAMIC, _body);
		name = "PlayerPhysicsComponent";
        hooks |= CompHooks::TICK;
		//hooks |= CompHooks::RENDER;
	}

	void Init()
	{
		@physics = @entity.scene.physics;
	}

	void Physics(ResponseResult&out result)
	{
		Vec3f pos = entity.transform.position;
		Vec3f vel = velocity;

		if(vel.Length() < 0.001f)
		{
			result.needed = false;
			return;
		}

		grounded = false;
		sloped = false;

		ComponentBodyPair@[]@ colliders = @entity.scene.physics.getNearbyColliders(@this);
		int colliders_size = colliders.size();

		CollisionData data = CollisionData(pos, vel);
		SphereBody@ our_sphere = cast<SphereBody>(body);
		for(int j = 0; j < precission_steps; j++)
		for(int j = 0; j < colliders_size; j++)
		{
			Vec3f other_pos = colliders[j].comp.entity.transform.position;
			data.final_pos -= other_pos;
			if(physics.Collide(@body, @colliders[j].body, @data))
			{
				float normal_dot = Maths::Min(1.0f, data.surface_normal.Dot(Vec3f_UP));
				//print("normal_dot: "+normal_dot); // 1 is up, 0 is a 90 degree wall, below 0 is ceilings
				if(normal_dot > 0.5f)
				{
					if(normal_dot > 0.8f)
					{
						grounded = true;
						ground_normal = data.surface_normal;
					}
					if(normal_dot < 0.9f)
						sloped = true;
				}
			}
			data.final_pos += other_pos;
		}

		result.needed = true;
		result.new_position = data.final_pos;
		result.new_velocity = data.final_pos - pos;
	}

	bool grounded = false;
	Vec3f ground_normal = Vec3f_ZERO;
	bool sloped = false;

    void Tick()
    {
        if(grounded)
		{
			Vec3f forward = entity.scene.camera.angle * Vec3f(0,0,1);
			forward.y = 0;
			forward.Normalize();
			Vec3f right = entity.scene.camera.angle * Vec3f(1,0,0);
			right.y = 0;
			right.Normalize();

			Vec3f move_acceleration = Vec3f_ZERO;

			if(getControls().isKeyPressed(KEY_KEY_W))
			{
				move_acceleration += forward;
			}
			if(getControls().isKeyPressed(KEY_KEY_S))
			{
				move_acceleration -= forward;
			}
			if(getControls().isKeyPressed(KEY_KEY_D))
			{
				move_acceleration += right;
			}
			if(getControls().isKeyPressed(KEY_KEY_A))
			{
				move_acceleration -= right;
			}

			move_acceleration *= 10.0f;

			Plane collision_plane = Plane(Vec3f_ZERO, ground_normal);
			move_acceleration += ground_normal * (collision_plane.signedDistanceTo(move_acceleration));

			move_acceleration.Normalize();
			move_acceleration *= 0.04f;

			velocity += move_acceleration;

			velocity.x *= 0.74f;
			velocity.z *= 0.74f;

			if(getControls().isKeyJustPressed(KEY_SPACE))
				velocity.y = 0.15f;
			//else
				//velocity.y = 0;
		}
		else
		{
			velocity.x *= 0.98f;
			velocity.z *= 0.98f;
		}
		if(sloped || !grounded)
			velocity.y += gravity_force.y;
    }

	/*void Render()
	{
		if(grounded)
		{
			//print("ground");
			float[] model;
			Matrix::MakeIdentity(model);
			Vec3f interpolated_position = entity.transform.old_position.Lerp(entity.transform.position, GoldEngine::render_delta);
			//Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
			Vec3f rotation = ground_normal.getSphericalCoordinateAngles();
			//rotation.Print();
			Matrix::SetRotationDegrees(model, rotation.x, rotation.y, 0.0f);
			Matrix::SetTranslation(model, interpolated_position.x, interpolated_position.y, interpolated_position.z);
			Render::SetModelTransform(model);

			RenderPrimitives::orientation_guide.RenderMeshWithMaterial();
		}
	}*/
}