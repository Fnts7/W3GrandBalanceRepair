//>--------------------------------------------------------------------------
// BTCondThreatLevelDifference
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check the threat level of the NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 30-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondThreatLevel extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var operator 					: EOperator;
	public var value						: int;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var oppNo 				: int;
		
		oppNo = GetNPC().GetThreatLevel();
		
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
class BTCondThreatLevelDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondThreatLevel';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var operator 					: EOperator;
	private editable var value						: int;
}


//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondTargetThreatLevel extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var operator 					: EOperator;
	public var value						: int;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var npc					: CNewNPC;
		var oppNo 				: int;
		
		
		npc = (CNewNPC)GetCombatTarget();
		
		if ( ! npc )
			return false;
		
		oppNo = npc.GetThreatLevel();
		
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
class BTCondTargetThreatLevelDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondTargetThreatLevel';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var operator 					: EOperator;
	private editable var value						: int;
}