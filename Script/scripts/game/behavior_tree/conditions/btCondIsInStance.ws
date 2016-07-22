/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class BTCondIsInStance extends IBehTreeTask
{
	var currStance : ENpcStance;
	var ifNot : bool;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var stanceName : ENpcStance;
		
		stanceName = npc.GetCurrentStance();
		
		if ( !ifNot )
		{
			if ( stanceName == currStance )
			{
				return true;
			}
		}
		else
		{
			if ( stanceName != currStance )
			{
				return true;
			}
		}
		return false;
	}
}

class BTCondIsInStanceDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsInStance';

	editable var currStance : ENpcStance;
	editable var ifNot : bool;
	
	default currStance = NS_Normal;
	default ifNot = false;
}