//////////////////////////////////////////////////////////////
// W3BoltProjectile
//witcher gabriel bolt ONLY
class W3BoltProjectile extends W3ArrowProjectile
{
	private editable var dismemberOnKill 	: bool;
	private editable var dodgeable 			: bool;
	private var projectiles 				: array<W3BoltProjectile>;	
	private saved var targetPos 			: Vector;					//vector of target, need to store it as the projectiles must be released with 1-frame delay (entity attaching)
	private saved var crossbowId			: SItemUniqueId;
	private var collisionGroups				: array<name>;
	private var hitVictims					: array<CActor>;			// list of already pierced enemies
	protected saved var wasShotUnderWater	: bool;						//set to true if bolt was shot when player was underwater
	
		default dodgeable = true;
	
	//extended Initialize, overrides parent
	public function InitializeCrossbow(ownr : CActor, boltId : SItemUniqueId, crossId : SItemUniqueId)
	{
		super.Initialize(ownr, boltId);
		crossbowId = crossId;
	}
	
	event OnProjectileInit()
	{
		InitCollisionGroups();
		super.OnProjectileInit();
	}
	
	private function InitCollisionGroups()
	{
		if( collisionGroups.Size() <= 0 )
		{
			collisionGroups.PushBack('Ragdoll');
			collisionGroups.PushBack('Static');
			collisionGroups.PushBack('Terrain');
			collisionGroups.PushBack('Water');
			collisionGroups.PushBack('Character');
		}
	}
	
	public function DismembersOnKill() : bool
	{
		return dismemberOnKill;
	}
	
	protected function ProcessDamageAction(victim : CGameplayEntity, pos : Vector, boneName : name)
	{
		var action : W3Action_Attack;
		var victimTags, attackerTags : array<name>;

		//Crossbow hack - since we need to get stats both from crossbow and bolt to calculate damage / damage buffs / critical change / damage reduction etc
		//we need crossbow and bolt abilities added on player so that functions that get these values from character stats would get them as well.
		//We cannot add ability on mount/equip as they would also work for other attacks / signs etc.
		//Since we don't know what stats will be on items the only reliable way to make sure anything would work is to add ability from item on character
		if(caster == thePlayer)
		{
			//bolt
			thePlayer.ApplyItemAbilities(itemId);
			
			//crossbow
			thePlayer.ApplyItemAbilities(crossbowId);
		}
		
		action = new W3Action_Attack in this;
		action.Init( (CGameplayEntity)caster, victim, this, itemId, 'bolt', caster.GetName(), EHRT_Light, false, false, '', AST_NotSet, ASD_NotSet, false, true, false, false, , , , , crossbowId);
		//action.SetHitAnimationPlayType( EAHA_ForceNo );

		//MS: this is causing visual problems
		//if( isOnFire )
		//	action.AddEffectInfo(EET_Burning);
		
		if ( (CNewNPC)victim )
		{
			if ( boneName == 'head' || boneName == 'neck' || boneName == 'hroll' || ( boneName == 'pelvis' && ((CNewNPC)victim).IsHuman() ) )
				action.SetHeadShot();
		}
			
		theGame.damageMgr.ProcessAction( action );		
		delete action;
		
		//player bolt hack disable
		if(caster == thePlayer)
		{
			//bolt
			thePlayer.RemoveItemAbilities(itemId);
			
			//crossbow
			thePlayer.RemoveItemAbilities(crossbowId);
		}
		
		collidedEntities.PushBack(victim);
		
		//crossbow action fact
		if(caster == thePlayer && (CActor)victim && IsRequiredAttitudeBetween(caster, victim, true))
		{
			FactsAdd("ach_crossbow", 1, 4 );
		}
		
		//quest
		victimTags = victim.GetTags();		
		attackerTags = caster.GetTags();		
		AddHitFacts( victimTags, attackerTags, "_bolt_hit" );
	}

	event OnProcessThrowEvent( animEventName : name )
	{
		var throwPos 			: Vector;
		var boneIndex 			: int;
		var orientationTarget	: EOrientationTarget;
		var tempComponent		: CDrawableComponent;
		var entityHeight		: float;
		var ownerPlayer			: CR4Player;
		var mat					: Matrix;
		var targetPosDist		: float;
		var maxRangePos			: Vector;
		
		if ( animEventName == 'ProjectileThrow' )
		{			
			ownerPlayer = (CR4Player)GetOwner();
			if ( ownerPlayer )
			{
				targetPosDist = VecDistance( ownerPlayer.GetLookAtPosition(), ownerPlayer.GetWorldPosition() );
				maxRangePos = VecNormalize( ownerPlayer.GetLookAtPosition() - ownerPlayer.GetWorldPosition() ) * theGame.params.MAX_THROW_RANGE + ownerPlayer.GetWorldPosition();	//actual max range
				
				if ( ownerPlayer.GetOrientationTarget() == OT_Player )//|| !ownerPlayer.GetDisplayTarget() )
					throwPos =  maxRangePos;
				else
				{					
					if ( targetPosDist > theGame.params.MAX_THROW_RANGE )
						throwPos = maxRangePos;	
					else
						throwPos = ownerPlayer.GetLookAtPosition();
				}
			}

			ThrowProjectile( throwPos );
		}
		
		return super.OnProcessThrowEvent( animEventName );
	}
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim 		: CActor;
		var gpEntity	: CGameplayEntity;
		
		var meshComponent		: CMeshComponent;
		var arrowHitPos			: Vector;
		var arrowSize			: Vector;
		var boundingBox			: Box;
		
		if( !isActive )
			return false;
		
		if(collidingComponent)
		{
			victim = (CActor)collidingComponent.GetEntity();
			if( victim.HasTag('AddRagdollCollision') && (CMovingAgentComponent)collidingComponent && !thePlayer.GetDisplayTarget())
			{
				return false;
			}
			if ( CanCollideWithVictim( victim ) && !hitVictims.Contains( victim ) )
			{
				hitVictims.PushBack( victim );
				super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
			}
			
			gpEntity = ( CGameplayEntity ) collidingComponent.GetEntity();
			
			if( gpEntity )
			{
				gpEntity.OnBoltHit();
			}
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			StopProjectile();	
			RemoveTimer( 'CheckIfInfWaterLoop' );
			StopActiveTrail();
			
			// override the timer so the arrow is visible for a time period
			AddTimer('TimeDestroy', 5, false);
			isScheduledForDestruction = true;
			
			// Compute exact pirce position based on component bounding box size
			arrowHitPos = pos;
			meshComponent = (CMeshComponent)GetComponentByClassName('CMeshComponent');
			if( meshComponent )
			{
				boundingBox = meshComponent.GetBoundingBox();
				arrowSize = boundingBox.Max - boundingBox.Min;
				arrowHitPos -= RotForward(  this.GetWorldRotation() ) * arrowSize.X * 0.7f; // pirce enemy a little
			}
			
			Teleport( arrowHitPos );
		}
	}
	
	//Because of OnAardHit in arrowProjectile, the attached crossbow bolt is blown away when you perform aard.
	event OnAardHit( sign : W3AardProjectile )
	{
	}
	
	private var visibility : bool;
	public function SetVisibility( flag : bool )
	{
		visibility = flag;
		if ( Visibility() )
			AddTimer( 'SetVisibilityTimer', 0.f, true );
	}
	
	private timer function SetVisibilityTimer( dt : float , id : int )
	{
		Visibility();
	}
	
	private function Visibility() : bool
	{
		var comp : CDrawableComponent;

		comp = (CDrawableComponent)( this.GetComponentByClassName( 'CDrawableComponent' ) );
		
		if (comp)
		{
			if ( visibility == comp.IsVisible() )
			{
				RemoveTimer( 'SetVisibilityTimer' );
			}
			else
			{
				comp.SetVisible( visibility );
				return true;
			}
		}	
		
		return false;
	}
	
	public function ThrowProjectile( targetPosIn : Vector )
	{	
		var inv : CInventoryComponent;
		var splitCount : int;
		var additionalProjectile : W3BoltProjectile;
		
		if(GetOwner() == thePlayer)
			theGame.VibrateControllerHard();	//shooting bolt
		
		inv = GetOwner().GetInventory();
		projectiles.Clear();
		projectiles.PushBack(this);
		wasShotUnderWater = ((CMovingPhysicalAgentComponent)GetOwner().GetMovingAgentComponent()).IsDiving();
		
		splitCount = (int)CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'split_count'));
		
		if (splitCount == 2 || splitCount == 3)
		{
			//bolt splits into 2 or 3 when shot
			
			additionalProjectile = (W3BoltProjectile)Duplicate();
			additionalProjectile.Init(GetOwner());
			additionalProjectile.CreateAttachment(GetOwner(), 'bolt' );
			projectiles.PushBack(additionalProjectile);
			
			if(splitCount > 2)
			{
				additionalProjectile = (W3BoltProjectile)Duplicate();
				additionalProjectile.Init(GetOwner());
				additionalProjectile.CreateAttachment(GetOwner(), 'bolt' );
				projectiles.PushBack(additionalProjectile);
			}
		}
		
		targetPos = targetPosIn;
		
		projectiles[0].BreakAttachment();
		projectiles[0].CheckIfInfWater();
		AddTimer( 'ReleaseProjectiles', 0.001, false );		
		
		FactsAdd("crossbow_was_fired", 1, 3);
		AddTag( 'fired_crossbow_bolt' );
		
		super.ThrowProjectile( targetPosIn );
	}
	
	timer function ReleaseProjectiles( time : float , id : int)
	{
		var sideVec, vecToTarget	: Vector;
		var sideLen 				: float;
		var pos1					: Vector;
		var rot1					: EulerAngles;
				
		// DEBUG
		//theGame.SetActivePause( true );
		// DEBUG
		
		pos1 = projectiles[0].GetWorldPosition();
		rot1 = projectiles[0].GetWorldRotation();
		
		if ( projectiles.Size() > 1 )
		{
			projectiles[1].BreakAttachment();
			projectiles[1].TeleportWithRotation(pos1, rot1 );
			projectiles[1].CheckIfInfWater();
			
			if(projectiles.Size() > 2)
			{
				projectiles[2].BreakAttachment();
				projectiles[2].TeleportWithRotation(pos1, rot1 );
				projectiles[2].CheckIfInfWater();
			}
		}
		
		AddTimer( 'ReleaseProjectiles2', 0.001, false );
	}
	
	// MS: We have two timer functions because when we BreakAttachment for the other bolts they ar not positioned in the same place as the first bolt
	timer function ReleaseProjectiles2( time : float , id : int)
	{
		var sideVec, vecToTarget	: Vector;
		var sideLen 				: float;	
		var distanceToTarget		: float;
		var	projectileFlightTime 	: float;
		var attackRange				: float;
		var target 					: CActor = thePlayer.GetTarget();
		var inv 					: CInventoryComponent;
		
		var boneIndex				: int;
		var npc						: CNewNPC;

		if ( thePlayer.IsSwimming() )
			attackRange = theGame.params.MAX_THROW_RANGE;
		else
			attackRange = theGame.params.UNDERWATER_THROW_RANGE;
		
		boneIndex = -1;
		if ( thePlayer.IsCombatMusicEnabled() && thePlayer.GetDisplayTarget() /*&& thePlayer.IsDiving()*/ && thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
		{
			npc = (CNewNPC)(thePlayer.GetDisplayTarget());
			if ( npc )
				boneIndex = npc.GetBoneIndex( 'torso2' );					
		}
		if ( target.HasTag('AddRagdollCollision'))
		{
			collisionGroups.Remove('Character');
		}
		if ( boneIndex >= 0 )
			projectiles[0].ShootProjectileAtBone( projAngle, projSpeed, npc, 'torso2', attackRange, collisionGroups );
		else
			projectiles[0].ShootProjectileAtPosition( projAngle, projSpeed, targetPos, attackRange, collisionGroups );
			
		projectiles[0].SoundEvent("cmb_arrow_swoosh");
		
		//remove item from inventory
		if(!FactsDoesExist("debug_fact_inf_bolts"))
		{
			inv = GetOwner().GetInventory();
		
			if(!inv.ItemHasTag(itemId, theGame.params.TAG_INFINITE_AMMO))
				inv.RemoveItem(itemId);
		}
		
		if ( dodgeable && target )
		{
			distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );		
			
			// used to dodge projectile before it hits
			projectileFlightTime = distanceToTarget / projSpeed;
			target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
		}
		
		if ( projectiles.Size() > 1 )
		{
			vecToTarget = GetOwner().GetWorldPosition() - targetPos;
			sideVec = VecCross(VecNormalize(vecToTarget), Vector(0, 0, 1));
			sideLen = SinF( 3.0f * Pi() / 180.0f ) * VecLength(vecToTarget);		//fixed side angle*/
			
			projectiles[1].ShootProjectileAtPosition( projAngle, projSpeed, targetPos + VecNormalize(sideVec) * sideLen, attackRange, collisionGroups );
			projectiles[1].SoundEvent("cmb_arrow_swoosh");
			
			if(projectiles.Size() > 2)
			{
				projectiles[2].ShootProjectileAtPosition( projAngle, projSpeed, targetPos - VecNormalize(sideVec) * sideLen, attackRange, collisionGroups);
				projectiles[2].SoundEvent("cmb_arrow_swoosh");
			}
		} 
	}
}
