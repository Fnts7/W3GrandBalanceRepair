//
//	@TODO - pass effects, damage or whatever somehow (maybe hardcoded) ?
//

struct SYrdenEffects
{
	editable var castEffect		: name;
	editable var placeEffect	: name;
	editable var shootEffect	: name;
	editable var activateEffect : name;
}

statemachine class W3YrdenEntity extends W3SignEntity
{
	editable var effects		: array< SYrdenEffects >;
	editable var projTemplate	: CEntityTemplate;
	editable var projDestroyFxEntTemplate : CEntityTemplate;
	editable var runeTemplates	: array< CEntityTemplate >;

	protected var validTargetsInArea, allActorsInArea : array< CActor >;
	protected var flyersInArea	: array< CNewNPC >;
	
	protected var trapDuration	: float;
	protected var charges		: int;
	protected var isPlayerInside : bool;
	protected var baseModeRange : float;
	
	public var notFromPlayerCast : bool;
	public var fxEntities : array< CEntity >;
	
	default skillEnum = S_Magic_3;

	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		notFromPlayerCast = notPlayerCast;
		
		return super.Init(inOwner, prevInstance, skipCastingAnimation, notPlayerCast);
	}
		
	public function GetSignType() : ESignType
	{
		return ST_Yrden;
	}
		
	public function GetIsPlayerInside() : bool
	{
		return isPlayerInside;
	}
	
	public function SkillUnequipped(skill : ESkill)
	{
		var i : int;
	
		super.SkillUnequipped(skill);
		
		if(skill == S_Magic_s11)
		{
			for(i=0; i<validTargetsInArea.Size(); i+=1)
				validTargetsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
	}
	
	public function IsValidTarget( target : CActor ) : bool
	{
		return target && target.GetHealth() > 0.f && target.GetAttitude( owner.GetActor() ) == AIA_Hostile;
	}
	
	public function SkillEquipped(skill : ESkill)
	{
		var i : int;
		var params : SCustomEffectParams;
	
		super.SkillEquipped(skill);
	
		if(skill == S_Magic_s11)
		{
			params.effectType = EET_YrdenHealthDrain;
			params.creator = owner.GetActor();
			params.sourceName = "yrden_mode0";
			params.isSignEffect = true;
			
			for(i=0; i<validTargetsInArea.Size(); i+=1)
				validTargetsInArea[i].AddEffectCustom(params);
		}
	}

	event OnProcessSignEvent( eventName : name )
	{
		/*if( eventName == 'yrden_alternate_ready' )
		{
			PlayEffect('yrden_ready');
		}
		else */if ( eventName == 'yrden_draw_ready' )
		{
			PlayEffect( 'yrden_cast' );
		}
		else
		{
			return super.OnProcessSignEvent(eventName);
		}
		
		return true;
	}
	
	public final function ClearActorsInArea()
	{
		var i : int;
		
		for(i=0; i<validTargetsInArea.Size(); i+=1)
			validTargetsInArea[i].SignalGameplayEventParamObject('LeavesYrden', this );
		
		validTargetsInArea.Clear();
		flyersInArea.Clear();
		allActorsInArea.Clear();
	}
	
	protected function GetSignStats()
	{
		var chargesAtt, trapDurationAtt : SAbilityAttributeValue;
	
		super.GetSignStats();
		
		chargesAtt = owner.GetSkillAttributeValue(skillEnum, 'charge_count', false, true);
		trapDurationAtt = owner.GetSkillAttributeValue(skillEnum, 'trap_duration', false, true);
		baseModeRange = CalculateAttributeValue( owner.GetSkillAttributeValue(skillEnum, 'range', false, true) );
		
		trapDurationAtt += owner.GetActor().GetTotalSignSpellPower(skillEnum);
		trapDurationAtt.valueMultiplicative -= 1;	//100% base spell power
		
		charges = (int)CalculateAttributeValue(chargesAtt);
		trapDuration = CalculateAttributeValue(trapDurationAtt);
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach(true, true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
		
		PlayEffect( 'cast_yrden' );
		
		if ( owner.ChangeAspect( this, S_Magic_s03 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'YrdenChanneled' );
		}
		else
		{
			GotoState( 'YrdenCast' );
		}
	}
	
	//isCreatedByPlayerCast - set to true if player creates yrden. If it's created by something else, set false.
	protected latent function Place(trapPos : Vector)
	{
		var trapPosTest, trapPosResult, collisionNormal, scale : Vector;
		var rot : EulerAngles;
		var witcher : W3PlayerWitcher;
		var trigger : CComponent;
		var min, max : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		witcher.yrdenEntities.PushBack(this);
		
		DisablePreviousYrdens();
		
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			
			trigger = GetComponent( "Slowdown" );
			scale = trigger.GetLocalScale() * min.valueAdditive;			
			
			trigger.SetScale( scale );
		}
		
		//detach from actor
		Detach();
		
		//wait for detach to process
		SleepOneFrame();
		
		//look for placement pos & teleport
		trapPosTest = trapPos;
		trapPosTest.Z -= 0.5;		
		rot = GetWorldRotation();
		rot.Pitch = 0;
		rot.Roll = 0;
		
		if(theGame.GetWorld().StaticTrace(trapPos, trapPosTest, trapPosResult, collisionNormal))
		{
			trapPosResult.Z += 0.1;	//so it's placed a bit above the ground so we could see all fx properly
			TeleportWithRotation ( trapPosResult, rot );
		}
		else
		{
			TeleportWithRotation ( trapPos, rot );
		}
		
		//wait for teleport to finish
		SleepOneFrame();
		
		AddTimer('TimedCanceled', trapDuration, , , , true);
		
		if(!notFromPlayerCast)
			owner.GetActor().OnSignCastPerformed(ST_Yrden, fireMode);
	}
	
	private final function DisablePreviousYrdens()
	{
		var maxCount, i, size, currCount : int;
		var isAlternate : bool;
		var witcher : W3PlayerWitcher;
		
		//check which Yrdens are alternate and which not
		isAlternate = IsAlternateCast();
		witcher = GetWitcherPlayer();
		size = witcher.yrdenEntities.Size();
		
		//calculate max allowed Yrden's count
		maxCount = 1;
		currCount = 0;
		
		if(!isAlternate && owner.CanUseSkill(S_Magic_s10) && owner.GetSkillLevel(S_Magic_s10) >= 2)
		{
			maxCount += 1;
		}
		
		for(i=size-1; i>=0; i-=1)
		{
			//yrdens that timed out
			if(!witcher.yrdenEntities[i])
			{
				witcher.yrdenEntities.Erase(i);		//cannot use EraseFast() as we need to keep the order of list unchanged!
				continue;
			}
			
			if(witcher.yrdenEntities[i].IsAlternateCast() == isAlternate)
			{
				currCount += 1;
				
				//if limit exceeded
				if(currCount > maxCount)
				{
					witcher.yrdenEntities[i].OnSignAborted(true);
				}
			}
		}
	}
	
	timer function TimedCanceled( delta : float , id : int)
	{
		var i : int;
		var areas : array<CComponent>;
		
		isPlayerInside = false;
		
		super.CleanUp();
		StopAllEffects();
		
		//disable the sign
		areas = GetComponentsByClassName('CTriggerAreaComponent');
		for(i=0; i<areas.Size(); i+=1)
			areas[i].SetEnabled(false);
		
		for(i=0; i<validTargetsInArea.Size(); i+=1)
		{
			validTargetsInArea[i].BlockAbility('Flying', false);
		}
		
		for( i=0; i<fxEntities.Size(); i+=1 )
		{
			fxEntities[i].StopAllEffects();
			fxEntities[i].DestroyAfter( 5.f );
		}
		
		UpdateGryphonSetBonusYrdenBuff();
		ClearActorsInArea();
		DestroyAfter(3);
	}
	
	//YYYY broken, range is 0 always
	protected function NotifyGameplayEntitiesInArea( componentName : CName )
	{
		var entities : array<CGameplayEntity>;
		var triggerAreaComp : CTriggerAreaComponent;
		var i : int;
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		triggerAreaComp = (CTriggerAreaComponent)this.GetComponent( componentName );
		triggerAreaComp.GetGameplayEntitiesInArea( entities, 6.0 );
		
		for ( i=0 ; i < entities.Size() ; i+=1 )
		{
			if( !((CActor)entities[i]) )
				entities[i].OnYrdenHit( ownerActor );
		}
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
	}
	
	protected function UpdateGryphonSetBonusYrdenBuff()
	{
		var player : W3PlayerWitcher;
		var i : int;
		var isPlayerInYrden, hasBuff : bool;
		
		player = GetWitcherPlayer();
		hasBuff = player.HasBuff( EET_GryphonSetBonusYrden );
		
		if ( player.IsSetBonusActive( EISB_Gryphon_2 ) ) 
		{
			isPlayerInYrden = false;
			
			for( i=0 ; i < player.yrdenEntities.Size() ; i+=1 )
			{
				if( !player.yrdenEntities[i].IsAlternateCast() && player.yrdenEntities[i].isPlayerInside )
				{
					isPlayerInYrden = true;
					break;
				}
			}
			
			if( isPlayerInYrden && !hasBuff )
			{
				player.AddEffectDefault( EET_GryphonSetBonusYrden, NULL, "GryphonSetBonusYrden" );
			}
			else if( !isPlayerInYrden && hasBuff )
			{
				player.RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
			}
		}
		else if( hasBuff )
		{
			player.RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
		}
	}
}

state YrdenCast in W3YrdenEntity extends NormalCast
{
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	//OnEnded is called when the trap object is destroyed not when you end cast
			parent.StopEffect( 'yrden_cast' );			
			parent.GotoState( 'YrdenSlowdown' );
		}
	}
}

state YrdenChanneled in W3YrdenEntity extends Channeling
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		caster.OnDelayOrientationChange();
		caster.GetActor().PauseStaminaRegen( 'SignCast' );
		ChannelYrden();
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	//OnEnded is called when the trap object is destroyed not when you end cast
		}
		
		parent.StopEffect( 'yrden_cast' );
		
		caster.GetActor().ResumeStaminaRegen( 'SignCast' );
		
		parent.GotoState( 'YrdenShock' );
	}
	
	event OnEnded(optional isEnd : bool)
	{
	}
	
	event OnSignAborted( optional force : bool )
	{
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}		
	
	entry function ChannelYrden()
	{
		while( Update() )
		{
			Sleep( 0.0001f );
		}
		
		OnSignAborted();
	}
}

//alternate mode
state YrdenShock in W3YrdenEntity extends Active
{
	private var usedShockAreaName : name;
	
	event OnEnterState( prevStateName : name )
	{
		var skillLevel : int;
		
		super.OnEnterState( prevStateName );
		
		skillLevel = caster.GetSkillLevel(parent.skillEnum);
		
		if(skillLevel == 1)
			usedShockAreaName = 'Shock_lvl_1';
		else if(skillLevel == 2)
			usedShockAreaName = 'Shock_lvl_2';
		else if(skillLevel == 3)
			usedShockAreaName = 'Shock_lvl_3';
			
		parent.GetComponent(usedShockAreaName).SetEnabled( true );
		
		ActivateShock();
		parent.NotifyGameplayEntitiesInArea( usedShockAreaName );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.GetComponent(usedShockAreaName).SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	entry function ActivateShock()
	{
		var i, size : int;
		var target : CActor;
		var hitEntity : CEntity;
		var shot, validTargetsUpdated : bool;
			
		parent.Place(parent.GetWorldPosition());
		
		parent.PlayEffect( parent.effects[parent.fireMode].placeEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
		
		//don't start firing right away (fx don't show yet etc, looks & feels bad)
		Sleep(1.f);
		
		while( parent.charges > 0 )
		{
			hitEntity = NULL;
			shot = false;
			size = parent.validTargetsInArea.Size();
			if ( size > 0 )
			{
				do
				{
					target = parent.validTargetsInArea[RandRange(size)];
					if(target.GetHealth() <= 0.f || target.IsInAgony() )
					{
						parent.validTargetsInArea.Remove(target);
						size -= 1;
						target = NULL;
					}
				}while(size > 0 && !target)
				
				if(target && target.GetGameplayVisibility())
				{
					shot = true;
					hitEntity = ShootTarget(target, true, 0.2f, false);
				}
			}
			
			if(hitEntity)
			{
				Sleep(2.f);		//tried to shoot and hit - wait 2 secs between shots
			}
			else if(shot)
			{
				Sleep(0.1f);	//tried to shoot but failed - make next attemp fast
			}
			else
			{
				validTargetsUpdated = false;
				
				//there is no one to shoot at - check if some actors became valid targets in the meantime (e.g. changed attitude)
				if( parent.validTargetsInArea.Size() == 0 )
				{				
					for( i=0; i<parent.allActorsInArea.Size(); i+=1 )
					{
						if( parent.IsValidTarget( parent.allActorsInArea[i] ) )
						{
							parent.validTargetsInArea.PushBack( parent.allActorsInArea[i] );
							validTargetsUpdated = true;
						}
					}
				}
				
				//there is no one to shoot at, keep checking after delay
				if( !validTargetsUpdated )
				{
					Sleep(1.f);		
				}
			}
		}
		
		parent.GotoState( 'Discharged' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;		
		var projectile : CProjectileTrajectory;		
		
		target = (CNewNPC)(activator.GetEntity());
		
		if( target && !parent.allActorsInArea.Contains( target ) )
		{
			parent.allActorsInArea.PushBack( target );
		}
		
		if ( parent.charges && parent.IsValidTarget( target ) && !parent.validTargetsInArea.Contains(target) )
		{
			if( parent.validTargetsInArea.Size() == 0 )
			{
				parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
			}
			
			parent.validTargetsInArea.PushBack( target );			
			
			target.OnYrdenHit( caster.GetActor() );
			
			target.SignalGameplayEventParamObject('EntersYrden', parent );
		}		
		else if(parent.projDestroyFxEntTemplate)
		{
			projectile = (CProjectileTrajectory)activator.GetEntity();
			
			if(projectile && !((W3SignProjectile)projectile) && IsRequiredAttitudeBetween(caster.GetActor(), projectile.caster, true, true, false))
			{
				if(projectile.IsStopped())
				{
					//case where npc is standing in yrden's range and he draws a new arrow
					projectile.SetIsInYrdenAlternateRange(parent);
				}
				else
				{			
					ShootDownProjectile(projectile);
				}
			}
		}
	}
	
	public final function ShootDownProjectile(projectile : CProjectileTrajectory)
	{
		var hitEntity, fxEntity : CEntity;
		
		hitEntity = ShootTarget(projectile, false, 0.1f, true);
					
		//if hit projectile or there's nothing in the way then destroy the projectile
		if(hitEntity == projectile || !hitEntity)
		{
			//'spark' on destroyed projectile
			fxEntity = theGame.CreateEntity( parent.projDestroyFxEntTemplate, projectile.GetWorldPosition() );
			
			//fx if no collision (projectile is hard to catch with RayCast for some bizzare reason. In any way if there is no collision then 
			//for sure the projectile is not obstructed. If we didn't detect collision the fx wete not played so we do it manually here)
			if(!hitEntity)
			{
				parent.PlayEffect( parent.effects[1].shootEffect );		//flash on trap
				parent.PlayEffect( parent.effects[1].shootEffect, fxEntity );
			}
			
			projectile.StopProjectile();
			projectile.Destroy();			
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var projectile : CProjectileTrajectory;
		
		target = (CNewNPC)(activator.GetEntity());
		
		if ( target && parent.charges && target.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			parent.validTargetsInArea.Erase( parent.validTargetsInArea.FindFirst( target ) );
			target.SignalGameplayEventParamObject('LeavesYrden', parent );
		}
		
		if ( parent.validTargetsInArea.Size() <= 0 )
		{
			parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
		}
	}
	
	var traceFrom, traceTo : Vector;
	private function ShootTarget( targetNode : CNode, useTargetsPositionCorrection : bool, extraRayCastLengthPerc : float, useProjectileGroups : bool ) : CEntity
	{
		var results : array<SRaycastHitResult>;
		var i, ind : int;
		var min : float;
		var collisionGroupsNames : array<name>;
		var entity : CEntity;
		var targetActor : CActor;
		var targetPos : Vector;
		var physTest : bool;
		
		traceFrom = virtual_parent.GetWorldPosition();
		traceFrom.Z += 1.f;
		
		targetPos = targetNode.GetWorldPosition();
		traceTo = targetPos;
		if(useTargetsPositionCorrection)
			traceTo.Z += 1.f;
		
		traceTo = traceFrom + (traceTo - traceFrom) * (1.f + extraRayCastLengthPerc);
		
		collisionGroupsNames.PushBack( 'RigidBody' );
		collisionGroupsNames.PushBack( 'Static' );
		collisionGroupsNames.PushBack( 'Debris' );	
		collisionGroupsNames.PushBack( 'Destructible' );	
		collisionGroupsNames.PushBack( 'Terrain' );
		collisionGroupsNames.PushBack( 'Phantom' );
		collisionGroupsNames.PushBack( 'Water' );
		collisionGroupsNames.PushBack( 'Boat' );		
		collisionGroupsNames.PushBack( 'Door' );
		collisionGroupsNames.PushBack( 'Platforms' );
		
		if(useProjectileGroups)
		{
			collisionGroupsNames.PushBack( 'Projectile' );
		}
		else
		{			
			collisionGroupsNames.PushBack( 'Character' );			
		}
		
		physTest = theGame.GetWorld().GetTraceManager().RayCastSync(traceFrom, traceTo, results, collisionGroupsNames);

		if ( !physTest || results.Size() == 0 )
			FindActorsAtLine( traceFrom, traceTo, 0.05f, results, collisionGroupsNames );
		
		if ( results.Size() > 0 )
		{
			//keep trying while we have valid targets
			while(results.Size() > 0)
			{
				//find closest target
				min = results[0].distance;
				ind = 0;
				
				for(i=1; i<results.Size(); i+=1)
				{
					if(results[i].distance < min)
					{
						min = results[i].distance;
						ind = i;
					}
				}
				
				//if entity check, otherwise it's a miss - break
				if(results[ind].component)
				{
					entity = results[ind].component.GetEntity();
					targetActor = (CActor)entity;
					
					//if friendly moves in on the line of shot - skip shot
					if(targetActor && IsRequiredAttitudeBetween(targetActor, caster.GetActor(), false, false, true))
						return NULL;
					
					//with recent changes when npc dies it's IsAlive() is not updated for 2 more secs so we need to check health as well
					if( (targetActor && targetActor.GetHealth() > 0.f && targetActor.IsAlive()) || (!targetActor && entity) )
					{
						//if alive actor or not an actor
						YrdenTrapHitEnemy(targetActor, results[ind].position);						
						return entity;
					}
					else if(targetActor)
					{
						//dead actor - pick other target (continue while() loop)
						results.EraseFast(ind);
					}
				}
				else
				{
					break;
				}
			}
		}
		
		return NULL;
	}
	
	private final function YrdenTrapHitEnemy(entity : CEntity, hitPosition : Vector)
	{
		var component : CComponent;
		var targetActor, casterActor : CActor;
		var action : W3DamageAction;
		var player : W3PlayerWitcher;
		var skillType : ESkill;
		var skillLevel, i : int;
		var damageBonusFlat : float;		
		var damages : array<SRawDamage>;
		var glyphwordY : W3YrdenEntity;
		
		//fx
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].shootEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
			
		targetActor = (CActor)entity;
		if(targetActor)
		{
			component = targetActor.GetComponent('torso3effect');		
			if ( component )
			{
				parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, component );
			}
		}
		
		if(!targetActor || !component)
		{
			parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, entity );
		}

		//ammo
		//if(FactsQuerySum("infinite_yrden_trap") <= 0)
			parent.charges -= 1;
		
		//hit
		casterActor = caster.GetActor();
		if ( casterActor && (CGameplayEntity)entity)
		{
			//needed vars
			action =  new W3DamageAction in theGame.damageMgr;
			player = caster.GetPlayer();
			skillType = virtual_parent.GetSkill();
			skillLevel = player.GetSkillLevel(skillType);
			
			//init basic damage action
			action.Initialize( casterActor, (CGameplayEntity)entity, this, casterActor.GetName()+"_sign", EHRT_Light, CPS_SpellPower, false, false, true, false, 'yrden_shock', 'yrden_shock', 'yrden_shock', 'yrden_shock');
			virtual_parent.InitSignDataForDamageAction(action);
			action.hitLocation = hitPosition;
			action.SetCanPlayHitParticle(true);
			
			//bonus damage from skill level
			if(player && skillLevel > 1)
			{
				action.GetDTs(damages);
				damageBonusFlat = CalculateAttributeValue(player.GetSkillAttributeValue(skillType, 'damage_bonus_flat_after_1', false, true));
				action.ClearDamage();
				
				for(i=0; i<damages.Size(); i+=1)
				{
					damages[i].dmgVal += damageBonusFlat * (skillLevel - 1);
					action.AddDamage(damages[i].dmgType, damages[i].dmgVal);
				}
			}
			
			//process
			theGame.damageMgr.ProcessAction( action );
		}
		else
		{
			entity.PlayEffect( 'yrden_shock' );
		}
		
		if(casterActor.HasAbility('Glyphword 15 _Stats', true))
		{
			glyphwordY = (W3YrdenEntity)theGame.CreateEntity(GetWitcherPlayer().GetSignTemplate(ST_Yrden), entity.GetWorldPosition(), entity.GetWorldRotation() );
			glyphwordY.Init(caster, parent, true, true);
			glyphwordY.CacheActionBuffsFromSkill();
			glyphwordY.GotoState( 'YrdenSlowdown' );
		}
	}
	
	event OnThrowing()
	{
		parent.CleanUp();	//OnEnded is called when the trap object is destroyed not when you end cast
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
		frame.DrawLine(traceFrom, traceTo, Color(255, 255, 0));
	}
}

state YrdenSlowdown in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		var player				: CR4Player;
		
		super.OnEnterState( prevStateName );
		
		parent.GetComponent( 'Slowdown' ).SetEnabled( true );
		parent.PlayEffect( 'yrden_slowdown_sound' );
		
		ActivateSlowdown();
		
		if(!parent.notFromPlayerCast)
		{
			player = caster.GetPlayer();
			
			if( player )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CleanUp();
		parent.GetComponent('Slowdown').SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	private function CleanUp()
	{
		var i, size : int;
		
		size = parent.validTargetsInArea.Size();
		for( i = 0; i < size; i += 1 )
		{
			parent.validTargetsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
		
		for( i=0; i<virtual_parent.fxEntities.Size(); i+=1 )
		{
			virtual_parent.fxEntities[i].StopAllEffects();
			virtual_parent.fxEntities[i].DestroyAfter( 5.f );
		}
	}
	
	event OnThrowing()
	{
		parent.CleanUp();	//OnEnded is called when the trap object is destroyed not when you end cast
	}
	
	event OnSignAborted( force : bool )
	{
		if( force )
			CleanUp();
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}
	
	entry function ActivateSlowdown()
	{
		var obj : CEntity;
		var pos : Vector;
		
		obj = (CEntity)parent;
		pos = obj.GetWorldPosition();
		parent.Place(pos);
		
		CreateTrap();
		
		theGame.GetBehTreeReactionManager().CreateReactionEvent( parent, 'YrdenCreated', parent.trapDuration, 30, 0.1f, 999, true );
		parent.NotifyGameplayEntitiesInArea( 'Slowdown' );
		YrdenSlowdown_Loop();
	}
	
	private function CreateTrap()
	{
		var i, size : int;
		var worldPos : Vector;
		var isSetBonus2Active : bool;
		var worldRot : EulerAngles;
		var polarAngle, yrdenRange, unitAngle : float;
		var runePositionLocal, runePositionGlobal : Vector;
		var entity : CEntity;
		var min, max : SAbilityAttributeValue;
		
		isSetBonus2Active = GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 );
		worldPos = virtual_parent.GetWorldPosition();
		worldRot = virtual_parent.GetWorldRotation();
		yrdenRange = virtual_parent.baseModeRange;
		size = virtual_parent.runeTemplates.Size();
		unitAngle = 2 * Pi() / size;
		
		if( isSetBonus2Active )
		{
			virtual_parent.PlayEffect( 'ability_gryphon_set' );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			yrdenRange *= min.valueAdditive;
		}
		
		for( i=0; i<size; i+=1 )
		{
			polarAngle = unitAngle * i;
			
			runePositionLocal.X = yrdenRange * CosF( polarAngle );
			runePositionLocal.Y = yrdenRange * SinF( polarAngle );
			runePositionLocal.Z = 0.f;
			
			runePositionGlobal = worldPos + runePositionLocal;			
			runePositionGlobal = TraceFloor( runePositionGlobal );
			runePositionGlobal.Z += 0.05f;		//otherwise it's z position is the same as terrain or mesh and you don't know which one will draw
			
			entity = theGame.CreateEntity( virtual_parent.runeTemplates[i], runePositionGlobal, worldRot );
			virtual_parent.fxEntities.PushBack( entity );
		}
	}
	
	entry function YrdenSlowdown_Loop()
	{
		var params, paramsDrain : SCustomEffectParams;
		var casterActor : CActor;
		var i : int;
		var min, max, scale, pts, prc : float;
		var casterPlayer : CR4Player;
		var npc : CNewNPC;
		
		casterActor = caster.GetActor();
		casterPlayer = caster.GetPlayer();
		
		//cache slowdown params
		min = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));

		params.effectType = parent.actionBuffs[0].effectType;
		params.creator = casterActor;
		params.sourceName = "yrden_mode0";
		params.isSignEffect = true;
		params.customPowerStatValue = casterActor.GetTotalSignSpellPower(virtual_parent.GetSkill());
		params.customAbilityName = parent.actionBuffs[0].effectAbilityName;
		params.duration = 0.1;	//continuous inside area
		scale = params.customPowerStatValue.valueMultiplicative / 4;
		params.effectValue.valueAdditive = min + (max - min) * scale;
		params.effectValue.valueAdditive = ClampF( params.effectValue.valueAdditive, min, max );
		
		//cache health drain params
		if(thePlayer.CanUseSkill(S_Magic_s11))
		{
			//previous params are the same
			paramsDrain = params;
			paramsDrain.customAbilityName = '';
			paramsDrain.effectType = EET_YrdenHealthDrain;
		}
						
		while(true)
		{
			//check if flyers landed / crashed
			for(i=parent.flyersInArea.Size()-1; i>=0; i-=1)
			{
				npc = parent.flyersInArea[i];
				if(!npc.IsFlying())
				{
					parent.validTargetsInArea.PushBack(npc);
					npc.BlockAbility('Flying', true);
					parent.flyersInArea.EraseFast(i);
				}
			}
			
			for(i=0; i<parent.validTargetsInArea.Size(); i+=1)
			{			
				//slowdown if Shock Resistance < 100%
				parent.validTargetsInArea[i].GetResistValue(CDS_ShockRes, pts, prc);
				if(prc < 1)
					parent.validTargetsInArea[i].AddEffectCustom(params);			
				
				//hp drain
				if(thePlayer.CanUseSkill(S_Magic_s11))
				{
					parent.validTargetsInArea[i].AddEffectCustom(paramsDrain);
				}
				
				//hit
				parent.validTargetsInArea[i].OnYrdenHit( casterActor );
			}
			
			SleepOneFrame();
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var casterActor : CActor;
		
		target = (CNewNPC)(activator.GetEntity());
		casterActor = caster.GetActor();
		if( (W3PlayerWitcher)activator.GetEntity() )
		{
			parent.isPlayerInside = true;
		}
		
		if( target && !parent.allActorsInArea.Contains( target ) )
		{
			parent.allActorsInArea.PushBack( target );
		}
		
		if ( parent.IsValidTarget( target ) && !parent.validTargetsInArea.Contains(target))
		{
			if (!target.IsFlying())
			{
				//yrden fx when first someone enters area
				if( parent.validTargetsInArea.Size() == 0 )
				{
					parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
				}
				
				parent.validTargetsInArea.PushBack( target );		
				target.SignalGameplayEventParamObject('EntersYrden', parent );
				target.BlockAbility('Flying', true);
			}
			else
			{
				parent.flyersInArea.PushBack(target);
			}
		}
		if( parent.isPlayerInside && GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
		{
			parent.UpdateGryphonSetBonusYrdenBuff();
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var i : int;
		
		target = (CNewNPC)(activator.GetEntity());
	
		if( (W3PlayerWitcher)activator.GetEntity() )
		{
			parent.isPlayerInside = false;
		}
		if( target )
		{
			i = parent.validTargetsInArea.FindFirst( target );
			if( i >= 0 )
			{
				target.RemoveBuff( EET_YrdenHealthDrain );
				
				parent.validTargetsInArea.Erase( i );
			}
			target.SignalGameplayEventParamObject('LeavesYrden', parent );
			target.BlockAbility('Flying', false);
			parent.flyersInArea.Remove(target);
		}
		
		if ( parent.validTargetsInArea.Size() == 0 )
		{
			parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
		}
		if( !parent.isPlayerInside )
		{
			parent.UpdateGryphonSetBonusYrdenBuff();
		}
	}
}

state Discharged in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		YrdenExpire();
	}
	
	entry function YrdenExpire()
	{
		Sleep( 1.f );
		OnSignAborted( true );
	}
}