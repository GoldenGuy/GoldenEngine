
interface Game
{
    //ComponentRegistrator comp_register; // here instead of inside main_scene, since they will be global in game
    //Scene main_scene;
    
    void Init();
    //{
        //main_scene.PreInit();
    //}

    void Tick();
    //{
        //main_scene.Tick();
    //}

    void Render();
    //{
        //main_scene.Render();
    //}
}

/*void traverse_octree_and_draw_box(AABBOctreeNode@ node)
{
    if(node.empty)
        return;

    if(node.leaf)
    {
        DrawAABB(node.box, SColor(0xFFFF00FF));
        return;
    }
    else
    {
        for(int i = 0; i < 8; i++)
        {
            traverse_octree_and_draw_box(node.children[i]);
        }
    }
}*/