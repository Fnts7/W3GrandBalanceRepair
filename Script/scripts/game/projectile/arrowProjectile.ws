//////////////////////////////////////////////////////////////
// W3ArrowProjectile
class W3ArrowProjectile extends W3AdvancedProjectile
{
	editable 	var defaultTrail 				: name;		default defaultTrail = 'arrow_trail';
	
	public	 	var underwaterTrail 			: name;		default underwaterTrail = 'arrow_trail_underwater';
	private 	var boneName 					: name;
	private 	var activeTrail					: name;
	private		var shouldBeAttachedToVictim 	: bool;		default shouldBeAttachedToVictim = true;
	
	protected 	var isOnFire 					: bool;
	protected 	var isUnderwater 				: bool;
	protected   var isBouncedArrow				: bool;
	protected   var isScheduledForDestruction	: bool; 	default isScheduledForDestruction = false;
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		super.OnProjectileShot(targetCurrentPosition,target);
		
		if ( !IsNameValid(activeTrail) )
		{
			if( ( W3PlayerWitcher ) GetOwner() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
			{
				defaultTrail = 'arrow_trail_mutation_9';
			}
		
			ActivateTrail( defaultTrail );
			//play sound
			this.SoundEvent( "cmb_arrow_swoosh" );
		}
	}
	
	event OnRangeReached()
	{
		StopAllEffects();
		// If we don't have a timer set (meaning we didnt hit anything), schedule destruction
		if( !isScheduledForDestruction )
		{
			AddTimer( 'TimeDestroy', 2, false );
			isScheduledForDestruction = true;
		}
	}
	
	//----------------- COLLISION EVENT -----------------//
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		//var victim 		: CGameplayEntity;
		var actorVictim	: CActor;
		var casterPos 	: Vector;
		var parryInfo 	: SParryInfo;
		var arrowHitPos : Vector;
		var bounce		: bool;
		var abs 		: array<name>;
		var isRolling	: bool;
		var template 	: CEntityTemplate;
		
		var meshComponent 	: CMeshComponent;
		var boundingBox 	: Box;
		var arrowSize 		: Vector;
		var hitPos 			: Vector;
		
		if ( yrdenAlternate )
		{
			return true;
		}
		
		SetShouldBeAttachedToVictim( true );
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		
		if ( collidingComponent || !hitCollisionsGroups.Contains( 'Water' ) )
			RemoveTimer( 'CheckIfInfWaterLoop' );
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if( collidingComponent && !hitCollisionsGroups.Contains( 'Static' ) )
		{	
			if ( !victim || collidedEntities.Contains(victim) || victim == caster )
				return false;
			
			actorVictim = (CActor)victim;
			
			if ( hitCollisionsGroups.Contains( 'Ragdoll' ) && actorVictim )
			{
				boneName = ((CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent()).GetRagdollBoneName(actorIndex);
			}
			
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			StopProjectile();
			isActive = false;
			StopActiveTrail();
			
			// override the timer so the arrow is visible for a time period
			AddTimer('TimeDestroy', 5, false);
			isScheduledForDestruction = true;
			
			
			arrowHitPos = pos + RotForward( this.GetWorldRotation() ) * 0.5f; // pierce the ground
			Teleport( arrowHitPos );
			
			this.SoundEvent("cmb_arrow_impact_dirt");
			return true;
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			if ( isUnderwater )
			{
				return false;
			}
			
			//play sound
			SoundEvent("cmb_arrow_impact_water");
			
			CheckIfInfWater();
			return true;
		}	
		else //ignore collision
		{
			return false;
		}
		
		if ( !actorVictim ) // if not actor;
		{
			StopProjectile();
			isActive = false;
			StopActiveTrail();
			
			// override the timer so the arrow is visible for a time period
			AddTimer('TimeDestroy', 5, false);
			isScheduledForDestruction = true;
			
			// If this is bolt move it toward target position
			if( StrFindFirst( this.GetName(), "bolt" ) != -1 )
			{
				// Compute exact pirce position based on component bounding box size
				meshComponent = (CMeshComponent)GetComponentByClassName('CMeshComponent');
				if( meshComponent )
				{
					boundingBox = meshComponent.GetBoundingBox();
					arrowSize = boundingBox.Max - boundingBox.Min;
					
					hitPos = pos;
					hitPos -= RotForward(  this.GetWorldRotation() ) * arrowSize.X * 0.7f; // pirce enemy a little
					
					Teleport( hitPos );
				}
			}
			
			ProcessDamageAction(victim, pos, boneName);
			
			this.SoundEvent("cmb_arrow_impact_wood");
			
			return true;
		}		
		else if (victim == thePlayer)
		{
			bounce = false;
			
			if ( thePlayer.IsCurrentlyDodging() && thePlayer.GetBehaviorVariable( 'isRolling' ) == 1.f )
			{
				isRolling = true;
			}
			else if(thePlayer.HasAbility( 'Glyphword 1 _Stats', true ))
			{
				//player fx
				thePlayer.PlayEffect('glyphword_reflection');
				
				//arrow fx
				template = (CEntityTemplate)LoadResource('glyphword_1');
				theGame.CreateEntity(template, GetWorldPosition(), thePlayer.GetWorldRotation(), , , true);
			
				if ( thePlayer.CheckCounterSpamming( (CActor)caster ) && thePlayer.GetSkillLevel(S_Sword_s10) > 1 )
				{
					casterPos = caster.GetWorldPosition();
					casterPos.Z += 1.5;
					this.Init(thePlayer);
					if ( thePlayer.GetSkillLevel(S_Sword_s10) == 3 )
					{
						this.projDMG *= 1 + CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, true) );
					}
					this.ShootProjectileAtPosition(2,projSpeed*0.7,casterPos);
					ActivateTrail('arrow_trail_red');
					return true;
				}
				else
				{
					this.SoundEvent( "cmb_arrow_bounce" );
					bounce = true;
				}
			}
			else if(thePlayer.CanParryAttack() && thePlayer.CanUseSkill(S_Sword_s10))
			{			
				//player.SetBehaviorVariable( 'combatActionType', (int)CAT_Parry );
				parryInfo = thePlayer.ProcessParryInfo(((CActor)caster),((CActor)victim),AST_Jab,ASD_NotSet,'attack_light',((CActor)caster).GetInventory().GetItemFromSlot('l_weapon'), true);
				if ( thePlayer.PerformParryCheck(parryInfo) )
				{
					if ( thePlayer.CheckCounterSpamming( (CActor)caster ) && thePlayer.GetSkillLevel(S_Sword_s10) > 1 )
					{
						casterPos = caster.GetWorldPosition();
						casterPos.Z += 1.5;
						this.Init(thePlayer);
						if ( thePlayer.GetSkillLevel(S_Sword_s10) == 3 )
						{
							this.projDMG *= 1 + CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, true) );
						}
						this.ShootProjectileAtPosition(2,projSpeed*0.7,casterPos);
						ActivateTrail('arrow_trail_red');
						isBouncedArrow = true;
						return true;
					}
					else
					{
						bounce = true;
					}
				}
			}
			
			//special item that can bounce arrows
			if(!bounce)
			{
				abs = thePlayer.GetAbilities(true);				
				bounce = abs.Contains(theGame.params.BOUNCE_ARROWS_ABILITY);
				
				if(bounce)
				{
					FactsAdd("sq108_arrow_deflected");
					thePlayer.PlayEffect( 'bolt_bump' );
				}
			}
			
			if(bounce)
			{	
				this.bounceOfVelocityPreserve = 0.7;
				this.BounceOff(normal,pos);
				this.Init(thePlayer);
				ActivateTrail('arrow_trail_orange');
				return false;
			}
			else if ( !isRolling )
			{
				if( actorVictim.IsAlive() )
					ProcessDamageAction( actorVictim, pos, boneName );
				
				this.SoundEvent( "cmb_arrow_impact_body" );
				
				if( IsNameValid( boneName ) )
					AttachArrowToRagdoll( actorVictim, pos, boneName );
				else
				{
					StopProjectile();
					StopActiveTrail();
					isActive = false;
					SmartDestroy();
				}
			}
		}
		else if ( (CNewNPC)victim && ((CNewNPC)victim).IsShielded(caster) ) // hit shield
		{
			((CNewNPC)victim).SignalGameplayEvent('PerformAdditiveParry');
			
			this.SoundEvent("cmb_arrow_impact_wood");
			
			AttachArrowToShield(actorVictim, pos);
		}
		else
		{
			if(actorVictim.IsAlive())
			{
				if ( actorVictim.HasAbility( 'BounceBoltsWildhunt' ))
				{
					this.bounceOfVelocityPreserve = 0.1;
					this.BounceOff(normal, pos);
					this.Init(actorVictim);
					this.PlayEffect('sparks');
					this.SoundEvent("cmb_arrow_impact_metal");
					ActivateTrail('arrow_trail_orange');
					return false;
				}
				else
				{
					ProcessDamageAction(actorVictim, pos, boneName);
				}
			}
			else if ( actorVictim.IsInAgony() )
			{
				//abandon agony
				actorVictim.SignalGameplayEvent('AbandonAgony');
				//enable ragdoll
				actorVictim.SetKinematic(false);
			}
			
			this.SoundEvent("cmb_arrow_impact_body");
			
			if( ShouldPierceVictim( actorVictim ) ) 
			{
				Mutation9HitFX( actorVictim );
			}
			else if(IsNameValid(boneName))
			{
				AttachArrowToRagdoll(actorVictim,pos,boneName);
			}
			else
			{
				StopProjectile();
				StopActiveTrail();
				isActive = false;
				SmartDestroy();
			}
		}
		return true;
	}
	
	public final function Mutation9HitFX( actorVictim : CActor )
	{
		var ent : CEntity;
		
		//mutation9
		//ActivateTrail( 'red_arrow_trail_mutation_9' );
		
		GCameraShake( 0.2f );
		
		if(IsNameValid(boneName))
		{
			ent = actorVictim.CreateFXEntityAtBone( 'mutation9_hit', boneName, true );
		}
		else
		{
			ent = actorVictim.CreateFXEntityAtPelvis( 'mutation9_hit', true );
		}
		
		ent.PlayEffect( 'hit_refraction' );
		ent.SoundEvent( 'ep2_mutations_09_bolt_impact_armor_type' );
	}
	
	protected function ShouldPierceVictim( victim : CActor ) : bool
	{
		//mutation causing bolts to pierce targets
		if( victim && GetOwner() && (W3PlayerWitcher)GetOwner() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
		{
			return true;
		}
		
		return false;
	}
	
	//----------------- INTERACTION EVENTS -----------------//
	
	/*event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh : CMeshComponent;
		
		super.OnAardHit(sign);
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			this.bounceOfVelocityPreserve = 0.7;
			this.BounceOff(VecRand2D(),this.GetWorldPosition());
			this.Init(thePlayer);
		}
	}*/
	
	event OnFireHit(source : CGameplayEntity)
	{
		if ( !isUnderwater && isActive )
		{
			super.OnFireHit(source);
			ToggleFire(true);
		}
	}
	
	//----------------- FUNCTIONS -----------------//
	
	public function ToggleFire( toggle : bool )
	{
		if( !isOnFire && toggle )
		{
			isOnFire = true;
			ActivateTrail('arrow_trail_fire');
			this.PlayEffect('fire');
		}
		else if( isOnFire && !toggle )
		{
			isOnFire = false;
			ActivateTrail(defaultTrail);
			this.StopEffect('fire');
		}
	}
	
	function ToggleUnderwater( toggle : bool )
	{
		if( !isUnderwater && toggle )
		{
			isUnderwater = true;
		}
		else if( isUnderwater && !toggle )
		{
			isUnderwater = false;
			
			// to prevent shooting enemies from underwater exploit
			this.isActive = false;
			this.DestroyAfter(0.5);
		}
	}
	
	function SmartDestroy()
	{
		var i : int;
		var compList : array<CComponent>;
		compList = GetComponentsByClassName('CDrawableComponent');
		
		for ( i=0; i<compList.Size(); i+=1 )
		{
			((CDrawableComponent)compList[i]).SetVisible(false);
		}
		if( !isScheduledForDestruction )
		{
			AddTimer('TimeDestroy', 3, false);
			isScheduledForDestruction = true;
		}
	}
	
	//----------------- TRAIL FUNCTIONS -----------------//
	
	function ActivateTrail( trailName : name )
	{
		if ( trailName != activeTrail )
		{
			if ( activeTrail )
				StopEffect( activeTrail );
			
			PlayEffect( trailName );
			activeTrail = trailName;
		}
	}
	
	function StopActiveTrail()
	{
		if (activeTrail)
		{
			StopEffect( activeTrail );
			activeTrail = '';
		}
	}
	
	timer function CheckIfInfWaterLoop( timeDelta : float , id : int)
	{
		if ( CheckIfInfWater() )
			RemoveTimer( 'CheckIfInfWaterLoop' );
	}

	protected function CheckIfInfWater() : bool
	{
		var entityPos	: Vector;
		var waterLevel	: float;
		
		entityPos = this.GetWorldPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel( entityPos ); 
		
		if ( isUnderwater )
		{
			if ( waterLevel < entityPos.Z )
			{
				ToggleUnderwater( false );
				ActivateTrail(defaultTrail);
				projAngle = 5.f;
				return true;
			}
		}
		else
		{
			if ( waterLevel > entityPos.Z )
			{
				ToggleUnderwater( true );
				ToggleFire(false);
				ActivateTrail(underwaterTrail);
				projAngle = 2.f;
				return true;
			}		
		}
		
		return false;
	}

	public function ThrowProjectile( targetPosIn : Vector )
	{	
		CheckIfInfWater();
		AddTimer( 'CheckIfInfWaterLoop', 0.05, true );
	}
	
	//----------------- ATTACH FUNCTIONS -----------------//
	
	function AttachArrowToShield( victim : CActor, pos : Vector )
	{
		var bones 		: array<name>;
		var res 		: bool;
		var inv 		: CInventoryComponent;
		var shield		: CEntity;
		
		StopProjectile();
		StopActiveTrail();
		isActive = false;
		
		inv = victim.GetInventory();
		
		shield = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('l_weapon'));
		this.CreateAttachment( shield );
		
		this.CreateAttachmentAtBoneWS(shield, 'Root', pos, this.GetWorldRotation());
	}
	
	function AttachArrowToRagdoll(victim : CActor, pos : Vector, boneName : name)
	{
		var bones 				: array<name>;
		var res 				: bool;
		var arrowHitPos 		: Vector;
		var timerAmount 		: float;
		var shouldPierceVictim 	: bool;
		
		var meshComponent		: CMeshComponent;
		var arrowSize			: Vector;
		var boundingBox			: Box;
		
		shouldPierceVictim = ShouldPierceVictim( victim );
		if( !shouldPierceVictim )
		{
			StopProjectile();
			StopActiveTrail();	
			isActive = false;
		}
		
		bones.PushBack( 'head' );
		bones.PushBack( 'hroll' );
		bones.PushBack( 'neck' );
		
		if ( ( victim == thePlayer && bones.Contains(boneName) ) || ( ((CNewNPC)victim).IsHorse() && !shouldPierceVictim ) ) // E3 hack condition, bug #31400
		{
			SmartDestroy();
		}
		else if( !shouldPierceVictim )
		{
			arrowHitPos = pos;
			
			// Compute exact pirce position based on component bounding box size
			meshComponent = (CMeshComponent)GetComponentByClassName('CMeshComponent');
			if( meshComponent )
			{
				boundingBox = meshComponent.GetBoundingBox();
				arrowSize = boundingBox.Max - boundingBox.Min;
				
				// Arrow entity has different local placeement ( tip in center ), than bolts ( back in center )
				if( StrFindFirst( this.GetName(), "arrow" ) != -1 )
					arrowHitPos += RotForward(  this.GetWorldRotation() ) * arrowSize.X * 0.1f; // pirce enemy a little
				else
					arrowHitPos -= RotForward(  this.GetWorldRotation() ) * arrowSize.X * 0.7f; // pirce enemy a little
			}
			
			if ( boneName )
			{
				res = this.CreateAttachmentAtBoneWS(victim, boneName, arrowHitPos, this.GetWorldRotation());
			}
			else
			{
				res = this.CreateAttachmentAtBoneWS(victim, 'torso3', arrowHitPos, this.GetWorldRotation());
			}
			
			if ( res )
			{
				if( victim == thePlayer && !GetShouldBeAttachedToVictim() )
					timerAmount = 0.01;
				else if( victim == thePlayer )
					timerAmount = 3;
				else
					timerAmount = 5;
				
				AddTimer('TimeDestroy', timerAmount, false);
				isScheduledForDestruction = true;
				
			}
			else
				SmartDestroy();
		}
	}
	
	//----------------- DAMAGE FUNCTIONS -----------------//
	
	protected function ProcessDamageAction(victim : CGameplayEntity, pos : Vector, boneName : name)
	{
		var action : W3DamageAction;
		var victimTags, attackerTags : array<name>;
		var none 		: SAbilityAttributeValue;
		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_AttackPower,false,true,false,false);				
		if( isOnFire )		//FIXME - if on fire should deal fire damage not physical, also setting damage should give damage type to set to make e.g. frost/poison projectiles
		{
			action.AddEffectInfo(EET_Burning);
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
		}
		else
		{
			action.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
		}
			
		if( this.projEfect != EET_Undefined )
		{
			action.AddEffectInfo(this.projEfect);
		}
		
		if ( ((CNewNPC)victim) )
		{
			if ( boneName == 'head' || boneName == 'neck' || boneName == 'hroll' || ( boneName == 'pelvis' && ((CNewNPC)victim).IsHuman() ) )
				action.SetHeadShot();
		}
		
		if(isBouncedArrow)
		{
			action.SetBouncedArrow();
		}
		
		theGame.damageMgr.ProcessAction( action );
		collidedEntities.PushBack(victim);
		delete action;
		
		//quest
		victimTags = victim.GetTags();
		
		attackerTags = caster.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_arrow_hit" );
	}
	
	public function SetShouldBeAttachedToVictim( val : bool )	{ shouldBeAttachedToVictim = val; }
	public function GetShouldBeAttachedToVictim() : bool		{ return shouldBeAttachedToVictim; }
}
