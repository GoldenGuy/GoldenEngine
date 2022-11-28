
#include "PhysicsBodies.as"
#include "PhysicsComponent.as"
#include "StaticSpatialHash.as"

class CollisionData
{
	bool intersect;
    Vec3f start_pos;
    Vec3f vel;
    Vec3f final_pos;
    float distance_to_collision;
    Vec3f surface_point;
	Vec3f surface_normal;

	CollisionData(Vec3f _start_pos = Vec3f_ZERO, Vec3f _velocity = Vec3f_ZERO)
	{
		intersect = false;
        start_pos = _start_pos;
        vel = _velocity;
        final_pos = start_pos + vel;
        distance_to_collision = 0.0f;
        surface_point = Vec3f_ZERO;
		surface_normal = Vec3f_ZERO;
	}
}

class ResponseResult
{
    bool needed;
    uint id;
    Vec3f new_position;
    Vec3f new_velocity;

    ResponseResult()
    {
        needed = false;
    }
}