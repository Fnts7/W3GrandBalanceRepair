/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondLairEntityInRange extends IBehTreeTask
{
	private var lair 						: CFlyingSwarmMasterLair;
	private var checkCount					: int;
	private var timeStamp 					: float;
	
	function IsAvailable() : bool
	{
		var lairEntities : array<CGameplayEntity>;
		
		if ( !lair && checkCount <= 5 && ( timeStamp + 5 < GetLocalTime() || timeStamp == 0 ) )
		{
			timeStamp = GetLocalTime();
			checkCount += 1;
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		if ( !lair )
		{
			return false;
		}
		return true;
	}
}

class CBTCondLairEntityInRangeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondLairEntityInRange';
};