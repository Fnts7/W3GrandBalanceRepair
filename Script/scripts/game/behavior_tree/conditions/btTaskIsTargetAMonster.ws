
class CBTCondIsTargetAMonster extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = GetCombatTarget();
		if ( target.IsMonster() )
			return true;
			
		return false;
	}
};

class CBTCondIsTargetAMonsterDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetAMonster';
};