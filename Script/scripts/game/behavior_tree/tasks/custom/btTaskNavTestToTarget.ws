class CBTTaskNavTestToTarget extends IBehTreeTask
{
	var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		return Check();
	}
	function OnActivate() : EBTNodeStatus
	{
		if ( Check() )
		{
			return BTNS_Active;
		}
		else
		{
			return BTNS_Failed;
		}
	}
	function Check() : bool
	{
		var target : CNode;
		
		if ( useCombatTarget )
		{
			target = GetCombatTarget();
		}
		else
		{
			target = GetActionTarget();
		}
		
		if ( !target )
		{
			return false;
		}
		
		if( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(),target.GetWorldPosition(),((CMovingPhysicalAgentComponent)GetActor().GetMovingAgentComponent()).GetCapsuleRadius()) )
		{
			return true;
		}
		
		return false;
	}
}

class CBTTaskNavTestToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskNavTestToTarget';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
}

