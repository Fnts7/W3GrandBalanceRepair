class W3QuestCond_PlayerIsOnBoat extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		if ( !inverted )
		{
			return thePlayer.IsOnBoat();
		}
		else
		{
			return !thePlayer.IsOnBoat();
		}
	}
}