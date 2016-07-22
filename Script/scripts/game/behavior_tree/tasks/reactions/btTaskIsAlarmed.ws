class CBTTaskIsAlarmed extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAlarmed(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
	
}

class CBTTaskIsAlarmedDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAlarmed';
}

class CBTTaskIsAngry extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAngry(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
	
}

class CBTTaskIsAngryDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAngry';
}

