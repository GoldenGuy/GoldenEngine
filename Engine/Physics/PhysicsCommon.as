
// component stuff ------------------------------------------------------------------------

enum BodyType
{
    NONE,
    POINT,
    PLANE,
    TRIANGLE,
    MESH, // should never be dynamic, sorry
    POLYGON,
    SPHERE,
    ELLIPSOID,
    AABB,
    OBB
}

enum PhysicsComponentType
{
    STATIC,
    DYNAMIC
}

class PhysicsComponent : Component
{
    uint phy_id;
    
    //AABBOctreeNode@[] nodes_occupied;
    ComponentBodyPair@[]@[] buckets_occupied; // for dynamics only
    
    PhysicsComponentType type;
    PhysicsBody@ body;

    Vec3f velocity;

    PhysicsComponent(PhysicsComponentType _type, PhysicsBody@ _body)
    {
        hooks = CompHooks::PHYSICS;
        name = "PhysicsComponent";
        
        type = _type;
        @body = @_body;

        if(body.type == BodyType::MESH)
        {
            MeshBody@ mesh = cast<MeshBody>(_body);
            if(mesh is null)
            {
                print("mesh isnt mesh!");
                return;
            }
            for(int i = 0; i < mesh.tris.size(); i++)
            {
                mesh.tris[i].bod_id = i;
            }
        }

        velocity = Vec3f_ZERO;
    }

    void Physics()// only happens when dynamic
    {
        PhysicsEngine@ phys_engine = @entity.scene.physics;
        ComponentBodyPair@[]@ colliders = @phys_engine.getNearbyColliders(@this);
        //if(colliders.size() == 0)
            entity.SetPosition(entity.transform.position + Vec3f(0,-phy_id*0.01f,0));
        //print("colliders: "+colliders.size());
        //for(int i = 0; i < colliders.size(); i++)
        {
            
        }
    }

    AABB getBounds()
    {
        AABB aabb = body.getBounds();
        aabb *= entity.transform.scale;
        aabb += entity.transform.position;
        return aabb;
    }
}

class PhysicsBody
{
    uint bod_id = 0;
    
    BodyType type;
    AABB bounds;

    AABB getBounds()
    {
        return bounds;
    }
}

class SphereBody : PhysicsBody
{
    float radius;

    SphereBody(float _radius)
    {
        radius = _radius;
        type = BodyType::SPHERE;
        bounds = AABB(Vec3f(-radius), Vec3f(radius));
    }
}

class EllipsoidBody : PhysicsBody
{
    Vec3f radius;

    EllipsoidBody(Vec3f _radius)
    {
        radius = _radius;
        type = BodyType::ELLIPSOID;
        bounds = AABB(-radius, radius);
    }
}

class TriangleBody : PhysicsBody
{
    Vec3f a;
    Vec3f b;
    Vec3f c;

    TriangleBody(Vec3f _a, Vec3f _b, Vec3f _c)
    {
        a = _a;
        b = _b;
        c = _c;
        type = BodyType::TRIANGLE;

        float x_min = Maths::Min(Maths::Min(a.x, b.x), c.x);
        float y_min = Maths::Min(Maths::Min(a.y, b.y), c.y);
        float z_min = Maths::Min(Maths::Min(a.z, b.z), c.z);

        float x_max = Maths::Max(Maths::Max(a.x, b.x), c.x);
        float y_max = Maths::Max(Maths::Max(a.y, b.y), c.y);
        float z_max = Maths::Max(Maths::Max(a.z, b.z), c.z);

        bounds = AABB(Vec3f(x_min, y_min, z_min)-Vec3f(0.1f), Vec3f(x_max, y_max, z_max)+Vec3f(0.1f));
    }
}

class MeshBody : PhysicsBody
{
    TriangleBody[] tris;

    MeshBody(Vertex[] _tris)
    {
        type = BodyType::MESH;
        int size = _tris.size();

        float x_min = 0;
        float y_min = 0;
        float z_min = 0;

        float x_max = 0;
        float y_max = 0;
        float z_max = 0;

        for(int i = 0; i < size; i += 3)
        {
            Vertex vert_a = _tris[i];
            Vertex vert_b = _tris[i+1];
            Vertex vert_c = _tris[i+2];
            tris.push_back(TriangleBody(Vec3f(vert_a.x, vert_a.y, vert_a.z), Vec3f(vert_b.x, vert_b.y, vert_b.z), Vec3f(vert_c.x, vert_c.y, vert_c.z)));

            x_min = Maths::Min(Maths::Min(Maths::Min(vert_a.x, vert_b.x), vert_c.x), x_min);
            y_min = Maths::Min(Maths::Min(Maths::Min(vert_a.y, vert_b.y), vert_c.y), y_min);
            z_min = Maths::Min(Maths::Min(Maths::Min(vert_a.z, vert_b.z), vert_c.z), z_min);
            x_max = Maths::Max(Maths::Max(Maths::Max(vert_a.x, vert_b.x), vert_c.x), x_max);
            y_max = Maths::Max(Maths::Max(Maths::Max(vert_a.y, vert_b.y), vert_c.y), y_max);
            z_max = Maths::Max(Maths::Max(Maths::Max(vert_a.z, vert_b.z), vert_c.z), z_max);
        }

        bounds = AABB(Vec3f(x_min, y_min, z_min), Vec3f(x_max, y_max, z_max));
    }
}

// -----------------------------------------------------------------------------------------

// space partitioning stuff ----------------------------------------------------------------

class SpatialHash
{
    dictionary hash_map;

    float GRID_SIZE = 4;

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
                //bounds *= comp.entity.transform.scale;
                //bounds += comp.entity.transform.position;
                int x_start = Maths::Floor(bounds.min.x/GRID_SIZE);
                int y_start = Maths::Floor(bounds.min.y/GRID_SIZE);
                int z_start = Maths::Floor(bounds.min.z/GRID_SIZE);
                int x_end = Maths::Ceil(bounds.max.x/GRID_SIZE);
                int y_end = Maths::Ceil(bounds.max.y/GRID_SIZE);
                int z_end = Maths::Ceil(bounds.max.z/GRID_SIZE);

                for(int x = x_start; x < x_end; x++)
                    for(int y = y_start; y < y_end; y++)
                        for(int z = z_start; z < z_end; z++)
                        {
                            string hash = getHash(x, y, z);
                            if(hash_map.exists(hash))
                            {
                                ComponentBodyPair@[]@ bucket;
                                hash_map.get(hash, @bucket);
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, @bucket);
                            }
                            else
                            {
                                ComponentBodyPair@[] bucket;
                                bucket.push_back(@ComponentBodyPair(@comp, @tris[i]));
                                hash_map.set(hash, @bucket);
                            }
                        }
            }
        }
        // for all the singular bodies
        else
        {
            AABB bounds = comp.getBounds();
            int x_start = Maths::Floor(bounds.min.x/GRID_SIZE);
            int y_start = Maths::Floor(bounds.min.y/GRID_SIZE);
            int z_start = Maths::Floor(bounds.min.z/GRID_SIZE);
            int x_end = Maths::Ceil(bounds.max.x/GRID_SIZE);
            int y_end = Maths::Ceil(bounds.max.y/GRID_SIZE);
            int z_end = Maths::Ceil(bounds.max.z/GRID_SIZE);

            for(int x = x_start; x < x_end; x++)
            {
                for(int y = y_start; y < y_end; y++)
                {
                    for(int z = z_start; z < z_end; z++)
                    {
                        string hash = getHash(x, y, z);
                        if(hash_map.exists(hash))
                        {
                            ComponentBodyPair@[]@ bucket;
                            hash_map.get(hash, @bucket);
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, @bucket);

                            if(comp.type == PhysicsComponentType::DYNAMIC)
                            {
                                comp.buckets_occupied.push_back(@bucket);
                            }
                        }
                        else
                        {
                            ComponentBodyPair@[] bucket;
                            bucket.push_back(@ComponentBodyPair(@comp, @comp.body));
                            hash_map.set(hash, @bucket);

                            if(comp.type == PhysicsComponentType::DYNAMIC)
                            {
                                comp.buckets_occupied.push_back(@bucket);
                            }
                        }
                    }
                }
            }
        }
    }

    void getIn(AABB bounds, ComponentBodyPair@[]@ colliders)
    {
        int x_start = Maths::Floor(bounds.min.x/GRID_SIZE);
        int y_start = Maths::Floor(bounds.min.y/GRID_SIZE);
        int z_start = Maths::Floor(bounds.min.z/GRID_SIZE);
        int x_end = Maths::Ceil(bounds.max.x/GRID_SIZE);
        int y_end = Maths::Ceil(bounds.max.y/GRID_SIZE);
        int z_end = Maths::Ceil(bounds.max.z/GRID_SIZE);

        dictionary copy_buffer;
        for(int x = x_start; x < x_end; x++)
        {
            for(int y = y_start; y < y_end; y++)
            {
                for(int z = z_start; z < z_end; z++)
                {
                    string hash = getHash(x, y, z);
                    if(hash_map.exists(hash))
                    {
                        ComponentBodyPair@[]@ bucket;
                        hash_map.get(hash, @bucket);
                        //print("bucket.size(): "+bucket.size());

                        for(int j = 0; j < bucket.size(); j++)
                        {
                            ComponentBodyPair@ pair = @bucket[j];
                            string hash = pair.comp.phy_id+"_"+pair.body.bod_id;
                            if(!copy_buffer.exists(hash))
                            {
                                colliders.push_back(pair);
                                copy_buffer.set(hash, true);
                            }
                        }
                    }
                }
            }
        }
    }

    void Clear()
    {
        hash_map.deleteAll();
    }

    string getHash(int x, int y, int z)
    {
        return x+";"+y+";"+z;
    }
}

// -----------------------------------------------------------------------------------------

// dynamics octree stuff -------------------------------------------------------------------

/*const float MIN_OCTR_SIZE = 16; //64

class AABBOctree
{
    Vec3f position;
    float size; //1024 // 4096
    
    AABBOctreeNode root_node;

    AABBOctree(Vec3f _pos, float _size)
    {
        position = _pos;
        size = _size;
        root_node = AABBOctreeNode(_pos, _size);
    }

    void Build(PhysicsComponent@[] objects)
    {
        root_node = AABBOctreeNode(position, size);

        int size = objects.size();
        for(int i = 0; i < size; i++)
        {
            PhysicsComponent@ comp = @objects[i];
            if(comp.type == PhysicsComponentType::DYNAMIC)
            {
                //comp.nodes_occupied.clear();
                root_node.Add(@comp, comp.getBounds());
            }
        }
    }
}

class AABBOctreeNode
{
    Vec3f position;
    float size;
    AABB box;
    PhysicsComponent@[] dynamics;

    AABBOctreeNode@[] children;

    int count = 0;
    bool empty = true;
    bool leaf = false;

    AABBOctreeNode(Vec3f _pos, float _size)
    {
        position = _pos;
        size = _size;
        box = AABB(position, size);
        //children.clear();
        dynamics.clear();
        count = 0;
        empty = true;

        if(_size > MIN_OCTR_SIZE)
        {
            //children.resize(8);

            float sub_size = size / 2.0f;
            Vec3f sub_pos = position + sub_size;

            array<AABBOctreeNode@> _children = {    @AABBOctreeNode(position, sub_size),
                                                    @AABBOctreeNode(Vec3f(sub_pos.x, position.y, position.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(position.x, sub_pos.y, position.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(sub_pos.x, sub_pos.y, position.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(position.x, position.y, sub_pos.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(sub_pos.x, position.y, sub_pos.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(position.x, sub_pos.y, sub_pos.z), sub_size),
                                                    @AABBOctreeNode(Vec3f(sub_pos.x, sub_pos.y, sub_pos.z), sub_size)
                                                };
            children = _children;

            leaf = false;
        }

        else
            leaf = true;
    }

    bool Add(PhysicsComponent@ comp, AABB bounds)
    {
        if(leaf)
        {
            if(box.Intersects(bounds))
            {
                dynamics.push_back(@comp);
                //comp.nodes_occupied.push_back(@this);
                empty = false;
                return true;
            }
        }
        for(int i = 0; i < 8; i++)
        {
            children[i].Add(@comp, bounds);
                //empty = false;
        }
        return false;
    }
}*/

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