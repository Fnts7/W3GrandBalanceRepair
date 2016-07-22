state Idle in W3HorseComponent
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.InternalSetSpeedMultiplier( 1 );
	}

	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
	}
	
	event OnMountStarted( entity : CEntity, vehicleSlot : EVehicleSlot )
	{
		parent.OnMountStarted( entity, vehicleSlot );
	}
	
	event OnMountFinished( entity : CEntity )
	{
		parent.OnMountFinished( entity );
		if ( entity == thePlayer ) // Exploration is only player specific logic
			parent.PushState( 'Exploration' );
	}
	
	event OnTick( dt : float )
	{
		if ( parent.ShouldTickInIdle() )
			parent.OnTick( dt );
	}
}
