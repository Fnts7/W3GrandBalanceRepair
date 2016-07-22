
class CBTTaskShouldUseReactionOneLiners extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		npc = GetNPC();
		
		if( npc.dontUseReactionOneLiners )
		{
			return false;
		}
		if( npc.IsAtWork() && !npc.IsConsciousAtWork()  )
		{
			return false;
		}
		return true;
	}
}

class CBTTaskShouldUseReactionOneLinersDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskShouldUseReactionOneLiners';
}
