void onInit(CBlob@ this)
{
	this.chatBubbleOffset = Vec2f(-200000,-200000);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}