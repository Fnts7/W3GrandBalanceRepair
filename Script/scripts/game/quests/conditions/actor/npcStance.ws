//>--------------------------------------------------------------------------
// W3QuestCond_NpcStance
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check the stance of an NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 13-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class W3QuestCond_NpcStance extends CQCActorScriptedCondition
{
	editable var stance 	: ENpcStance;

	function Evaluate( act : CActor ) : bool
	{		
		var l_result		: bool;
		var l_npc			: CNewNPC;
		
		l_npc = (CNewNPC) act;		
		if( !l_npc ) return false;
		
		l_result = ( l_npc.GetCurrentStance() == stance );
		
		return l_result;
	}
}