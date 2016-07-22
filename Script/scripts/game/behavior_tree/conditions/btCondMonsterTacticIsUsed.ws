/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : R.Pergent - 14-February-2014
/***********************************************************************/

enum EMonsterTactic
{
	EMT_None,
	EMT_FarSurround
}

class BTCondMonsterTacticIsUsed extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	var tactic 				: EMonsterTactic;
	var distanceToCheck 	: float;
	var ignoreMyself 		: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var i				: int;
		var l_npc 			: CNewNPC = GetNPC();
		var l_actorsInRange : array <CActor>;
		
		l_actorsInRange = GetActorsInRange( l_npc , 30, 50, '', true);
		
		for ( i = 0 ; i < l_actorsInRange.Size() ; i += 1 )
		{
			if( ignoreMyself && l_actorsInRange[i] == l_npc ) continue;
			if( l_actorsInRange[i].GetBehaviorVariable( 'CurrentTactic' ) == (int) tactic )
			{
				return true;
			}
		}
		
		return false;
	}
}

class BTCondMonsterTacticIsUsedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondMonsterTacticIsUsed';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	editable var tactic 			: EMonsterTactic;
	editable var distanceToCheck 	: float;
	editable var ignoreMyself		: bool;
	
	hint ignoreMyself = "Ignore if I am the one using the tactic";
}