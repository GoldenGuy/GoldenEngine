
/*#include "ComponentRegistrator.as"
#include "Component.as"

// defaults
#include "ObjRender_C.as"
#include "MeshRenderer_C.as"
#include "Move_C.as"
//#include "DynamicBody_C.as"
//#include "StaticBody_C.as"
#include "FPSCameraController_C.as"
#include "FreeFlyMovement_C.as"

// custom
#include "Components.as"

class ComponentManager
{
    Component@[] tick;
    Component@[] render;
    Component@[] physics;

    ComponentManager()
    {
        tick.clear();
        render.clear();
        physics.clear();
    }

    void AddComponent(Component@ comp)
    {
        print("  comp ["+comp.name+"]");
        if(comp.hasFlag(CompHooks::TICK))
        {
            print("    tick");
            tick.push_back(@comp);
        }
        if(comp.hasFlag(CompHooks::RENDER))
        {
            print("    render");
            render.push_back(@comp);
        }
        if(comp.hasFlag(CompHooks::PHYSICS))
        {
            print("    physics");
            physics.push_back(@comp);
        }
    }

    void Tick()
    {
        for(uint i = 0; i < tick.size(); i++)
		{
			tick[i].Tick();
		}
    }

    void Render()
    {
        for(uint i = 0; i < render.size(); i++)
		{
			render[i].Render();
		}
    }
}*/