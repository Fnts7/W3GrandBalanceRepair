class CVFXTrigger extends CGameplayEntity
{
	editable var fxOnEnter : name;
	
	default fxOnEnter = 'none';
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CActor) activator.GetEntity();
		
		if( actor )
		{
			actor.PlayEffect( fxOnEnter );
			
			return true;
		}
		
		return false;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CActor) activator.GetEntity();
		
		if( actor )
		{
			actor.StopEffect( fxOnEnter );
			
			return true;
		}
		
		return false;
	}
}