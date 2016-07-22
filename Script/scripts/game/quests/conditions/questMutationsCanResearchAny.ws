class W3QuestCond_MutationsCanStartResearch extends CQuestScriptedCondition
{
	public function Evaluate() : bool
	{
		return GetWitcherPlayer() && GetWitcherPlayer().HasResourcesToStartAnyMutationResearch();
	}
}