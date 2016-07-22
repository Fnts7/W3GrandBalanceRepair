// copyrajt orajt
// W. Zerek

class CBTTaskDisableHitReactionFor extends IBehTreeTask
{
	var time : float;

	function OnActivate() : EBTNodeStatus
	{
		GetNPC().DisableHitAnimFor( time );
		
		return BTNS_Active;
	}
};

class CBTTaskDisableHitReactionForDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDisableHitReactionFor';

	editable var time : float;
	
	default time = 2;
};