/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_PlayerHasQuenActive extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		var quen : W3QuenEntity;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
			return inverted;
		
		quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
		if(!quen)
			return inverted;
			
		if(inverted)
			return !quen.IsAnyQuenActive();
		
		return quen.IsAnyQuenActive();
	}
}