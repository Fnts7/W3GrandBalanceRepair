class BTCondHasTarget extends IBehTreeTask
{
	var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		if( HasTarget() )
		{
			return true;
		}
		return false;
	}
	
	function HasTarget() : bool
	{
		if ( useCombatTarget )
			return GetCombatTarget();
		else
			return GetActionTarget();
			
		return false;
	}
}

class BTCondHasTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHasTarget';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
}