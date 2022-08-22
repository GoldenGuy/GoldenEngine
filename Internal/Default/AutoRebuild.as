
void onTick( CRules@ this )
{
	CControls@ c = getControls();
	if(c.isKeyJustPressed(KEY_BACK))
	{
		rebuild();
	}
}