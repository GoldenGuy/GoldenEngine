
void onTick( CRules@ this )
{
	CControls@ c = getControls();
	if(c.isKeyJustPressed(KEY_BACK))
	{
		rebuild();
	}
}

void onRender( CRules@ this )
{
	//GUI::SetFont("menu");
	//GUI::DrawText("Backspace to rebuild!", Vec2f(getScreenWidth()-180, 10), SColor(255, 220, 0, 0));
}