struct SIgniEffects
{
	editable var throwEffect	: name;
	editable var forestEffect	: name;
	editable var upgradedThrowEffect : name;
	editable var meltArmorEffect : name;		//fx added when using melt skill with base aspect
	editable var combustibleEffect : name;		//fx added when using combustible skill with base aspect
	editable var throwEffectSpellPower : name;		//fx used when using spell power skill with base aspect
}

struct SIgniAspect
{
	editable var projTemplate		: CEntityTemplate;
	editable var cone				: float;
	editable var distance			: float;
	editable var upgradedDistance 	: float;
}

struct SIgniChannelDT
{
	var actor : CActor;
	var dtSinceLastTest : float;
};

statemachine class W3IgniEntity extends W3SignEntity
{
	private var collisionFxEntity, rangeFxEntity	: CEntity;				//igni channeling's collision & range fx entities
	private var channelBurnTestDT : array<SIgniChannelDT>;					//dts for burning buff test for channeling
	private var lastCollisionFxPos : Vector;								//recently updated collision fx position
	
	private const var CHANNELLING_BURN_TEST_FREQUENCY : float;		//frequency of burning buff application test for channeling mode
	
		default CHANNELLING_BURN_TEST_FREQUENCY = 0.2;

	// all aspects data of sign casting should be placed here thru editor
	editable var aspects			: array< SIgniAspect >;

	editable var effects			: array< SIgniEffects >;
	
	//for additional effects
	private var forestTrigger		: W3ForestTrigger;
			
	default skillEnum = S_Magic_2;

	var projectileCollision 		: array< name >;
	
	// holds handles to already hit entities, to prevent from hitting twice in channeled mode
	var hitEntities					: array< CGameplayEntity >;
	
	public 	  var lastFxSpawnTime : float;
	
	public function GetSignType() : ESignType
	{
		return ST_Igni;
	}
		
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach( true );
		
		channelBurnTestDT.Clear();
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
		
		projectileCollision.Clear();
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Door' );
		projectileCollision.PushBack( 'Static' );		
		projectileCollision.PushBack( 'Character' );
		projectileCollision.PushBack( 'Terrain' );
		projectileCollision.PushBack( 'Ragdoll' );
		projectileCollision.PushBack( 'Destructible' );
		projectileCollision.PushBack( 'RigidBody' );
		projectileCollision.PushBack( 'Dangles' );
		projectileCollision.PushBack( 'Water' );
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Foliage' );
		projectileCollision.PushBack( 'Boat' );
		projectileCollision.PushBack( 'BoatDocking' );
		projectileCollision.PushBack( 'Platforms' );
		projectileCollision.PushBack( 'Corpse' );
		projectileCollision.PushBack( 'ParticleCollider' ); //Added so it can collide with Aard, but Geralt isn't blocked. Used for QFM_Hit_By_Aard on otherwise non-colliding objects. DZ
	
		if ( owner.ChangeAspect( this, S_Magic_s02 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'IgniChanneled' );
		}
		else
		{
			if(owner.GetActor().HasAbility('Glyphword 7 _Stats', true))
				fireMode = 2;
				
			GotoState( 'IgniCast' );
		}
	}
	
	protected function FillActionBuffsFromSkill(act : W3DamageAction)
	{
		//no burning if using 360 runeword
		if(fireMode != 2)
			super.FillActionBuffsFromSkill(act);
	}
	
	//Updates dt for burning effect application for given target actor. Once every CHANNELLING_BURN_TEST_FREQUENCY seconds
	//a burning application test will be allowed. Function returns true if test should be done.
	public function UpdateBurningChance(actor : CActor, dt : float) : bool
	{
		var i, j : int;
		var temp : SIgniChannelDT;
		
		if(!actor)
			return false;
			
		i = -1;
		for(j=0; j<channelBurnTestDT.Size(); j+=1)
		{
			if(channelBurnTestDT[j].actor == actor)
			{
				i = j;
				break;
			}
		}
		
		if(i >= 0)
		{
			channelBurnTestDT[i].dtSinceLastTest += dt;
		}
		else
		{
			temp.actor = actor;
			temp.dtSinceLastTest = dt;
			channelBurnTestDT.PushBack(temp);
			i = channelBurnTestDT.Size() - 1;
		}
		
		if(channelBurnTestDT[i].dtSinceLastTest >= CHANNELLING_BURN_TEST_FREQUENCY)
		{
			channelBurnTestDT[i].dtSinceLastTest -= CHANNELLING_BURN_TEST_FREQUENCY;
			return true;
		}
			
		return false;
	}
	
	protected function InitThrown()
	{
		var entity : CEntity;
		
		entity = theGame.GetEntityByTag( 'forest' );		//PFTODO: only one? shouldn't we get all?
		if(entity)
			forestTrigger = (W3ForestTrigger)entity;
				
		if(false)
		{
			PlayEffect( effects[fireMode].upgradedThrowEffect );
		}
		else
		{
			if(!IsAlternateCast() && owner.CanUseSkill(S_Magic_s07))
			{
				PlayEffect( effects[fireMode].throwEffectSpellPower );
			}
			else
			{
				PlayEffect( effects[fireMode].throwEffect );
			}
		}
			
		//additional cone fx
		if(!IsAlternateCast())
		{
			//melt
			if(owner.CanUseSkill(S_Magic_s08))
				PlayEffect(effects[0].meltArmorEffect);
			
			//combustible
			if(owner.CanUseSkill(S_Magic_s09))
				PlayEffect(effects[0].combustibleEffect);
		}
		
		if( owner.IsPlayer() && forestTrigger && forestTrigger.IsPlayerInForest() )
		{
			PlayEffect( effects[fireMode].forestEffect );
		}
	}
	
	function BroadcastSignCast_Override()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'FireDanger', 5, 8.0f, -1.f, -1, true, true );
	}
		
	//displays collision fx at designated pos
	public function ShowChannelingCollisionFx(pos : Vector, rot : EulerAngles, normall : Vector)
	{
		var collisionFxTemplate : CEntityTemplate;
		var coll, normal : Vector;
		
		//update position only if it changed significantly. Otherwise it will bounce back and forth by a small distance as the hand is animated while
		//channeling, so the collision is slightly different
		if(VecDistance(lastCollisionFxPos, pos) > 0.35)
		{
			lastCollisionFxPos = pos;
			
			if(theGame.GetWorld().StaticTrace(GetWorldPosition(), pos, coll, normal))
			{
				//test for more accurate position of collision (projectile is a box, not a point)
				pos = coll;
			}
			
			//a little bit before the collision pos - otherwise broken meshes obstruct the light
			pos = pos + normall * 0.1;
		
			if(!collisionFxEntity)
			{			
				collisionFxTemplate = (CEntityTemplate)LoadResource("gameplay\sign\igni_channeling_collision_fx");
				collisionFxEntity = theGame.CreateEntity(collisionFxTemplate, pos, rot);
			}
			else
			{
				collisionFxEntity.TeleportWithRotation(pos, rot);
			}
		}
		
		AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
	}
	
	public function ShowChannelingRangeFx(pos : Vector, rot : EulerAngles)
	{
		var rangeFxTemplate : CEntityTemplate;
	
		if(!rangeFxEntity)
		{			
			rangeFxTemplate = (CEntityTemplate)LoadResource("gameplay\sign\igni_channeling_range_fx");
			rangeFxEntity = theGame.CreateEntity(rangeFxTemplate, pos, rot);
		}
		else
		{
			rangeFxEntity.TeleportWithRotation(pos, rot);
		}
		
		AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
	}
	
	protected function CleanUp()
	{
		hitEntities.Clear();
		super.CleanUp();
	}
	
	//if called then igni stopped colliding with something
	timer function CollisionFXTimedOutDestroy(dt : float, id : int)
	{
		if(collisionFxEntity)
			collisionFxEntity.AddTimer('TimerStopVisualFX', 0.001, , , , true);
	}
	
	//if called then igni started colliding with something
	timer function RangeFXTimedOutDestroy(dt : float, id : int)
	{
		if(rangeFxEntity)
			rangeFxEntity.AddTimer('TimerStopVisualFX', 0.001, , , , true);
	}
}

state IgniCast in W3IgniEntity extends NormalCast
{
	event OnThrowing()
	{
		var player			: CR4Player;
		
		if( super.OnThrowing() )
		{
			parent.InitThrown();
			
			ProcessThrow();
			
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
	
	private function ProcessThrow()
	{
		var projectile	: W3SignProjectile;
		var spawnPos, heading: Vector;
		var spawnRot : EulerAngles;		
		var attackRange : CAIAttackRange;
		var distance : float;
		var castDir	: Vector;
		var castDirEuler : EulerAngles;
		var casterActor : CActor;		
		var dist, aspectDist : float;
		var angle : float;

		// set spawning position
		spawnPos = parent.GetWorldPosition();
		spawnRot = parent.GetWorldRotation();		
		heading = parent.owner.GetActor().GetHeadingVector();
		casterActor = caster.GetActor();

		//we move the projectile back as a hackfix for situations where:
		// geralt would stand facing a wall and thus create projectile inside wall causing it to work on the other side of the collision
		// geralt would stande close to a fireplace and his projectile would be created 'beyond' it and thus not work with it
		projectile = (W3SignProjectile)theGame.CreateEntity( parent.aspects[parent.fireMode].projTemplate, spawnPos - heading * 0.7f, spawnRot );
		projectile.ExtInit( caster, parent.skillEnum, parent );
		
		parent.PlayEffect( projectile.projData.flyEffect );
		
		distance = parent.aspects[parent.fireMode].distance;
		
		if ( caster.HasCustomAttackRange() )
			attackRange = theGame.GetAttackRangeForEntity( parent, caster.GetCustomAttackRange() );
		else if(parent.fireMode == 2)
			attackRange = theGame.GetAttackRangeForEntity( parent, 'cylinder' );
		else
			attackRange = theGame.GetAttackRangeForEntity( parent, 'cone' );
		
		projectile.SetAttackRange( attackRange );
		// shoot cake 3.5 m height and 30 m/s fast
		if(parent.fireMode == 2)
			projectile.SphereOverlapTest(distance, parent.projectileCollision);		
		else
			projectile.ShootCakeProjectileAtPosition( parent.aspects[parent.fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, parent.projectileCollision );		
		
		// Inform swarms about igni cast
		aspectDist 		= parent.aspects[parent.fireMode].distance;
		castDir 		= MatrixGetAxisX( casterActor.GetBoneWorldMatrixByIndex( parent.boneIndex ) );
		castDirEuler 	= VecToRotation( castDir );
		dist = aspectDist * ( 1.f - caster.GetHandAimPitch() * 0.75f );
		angle = 45.0 + ( caster.GetHandAimPitch() * 45.f );
		Boids_CastFireInCone( casterActor.GetWorldPosition(), castDirEuler.Yaw, angle, dist );	
		
		casterActor.OnSignCastPerformed(ST_Igni, false);
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.CleanUp();
		
		super.OnEnded(isEnd);
	}
	
	event OnSignAborted( optional force : bool )
	{		
		parent.CleanUp();
		
		super.OnSignAborted( force );
	}
}

state IgniChanneled in W3IgniEntity extends Channeling
{
	var reusableProjectiles : array< W3IgniProjectile >;
		
	function GetReusableProjectile( spawnPos : Vector, spawnRot : EulerAngles, dt : float ) : W3IgniProjectile
	{
		var i, size : int;
		var projectile : W3IgniProjectile;
		var unusedProjectile : W3IgniProjectile;
		var emptyIndex : int;
		
		emptyIndex = -1;
		size = reusableProjectiles.Size();
		for ( i = 0; i < size; i+=1 )
		{
			projectile = reusableProjectiles[i];
			if ( !projectile )
			{
				if ( emptyIndex == -1 )
				{
					emptyIndex = i;
				}
			}
			else if ( !projectile.IsUsed() || projectile.IsStopped() )
			{			
				unusedProjectile = projectile;
				unusedProjectile.StopProjectile();
				unusedProjectile.ClearHitEntities();
				unusedProjectile.TeleportWithRotation( spawnPos, spawnRot );
				break;
			}
		}
		
		if ( !unusedProjectile )
		{
			unusedProjectile = (W3IgniProjectile)theGame.CreateEntity( parent.aspects[parent.fireMode].projTemplate, spawnPos, spawnRot );
			unusedProjectile.ExtInit( caster, parent.skillEnum, parent, true );
			if ( emptyIndex != -1 )
			{
				reusableProjectiles[ emptyIndex ] = unusedProjectile;
			}
			else
			{				
				reusableProjectiles.PushBack( unusedProjectile );
			}
		}	

		unusedProjectile.SetIsUsed( true );
		unusedProjectile.SetDT( dt );		
				
		return projectile;
	}

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
				
		caster.OnDelayOrientationChange();
	}
	
	event OnThrowing()
	{
		if ( super.OnThrowing() )
		{
			parent.InitThrown();
			
			ChannelIgni();
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		super.OnEnded(isEnd);
		
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
			caster.GetPlayer().ResetRawPlayerHeading();		
		}		
		
		parent.AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
		parent.AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
		
		CleanUp();
		
		if ( false )
		{
			parent.StopEffect( parent.effects[parent.fireMode].upgradedThrowEffect );
		}
		else
		{
			parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
			parent.StopEffect( parent.effects[parent.fireMode].throwEffectSpellPower );			
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
		
		parent.AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
		parent.AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
		
		CleanUp();
		
		super.OnSignAborted( force );
	}	
	
	entry function ChannelIgni()
	{
		var lastTime, currTime : float;
		
		lastTime = -1;
		caster.GetActor().OnSignCastPerformed(ST_Igni, true);
		while( Update() )
		{
			currTime = theGame.GetEngineTimeAsSeconds();
			if(lastTime == -1)
				lastTime = currTime;	//on first run dt is 0
			
			if(currTime - lastTime > 0)	//because SleepOneFrame() is broken
				ProcessThrow(currTime - lastTime);
				
			lastTime = currTime;			
			SleepOneFrame();
		}
	}
	
	function CleanUp()
	{
		var i, size : int;
		
		size = reusableProjectiles.Size();
		for ( i = 0; i < size; i+=1 )
		{
			if ( reusableProjectiles[i] )
			{
				reusableProjectiles[i].Destroy();
			}		
		}
		reusableProjectiles.Clear();
		
		parent.CleanUp();
	}
	
	private function ProcessThrow(dt : float)
	{
		var projectile	: W3IgniProjectile;
		var dist, aspectDist : float;
		var angle : float;
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		var targetPosition : Vector;
		var combatTargetPosition : Vector;
		var castDir	: Vector;
		var castDirEuler : EulerAngles;
		var casterActor : CActor;		
		var attackRange : CAIAttackRange;
		
		casterActor = caster.GetActor();
		
		// set spawning position		
		spawnPos = parent.GetWorldPosition();
		spawnRot = parent.GetWorldRotation();
		
		//we move the projectile back as a hackfix for situations where:
		// geralt would stand facing a wall and thus create projectile inside wall causing it to work on the other side of the collision
		// geralt would stande close to a fireplace and his projectile would be created 'beyond' it and thus not work with it
		projectile = GetReusableProjectile( spawnPos - 0.7 * casterActor.GetHeadingVector(), spawnRot, dt );
		
		if(true)
			aspectDist 		= parent.aspects[parent.fireMode].distance;
		else
			aspectDist 		= parent.aspects[parent.fireMode].upgradedDistance;		
			
		castDir 		= MatrixGetAxisX( casterActor.GetBoneWorldMatrixByIndex( parent.boneIndex ) );
		castDirEuler 	= VecToRotation( castDir );
		
		targetPosition = spawnPos + ( aspectDist * castDir );
		if ( casterActor.IsInCombat() )
		{
			combatTargetPosition = casterActor.GetTarget().GetWorldPosition();
			targetPosition.Z = combatTargetPosition.Z + 1;			
		}
		
		if ( caster.HasCustomAttackRange() )
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, caster.GetCustomAttackRange() );
		}
		else if (false)
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, 'burn_upgraded' );
		}
		else
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, 'burn' );
		}		
		
		projectile.SetAttackRange( attackRange );
		projectile.ShootProjectileAtPosition( 0, 10, targetPosition, aspectDist, parent.projectileCollision );
		
		dist = aspectDist * ( 1.f - caster.GetHandAimPitch() * 0.75f );
		angle = 45.0 + ( caster.GetHandAimPitch() * 45.f );
		Boids_CastFireInCone( casterActor.GetWorldPosition(), castDirEuler.Yaw, angle, dist );		
	}
}
