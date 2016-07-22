/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Bartosz Bigaj
/***********************************************************************/

class W3QuestCond_UsedMedallion extends CQuestScriptedCondition
{
	var medallion : W3MedallionController;
		
	function Evaluate() : bool
	{	
		if ( !medallion && GetWitcherPlayer() )
		{
			medallion = GetWitcherPlayer().GetMedallion();
		}
		if ( medallion )
		{
			return medallion.IsActive();
		}
		return false;
	}
}