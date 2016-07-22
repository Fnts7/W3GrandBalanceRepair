class CBTCondIsReactionTargetInTheSameAttitudeGroup extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var reactionTargetAttitudeGroup	: name;
		var ownerAttitudeGroup			: name;
		var reactionTarget 				: CActor;
		
		reactionTarget = (CActor)GetNamedTarget('ReactionTarget');
		
		if ( !reactionTarget )
			return false;
		
		ownerAttitudeGroup = GetActor().GetAttitudeGroup();
		reactionTargetAttitudeGroup = reactionTarget.GetAttitudeGroup();
		
		return ownerAttitudeGroup == reactionTargetAttitudeGroup;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsReactionTargetInTheSameAttitudeGroupDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsReactionTargetInTheSameAttitudeGroup';
}
