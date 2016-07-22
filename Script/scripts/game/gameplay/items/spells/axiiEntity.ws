﻿struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets		: array<CActor>;
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		if ( inOwner.CanUseSkill(S_Magic_s17) && inOwner.GetSkillLevel(S_Magic_s17) > 1)
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		else
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation );
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		
		SelectTargets();
		
		for(i=0; i<targets.Size(); i+=1)
		{
			AddMagic17Effect(targets[i]);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	//PF: I know that this is hacky hack, but the time has come!
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	//Checks if actor is a valid Axii target
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		//if using channeled axii then additional targets are not taken into consideration unless hostile
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			//friendlies axiiable only if they have axiiable tag
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		//exclude mounted horse, unless it's owner's horse
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	//mounted horse
			{
				if(horse.GetCurrentUser() != owner.GetActor())	//mounted by other than sign owner
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		var projCount, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		if(owner.CanUseSkill(S_Magic_s19))
			projCount = 2;
		else
			projCount = 1;
		
		targets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			projCount -= 1;
			
			if(projCount == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		//add remaining targets
		actors = ownerActor.GetNPCsAndPlayersInCone(15, VecHeading(ownerActor.GetHeadingVector()), 120, 20, , FLAG_OnlyAliveActors + FLAG_TestLineOfSight);
					
		//filter out invalid targets
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			//remove self, slideTarget (already checked) and invalid targets
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		//sort targets by distance
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			//if not inserted
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		//select final targets by distance
		if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
					targets.PushBack(finalActors[i]);
				else
					break;	//no more targets found
			}
		}
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		// should select target first before releasing, because you can change target in the middle of the channel
		//SelectTargets();
				
		// set spawning position
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		// play effects		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		//projectiles - they do only visuals!
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var i : int;
		var duration, durationAnimal : SAbilityAttributeValue;
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		
		//remove immobilize from targets
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		
		//also from orienttation target if targets were not set yet
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		if (targets.Size() > 0 )
		{
			//base duration
			duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
			durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);
			
			duration.valueMultiplicative = 1.0f;
			durationAnimal.valueMultiplicative = 1.0f;
			
			//spell power bonus
			//duration += casterActor.GetTotalSignSpellPower(skillEnum);
			//durationAnimal += casterActor.GetTotalSignSpellPower(skillEnum);
			if(owner.CanUseSkill(S_Magic_s19))
			{
				duration -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
				durationAnimal -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
			}
			
			//final
			dur = CalculateAttributeValue(duration);
			durAnimals = CalculateAttributeValue(durationAnimal);
			
			//params			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			params.customPowerStatValue = casterActor.GetTotalSignSpellPower(skillEnum);
			params.isSignEffect = true;
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];
				
				//different duration for animal targets and horses
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					params.duration = durAnimals;
				}
				else
				{
					params.duration = dur;
				}
				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if ( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
				}
				//set buff for alternate mode depending on friendly or not
				else if(IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly)
				{
					params.effectType = EET_Confusion;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}
			
				//remove immobilize first
				RemoveMagic17Effect(targets[i]);
			
				buff = targets[i].AddEffectCustom(params);
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );
									
					if(owner.CanUseSkill(S_Magic_s18))
					{
						conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
						conf.SetDrainStaminaOnExit();
					}
				}
				else
				{
					//stagger if level 3 expression
					if(owner.CanUseSkill(S_Magic_s17) && owner.GetSkillLevel(S_Magic_s17) == 3)
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0;	//use default
						targets[i].AddEffectCustom(staggerParams);					
					}
					else
					{
						//cast resisted
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	//because OnSignAborted is called from several different places in different circumstances and it is no longer a valid way of aborting sign
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	//called when display target changes
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		//noskill
		if(!owner.CanUseSkill(S_Magic_s17) || owner.GetSkillLevel(S_Magic_s17) == 0)
			return;
	 
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		
		AddMagic17Effect(orientationTarget);			
	}
	
	private function AddMagic17Effect(target : CActor)
	{
		var buffParams : SCustomEffectParams;
		
		if(!target || owner.GetActor() != GetWitcherPlayer() || !GetWitcherPlayer().CanUseSkill(S_Magic_s17))
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = 0.999f;
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		//because signs are using parent instead of virtual_parent all over the place
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
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
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			//parent.BreakAttachment();
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		//because signs are using parent instead of virtual_parent all over the place
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			//parent.BreakAttachment();
			// It is never used... oh well
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
			ChannelAxii();			
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	entry function ChannelAxii()
	{	
		while( Update() )
		{
			Sleep( 0.0001f );
		}
	}
}

