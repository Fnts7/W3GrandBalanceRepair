class CBTTaskRainReaction extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		return BTNS_Completed;
	}
	
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
}

class CBTTaskRainReactionDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskRainReaction';
}
