class CBTTaskIsSpeaking extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().IsSpeaking() || GetNPC().IsPlayingChatScene();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskIsSpeakingDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsSpeaking';
}


class CBTTaskIsInChatScene extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().IsPlayingChatScene();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskIsInChatSceneDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsInChatScene';
}

class CBTTaskStopAllScenes extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var actor : CActor;
		
		actor = GetActor();
		
		actor.StopAllScenes();
		
		return BTNS_Active;
	}
}

class CBTTaskStopAllScenesDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskStopAllScenes';
}
