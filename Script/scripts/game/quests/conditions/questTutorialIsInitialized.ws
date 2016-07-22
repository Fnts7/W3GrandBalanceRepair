/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_TutorialIsInitialized extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{
		return theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning();
	}
}