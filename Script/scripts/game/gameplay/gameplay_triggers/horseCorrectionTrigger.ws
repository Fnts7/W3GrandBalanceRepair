class CHorseCorrectionTrigger extends CGameplayEntity
{
	editable var valueOnEnter : bool;
	editable var valueOnExit : bool;
	
	default valueOnEnter = false;
	default valueOnExit = true;
	
	var horse : CGameplayEntity;
	var horseComp : W3HorseComponent;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer && ((CActor)activator.GetEntity()).IsUsingHorse() )
		{
			horse = ((CActor)activator.GetEntity()).GetUsedVehicle();
			horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
			
			horseComp.SetIsInCustomSpot( valueOnEnter );
			
			return true;
		}
		
		return false;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer && ((CActor)activator.GetEntity()).IsUsingHorse() )
		{
			horse = ((CActor)activator.GetEntity()).GetUsedVehicle();
			horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
			
			horseComp.SetIsInCustomSpot( valueOnExit );
			
			return true;
		}
		
		return false;
	}
}