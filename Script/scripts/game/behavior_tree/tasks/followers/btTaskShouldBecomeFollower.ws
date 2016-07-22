

class CBTTaskShouldBecomeAFollower extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	//Init
	function Initialize()
	{
		combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
	}
	
	///////////////////////////////////////////////////////////////////////////
	
	function OnActivate() : EBTNodeStatus
	{
		if ( GetActor().HasTag(theGame.params.TAG_NPC_IN_PARTY) )
			combatDataStorage.BecomeAFollower();
		else
			combatDataStorage.NoLongerFollowing();
		
		return BTNS_Active;			
	}
}

class CBTTaskShouldBecomeAFollowerDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTaskShouldBecomeAFollower';
}