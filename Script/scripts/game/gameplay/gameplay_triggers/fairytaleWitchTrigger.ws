class CFairytaleWitchTrigger extends CGameplayEntity
{
	editable var areaNumber : int;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetInsideDiveAttackArea( true );
			thePlayer.SetDiveAreaNumber( areaNumber );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer )
		{
			if( areaNumber == 0 )
			{
				thePlayer.SetInsideDiveAttackArea( false );
			}
			thePlayer.SetDiveAreaNumber( -1 );
		}
	}
}