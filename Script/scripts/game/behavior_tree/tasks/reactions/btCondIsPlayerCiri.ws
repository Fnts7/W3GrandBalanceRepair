class CBTCondIsPlayerCiri extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var ciriEntity  : W3ReplacerCiri;
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		
		if ( ciriEntity )
			return true;
		else
			return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsPlayerCiriDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsPlayerCiri';
}
