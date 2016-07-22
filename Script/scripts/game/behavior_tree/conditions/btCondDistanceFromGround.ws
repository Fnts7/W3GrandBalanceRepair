//>--------------------------------------------------------------------------
// BTCondDistanceFromGround
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check the disatnce from ground on a NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 10-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondDistanceFromGround extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var checkedActor 		: EStatOwner;
	var value				: float;
	var operator 			: EOperator;
	
	// private
	private var m_collisionGroupNames : array<name>;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	final function Initialize()
	{
		m_collisionGroupNames.PushBack('Terrain');
		m_collisionGroupNames.PushBack('Foliage');
		m_collisionGroupNames.PushBack('Static');
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var target 	: CActor;		
		var oppNo 	: float;
		
		target = GetNPC();
		
		if( checkedActor == SO_Target )
		{
			target = target.GetTarget();
		}
		
		// If we compare to 0, there is no point really calculating the distance from ground, 
		// it will always be greater than 0.
		if( value <= 0 )
		{ 
			oppNo = 0.1f;
		}
		else
		{
			oppNo = target.GetDistanceFromGround( value + 1, m_collisionGroupNames);
		}
		
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
class BTCondDistanceFromGroundDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDistanceFromGround';

	editable var checkedActor 		: EStatOwner;
	editable var value				: CBehTreeValFloat;
	editable var operator 			: EOperator;
	
	default checkedActor = SO_NPC;
}
