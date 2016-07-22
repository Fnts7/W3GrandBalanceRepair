/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class W3BirdAttackTrigger extends CEntity
{
	var lair : CFlyingSwarmMasterLair;
	
	editable var affectedEntityTag : name;
	editable var attackRequestInterval : float;
	editable var affectBirdsInRange : float;
	
	default attackRequestInterval = 2.0;
	default affectBirdsInRange = 50;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CActor)(activator.GetEntity());		
		if (actor && IsNameValid(affectedEntityTag) && actor.HasTag( affectedEntityTag ) )
		{
			if ( GetLairEntity() )
			{
				lair.RequestGroupStateChange( 'attackPlayer' );
				AddTimer( 'RequestAttack', attackRequestInterval, true );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)(activator.GetEntity());		
		if (actor && IsNameValid(affectedEntityTag) && actor.HasTag( affectedEntityTag ) )
		{
			if ( GetLairEntity() )
			{
				RemoveTimer( 'RequestAttack' );
			}
		}
	}
	
	function GetLairEntity() : bool
	{
		var entities : array<CGameplayEntity>;
		var i : int;
		var lairLocal : CFlyingSwarmMasterLair;
		
		FindGameplayEntitiesInRange( entities, this, affectBirdsInRange, 100000 );
		
		for ( i=0 ; entities.Size() > i ; i+=1 )
		{
			lairLocal = (CFlyingSwarmMasterLair)entities[i];
			
			if(lairLocal)
			{
				lair = lairLocal;
				return true;
			}
		}
		
		return false;
	}
	
	timer function RequestAttack( t : float , id : int)
	{
		lair.RequestGroupStateChange( 'attackPlayer' );
	}
};
