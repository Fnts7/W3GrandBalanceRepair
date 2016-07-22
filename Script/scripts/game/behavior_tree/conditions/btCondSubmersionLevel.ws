//>--------------------------------------------------------------------------
// BTCondSubmersionLevel
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check how deep in water the Actor is
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 30-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondSubmersionLevel extends IBehTreeTask
{
	var checkedActor 	: EStatOwner;
	var value 			: float;
	var operator 		: EOperator;
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_actor			: CActor	= GetNPC();
		var l_pos			: Vector;
		var waterLevel 		: float;
		var submersionLevel	: float;
		
		if( checkedActor == SO_NPC )
		{
			l_actor = GetNPC();
		}
		else
		{
			l_actor = GetCombatTarget();
		}
		l_pos = l_actor.GetWorldPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel ( l_pos, true );
		
		submersionLevel = waterLevel - l_pos.Z;
		
		switch ( operator )
		{
			case EO_Equal:			return submersionLevel == value;
			case EO_NotEqual:		return submersionLevel != value;
			case EO_Less:			return submersionLevel < value;
			case EO_LessEqual:		return submersionLevel <= value;
			case EO_Greater:		return submersionLevel > value;
			case EO_GreaterEqual:	return submersionLevel >= value;
			default : 				return false;
		}
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondSubmersionLevelDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondSubmersionLevel';
	//>----------------------------------------------------------------------
	// VARIABLE
	//-----------------------------------------------------------------------
	editable var checkedActor 	: EStatOwner;
	editable var value 			: float;
	editable var operator 		: EOperator;
	
	default checkedActor = SO_NPC;
}