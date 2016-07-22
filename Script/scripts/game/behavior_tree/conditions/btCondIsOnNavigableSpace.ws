class CBTCondIsOnNavigableSpaceDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsOnNavigableSpace';
};

class CBTCondIsOnNavigableSpace extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var mac : CMovingAgentComponent;
		
		mac = GetNPC().GetMovingAgentComponent();
		
		if( mac.IsOnNavigableSpace() )
		{
			return true;
		}
		return false;
	}
}
