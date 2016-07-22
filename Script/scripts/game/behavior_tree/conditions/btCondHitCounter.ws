class BTCondHitCounter extends IBehTreeTask
{
	var value : float;
	var operator : EOperator;
	var total : bool;
	
	function IsAvailable() : bool
	{
		var hitCounter : int = GetNPC().GetHitCounter(total);
		
		switch ( operator )
		{
			case EO_Equal:			return hitCounter == value;
			case EO_NotEqual:		return hitCounter != value;
			case EO_Less:			return hitCounter < value;
			case EO_LessEqual:		return hitCounter <= value;
			case EO_Greater:		return hitCounter > value;
			case EO_GreaterEqual:	return hitCounter >= value;
			default : 				return false;
		}
	}
}

class BTCondHitCounterDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHitCounter';

	editable var value : float;
	editable var operator : EOperator;
	editable var total : bool;
	
	default total = false;
	
	default value = 1;
}