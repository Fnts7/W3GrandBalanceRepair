
class CBTTasFollowerShouldKeepDistanceToPlayer extends IBehTreeTask
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
		if ( combatDataStorage.ShouldKeepDistanceToPlayer() )
		{
			if ( GetActionTarget() != thePlayer )
				SetActionTarget(thePlayer);
			
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;			
	}
}

class CBTTasFollowerShouldKeepDistanceToPlayerDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTasFollowerShouldKeepDistanceToPlayer';
}