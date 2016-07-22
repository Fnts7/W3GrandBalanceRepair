﻿/*
	Swarm will pursue player and NPCs but will not wander off too far from origin point.
*/
statemachine class W3BeeSwarm extends CGameplayEntity
{
	editable var damageVal			: SAbilityAttributeValue;
	editable var destroyEntAfter	: float;
	editable var velocity			: float;
	editable var bIsEnabled			: bool;
	editable var AIReactionRange 	: float;
	editable var ignoreNPCsFriendlyToPlayer : bool;
	editable var maxChaseDistance	: float;
	editable var desiredTargetTag	: name;
	editable var excludedEntitiesTags : array<name>;
	editable var factOnDestruction : string;
	
	private var originEntity		: CGameplayEntity;						//origin entity to attach to (optional), bees will not wander too far from it (maxChaseDistance)
	private var originPoint 		: Vector;								//origin point, used if swarm is not attached to origin entity
	private var victims 			: array<SSwarmVictim>;					//actors in damage area
	private var buffParams 			: SCustomEffectParams;
	private var targets				: array<CGameplayEntity>;				//currently found pursuable targets
	private var activeDistanceSquared : float;								//actual activity distance squared
	
	public const var PLAYER_PRESENCE_CHECK_DISTANCE : float;				//distance from player when we start checking bee logic
	public const var PRESENCE_CHECK_DT : float;								//time frequency of checking player proximity
	public const var TARGETS_CHECK_DT : float;								//how often we check for pursuable targets

		default destroyEntAfter = 2.0;
		default velocity = 3.0;
		default AIReactionRange = 8;
		default bIsEnabled = true;
		default maxChaseDistance = 20;
		default PLAYER_PRESENCE_CHECK_DISTANCE = 30;
		default PRESENCE_CHECK_DT = 2;
		default TARGETS_CHECK_DT = 1;
	
		hint AIReactionRange = "Max range at which bees will hunt player";
		hint ignoreNPCsFriendlyToPlayer = "Bees will not damage or target NPCs that are friendly towards player";
		hint excludedEntitiesTags = "Entities having any of those tags will not be attacked";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);

		originPoint = GetWorldPosition();
		activeDistanceSquared = MaxF(maxChaseDistance, PLAYER_PRESENCE_CHECK_DISTANCE);
		activeDistanceSquared *= activeDistanceSquared;
		Enable( bIsEnabled );
	}
	
	function Enable( flag : bool )
	{
		bIsEnabled = flag;
		
		if ( bIsEnabled )
		{
			if(velocity <= 0.01)
				GotoState('Stationary');
			else
				GotoState('FarFromPlayer');
		}
		else
		{
			GotoState('Disabled');			
		}
	}
	
	public function SetVelocity(newVel : float)
	{
		if(newVel == 0)
		{			
			GotoState('Stationary');
		}
		else
		{
			if(IsPlayerTooFar())
				GotoState('FarFromPlayer');
			else
				GotoState('BeeSwarm_Idle');
		}
	}
	
	//checks if player is too far away and we can shut down the logic
	public function IsPlayerTooFar() : bool
	{
		var originToPlayerDistSq : float;
		
		if(!thePlayer)
			return true;
			
		originToPlayerDistSq = VecDistanceSquared(GetOriginPoint(), thePlayer.GetWorldPosition());	
		return originToPlayerDistSq > activeDistanceSquared;
	}
		
	event OnFireHit(source : CGameplayEntity)
	{
		if( bIsEnabled )
		{	
			Enable(false);
			PlayEffectSingle( 'bee_fire' );			
			AddTimer( 'DestroyEnt', destroyEntAfter );
		}
		
		super.OnFireHit(source);
	}
	
	timer function DestroyEnt(dt : float, id : int)
	{
		if(buffParams.buffSpecificParams)
			delete buffParams.buffSpecificParams;
			
		
		if( factOnDestruction  != "" )
			FactsAdd(factOnDestruction, 1, -1);
		
		Destroy();
	}
	
	
	//sets origin entity to attach to
	public function SetSwarmOriginEntity(e : CGameplayEntity)
	{
		originEntity = e;
	}
	
	//Gets position of origin
	public function GetOriginPoint() : Vector
	{
		//if attached to something
		if(originEntity)
			return originEntity.GetWorldPosition();
			
		return originPoint;
	}
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		var swarmVictim : SSwarmVictim;
		var wasVictimBefore : bool;
		var i, cnt : int;
		
		if(area.GetName() == "damageArea")
		{
			victim = (CActor)activator.GetEntity();
			if(victim)
			{
				wasVictimBefore = false;
				cnt = 0;
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].actor == victim)
					{
						wasVictimBefore = true;						
						victims[i].inTrigger = true;
					}
					
					if(victims[i].inTrigger)
						cnt += 1;
				}
				
				if(!wasVictimBefore)
				{
					swarmVictim.actor = victim;
					swarmVictim.timeInSwarm = 0.f;
					swarmVictim.inTrigger = true;
					victims.PushBack( swarmVictim );
					cnt += 1;
				}
				
				if ( cnt == 1 )
					AddTimer( 'ApplyEffect', 0.1, true );
					
				return true;
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		var i : int;
		var empty : bool;
		
		if(area.GetName() == "damageArea")
		{
			victim = (CActor)activator.GetEntity();
			if(victim)
			{
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].actor == victim)
					{
						victims[i].inTrigger = false;
						break;
					}
				}
				
				empty = true;
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].inTrigger)
					{
						empty = false;
						break;
					}
				}
				
				if(empty)
					RemoveTimer( 'ApplyEffect' );
					
				return true;
			}
		}
	}
		
	timer function ApplyEffect( deltaTime : float , id : int)
	{
		var i : int;
		var specParams : W3BuffDoTParams;
		var damageAction : W3DamageAction;
		var damage : float;
		
		if(buffParams.effectType == EET_Undefined)
		{
			specParams = new W3BuffDoTParams in this;
			specParams.isEnvironment = true;
			
			buffParams.vibratePadLowFreq = 0.1;
			buffParams.vibratePadHighFreq = 0.2;			
			buffParams.effectType = EET_Swarm;
			buffParams.creator = this;
			buffParams.sourceName = "bee_swarm";
			buffParams.duration = 1;
			buffParams.effectValue = damageVal;			
			buffParams.buffSpecificParams = specParams;
		}
		
		for ( i = 0; i < victims.Size(); i += 1 ) 
		{
			if(!victims[i].inTrigger)
				continue;
				
			victims[i].timeInSwarm += deltaTime;
			
			//for NPCs: CS for first 3 secs every 15 secs, otherwise just damage
			if( (CPlayer)victims[i].actor || CeilF(victims[i].timeInSwarm) % 15 < 3)
			{
				victims[i].actor.AddEffectCustom(buffParams);
			}
			else
			{
				damageAction = new W3DamageAction in theGame;
				
				damageAction.Initialize(this, victims[i].actor, NULL, "beeSwarm3Plus", EHRT_None, CPS_Undefined, false, false, false, true);
				damage = deltaTime * ( damageVal.valueAdditive + damageVal.valueMultiplicative * victims[i].actor.GetMaxHealth() );
				damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, damage);
				damageAction.SetIsDoTDamage(deltaTime);
				damageAction.SetIgnoreArmor(true);
				damageAction.SetCanPlayHitParticle(false);
				theGame.damageMgr.ProcessAction( damageAction );
				
				delete damageAction;
			}				
		}
	}
	
	timer function CheckForTargets(dt : float, id : int)
	{
		var i,j : int;
		var distSq : float;
		var orig : Vector;
		
		//targets in 'AI' range
		targets.Clear();
		FindGameplayEntitiesInCylinder(targets, GetWorldPosition(), AIReactionRange, 10, 10000, '', FLAG_OnlyAliveActors + FLAG_TestLineOfSight);
		
		//filtering
		distSq = (maxChaseDistance - 1) * (maxChaseDistance - 1);
		orig = GetOriginPoint();
		for(i=targets.Size()-1; i>=0; i-=1)
		{
			//remove targets which are too far away from origin
			if(VecDistanceSquared(targets[i].GetWorldPosition(), orig) > distSq)
			{
				targets.Erase(i);
				continue;
			}
				
			//attitude filters
			if(ignoreNPCsFriendlyToPlayer && targets[i] != thePlayer && GetAttitudeBetween(targets[i], thePlayer) == AIA_Friendly)
			{
				targets.Erase(i);
				continue;
			}
			
			//tag filters
			for(j=0; j<excludedEntitiesTags.Size(); j+=1)
			{
				if(targets[i].HasTag(excludedEntitiesTags[j]))
				{
					targets.Erase(i);
					break;
				}
			}
		}
	}
	
	public function HasTarget() : bool
	{
		return targets.Size() > 0;
	}
	
	public function GetTargets() : array<CGameplayEntity>
	{
		return targets;
	}
	
	public function ClearVictims()
	{
		victims.Clear();
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//While having target and player is close
state ReturnToOrigin in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		BeeSwarm_ReturnToOrigin_Loop();
	}
	
	entry function BeeSwarm_ReturnToOrigin_Loop()
	{
		var swarmPos, targetPos, orPoint : Vector;
		var dt : float;
		
		dt = 0.03;
		while(true)
		{
			swarmPos = virtual_parent.GetWorldPosition();
			orPoint = virtual_parent.GetOriginPoint();
			targetPos = swarmPos + VecNormalize( orPoint - swarmPos ) * dt * virtual_parent.velocity;
			virtual_parent.Teleport(targetPos);
			
			if(VecDistance(targetPos, orPoint) <= 0.2)
			{
				if(virtual_parent.IsPlayerTooFar())
					virtual_parent.GotoState('FarFromPlayer');
				else
					virtual_parent.GotoState('BeeSwarm_Idle');
			}
				
			if(virtual_parent.HasTarget())
				virtual_parent.GotoState('PursueTarget');
				
			Sleep(dt);
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//While having target and player is close
state PursueTarget in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		BeeSwarm_PursueTarget_Loop();
	}
	
	entry function BeeSwarm_PursueTarget_Loop()
	{
		var swarmPos, targetPos, actorPos, orPoint : Vector;
		var distance, minDist, distanceToOrigin, dt : float;
		var i : int;
		var ents : array<CGameplayEntity>;
		var actor : CActor;
		var specParams : W3BuffDoTParams;
		
		dt = 0.03;
		do
		{			
			ents = virtual_parent.GetTargets();
			
			if(ents.Size() == 0)
				break;
			
			swarmPos = virtual_parent.GetWorldPosition();
			minDist = virtual_parent.AIReactionRange + 1;
			for(i=0; i<ents.Size(); i+=1)
			{
				actor = (CActor)ents[i];
				if(actor)
				{					
					actorPos = actor.GetWorldPosition();
					distance = VecDistance(swarmPos, actorPos);
					if(distance < minDist)
					{
						minDist = distance;
						targetPos = actorPos;
					}
					
					if( virtual_parent.desiredTargetTag != '' && actor.HasTag( virtual_parent.desiredTargetTag ) )
					{
						minDist = distance;
						targetPos = actorPos;
						break;
					}
				}
			}

			//don't teleport if distance is small (performance when target is standing in place) or too far
			orPoint = virtual_parent.GetOriginPoint();
			distanceToOrigin = VecDistance(targetPos, orPoint);
			
			if(minDist > 0.2 && minDist <= virtual_parent.AIReactionRange)
				virtual_parent.Teleport( swarmPos + VecNormalize( targetPos - swarmPos ) * dt * virtual_parent.velocity );
				
			Sleep(dt);
			
		}while(distanceToOrigin <= virtual_parent.maxChaseDistance)
		
		virtual_parent.GotoState('ReturnToOrigin');
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//While being close to player but there is noone to chase
state BeeSwarm_Idle in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		BeeSwarm_Idle_Loop();
	}
	
	entry function BeeSwarm_Idle_Loop()
	{
		//will not move ever
		if(virtual_parent.velocity <= 0.01)
			return;
			
		virtual_parent.AddTimer('CheckForTargets', virtual_parent.TARGETS_CHECK_DT, true);
		
		while(true)
		{			
			Sleep(virtual_parent.TARGETS_CHECK_DT);
			
			if(virtual_parent.HasTarget())
				virtual_parent.GotoState('PursueTarget');
				
			if(virtual_parent.IsPlayerTooFar())
				virtual_parent.GotoState('FarFromPlayer');
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//While being far away from player
state FarFromPlayer in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		BeeSwarm_FarFromPlayer_Loop();
	}
	
	event OnLeaveState( prevStateName : name )
	{
		BeeSwarm_FarFromPlayer_Loop();
	}
	
	entry function BeeSwarm_FarFromPlayer_Loop()
	{
		virtual_parent.RemoveTimer('CheckForTargets');
		virtual_parent.PlayEffectSingle( 'bee_cloud' );
		
		while(virtual_parent.IsPlayerTooFar())
			Sleep(virtual_parent.PRESENCE_CHECK_DT);
				
		virtual_parent.GotoState('BeeSwarm_Idle');
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Disabled
state Disabled in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		virtual_parent.StopEffect('bee_cloud');
		virtual_parent.RemoveTimer('ApplyEffect');
		virtual_parent.RemoveTimer('CheckForTargets');
		virtual_parent.ClearVictims();
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Does not move
state Stationary in W3BeeSwarm
{
	event OnEnterState( prevStateName : name )
	{
		virtual_parent.RemoveTimer('CheckForTargets');
	}
}