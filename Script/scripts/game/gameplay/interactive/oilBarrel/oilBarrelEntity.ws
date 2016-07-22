enum EOilBarrelOperation
{
	OBO_Ignite,
	OBO_Explode,
}

class COilBarrelEntity extends CGameplayEntity
{
	editable var fx_onInteraction	: name;
	editable var damageRadius		: float;
	editable var damageVal			: float;
	editable var explodeAfter		: float;
	editable var destroyEntAfter	: float;
	editable var randomizeTime		: bool;
	editable var onFireDamagePerSec	: float;
	
	private var isSetOnFire : bool;
	private var isExploding : bool;
	private var onFireDamageArea : CTriggerAreaComponent;
	private var entitiesInOnFireArea : array<CGameplayEntity>;
	
	default randomizeTime = true;
	default isSetOnFire = false;
	default isExploding = false;
	default fx_onInteraction = 'fire';
	default damageRadius = 5;
	default damageVal = 50;
	default explodeAfter = 3.0;
	default destroyEntAfter = 10.0;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{	
		isExploding = false;
		super.OnSpawned(spawnData);
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		var destructionCmp : CDestructionSystemComponent;

		super.OnFireHit(source);
	
		destructionCmp = (CDestructionSystemComponent) GetComponentByClassName('CDestructionSystemComponent');
		if( destructionCmp && destructionCmp.IsDestroyed() )
		{
		}
		else
		{
			if((COilBarrelEntity)source || (W3Petard)source || (W3ExplosiveBolt)source)
				Explosion(0);
			else
				SetOnFire( explodeAfter, randomizeTime );
		}
	}
	
	private function EnableOnFireDamageArea()
	{
		var i : int;
		var ents : array<CGameplayEntity>;
		
		onFireDamageArea.SetEnabled(true);
		FindGameplayEntitiesInRange(ents, this, 10, 100000);
		for(i=0; i<ents.Size(); i+=1)
			if(!((COilBarrelEntity)ents[i]) && onFireDamageArea.TestEntityOverlap(ents[i]))
				entitiesInOnFireArea.PushBack(ents[i]);
				
		AddTimer('OnFireTimer', 0.0001, true, , , true);
	}				
	
	function SetOnFire( explTime : float, randomize : bool )
	{
		if( !isSetOnFire )
		{
			onFireDamageArea = (CTriggerAreaComponent)GetComponent('OnFireDamageArea');
			if(onFireDamageArea)
				EnableOnFireDamageArea();
			
			PlayEffect( fx_onInteraction );
			if( randomize )
				AddTimer( 'Explosion', explTime + RandRangeF( 1, 0 ), , , , true );
			else
				AddTimer( 'Explosion', explTime, , , , true );
				
			RemoveTag( theGame.params.TAG_SOFT_LOCK );	
			isSetOnFire = true;	
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		
		if(area == onFireDamageArea)
		{
			ent = (CGameplayEntity)activator.GetEntity();
			if(ent && !entitiesInOnFireArea.Contains(ent))
				entitiesInOnFireArea.PushBack(ent);
				
			if(entitiesInOnFireArea.Size() == 1)
				AddTimer('OnFireTimer', 0.0001, true, , , true);
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		
		if(area == onFireDamageArea)
		{
			ent = (CGameplayEntity)activator.GetEntity();
			if(ent)
				entitiesInOnFireArea.Remove(ent);
		}
	}
	
	timer function OnFireTimer(dt : float, id : int)
	{
		var i : int;
		var actor : CActor;
		var damageAction : W3DamageAction;
	
		//skip if already exploded
		if(isExploding)
		{
			RemoveTimer('OnFireTimer');
			return;
		}
		
		if(entitiesInOnFireArea.Size() == 0)
			RemoveTimer('OnFireTimer');
			
		for(i=entitiesInOnFireArea.Size()-1; i>=0; i-=1)
		{
			actor = (CActor)entitiesInOnFireArea[i];
			
			if(actor && onFireDamagePerSec > 0)
			{
				if(!actor.IsAlive())
				{
					entitiesInOnFireArea.Erase(i);
					continue;					
				}
				
				damageAction = new W3DamageAction in this;
				damageAction.Initialize(this, actor, this, this, EHRT_None, CPS_Undefined, false, false, false, true);
				damageAction.AddDamage(theGame.params.DAMAGE_NAME_FIRE, onFireDamagePerSec * dt);
				damageAction.SetIsDoTDamage(dt);
				damageAction.SetCanPlayHitParticle(false);
				theGame.damageMgr.ProcessAction(damageAction);
				delete damageAction;
			}
			else if(entitiesInOnFireArea[i] != this)
			{
				entitiesInOnFireArea[i].OnFireHit(this);
			}
		}
	}

	timer function Explosion( deltaTime : float, optional id : int)
	{
		var damage : W3DamageAction;
		var entitiesInRange : array< CGameplayEntity >;
		var i : int;
		var targetEntity : CActor;
		
		if(isExploding)
			return;
			
		isExploding = true;
		
		if(onFireDamageArea)
			onFireDamageArea.SetEnabled(false);
			
		StopAllEffects();
		PlayEffect( 'explosion' );
		PlayEffect( 'fire_ground' );
		GCameraShake( 1.5, true, GetWorldPosition(), 20.0f );
		AddTimer( 'DestroyEnt', destroyEntAfter + RandRangeF( 1.5 ) );
		
		//Change to another target if player is locked to barrel upon exploding
		if ( thePlayer.IsCameraLockedToTarget() && thePlayer.GetDisplayTarget() == this )
		{
			thePlayer.OnForceSelectLockTarget();
		}
		
		entitiesInRange = GatherTargets();		
		entitiesInRange.Remove(this);
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			targetEntity = (CActor)entitiesInRange[i];
			if(targetEntity)
			{
				damage = new W3DamageAction in this;
				
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_None, CPS_Undefined, false, false, false, true );
				if ( targetEntity == GetWitcherPlayer() )
					damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)GetWitcherPlayer().GetLevel() );
				else
					damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)CalculateAttributeValue(targetEntity.GetAttributeValue('level',,true)) );
				damage.AddEffectInfo(EET_Burning);
				damage.AddEffectInfo(EET_KnockdownTypeApplicator);
				damage.SetProcessBuffsIfNoDamage(true);
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				entitiesInRange[i].OnFireHit(this);
			}
		}
		
		//disable burning fire area once exploded
		if(onFireDamageArea)
			onFireDamageArea.SetEnabled(false);
	}
	
	//Gather targets and do line of sight test.
	//Default test from FindGameplayEntitiesInSphere() tests only bottom position of both entities so if barrel is slightly under terrain 
	//or if there is a small rock on the ground it will fail.
	//
	//Instead we do tests from barrel's half height to target's half height, top and bottom. 
	//If all fail target is not visible, if at least one does not fail target is visible.
	private function GatherTargets() : array<CGameplayEntity>
	{
		var ents : array<CGameplayEntity>;
		var barrelPosMiddle, targetPosMiddle, collisionPos, collisionNormal : Vector;
		var i : int;
		var box : Box;
		var height : float;
		var world : CWorld;
				
		world = theGame.GetWorld();
		GetStorageBounds(box);
		height = AbsF(box.Min.Z - box.Max.Z);
		barrelPosMiddle = GetWorldPosition() + GetWorldUp() * (height/2);
			
		//get all without line of sight test
		FindGameplayEntitiesInSphere(ents, barrelPosMiddle, damageRadius, 1000);
		
		//do line of sight test
		for(i=ents.Size()-1; i>=0; i-=1)
		{
			//skip entities we get almost always but never care for
			if( (W3BoltProjectile)ents[i] || (W3SignEntity)ents[i] || (CollisionTrajectory)ents[i])
			{
				ents.Erase(i);
				continue;
			}
		
			ents[i].GetStorageBounds(box);
			height = AbsF(box.Min.Z - box.Max.Z);
			targetPosMiddle = ents[i].GetWorldPosition() + ents[i].GetWorldUp() * (height/2);
			
			//test middle - middle
			if(world.StaticTrace(barrelPosMiddle, targetPosMiddle, collisionPos, collisionNormal))
			{
				//some obstruction
				ents.Erase(i);				
			}			
		}
		
		return ents;
	}
	
	timer function DestroyEnt( deltaTime : float , id : int)
	{
		StopAllEffects();
		Destroy();
	}
	
	event OnManageOilBarrel( operations : array< EOilBarrelOperation > )
	{
		if(operations.Contains(OBO_Explode))
			Explosion(0);
		else if(operations.Contains(OBO_Ignite))
			SetOnFire(explodeAfter,randomizeTime);
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return !isExploding;
	}	
}