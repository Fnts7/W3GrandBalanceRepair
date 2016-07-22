/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondSwarmShieldAvailable extends IBehTreeTask
{
	public var checkIsShieldInPlace : bool;
	private var lair : CFlyingSwarmMasterLair;

	function IsAvailable() : bool
	{
		var owner 	: CNewNPC = GetNPC();
		var lairEntities : array<CGameplayEntity>;
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		
		if ( checkIsShieldInPlace )
		{
			if ( lair )
			{
				if ( lair.CurrentShieldGroupState() == 'shield' )
				{
					return true;
				}
			}
		}
		else if ( lair )
		{
			if ( lair.CurrentShieldGroupState() != 'shield' && lair.CurrentShieldGroupState() != 'gotoBirdMaster' )
			{
				return true;
			}
		}
		return false;
	}
};

class CBTCondSwarmShieldAvailableDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondSwarmShieldAvailable';

	editable var checkIsShieldInPlace : bool;
	default checkIsShieldInPlace = false;
};