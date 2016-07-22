class CBTTaskFinishable extends IBehTreeTask
{
	var finisherAnimName : name;
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		
		if ( finisherAnimName )
		{
			owner.EnableFinishComponent( true );
			thePlayer.AddToFinishableEnemyList( owner, true );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		owner.EnableFinishComponent( false );
		thePlayer.AddToFinishableEnemyList( owner, false );
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC;
		var syncAnimName : name;
		
		npc = GetNPC();
		if ( eventName == 'Finisher' )
		{
			npc.EnableFinishComponent( false );
			thePlayer.AddToFinishableEnemyList( GetNPC(), false );
			FinisherSyncAnim();
			
			return true;
		}
		
		return false;
	}
	
	function FinisherSyncAnim()
	{
		theGame.GetSyncAnimManager().SetupSimpleSyncAnim( finisherAnimName, thePlayer, GetActor() );
	}
}

class CBTTaskFinishableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFinishable';

	editable var finisherAnimName : name;
}

//FinisherEnd on Deactivate//
class CBTTaskEndFinisherOnDeactivate extends IBehTreeTask
{
	function OnDeactivate()
	{
		thePlayer.OnFinisherEnd();
	}
}
class CBTTaskEndFinisherOnDeactivateDef extends IBehTreeTaskDefinition
{
	default instanceClass ='CBTTaskEndFinisherOnDeactivate';
}
