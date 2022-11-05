
#include "PhysicsBodies.as"
#include "PhysicsComponent.as"

class SpatialHash
{
    dictionary hash_map;

    float GRID_SIZE;

    SpatialHash(float grid)
    {
        GRID_SIZE = grid;
    }

    void Add(PhysicsComponent@ comp)
    {
        // for mesh (many triangles)
        if(comp.body.type == BodyType::MESH)
        {
            MeshBody@ mesh = cast<MeshBody>(comp.body);
            if(mesh is null)
            {
                print("mesh isnt mesh!");
                return;
            }
            TriangleBody[]@ tris = @mesh.tris;
            for(int i = 0; i < tris.size(); i++)
            {
                AABB bounds = tris[i].bounds * comp.entity.transform;
                int x_start = bounds.min.x/GRID_SIZE;
                int y_start = bounds.min.y/GRID_SIZE;
                int z_start = bounds.min.z/GRID_SIZE;
                int x_end = bounds.max.x/GRID_SIZE;
                int y_end = bounds.max.y/GRID_SIZE;
                int z_end = bounds.max.z/GRID_SIZE;

                for(int x = x_start; x <= x_end; x++)
                {
                    for(int y = y_start; y <= y_end; y++)
                    {
                        for(int z = z_start; z <= z_end; z++)
                        {
                            string hash = getHash(x, y, z);
                            if(hash_map.exists(hash))
                            {
                                ComponentBodyPair@[] bucket;
                                hash_map.get(hash, bucket);
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, bucket);
                            }
                            else
                            {
                                ComponentBodyPair@[] bucket;
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, bucket);
                            }
                        }
                    }
                }
            }
        }
        // for all the singular bodies
        else
        {
            AABB bounds = comp.getBounds();
            int x_start = bounds.min.x/GRID_SIZE;
            int y_start = bounds.min.y/GRID_SIZE;
            int z_start = bounds.min.z/GRID_SIZE;
            int x_end = bounds.max.x/GRID_SIZE;
            int y_end = bounds.max.y/GRID_SIZE;
            int z_end = bounds.max.z/GRID_SIZE;

            for(int x = x_start; x <= x_end; x++)
            {
                for(int y = y_start; y <= y_end; y++)
                {
                    for(int z = z_start; z <= z_end; z++)
                    {
                        string hash = getHash(x, y, z);
                        if(hash_map.exists(hash))
                        {
                            ComponentBodyPair@[] bucket;
                            hash_map.get(hash, bucket);
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, bucket);
                        }
                        else
                        {
                            ComponentBodyPair@[] bucket;
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, bucket);
                        }
                    }
                }
            }
        }
    }

    void getIn(AABB&in bounds, ComponentBodyPair@[]& colliders)
    {
        int x_start = bounds.min.x/GRID_SIZE;
        int y_start = bounds.min.y/GRID_SIZE;
        int z_start = bounds.min.z/GRID_SIZE;
        int x_end = bounds.max.x/GRID_SIZE;
        int y_end = bounds.max.y/GRID_SIZE;
        int z_end = bounds.max.z/GRID_SIZE;

        dictionary copy_buffer;
        for(int x = x_start; x <= x_end; x++)
        {
            for(int y = y_start; y <= y_end; y++)
            {
                for(int z = z_start; z <= z_end; z++)
                {
                    string hash = getHash(x, y, z);
                    if(hash_map.exists(hash))
                    {
                        ComponentBodyPair@[] bucket;
                        hash_map.get(hash, bucket);

                        for(int j = 0; j < bucket.size(); j++)
                        {
                            ComponentBodyPair@ pair = @bucket[j];
                            string clone_hash = pair.comp.phy_id+"_"+pair.body.bod_id;
                            if(!copy_buffer.exists(clone_hash))
                            {
                                colliders.push_back(pair);
                                copy_buffer.set(clone_hash, true);
                            }
                        }
                    }
                }
            }
        }
    }

    string getHash(int x, int y, int z)
    {
        return x+";"+y+";"+z;
    }
}

// -----------------------------------------------------------------------------------------

// common 

class ComponentBodyPair
{
    PhysicsComponent@ comp;
    PhysicsBody@ body;
    AABB bounds;

    ComponentBodyPair(PhysicsComponent@ _comp, PhysicsBody@ _body)
    {
        @comp = @_comp;
        @body = @_body;
        bounds = _body.getBounds() * _comp.entity.transform;
    }
}

class PairBucket
{
    ComponentBodyPair[] data;
    int size;
}

class CollisionData
{
	bool intersect;
    bool inside;
    Vec3f start_pos;
    Vec3f vel;
    //Vec3f other_vel;
	Vec3f intersect_point;
	Vec3f intersect_normal;
    Vec3f push_out;
	float t; // time of collision 
	//int collision_type; // 0 = triangle, 1 = point, 2 = edge

	CollisionData(Vec3f _start_pos = Vec3f(), Vec3f _velocity = Vec3f())
	{
		intersect = false;
        inside = false;
        start_pos = _start_pos;
        vel = _velocity;
        //other_vel = Vec3f_ZERO;
		intersect_point = Vec3f();
		intersect_normal = Vec3f();
        push_out = Vec3f();
		t = 1.0f;
		//collision_type = -1;
	}

    //Therefore, we can simply
    //use the unmodified intersection point and the vector pointing
    //from the unmodified intersection point to the touch point to
    //find the sliding plane...
    Plane slidingPlane()
    {
        Vec3f touch_point = start_pos + (vel * t);
        Vec3f normal = (touch_point - intersect_point).Normal();
        return Plane(intersect_point, normal);
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

// maths

void SphereTriangleCollision(CollisionData@ colPackage, Vec3f p1, Vec3f p2, Vec3f p3)
{
	// Make the Plane containing this triangle.
	Plane trianglePlane(p1, p2, p3);
	// Is triangle front-facing to the velocity vector?
	// We only check front-facing triangles
	// (your choice of course)
	if (trianglePlane.isFrontFacingTo(colPackage.vel.Normal())) // should i normalize?
    {
		// Get interval of Plane intersection:
		float t0, t1;
		bool embeddedInPlane = false;

		// Calculate the signed distance from sphere
		// position to triangle Plane
		float signedDistToTrianglePlane = trianglePlane.signedDistanceTo(colPackage.start_pos);

		// cache this as we’re going to use it a few times below:
		float normalDotVelocity = trianglePlane.normal.Dot(colPackage.vel);
		// if sphere is travelling parrallel to the Plane:
		if (normalDotVelocity == 0.0f)
        {
			if (Maths::Abs(signedDistToTrianglePlane) >= 1.0f)
            {
				// Sphere is not embedded in Plane.
				// No collision possible:
				return;
			}
			else
            {
				// sphere is embedded in Plane.
				// It intersects in the whole range [0..1]
				embeddedInPlane = true;
				t0 = 0.0f;
				t1 = 1.0f;
			}
		}
		else
        {
			// N dot D is not 0. Calculate intersection interval:
			t0 = (-1.0f - signedDistToTrianglePlane) / normalDotVelocity;
			t1 = ( 1.0f - signedDistToTrianglePlane) / normalDotVelocity;

			// Swap so t0 < t1
			if (t0 > t1)
            {
				float temp = t1;
				t1 = t0;
				t0 = temp;
			}

			// Check that at least one result is within range:
			if (t0 > 1.0f || t1 < 0.0f)
            {
				// Both t values are outside values [0,1]
				// No collision possible:
				return;
			}
			// Clamp to [0,1]
			if (t0 < 0.0f) t0 = 0.0f;
			if (t1 < 0.0f) t1 = 0.0f;
			if (t0 > 1.0f) t0 = 1.0f;
			if (t1 > 1.0f) t1 = 1.0f;
		}

		// OK, at this point we have two time values t0 and t1
		// between which the swept sphere intersects with the
		// triangle Plane. If any collision is to occur it must
		// happen within this interval.
		Vec3f collisionPoint;
		bool foundCollison = false;
		float t = 1.0f;

		// First we check for the easy case - collision inside
		// the triangle. If this happens it must be at time t0
		// as this is when the sphere rests on the front side
		// of the triangle Plane. Note, this can only happen if
		// the sphere is not embedded in the triangle Plane.
		if (!embeddedInPlane)
        {
			Vec3f PlaneIntersectionPoint = (colPackage.start_pos - trianglePlane.normal) + colPackage.vel * t0;

			if (checkPointInTriangle(PlaneIntersectionPoint, p1, p2, p3))
			{
				foundCollison = true;
				t = t0;
				collisionPoint = PlaneIntersectionPoint;
			}
		}
		// if we haven’t found a collision already we’ll have to
		// sweep sphere against points and edges of the triangle.
		// Note: A collision inside the triangle (the check above)
		// will always happen before a vertex or edge collision!
		// This is why we can skip the swept test if the above
		// gives a collision!

		if (!foundCollison)
        {
			// some commonly used terms:
			Vec3f velocity = colPackage.vel;
			Vec3f base = colPackage.start_pos;
			float velocitySquaredLength = velocity.SquaredLength();
			float a, b, c; // Params for equation
			float newT;

			// For each vertex or edge a quadratic equation have to
			// be solved. We parameterize this equation as
			// a*t^2 + b*t + c = 0 and below we calculate the
			// parameters a,b and c for each test.

			// Check against points:
			a = velocitySquaredLength;

			// P1
			b = 2.0f * (velocity.Dot(base - p1));
			c = (p1 - base).Dot(p1 - base) - 1.0f;
			if (getLowestRoot(a, b , c, t, newT))
            {
				t = newT;
				foundCollison = true;
				collisionPoint = p1;
			}

			// P2
			b = 2.0f * (velocity.Dot(base - p2));
			c = (p2 - base).Dot(p2 - base) - 1.0f;
			if (getLowestRoot(a, b, c, t, newT))
            {
				t = newT;
				foundCollison = true;
				collisionPoint = p2;
			}

			// P3
			b = 2.0f * (velocity.Dot(base - p3));
			c = (p3 - base).Dot(p3 - base) - 1.0f;
			if (getLowestRoot(a, b, c, t, newT))
            {
				t = newT;
				foundCollison = true;
				collisionPoint = p3;
			}

			// Check agains edges:

			// p1 . p2:
			Vec3f edge = p2-p1;
			Vec3f baseToVertex = p1 - base;
			float edgeSquaredLength = edge.Dot(edge);
			float edgeDotVelocity = edge.Dot(velocity);
			float edgeDotBaseToVertex = edge.Dot(baseToVertex);

			// Calculate parameters for equation
			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0f * velocity.Dot(baseToVertex)) - 2.0f * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0f - baseToVertex.Dot(baseToVertex)) + edgeDotBaseToVertex * edgeDotBaseToVertex;

			// Does the swept sphere collide against infinite edge?
			if (getLowestRoot(a,b,c, t, newT))
            {
				// Check if intersection is within line segment:
				float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
				if (f >= 0.0 && f <= 1.0)
                {
					// intersection took place within segment.
					t = newT;
					foundCollison = true;
					collisionPoint = p1 + edge * f;
				}
			}

			// p2 . p3:
			edge = p3 - p2;
			baseToVertex = p2 - base;
			edgeSquaredLength = edge.Dot(edge);
			edgeDotVelocity = edge.Dot(velocity);
			edgeDotBaseToVertex = edge.Dot(baseToVertex);

			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0f * velocity.Dot(baseToVertex)) - 2.0f * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0f - baseToVertex.Dot(baseToVertex)) + edgeDotBaseToVertex * edgeDotBaseToVertex;

			if (getLowestRoot(a, b, c, t, newT))
            {
				float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
				if (f >= 0.0f && f <= 1.0f)
                {
					t = newT;
					foundCollison = true;
					collisionPoint = p2 + edge * f;
				}
			}

			// p3 . p1:
			edge = p1 - p3;
			baseToVertex = p3 - base;
			edgeSquaredLength = edge.Dot(edge);
			edgeDotVelocity = edge.Dot(velocity);

			edgeDotBaseToVertex = edge.Dot(baseToVertex);

			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0f * velocity.Dot(baseToVertex)) - 2.0f * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0f - baseToVertex.Dot(baseToVertex)) + edgeDotBaseToVertex * edgeDotBaseToVertex;

			if (getLowestRoot(a, b, c, t, newT))
            {
				float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
				if (f >= 0.0f && f <= 1.0f)
                {
					t = newT;
					foundCollison = true;
					collisionPoint = p3 + edge * f;
				}
			}
		}
		// Set result:
		if (foundCollison)
        {
			// distance to collision: ’t’ is time of collision
			// float distToCollision = t*colPackage.vel.Length();
			// Does this triangle qualify for the closest hit?
			// it does if it’s the first hit or the closest
			if (!colPackage.intersect || t < colPackage.t)//distToCollision < colPackage.nearestDistance)
            {
				// Collision information nessesary for sliding
				//colPackage.nearestDistance = distToCollision;
                colPackage.t = t;
				colPackage.intersect_point = collisionPoint;
				colPackage.intersect = true;
			}
		}
	} // if not backface
}

void sphIntersect(CollisionData@ colPackage, float ra )
{
    Vec3f oc = colPackage.start_pos;
    Vec3f move_dir = colPackage.vel.Normal();
    float b = oc.Dot(move_dir);
    float c = oc.Dot(oc) - ra*ra;
    float h = b*b - c;
    if( h < 0.0 )  // no intersection
    {
        return;
    }
    h = Maths::Sqrt( h );
    float vel_len = colPackage.vel.Length();
    if( -b-h > vel_len || -b-h < 0 ) // too far or negative
    {
        return;
    }

    float t = (-b-h) / vel_len;

    if( t < 0 ) return;

    if (!colPackage.intersect || t < colPackage.t)
    {
        colPackage.intersect_point = oc + (move_dir * (-b-h));
        colPackage.t = t;
        //print("t: "+t);
        colPackage.intersect = true;
    }
    //return vec2( -b-h, -b+h );
}