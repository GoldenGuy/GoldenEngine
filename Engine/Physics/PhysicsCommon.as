
// component stuff ------------------------------------------------------------------------

enum BodyType
{
    NONE,
    POINT,
    PLANE,
    TRIANGLE,
    MESH,
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
    AABBOctreeNode@[] nodes_occupied;
    
    PhysicsComponentType type;
    PhysicsBody@ body;

    Vec3f velocity;

    PhysicsComponent(PhysicsComponentType _type, PhysicsBody@ _body)
    {
        hooks = CompHooks::PHYSICS;
        name = "PhysicsComponent";
        
        type = _type;
        @body = @_body;

        velocity = Vec3f_ZERO;
    }

    void Physics()// only happens when dynamic
    {
        PhysicsEngine@ phys_engine = @entity.scene.physics;
        SHBody@[] statics = phys_engine.getNearbyStatics(@this);
        for(int i = 0; i < statics.size(); i++)
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

        bounds = AABB(Vec3f(x_min, y_min, z_min), Vec3f(x_max, y_max, z_max));
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

// statics space partitioning stuff --------------------------------------------------------

const float SH_GRID_SIZE = 4;

class StaticSpatialHash
{
    dictionary hash_map;

    StaticSpatialHash()
    {

    }

    void Add(PhysicsComponent@ comp)
    {
        // for mesh (many triangles)
        if(comp.body.type == BodyType::MESH)
        {
            MeshBody@ mesh = cast<MeshBody>(comp.body);
            if(mesh is null)
            {
                print("hmm");
                return;
            }
            TriangleBody[]@ tris = @mesh.tris;
            for(int i = 0; i < tris.size(); i++)
            {
                AABB bounds = tris[i].bounds;
                bounds *= comp.entity.transform.scale;
                bounds += comp.entity.transform.position;
                int x_start = bounds.min.x/SH_GRID_SIZE;
                int y_start = bounds.min.y/SH_GRID_SIZE;
                int z_start = bounds.min.z/SH_GRID_SIZE;
                int x_end = bounds.max.x/SH_GRID_SIZE;
                int y_end = bounds.max.y/SH_GRID_SIZE;
                int z_end = bounds.max.z/SH_GRID_SIZE;

                for(int x = x_start; x < x_end; x++)
                    for(int y = y_start; y < y_end; y++)
                        for(int z = z_start; z < z_end; z++)
                        {
                            string hash = getHash(x, y, z);
                            if(hash_map.exists(hash))
                            {
                                SHBody[]@ bucket;
                                hash_map.get(hash, @bucket);
                                bucket.push_back(SHBody(@comp, @tris[i]));
                                hash_map.set(hash, @bucket);
                            }
                            else
                            {
                                SHBody[] bucket;
                                bucket.push_back(SHBody(@comp, @tris[i]));
                                hash_map.set(hash, @bucket);
                            }
                        }
            }
        }
        // for all the singular bodies
        else
        {
            AABB bounds = comp.getBounds();
            int x_start = bounds.min.x/SH_GRID_SIZE;
            int y_start = bounds.min.y/SH_GRID_SIZE;
            int z_start = bounds.min.z/SH_GRID_SIZE;
            int x_end = bounds.max.x/SH_GRID_SIZE;
            int y_end = bounds.max.y/SH_GRID_SIZE;
            int z_end = bounds.max.z/SH_GRID_SIZE;

            for(int x = x_start; x < x_end; x++)
                for(int y = y_start; y < y_end; y++)
                    for(int z = z_start; z < z_end; z++)
                    {
                        string hash = getHash(x, y, z);
                        if(hash_map.exists(hash))
                        {
                            SHBody[]@ bucket;
                            hash_map.get(hash, @bucket);
                            bucket.push_back(SHBody(@comp, @comp.body));
                            hash_map.set(hash, @bucket);
                        }
                        else
                        {
                            SHBody[] bucket;
                            bucket.push_back(SHBody(@comp, @comp.body));
                            hash_map.set(hash, @bucket);
                        }
                    }
        }
    }

    void getIn(AABB bounds, SHBody@[]@ colliders)
    {
        int x_start = bounds.min.x/SH_GRID_SIZE;
        int y_start = bounds.min.y/SH_GRID_SIZE;
        int z_start = bounds.min.z/SH_GRID_SIZE;
        int x_end = bounds.max.x/SH_GRID_SIZE;
        int y_end = bounds.max.y/SH_GRID_SIZE;
        int z_end = bounds.max.z/SH_GRID_SIZE;

        for(int x = x_start; x < x_end; x++)
            for(int y = y_start; y < y_end; y++)
                for(int z = z_start; z < z_end; z++)
                {
                    string hash = getHash(x, y, z);
                    SHBody[]@ bucket;
                    hash_map.get(hash, @bucket);

                    for(int i = 0; i < bucket.size(); i++)
                        colliders.push_back(@bucket[i]);
                }
    }

    string getHash(int x, int y, int z)
    {
        return x+";"+y+";"+z;
    }
}

class SHBody
{
    PhysicsComponent@ comp;
    PhysicsBody@ body;
    AABB bounds;

    SHBody(PhysicsComponent@ _comp, PhysicsBody@ _body)
    {
        @comp = @_comp;
        @body = @_body;
        bounds = comp.getBounds();
    }
}

// -----------------------------------------------------------------------------------------

// dynamics octree stuff -------------------------------------------------------------------

const float MIN_OCTR_SIZE = 16; //64

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
                comp.nodes_occupied.clear();
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
                comp.nodes_occupied.push_back(@this);
                empty = false;
                return true;
            }
        }
        for(int i = 0; i < 8; i++)
        {
            if(children[i].Add(@comp, bounds))
                empty = false;
        }
        return false;
    }
}

// -----------------------------------------------------------------------------------------