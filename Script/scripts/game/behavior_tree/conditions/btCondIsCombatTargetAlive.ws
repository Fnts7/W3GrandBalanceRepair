/***********************************************************************/
/** 
/***********************************************************************/

class CBTCondIsCombatTargetAlive extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if( GetCombatTarget() )
		{
			return GetCombatTarget().IsAlive();
		}
		return false;
	}
};


class CBTCondIsCombatTargetAliveDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsCombatTargetAlive';
};


















