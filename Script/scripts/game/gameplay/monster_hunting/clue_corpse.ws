class W3ClueCorpse extends W3MonsterClue
{
	editable var woundName : name;

	hint woundName = "Name of the wound from the the dismemberment system that should applied on spawn.";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		AddTimer('ApplyDismemberment', 0.2, false);
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		UpdateVisibility();
	}
	
	event OnStreamIn()
	{
		super.OnStreamIn();
		UpdateVisibility();	
	}
	
	timer function ApplyDismemberment( time : float , id : int)
	{
		UpdateVisibility();			
	}
	
	//Focus visiblity function changed to update dismemberment as well
	function UpdateVisibility()
	{
		var component : CDismembermentComponent;
		
		ProcessReleaseVersions();
		super.UpdateVisibility();
		
		component = (CDismembermentComponent) this.GetComponentByClassName('CDismembermentComponent');
		
		if(component)
		{
			if(woundName != '' && component.IsWoundDefined(woundName) )
			{
				component.ClearVisibleWound();
				component.SetVisibleWound( woundName );
			}
		}
		
		
	}
	
}
