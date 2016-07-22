class BTCondIsChangingWeapon extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.IsProcessingItems();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class BTCondIsChangingWeaponDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsChangingWeapon';
}


//////////////////////////////////////////////////////////////////

class BTCondDoesChangingWeaponRequiresIdle extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.DoesProcessingRequiresIdle();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class BTCondDoesChangingWeaponRequiresIdleDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDoesChangingWeaponRequiresIdle';
}