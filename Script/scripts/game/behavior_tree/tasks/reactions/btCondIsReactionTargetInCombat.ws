class CBTCondIsReactionTargetInCombat extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = (CActor)GetNamedTarget('ReactionTarget');
		
		if ( !target )
			return false;
		
		return target.IsInCombat();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsReactionTargetInCombatDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsReactionTargetInCombat';
}
