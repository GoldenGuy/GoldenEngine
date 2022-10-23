
#include "PhysicsCommon.as"

uint comp_id = 0;

class PhysicsEngine
{
    Scene@ scene;
    PhysicsComponent@[] physics_components;
    SpatialHash statics_spatial_hash;
    SpatialHash dynamics_spatial_hash;
    //SpatialHash temp_empty_copy;
    //AABBOctree dynamics_octree;
    //AABBOctree temp_empty_octree;

    // for static spatial partitioning
    // for dynamic (octree)

    PhysicsEngine(Scene@ _s)
    {
        @scene = @_s;
        statics_spatial_hash = SpatialHash(4);
        dynamics_spatial_hash = SpatialHash(4);
        //temp_empty_copy = statics_spatial_hash;
        //dynamics_octree = AABBOctree(Vec3f(-128,-128,-128), 256);
        //temp_empty_octree = dynamics_octree;
    }

    void Physics()
    {
        //dynamics_octree = temp_empty_octree;
        //dynamics_octree.Build(physics_components);
        dynamics_spatial_hash.Clear();
        for(int i = 0; i < physics_components.size(); i++)
        {
            PhysicsComponent@ comp = @physics_components[i];
            if(comp.type == PhysicsComponentType::DYNAMIC)
            {
                comp.buckets_occupied.clear();
                dynamics_spatial_hash.Add(@comp);
            }
        }

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

    /*ComponentBodyPair@[] getNearbyStatics(PhysicsComponent@ comp)
    {
        ComponentBodyPair@[] output;
        AABB bounds = comp.getBounds();
        statics_spatial_hash.getIn(bounds, @output);
        return output;
    }*/

    ComponentBodyPair@[]@ getNearbyColliders(PhysicsComponent@ comp) // only for dynamics!
    {
        dictionary copy_buffer;
        ComponentBodyPair@[] output;
        AABB bounds = comp.getBounds();
        // get the statics
        statics_spatial_hash.getIn(bounds, @output);

        // now get the dynamics
        for(int i = 0; i < comp.buckets_occupied.size(); i++)
        {
            ComponentBodyPair@[]@ pair_array = @comp.buckets_occupied[i];
            if(pair_array.size() > 0)
            {
                for(int j = 0; j < pair_array.size(); j++)
                {
                    ComponentBodyPair@ temp = @pair_array[j];
                    if(temp.comp.phy_id == comp.phy_id)
                        continue;
                    string hash = temp.comp.phy_id+"_"+temp.body.bod_id;
                    if(!copy_buffer.exists(hash))
                    {
                        output.push_back(@temp);
                    }
                }
            }
        }
        return @output;
    }

    void AddComponent(Component@ component)
	{
        PhysicsComponent@ phy_comp = cast<PhysicsComponent>(component);
        phy_comp.phy_id = comp_id++;
        physics_components.push_back(@phy_comp);

        if(phy_comp.type == PhysicsComponentType::STATIC)
        {
            statics_spatial_hash.Add(@phy_comp);
        }
    }
}