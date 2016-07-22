//-------------------------------------------------------------------  ENTITY  --------------------------------------------------------------------------
statemachine class W3BeehiveStandingEntity extends W3AnimatedContainer
{
	editable var damageVal : SAbilityAttributeValue;

	private var actorsInRange : array<CActor>;
	private var wasInteracted : bool;
	
		default wasInteracted = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		GotoState('Idle');
	}
	
	event OnItemGiven(data : SItemChangedData)
	{
		//This gets called when entity is created to add items from template to the object.
		//We only want to agitate when it was due to players action so I set flag when player interacts.
		//As a result if we're here and flag is false it means that player never interacted with it so it's coming from spawn (actually even before OnSpawned() is called).
		if(wasInteracted)
			GotoState('Agitated');
		
		super.OnItemGiven(data);
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		wasInteracted = true;
		super.OnInteraction(actionName, activator);
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
	
		actor = (CActor)activator.GetEntity();
		if(actor && !actorsInRange.Contains(actor))
			actorsInRange.PushBack(actor);
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		if(actor)
			actorsInRange.Remove(actor);
	}
	
	public function ClearActorsInRange()
	{
		actorsInRange.Clear();
	}
	
	public function GetActorsInArea() : array<CActor>
	{
		return actorsInRange;
	}
}

//-------------------------------------------------------------------  IDLE  --------------------------------------------------------------------------
state Idle in W3BeehiveStandingEntity {}

//-------------------------------------------------------------------  AGITATED  --------------------------------------------------------------------------
state Agitated in W3BeehiveStandingEntity
{
	event OnEnterState( prevStateName : name )
	{
		var entityTemplate : CEntityTemplate;
		
		parent.PlayEffect('bee_cloud');
		parent.GetComponentByClassName('CTriggerAreaComponent').SetEnabled(true);
		
		//spawn moving bees
		entityTemplate = (CEntityTemplate)LoadResource('bees');		
		if ( entityTemplate )
			theGame.CreateEntity( entityTemplate, parent.GetWorldPosition());
		
		W3BeehiveStandingEntity_Agitated_Loop();
	}
	
	entry function W3BeehiveStandingEntity_Agitated_Loop()
	{
		var i : int;
		var actors : array<CActor>;
		var params : SCustomEffectParams;
	
		params.effectType = EET_Swarm;
		params.creator = parent;
		params.duration = 0.5;
		params.vibratePadLowFreq = 0.1;
		params.vibratePadHighFreq = 0.2;
		params.effectValue = parent.damageVal;
		
		while(true)
		{
			actors = parent.GetActorsInArea();			
			for(i=0; i<actors.Size(); i+=1)
				actors[i].AddEffectCustom(params);
				
			Sleep(0.1);
		}
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		parent.OnIgniHit(sign);
		parent.StopEffect('bee_cloud');
		parent.PlayEffect('bee_fire');
		parent.ClearActorsInRange();
		parent.GetComponentByClassName('CTriggerAreaComponent').SetEnabled(false);
		GotoState('Idle');
	}
}