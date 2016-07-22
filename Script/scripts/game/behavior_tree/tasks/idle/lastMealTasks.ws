//>--------------------------------------------------------------------------
// BTTaskCheckDelaySinceLastMeal
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check NPC's hunger level
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 20-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskCheckDelaySinceLastMeal extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	public var value 	: float;
	public var operator : EOperator;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var lastMeal	: float = GetNPC().lastMealTime;
		var oppNo 		: float = GetLocalTime() - lastMeal;
		
		if ( lastMeal < 0 ) return true;
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == value;
			case EO_NotEqual:		return oppNo != value;
			case EO_Less:			return oppNo < value;
			case EO_LessEqual:		return oppNo <= value;
			case EO_Greater:		return oppNo > value;
			case EO_GreaterEqual:	return oppNo >= value;
			default : 				return false;
		}
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskCheckDelaySinceLastMealDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCheckDelaySinceLastMeal';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var value : float;
	private editable var operator : EOperator;
}


//>--------------------------------------------------------------------------
// BTTaskResetLastMealDelay
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 20-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskResetLastMealDelay extends IBehTreeTask
{	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		var l_npc : CNewNPC = GetNPC();
		l_npc.lastMealTime = GetLocalTime();
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskResetLastMealDelayDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskResetLastMealDelay';
}