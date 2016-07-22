/***********************************************************************/
/** Copyright © 2015
/** Author : Patryk Fiutowski
/***********************************************************************/

class W3QuestCond_HorsePanic extends CQCActorScriptedCondition
{
	editable var condition : ECompareOp;
	editable var percents : int;	
	
	default condition = CO_Lesser;
	
	hint percents = "Percentage of actor max stat [0-100]";

	public function Evaluate(act : CActor ) : bool
	{		
		var perc : float;
		var horseComp : W3HorseComponent;
		
		
		horseComp = ((CNewNPC)act).GetHorseComponent();
		
		if ( !horseComp )
			return false;
		
		perc = horseComp.GetPanicPercent();
		
		//if doesn't have that stat
		if(perc == -1)
			return false;
			
		return ProcessCompare(condition, RoundMath(perc * 100), percents);
	}
}