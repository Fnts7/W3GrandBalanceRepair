//>--------------------------------------------------------------------------
// BTCondMorphRatio
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Compare a value to the current morph ratio of the Actor
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 21-March-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondMorphRatio extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var value 		: float;
	var operator 	: EOperator;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_component			: CMorphedMeshManagerComponent;
		var l_currentValue 		: float;
		
		l_component	= GetNPC().GetMorphedMeshManagerComponent();
		
		if( !l_component) return false;
		
		l_currentValue = l_component.GetMorphBlend();
		
		switch ( operator )
		{
			case EO_Equal:			return l_currentValue == value;
			case EO_NotEqual:		return l_currentValue != value;
			case EO_Less:			return l_currentValue < value;
			case EO_LessEqual:		return l_currentValue <= value;
			case EO_Greater:		return l_currentValue > value;
			case EO_GreaterEqual:	return l_currentValue >= value;
			default : 				return false;
		}
	}
}
//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
class BTCondMorphRatioDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondMorphRatio';
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var value 		: float;
	editable var operator 	: EOperator;
	
	default value = 1;
}