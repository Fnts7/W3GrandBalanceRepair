class W3QuestCond_IsFalling extends CQCActorScriptedCondition
{
	function Evaluate(act : CActor ) : bool
	{		
		return act.IsFalling();
	}
}