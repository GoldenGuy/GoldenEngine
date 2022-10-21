
#include "PhysicsCommon.as"

class PhysicsEngine
{
    Scene@ scene;
    PhysicsComponent@[] physics_components;
    StaticSpatialHash static_spatial_hash;
    //StaticSpatialHash temp_empty_copy;
    AABBOctree dynamics_octree;

    // for static spatial partitioning
    // for dynamic (octree)

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
        static_spatial_hash = StaticSpatialHash();
        //temp_empty_copy = static_spatial_hash;
        dynamics_octree = AABBOctree(Vec3f(-256,-256,-256), 512);
    }

    void Physics()
    {
        dynamics_octree.Build(physics_components);

        for(uint i = 0; i < physics_components.size(); i++)
		{
			if(physics_components[i].remove)
            {
                physics_components.removeAt(i);
                i--;
            }

            // now her is the tricky part...
            
            else if (physics_components[i].type == PhysicsComponentType::DYNAMIC)
                physics_components[i].Physics();
		}
    }

    SHBody@[] getNearbyStatics(PhysicsComponent@ comp)
    {
        SHBody@[] output;
        AABB bounds = comp.getBounds();
        static_spatial_hash.getIn(bounds, @output);
        return output;
    }

    void AddComponent(Component@ component)
	{
        PhysicsComponent@ phy_comp = cast<PhysicsComponent>(component);
        physics_components.push_back(phy_comp);

        if(phy_comp.type == PhysicsComponentType::STATIC)
        {
            static_spatial_hash.Add(@phy_comp);
        }
    }
}