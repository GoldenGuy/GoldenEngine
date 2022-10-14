
enum PrintColor
{
    WHT = 0xFFC6C6C6,
    GRY = 0xFF6B6B6B,
    GRN = 0xFF199600,
    RED = 0xFFB51200,
    YLW = 0xFFC6AF00,
    BLU = 0xFF004BC4
}

void Print(const string&in text, uint color = PrintColor::WHT)
{
    print(text, SColor(color));
}