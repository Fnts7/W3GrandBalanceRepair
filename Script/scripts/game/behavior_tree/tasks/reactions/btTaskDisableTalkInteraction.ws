class CBTTaskDisableTalkInteraction extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().DisableTalking( true, true );
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().DisableTalking( false, true );
	}
}

class CBTTaskDisableTalkInteractionDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskDisableTalkInteraction';
}
