class CBTTaskCounterDecorator extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{	
		GetNPC().SetIsCountering(true);
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetIsCountering(false);
	}
}
class CBTTaskCounterDecoratorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCounterDecorator';
}


class CBTCondIsCountering extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().IsCountering();
	}
}
class CBTCondIsCounteringDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondIsCountering';
}