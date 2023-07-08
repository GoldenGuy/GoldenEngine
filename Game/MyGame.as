#include "Engine.as"

Game@ game = MyGame();

class MyGame : Game
{
    void Init()
    {
        print("nothing yet");
    }

    void Render()
    {
        GUI::DrawRectangle(Vec2f(100,100), Vec2f(200,500));
    }
}