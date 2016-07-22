class W3QuestCond_MutationSystemIsEnabled extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{	
		return GetWitcherPlayer().IsMutationSystemEnabled();
	}
}