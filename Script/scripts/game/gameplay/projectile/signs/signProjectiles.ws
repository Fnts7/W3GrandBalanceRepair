/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
		var isMutation6 : bool;
		var victimNPC : CNewNPC;
	
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		
		
		if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
		{
			isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) );
			if( isMutation6 )
			{
				action.SetBuffSourceName( "Mutation6" );
			}		
			else if ( owner.CanUseSkill(S_Magic_s06) )		
			{			
				
				dmgVal = CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) ) + 2.0f * GetWitcherPlayer().GetLevel();
				dmgVal *= GetWitcherPlayer().GetSkillLevel(S_Magic_s06);
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
		}
		else
		{
			isMutation6 = false;
		}
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);
		
		
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		
		
		
		
		
		theGame.damageMgr.ProcessAction( action );
		
		collider.OnAardHit( this );
		
		
		if( isMutation6 && victimNPC && victimNPC.IsAlive() )
		{
			ProcessMutation6( victimNPC );
		}
	}
	
	private final function ProcessMutation6( victimNPC : CNewNPC )
	{
		var result : EEffectInteract;
		var mutationAction : W3DamageAction;
		var min, max : SAbilityAttributeValue;
		var dmgVal, drainVal : float;
		var instaKill, hasKnockdown, applySlowdown, applyDrain, applyDrainWeak : bool;
		var knockDownType : EEffectType;
				
		instaKill = false;
		hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
		
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
		if( RandF() >= min.valueMultiplicative )
		{
			
			applySlowdown = true;			
			instaKill = false;
		}
		else
		{
			applyDrain = false;
			applyDrainWeak = false;
			
			result = victimNPC.AddEffectDefault( EET_Frozen, this, "Mutation 6", true );
			
			if( EffectInteractionSuccessfull( result ) && hasKnockdown) 				
			{
				if (!victimNPC.IsImmuneToInstantKill() && victimNPC.GetHealthPercents() < 0.5f)
				{
					mutationAction = new W3DamageAction in theGame.damageMgr;
					mutationAction.Initialize( action.attacker, victimNPC, this, "Mutation 6", EHRT_None, CPS_Undefined, false, false, true, false );
					mutationAction.SetInstantKill();
					mutationAction.SetForceExplosionDismemberment();
					mutationAction.SetIgnoreInstantKillCooldown();
					theGame.damageMgr.ProcessAction( mutationAction );
					delete mutationAction;
					instaKill = true;
				}
				else
					applyDrain = true;
			}
			else
			{
				applyDrain = hasKnockdown;

				if (!applyDrain)
				{
					if (victimNPC.HasShieldedAbility() && victimNPC.IsShielded(action.attacker))
					{
						applyDrain = VirtualKnockdownTest(victimNPC, 0.25f);
						applyDrainWeak = true;
					}
					else if (victimNPC.HasAbility( 'mon_type_huge' ))
					{
						applyDrain = VirtualKnockdownTest(victimNPC, 0);
						applyDrainWeak = true;
					}
					else
					{
						knockDownType = ModifyHitSeverityBuff(victimNPC, EET_Knockdown);
						if (knockDownType != EET_Knockdown)
							applyDrain = VirtualKnockdownTest(victimNPC, 0);
					}
				}

				if (!EffectInteractionSuccessfull( result ))
				{
					applySlowdown = RandF() < 0.5f; 
					applyDrainWeak = true;
				}
			}
			
			if (applyDrain)
			{
				drainVal = 0.2f + RandF() / 5.0f;
				if (applyDrainWeak)
					drainVal *= 0.5f;
				if (victimNPC.UsesVitality())
				{
					victimNPC.DrainVitality( victimNPC.GetStatMax(BCS_Vitality) * drainVal );
				}
				else if (victimNPC.UsesEssence())
				{
					victimNPC.DrainEssence( victimNPC.GetStatMax(BCS_Essence) * drainVal);
				}
				
				if (victimNPC.GetHealth() <= 0)
					victimNPC.Kill('Mutation 6');
				
				if( victimNPC.IsAlive() || !EffectInteractionSuccessfull( result ))
				{
					victimNPC.PlayEffect( 'critical_frozen' );
					victimNPC.AddTimer( 'StopMutation6FX', 2.0f );
				}
			}
		}
		
		if( applySlowdown && victimNPC.IsAlive() && !hasKnockdown && RandF() < 0.7f)
		{
			victimNPC.AddEffectDefault( EET_SlowdownFrost, this, "Mutation 6", true );
		}
		
		
		if( !instaKill && !victimNPC.HasBuff( EET_Frozen ))
		{			
			if ( owner.CanUseSkill(S_Magic_s06) )
			{
				dmgVal = CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) ) + 2.0f * GetWitcherPlayer().GetLevel();
				dmgVal *= GetWitcherPlayer().GetSkillLevel(S_Magic_s06);
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
			dmgVal = CalculateAttributeValue( min ) + 6.0f * GetWitcherPlayer().GetLevel();
			action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal / 2.0f);
			action.AddDamage( theGame.params.DAMAGE_NAME_FROST, dmgVal / 2.0f);
			action.SetBuffSourceName( "Mutation 6" );
			
			action.ClearEffects();
			action.SetProcessBuffsIfNoDamage( false );
			action.SetForceExplosionDismemberment();
			action.SetIgnoreInstantKillCooldown();
			theGame.damageMgr.ProcessAction( action );
		}
	}
	
	private function VirtualKnockdownTest(victimNPC : CNewNPC, extraResist : float) : bool
	{
		var spellPowerAtt : SAbilityAttributeValue;
		var forceResist, forceResistPt, spellPower : float;
		
		if (RandF() < 0.2f)
			return true;
	
		spellPowerAtt = GetWitcherPlayer().GetTotalSignSpellPower(signSkill);
		spellPower = spellPowerAtt.valueMultiplicative;
		victimNPC.GetResistValue( CDS_ForceRes, forceResistPt, forceResist);
		forceResist += extraResist;

		spellPower *= 1.0f - forceResist;
		if (spellPower < 1.1f)
			return false;
			
		if (spellPower > 2.0f)
		{
			spellPower = 2.0f + LogF ((spellPower - 2.0f) + 1);
		}

		spellPower *= RandF();
	
		return spellPower >= 1.1f;
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		staminaDrainPerc = p;
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg : SAbilityAttributeValue;
		var burnChance : float;					
		var maxArmorReduction : float;			
		var applyNbr : int;						
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var currentReduction : int;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
			
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
				
		
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			
			
			
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				
				channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				if (!owner.IsPlayer())
					dmg = channelDmg.valueAdditive + channelDmg.valueMultiplicative * actorVictim.GetMaxHealth();
				else
					dmg = channelDmg.valueAdditive + 4.0f * owner.GetPlayer().GetLevel();
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				if(!collider)	
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
		}
		else if (owner.IsPlayer())
		{
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 10.0f * owner.GetPlayer().GetLevel());
		}
		
		
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		
		
		signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());

		
		if ( !owner.IsPlayer() )
		{
			
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}			
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		
		if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
		{	
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s08);
			applyNbr = RoundMath( 100 * maxArmorReduction * ( signPower.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED ) );
			
			armorRedAblName = SkillEnumToName(S_Magic_s08);
			currentReduction = ((CActor)collider).GetAbilityCount(armorRedAblName);
			
			applyNbr -= currentReduction;
			
			for ( i = 0; i < applyNbr; i += 1 )
				action.victim.AddAbility(armorRedAblName, true);
		}	
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}