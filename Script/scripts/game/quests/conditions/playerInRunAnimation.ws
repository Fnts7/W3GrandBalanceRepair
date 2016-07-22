//>--------------------------------------------------------------------------
// W3QuestCond_PlayerInRunAnimation
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if the player is actually in the Run behavior graph state
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 15-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class W3QuestCond_PlayerInRunAnimation extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{	
		return thePlayer.IsInRunAnimation();
	}
}