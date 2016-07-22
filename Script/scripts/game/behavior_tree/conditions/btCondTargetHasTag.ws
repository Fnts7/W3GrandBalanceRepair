/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondTargetHasTag extends IBehTreeTask
{
	var tag		: name;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if( GetCombatTarget().HasTag( tag ))
		{
			return true;
		}
		return false;
	}
};


class CBTCondTargetHasTagDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondTargetHasTag';

	editable var tag		: name;
};


















