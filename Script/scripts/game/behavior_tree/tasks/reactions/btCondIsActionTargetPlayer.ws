class CBTCondIsActionTargetPlayer extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = (CActor)GetActionTarget();
		
		if ( !target )
			return false;
		else
			return target == thePlayer;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsActionTargetPlayerDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsActionTargetPlayer';
}
