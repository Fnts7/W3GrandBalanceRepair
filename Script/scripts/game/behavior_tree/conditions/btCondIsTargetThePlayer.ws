/***********************************************************************/
/** 
/***********************************************************************/

class CBTCondIsTargetThePlayer extends IBehTreeTask
{
	public var useCombatTarget : bool;

	function IsAvailable() : bool
	{
		return GetTarget() == thePlayer;
	}
	
	function GetTarget() : CNode
	{
		if ( useCombatTarget )
			return GetCombatTarget();
		else
			return GetActionTarget();
	}

};

class CBTCondIsTargetThePlayerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetThePlayer';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
};