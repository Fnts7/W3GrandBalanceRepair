/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/**			 Małgorzata Napiontek	
/***********************************************************************/

class W3PressureSwitch extends W3PhysicalSwitch
{
	protected editable	var	autoSwitchOnLeave		: bool;				default autoSwitchOnLeave = true;
	protected 			var entities				: array< CEntity >;
	protected			var delayedTurnOffEntity	: CEntity;
	protected			var delayedTurnOnEntity		: CEntity;

	hint autoSwitchOnLeave = "If true then leaving the trigger will flip the switch";
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( !entities.Contains( entity ) )
		{
			entities.PushBack( entity );
		}
		LogChannel( 'pressure', "OnAreaEnter " + entity.GetName() );

		TurnOnIfPossible( entity );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		entities.Remove( entity );

		LogChannel( 'pressure', "OnAreaExit " + entity.GetName() );

		TurnOffIfPossible( entity );
	}
	
	// Experimental - Łukasz Szczepankowski - problem here is that "entity' must be an actor in order to make projectile works.
	event OnAardHit( sign : W3AardProjectile )
	{
			var entity : CEntity;
		
		entity = thePlayer;
		if ( !entities.Contains( entity ) )
		{
			entities.PushBack( entity );
		}
		LogChannel( 'pressure', "OnAardHitStart " + entity.GetName() );

		TurnOnIfPossible( entity );
		
		entities.Remove( entity );

		LogChannel( 'pressure', "OnAardHitStop " + entity.GetName() );

		TurnOffIfPossible( entity );
	}
	
	timer function OnCheckInventoryEntities( delta : float , id : int)
	{
		var i, size : int;
		var entity : CEntity;
		var inventory : CInventoryComponent;
		
		size = entities.Size();
		for ( i = 0; i < size; )
		{
			entity = entities[ i ];
			
			// check if entity is correct
			if ( (W3ActorRemains)entity )
			{
				// check if entity has an empty inventory
				inventory = (CInventoryComponent)entity.GetComponentByClassName( 'CInventoryComponent' );
				if ( inventory )
				{
					if ( inventory.IsEmpty() )
					{
						// if so remove it since it was taken
						entities.Remove( entity );
						TurnOffIfPossible( NULL );
						continue;
					}
				}
			}
			i += 1;
		}
	}
	
	function TurnOnIfPossible( entity : CEntity )
	{
		if ( IsAvailable() )
		{
			if ( IsOff() )
			{
				LogChannel( 'pressure', "turning on" );
				Turn( true, (CActor)entity, false, false );
			
				AddTimer( 'OnCheckInventoryEntities', 0.2f, true, , , true );
			
				// just in case
				RemoveTimer( 'OnDelayedTurnOff' );
				RemoveTimer( 'OnDelayedTurnOn' );
			}
			else if ( IsSwitchingOff() )
			{
				LogChannel( 'pressure', "turning on delayed" );
				delayedTurnOnEntity = entity;
				AddTimer( 'OnDelayedTurnOn', 0.2f, , , , true );
			}
		}
	}
	
	function TurnOffIfPossible( entity : CEntity )
	{
		if ( ( entities.Size() == 0 ) && autoSwitchOnLeave && IsAvailable() )
		{
			if ( IsOn() )
			{
				// everything is ok, there are no entites and switch is on
				// so we need to turn it off
				LogChannel( 'pressure', "turning off" );
				Turn( false, (CActor)entity, false, false );
			
				RemoveTimer( 'OnCheckInventoryEntities' );

				RemoveTimer( 'OnDelayedTurnOff' );
				RemoveTimer( 'OnDelayedTurnOn' );
			}
			else if ( IsSwitchingOn() )
			{
				// there are no entities, but switch is just switching on
				// so we need to turn it off when it gets on
				LogChannel( 'pressure', "turning off delayed" );
				delayedTurnOffEntity = entity;
				AddTimer( 'OnDelayedTurnOff', 0.2f, , , , true );
			}
		}
	}
	
	timer function OnDelayedTurnOn( delta : float , id : int)
	{
		LogChannel( 'pressure', "timer OnDelayedTurnOn" );
		TurnOnIfPossible( delayedTurnOnEntity );
	}

	timer function OnDelayedTurnOff( delta : float , id : int)
	{
		LogChannel( 'pressure', "timer OnDelayedTurnOff" );
		TurnOffIfPossible( delayedTurnOffEntity );
	}
}
