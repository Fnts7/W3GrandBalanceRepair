/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondActorCharmed extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if( owner.HasBuff( EET_AxiiGuardMe ) || owner.HasBuff( EET_Confusion ) )
		{
			return true;
		}
		return false;
	}
};


class CBTCondActorCharmedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondActorCharmed';
};


















