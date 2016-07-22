class W3QuestCond_IsStandardCampaign extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var ret : bool;
		
		ret = theGame.IsNewGame();
		
		if( inverted )
		{
			ret = !ret;
		}
		
		return ret;
	}
}