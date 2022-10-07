
#include "Component.as"
// defaults
#include "Render_C.as"
#include "MeshRenderer_C.as"
//#include "Move_C.as"
//#include "DynamicBody_C.as"
//#include "StaticBody_C.as"
//#include "FPSCameraController_C.as"
//#include "FreeFlyMovement_C.as"
// custom
#include "Components.as"

class ComponentManager
{
    uint comp_id_tracker = 0;
    dictionary name_ids;

    void RegisterComponent(Component@ comp)
    {
        if(!name_ids.exists(comp.name))
        {
            name_ids.set(comp.name, comp_id_tracker++);
        }
        name_ids.get(comp.name, comp.comp_id);
    }
}