
enum PrintColor
{
    WHT = 0xFFC6C6C6,
    GRY = 0xFF6B6B6B,
    GRN = 0xFF199600,
    RED = 0xFFB51200,
    YLW = 0xFFC6AF00,
    BLU = 0xFF004BC4
}

void S_Print(const string&in text, uint color = PrintColor::WHT)
{
    if(isServer())
        Print(text, color);
}

void Print(const string&in text, uint color = PrintColor::WHT)
{
    print(text, SColor(color));
}

const uint16[] box_ids = {
    0,1,2,0,2,3,
    4,5,6,4,6,7,
    8,9,10,8,10,11,
    12,13,14,12,14,15,
    16,17,18,16,18,19,
    20,21,22,20,22,23
};

void DrawAABB(AABB box, SColor color)
{
    Vertex[] verts = {
        // front
        Vertex(box.min.x, box.min.y, box.min.z, 0, 0, color),
        Vertex(box.min.x, box.max.y, box.min.z, 0, 1, color),
        Vertex(box.max.x, box.max.y, box.min.z, 1, 1, color),
        Vertex(box.max.x, box.min.y, box.min.z, 1, 0, color),
        // right
        Vertex(box.min.x, box.min.y, box.max.z, 0, 0, color),
        Vertex(box.min.x, box.max.y, box.max.z, 0, 1, color),
        Vertex(box.min.x, box.max.y, box.min.z, 1, 1, color),
        Vertex(box.min.x, box.min.y, box.min.z, 1, 0, color),
        // left
        Vertex(box.max.x, box.min.y, box.min.z, 0, 0, color),
        Vertex(box.max.x, box.max.y, box.min.z, 0, 1, color),
        Vertex(box.max.x, box.max.y, box.max.z, 1, 1, color),
        Vertex(box.max.x, box.min.y, box.max.z, 1, 0, color),
        // back
        Vertex(box.max.x, box.min.y, box.max.z, 0, 0, color),
        Vertex(box.max.x, box.max.y, box.max.z, 0, 1, color),
        Vertex(box.min.x, box.max.y, box.max.z, 1, 1, color),
        Vertex(box.min.x, box.min.y, box.max.z, 1, 0, color),
        // up
        Vertex(box.min.x, box.max.y, box.min.z, 0, 0, color),
        Vertex(box.min.x, box.max.y, box.max.z, 0, 1, color),
        Vertex(box.max.x, box.max.y, box.max.z, 1, 1, color),
        Vertex(box.max.x, box.max.y, box.min.z, 1, 0, color),
        // down
        Vertex(box.min.x, box.min.y, box.max.z, 0, 0, color),
        Vertex(box.min.x, box.min.y, box.min.z, 0, 1, color),
        Vertex(box.max.x, box.min.y, box.min.z, 1, 1, color),
        Vertex(box.max.x, box.min.y, box.max.z, 1, 0, color)
    };
    
    Render::RawTrianglesIndexed("frame.png", verts, box_ids);
}