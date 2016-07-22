/***********************************************************************/
/** IsTeleporting
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondIsTeleporting extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		
		if ( !npc )
		{
			npc = GetNPC();
		}
		
		return npc.IsTeleporting();
	}
}

class CBTCondIsTeleportingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondIsTeleporting';
};