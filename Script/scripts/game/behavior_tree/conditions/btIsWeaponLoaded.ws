class CBTCondIsWeaponLoaded extends IBehTreeTask
{	
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		if( combatDataStorage.GetProjectile() || combatDataStorage.ReturnWeaponSubTypeForActiveCombatStyle() == 0 ) // bow is always loaded... for now
		{
			return true;
		}
		return false;
	}
	
	function Initialize()
	{
		combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
	}
};

class CBTCondIsWeaponLoadedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsWeaponLoaded';
};