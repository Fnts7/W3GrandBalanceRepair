/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondAppearanceName extends IBehTreeTask
{
	var appearanceName : name;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		var currentAppearance : name;
		
		currentAppearance = owner.GetAppearance();
		//Log( currentAppearance );
		
		if( currentAppearance == appearanceName )
		{
			return true;
		}
		else
		{
			return false;		
		}
	}
};


class CBTCondAppearanceNameDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondAppearanceName';

	editable var appearanceName : name;
};