/***********************************************************************/
/** Copyright © 2016
/** Author : Paweł Sasko
/***********************************************************************/

class W3QuestCond_NewGamePlusEnabled extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{	
		return theGame.IsNewGamePlusEnabled();
	}
}