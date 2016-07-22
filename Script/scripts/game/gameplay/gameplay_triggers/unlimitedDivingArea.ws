class W3UnlimitedDivingArea extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( entity == thePlayer )
		{
			((CR4PlayerStateSwimming)thePlayer.GetState('Swimming')).EnableUnlimitedDiving( true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( entity == thePlayer )
		{
			((CR4PlayerStateSwimming)thePlayer.GetState('Swimming')).EnableUnlimitedDiving( false );
		}
	}
}