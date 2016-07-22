class BTCondIsDodging extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().IsCurrentlyDodging();
	}
}

class BTCondIsDodgingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsDodging';
}

class BTCondIsTargetDodging extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetCombatTarget().IsCurrentlyDodging();
	}
}

class BTCondIsTargetDodgingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsTargetDodging';
}