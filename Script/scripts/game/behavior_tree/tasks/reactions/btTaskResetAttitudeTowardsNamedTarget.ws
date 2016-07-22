

class CBTTaskResetAttitudes extends IBehTreeTask
{
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function OnActivate() : EBTNodeStatus
	{		
		reactionDataStorage.ResetAttitudes(GetActor());
		return BTNS_Active;			
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		reactionDataStorage.ResetAttitudes(GetActor());
		return true;
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
}

class CBTTaskResetAttitudesDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskResetAttitudes';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'PlayerUnconsciousAction' );
		listenToGameplayEvents.PushBack( 'PlayerInScene' );
		listenToGameplayEvents.PushBack( 'GuardUnconsciousAction' );
	}
}
