/***********************************************************************/
/** CBTTaskManageRepulseProjectileEvents
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskManageRepulseProjectileEvents extends IBehTreeTask
{
	private var performRepulseProjectileDelay			: float;
	private var ownerPosition							: Vector;
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( eventName == 'Time2DodgeProjectile' )
		{
			ownerPosition = npc.GetWorldPosition();
			performRepulseProjectileDelay = this.GetEventParamFloat(-1);
			performRepulseProjectileDelay = ClampF( (performRepulseProjectileDelay -0.4), 0, 99 );
			npc.AddTimer( 'DelayRepulseProjectileEventTimer', performRepulseProjectileDelay );
			return true;
		}
		
		if ( eventName == 'Time2DodgeBomb' )
		{
			ownerPosition = npc.GetWorldPosition();
			performRepulseProjectileDelay = this.GetEventParamFloat(-1);
			performRepulseProjectileDelay = ClampF( (performRepulseProjectileDelay -0.4), 0, 99 );
			npc.AddTimer( 'DelayRepulseBombEventTimer', performRepulseProjectileDelay );
			return true;
		}	
		
		return false;
	}
}

class CBTTaskManageRepulseProjectileEventsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageRepulseProjectileEvents';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Time2DodgeProjectile' );
		listenToGameplayEvents.PushBack( 'Time2DodgeBomb' );
	}
}