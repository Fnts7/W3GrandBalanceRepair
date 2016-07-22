//-------------------------------------------------------------------  ENTITY  --------------------------------------------------------------------------
import statemachine class CBeehiveEntity extends W3Container
{
	editable var damageVal						: SAbilityAttributeValue;
	editable var destroyEntAfter				: float;
	editable var isFallingObject				: bool;
	editable var desiredTargetTagForBeesSwarm	: name;
	editable var excludedEntitiesTagsForBeeSwarm : array<name>;
	
	private var isOnFire : bool;
	private var hangingDamageArea : CComponent;
	public var originPoint : Vector;
	public var actorsInHangArea : array<CActor>;
	public var hangingBuffParams : SCustomEffectParams;
	public var beesActivated					: bool;
	 var activeMovingBees 						: W3BeeSwarm;
	 var activeAttachedBees 					: W3BeeSwarm;
	
		hint excludedEntitiesTagsForBeeSwarm = "Entities with any of these tags will NOT be damaged";
		
	private const var HANGING_AREA_NAME : name;
	
		default destroyEntAfter = 60.0;
		default isFallingObject = true;
		default autoState = 'HangingIntact';
		default isOnFire = false;
		default HANGING_AREA_NAME = 'hangingDamageArea';
		default beesActivated = false;
	
	event OnDetaching()
	{
		if ( activeMovingBees )
		{
			activeMovingBees.Destroy();
		}
		if ( activeAttachedBees )
		{
			activeAttachedBees.Destroy();
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
				
		hangingDamageArea = GetComponent(HANGING_AREA_NAME);
		
		hangingDamageArea.SetEnabled(false);
		
		originPoint = GetWorldPosition();
		
		GotoStateAuto();
	}
	
	event OnStreamIn()
	{
		Log( "Beehive streamed in" );
	}
	
	event OnStreamOut()
	{
		Log( "Beehive streamed out" );
	}
	
		
	public function EnableHangingDamageArea(flag : bool)
	{
		hangingDamageArea.SetEnabled(flag);
		
		if(!flag)
		{
			actorsInHangArea.Clear();
		}
	}
		
	event OnFireHit( source : CGameplayEntity )
	{
		super.OnFireHit( source );
		isOnFire = true;
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		super.OnInteraction(actionName,activator);
	}
	
	public function IsOnFire() : bool
	{
		return isOnFire;
	}
	
	public function OnShotByProjectile()
	{
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		if(currentStateName == 'HangingIntact' || currentStateName == 'HangingBurning')
			Fall();
	}
	
	public function Fall()
	{
		if(!isFallingObject)
			return;
			
		GotoState( 'Falling' );
	}
	
	//hanging damage
	timer function HangAreaDamage(dt : float, id : int)
	{
		var i : int;
		
		for(i=0; i<actorsInHangArea.Size(); i+=1)
		{
			actorsInHangArea[i].AddEffectCustom(hangingBuffParams);
		}
	}
	
	// unused for now
	// direct damage to trigger quen
	// adding very small damage here, because when in channeled quen, player is immune to EET_Swarm, therefore no FX is being played when we move through bees using quen
	timer function DummyDamage(dt : float, id : int)
	{
		var i : int;
		var damage : W3DamageAction;
		
		for(i=0; i<actorsInHangArea.Size(); i+=1)
		{
			damage = new W3DamageAction in this;
			damage.Initialize( this, actorsInHangArea[i], NULL, this, EHRT_None, CPS_Undefined, false, false, false, true );
			damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, 0.0001 );
			theGame.damageMgr.ProcessAction( damage );
				
			delete damage;
		}
	}
}
//-------------------------------------------------------------------  HANGING  --------------------------------------------------------------------------
state HangingIntact in CBeehiveEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.EnableHangingDamageArea(true);
		
		parent.PlayEffect( 'bee_default' );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.OnAardHit( sign );
		parent.Fall();
	}
	
	event OnFireHit( source : CGameplayEntity )
	{
		parent.OnFireHit( source );
		
		parent.GotoState( 'HangingBurning' );
	}
	
	event OnLeaveState( prevStateName : name )
	{
		parent.EnableHangingDamageArea(false);
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		if(area.GetName() == "hangingDamageArea")
		{
			actor = (CActor)activator.GetEntity();
			if(actor)
			{
				parent.actorsInHangArea.PushBack(actor);
				if(parent.actorsInHangArea.Size() == 1)
				{
					if(parent.hangingBuffParams.effectType == EET_Undefined)
					{
						parent.hangingBuffParams.effectType = EET_Swarm;
						parent.hangingBuffParams.vibratePadLowFreq = 0.1;
						parent.hangingBuffParams.vibratePadHighFreq = 0.2;
						parent.hangingBuffParams.creator = parent;
						parent.hangingBuffParams.sourceName = "hanging beehive";
						parent.hangingBuffParams.duration = 0.25;
						parent.hangingBuffParams.effectValue = parent.damageVal;
					}
					parent.AddTimer('HangAreaDamage', 0.2, true);
					//parent.AddTimer('DummyDamage', 0.75, true);
				}
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		if(area.GetName() == "hangingDamageArea")
		{
			actor = (CActor)activator.GetEntity();
			if(actor)
			{
				parent.actorsInHangArea.Remove(actor);
				if(parent.actorsInHangArea.Size() == 0)
				{
					parent.RemoveTimer('HangAreaDamage');
					//parent.RemoveTimer('DummyDamage');
				}
			}
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{	
		var entityTemplate : CEntityTemplate;
		var parentPos : Vector;
		var movingBees, attachedBees : W3BeeSwarm;
		
		parent.OnInteraction(actionName,activator);
		entityTemplate = (CEntityTemplate)LoadResource('bees');
		if ( entityTemplate && !parent.beesActivated )
		{
			parentPos = parent.GetWorldPosition();
				
			movingBees = (W3BeeSwarm)theGame.CreateEntity( entityTemplate, parentPos);
			parent.activeMovingBees   = movingBees;
			movingBees.damageVal = parent.damageVal;
			movingBees.SetSwarmOriginEntity(parent);
			if( parent.desiredTargetTagForBeesSwarm != '' )
			{
				movingBees.desiredTargetTag = parent.desiredTargetTagForBeesSwarm;
			}
			if(parent.excludedEntitiesTagsForBeeSwarm.Size() > 0)
			{
				movingBees.excludedEntitiesTags = parent.excludedEntitiesTagsForBeeSwarm;
			}
			parent.beesActivated = true;
			parent.GetComponent('Loot').SetEnabled(true);			
		}
	}
	
}

//-------------------------------------------------------------------  FALLING  --------------------------------------------------------------------------
state Falling in CBeehiveEntity
{	
	event OnEnterState( prevStateName : name )
	{
		FallDown();
	}
	
	entry function FallDown()
	{
		var groundLevel, currentPos : Vector;
		var rot : EulerAngles;
		var beehiveComp : CComponent;
		
		//enable dynamic physics
		beehiveComp = parent.GetComponent('beehive');
		beehiveComp.SetEnabled(true);
		
		//register receiving collision events - for now we don't need a callback
		SetPhysicalEventOnCollision(beehiveComp, parent);
	}
	
	event OnCollision(object : CObject, actorIndex : int, shapeIndex : int)
	{
		if(parent.IsOnFire())
			parent.GotoState('OnGroundBurned');
		else
			parent.GotoState( 'OnGroundActive' );
	}
}

//-------------------------------------------------------------------  GROUND INTACT  --------------------------------------------------------------------------
state OnGroundActive in CBeehiveEntity
{
	event OnEnterState( prevStateName : name )
	{
		var entityTemplate : CEntityTemplate;
		var parentPos : Vector;
		var movingBees, attachedBees : W3BeeSwarm;
	
		parent.StopAllEffects();
		
		//spawn bees
		entityTemplate = (CEntityTemplate)LoadResource('bees');
		if ( entityTemplate )
		{
			parentPos = parent.GetWorldPosition();
			if ( !parent.beesActivated )
			{
				movingBees = (W3BeeSwarm)theGame.CreateEntity( entityTemplate, parentPos);
				parent.activeMovingBees   = movingBees;
				movingBees.damageVal = parent.damageVal;
				movingBees.SetSwarmOriginEntity(parent);
				
				if( parent.desiredTargetTagForBeesSwarm != '' )
				{
					movingBees.desiredTargetTag = parent.desiredTargetTagForBeesSwarm;
				}
				if(parent.excludedEntitiesTagsForBeeSwarm.Size() > 0)
				{
					movingBees.excludedEntitiesTags = parent.excludedEntitiesTagsForBeeSwarm;
				}
			
				parent.beesActivated = true;
			}
			attachedBees = (W3BeeSwarm)theGame.CreateEntity( entityTemplate, parentPos);
			parent.activeAttachedBees = attachedBees;
			attachedBees.CreateAttachment(parent);
			attachedBees.SetVelocity(0);
			attachedBees.damageVal = parent.damageVal;
			attachedBees.SetSwarmOriginEntity(parent);
			
		}
	}

	event OnFireHit( source : CGameplayEntity )
	{
		parent.OnFireHit( source );
		
		parent.StopAllEffects();
		parent.PlayEffect( 'fire' );
		
		parent.GotoState( 'OnGroundBurned' );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.OnAardHit( sign );
		
		if ( VecDistance( parent.originPoint, parent.GetWorldPosition() ) > 50.f )
		{
			if ( parent.activeMovingBees )
			{
				parent.activeMovingBees.Enable(false);
				parent.GotoState( 'OnGroundBurned' );
			}
			if ( parent.activeAttachedBees )
			{
				parent.activeAttachedBees.Enable(false);
				parent.GotoState( 'OnGroundBurned' );
			}
		}
	}
}

//-------------------------------------------------------------------  GROUND BURNED  --------------------------------------------------------------------------
state OnGroundBurned in CBeehiveEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.GetComponent('Loot').SetEnabled(true);
		
		//remove locking on target
		parent.RemoveTag(theGame.params.TAG_SOFT_LOCK);
		
		CBeehiveEntity_OnGroundBurned_Loop();		
	}
	
	entry function CBeehiveEntity_OnGroundBurned_Loop()
	{
		Sleep( 10.0 );
		parent.StopAllEffects();
	}
}

//-------------------------------------------------------------------  HANG BURN  --------------------------------------------------------------------------
state HangingBurning in CBeehiveEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.StopAllEffects();
		
		BurnBeehive();
	}
	
	entry function BurnBeehive()
	{
		parent.PlayEffect( 'fire' );
		parent.PlayEffect( 'bee_fire' );
		
		Sleep(5);
		
		parent.GotoState('Falling');
	}
		
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.OnAardHit( sign );
		parent.Fall();
	}
}