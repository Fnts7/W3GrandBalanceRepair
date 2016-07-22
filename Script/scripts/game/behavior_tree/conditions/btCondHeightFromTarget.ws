//>--------------------------------------------------------------------------
// BTCondHeightFromTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check the height from target
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 19-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondHeightFromTarget extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var value				: float;
	var operator 			: EOperator;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var target 		: CActor;		
		var oppNo 		: float;
		var pos			: Vector;
		var targetPos 	: Vector;
		
		target = GetNPC().GetTarget();
		
		pos 		= GetNPC().GetWorldPosition();
		targetPos 	= target.GetWorldPosition();
		
		oppNo = pos.Z - targetPos.Z;
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == value;
			case EO_NotEqual:		return oppNo != value;
			case EO_Less:			return oppNo < 	value;
			case EO_LessEqual:		return oppNo <= value;
			case EO_Greater:		return oppNo > 	value;
			case EO_GreaterEqual:	return oppNo >= value;
			default : 				return false;
		}
	}
	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondHeightFromTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHeightFromTarget';

	editable var value				: float;
	editable var operator 			: EOperator;
	
	default value		= 5;
	default operator 	= EO_LessEqual;
}
