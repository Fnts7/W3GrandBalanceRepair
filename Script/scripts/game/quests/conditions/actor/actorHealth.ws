/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

/**	
	When editing this function make sure to make corresponding changes in ChangeNPCState quest function!
*/
class W3QuestCond_Health extends CQCActorScriptedCondition
{
	editable var condition : ECompareOp;
	editable var percents : int;	
	
	default condition = CO_Lesser;
	
	hint percents = "Percentage of actor max health [0-100]";

	function Evaluate(act : CActor ) : bool
	{		
		var hpp : float;
		var hppi : int;

		hpp = act.GetHealthPercents();
		
		if(hpp == -1)
			return false;
			
		hppi = FloorF(100 * hpp);
	
		return ProcessCompare(condition, hppi, percents);
	}
}