/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_IsInWater extends CQCActorScriptedCondition
{
	function Evaluate(act : CActor ) : bool
	{
		var mpac : CMovingPhysicalAgentComponent;
		
		mpac = (CMovingPhysicalAgentComponent)act.GetMovingAgentComponent();
		if(mpac)
			return mpac.GetSubmergeDepth() < 0;
		
		return false;
	}
}