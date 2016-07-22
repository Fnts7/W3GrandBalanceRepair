class W3QuestCond_TutorialSystemIsAvailable extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{
		var b : bool;
		
		b = theGame.GetTutorialSystem();
		b = b && theGame.GetTutorialSystem().IsRunning();
		b = b && !theGame.GetTutorialSystem().IsOnTickOptimalizationEnabled();
		b = b && theGame.GetTutorialSystem().AreMessagesEnabled();
		
		return b;
	}
}