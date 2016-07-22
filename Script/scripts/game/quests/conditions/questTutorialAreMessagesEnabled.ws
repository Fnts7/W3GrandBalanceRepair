/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_TutorialMessagesEnabled extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		if(inverted)
			return !theGame.GetTutorialSystem().AreMessagesEnabled();
			
		return theGame.GetTutorialSystem().AreMessagesEnabled();
	}
}