class CAIChatsInAPTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\reactions\chats_in_aps";
};

class CBTTaskCanUseChatScene extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		npc = GetNPC();
		
		return npc.CanUseChatInCurrentAP();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskCanUseChatSceneDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCanUseChatScene';
}

class CBTTaskIsAtWork extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		var isAtWork : bool;		
		
		npc = GetNPC();
		isAtWork = npc.IsAtWork();
		
		return isAtWork;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskIsAtWorkDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAtWork';
}
