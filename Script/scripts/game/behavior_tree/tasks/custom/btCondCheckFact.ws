/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/


class CBTCondCheckFact extends IBehTreeTask
{
	var fact		: string;
	var value		: int;
	var operator 	: EOperator;
	
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var oppNo : int;
		
		oppNo = FactsQuerySum( fact );
		
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

class CBTCondCheckFactDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondCheckFact';

	editable var fact		: string;
	editable var value		: int;
	editable var operator 	: EOperator;
}