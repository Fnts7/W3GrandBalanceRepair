/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

class W3QuestCond_World extends CQuestScriptedCondition
{
	editable var currentArea : EAreaName;		default currentArea = AN_Undefined;
	
	function Evaluate() : bool
	{
		return currentArea == theGame.GetCommonMapManager().GetCurrentArea();
	}
}