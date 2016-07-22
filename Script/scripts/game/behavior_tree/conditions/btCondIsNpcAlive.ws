class CBTCondIsNpcAlive extends IBehTreeTask
{
	private var npcTag : name;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		
		npc = (CNewNPC)theGame.GetNodeByTag( npcTag );
		
		if( npc )
		{
			if( npc.IsAlive() )
			{
				return true;
			}
		}
			
		return false;
	}
};

class CBTCondIsNpcAliveDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsNpcAlive';
	
	editable var npcTag : name;
};