class BTCondIsGuarded extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().IsGuarded();
	}
}

class BTCondIsGuardedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsGuarded';
}

class BTCondIsTargetGuarded extends IBehTreeTask
{
	public var longerThan 			: float;
	public var timeStamp  			: float;
	public var guardedRegistered 	: bool;
	
	function IsAvailable() : bool
	{
		if ( longerThan > 0 )
		{
			if ( GetCombatTarget().IsGuarded() )
			{
				if ( !guardedRegistered )
				{
					guardedRegistered = true;
					timeStamp = GetLocalTime();
				}
				if ( GetLocalTime() > timeStamp + longerThan )
				{
					return true;
				}
			}
			else
			{
				guardedRegistered = false;
			}
		}
		else
		{
			return GetCombatTarget().IsGuarded();
		}
		
		return false;
	}
}

class BTCondIsTargetGuardedDef extends IBehTreeConditionalTaskDefinition
{
	editable var longerThan : float;
	
	default instanceClass = 'BTCondIsTargetGuarded';
}