

class CBTTasFollowerShouldAttack extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	//Init
	function Initialize()
	{
		combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
	}
	
	///////////////////////////////////////////////////////////////////////////
	
	function IsAvailable() : bool
	{
		if ( combatDataStorage.IsAFollower() && GetCombatTarget() != thePlayer.GetTarget() )
			return true;
		
		return combatDataStorage.ShouldAttack( GetLocalTime() );
	}
	
	function OnActivate() : EBTNodeStatus
	{		
		return BTNS_Active;			
	}
}

class CBTTasFollowerShouldAttackDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTasFollowerShouldAttack';
}