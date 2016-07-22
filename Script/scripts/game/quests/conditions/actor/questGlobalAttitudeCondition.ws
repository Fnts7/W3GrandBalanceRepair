/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2015
/** Author : Danisz Markiewicz
/***********************************************************************/

class W3QuestCond_GlobalAttitude extends CQuestScriptedCondition
{

	editable var srcGroup : name;
	editable var dstGroup : name;
	editable var attitude : EAIAttitude;
	

	function Evaluate() : bool
	{		
		return ( theGame.GetGlobalAttitude( srcGroup, dstGroup ) == attitude );
	}
}