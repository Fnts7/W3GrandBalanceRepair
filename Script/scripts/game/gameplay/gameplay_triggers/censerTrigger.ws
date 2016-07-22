class CCenserTrigger extends CGameplayEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetBehaviorVariable( 'censerSwinging', 1.0, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetBehaviorVariable( 'censerSwinging', 0.0, true );
		}
	}
}