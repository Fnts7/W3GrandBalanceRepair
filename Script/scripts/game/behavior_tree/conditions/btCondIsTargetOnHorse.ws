class CBTCondIsTargetOnHorse extends IBehTreeTask
{
	public var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		if( useCombatTarget )
			return GetCombatTarget().IsUsingHorse();
		else
			return ((CActor)GetActionTarget()).IsUsingHorse();
		
		return false;
	}
};

class CBTCondIsTargetOnHorseDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetOnHorse';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
};