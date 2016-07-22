/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3WhiteFrost extends W3Petard
{
	editable var waveProjectileTemplate : CEntityTemplate;
	editable var freezeNPCFadeInTime : float;
	editable var waveSpeedModifier : float;
	editable var HAX_waveRadius : float;

	private var collisionMask : array<name>;
	private var shaderSpeed : float;							//calculated speed of wave projectile to match fx
	private var totalTime : float;								//sumed time of releasing wave projectiles - removed projectiles when this time > shader progression time
	private var collidedEntities : array<CGameplayEntity>;		//kept to avoid multiple collisions from different wave projectiles
	private var waveProjectile : W3WhiteFrostWaveProjectile;	//recent wave projectile, kept to destroy when needed
	
		hint waveSpeedModifier = "Multiplier for wave progression speed - freezing effect on actors";
		hint HAX_waveRadius = "HACK - surface fx radius is not properly calculated - fixed max radius";

	protected function ProcessLoopEffect()
	{
		//snap components
		SnapComponents(false);
		
		//enable loop components
		LoopComponentsEnable(true);		
		
		//loop fx
		ProcessEffectPlayFXs(false);
		
		//wave projectiles' duration
		totalTime = 0;
		
		//calulate shader progression speed - will be used by wave projectiles to match visuals
		shaderSpeed = HAX_waveRadius / impactParams.surfaceFX.fxFadeInTime * waveSpeedModifier;
		
		AddTimer('OnTimeEnded', loopDuration, false, , , true);
		AddTimer('WaveProjectile', 0.3, true, , , true);
		
		//force first AoE check on explosion - use the same radius as first wave check
		WaveProjectile(0.3);
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var customParam : W3FrozenEffectCustomParams;
		var i : int;
		
		super.LoadDataFromItemXMLStats();
		
		//pass frozen effect custom param
		customParam = new W3FrozenEffectCustomParams in this;
		customParam.freezeFadeInTime = freezeNPCFadeInTime;
		for(i=0; i<impactParams.buffs.Size(); i+=1)
		{
			if(impactParams.buffs[i].effectType == EET_Frozen)
			{
				impactParams.buffs[i].effectCustomParam = customParam;
				break;
			}
		}
	}
	
	//shoots wave projectile - a sphere which radius depends on speed and total time since explosion
	timer function WaveProjectile(dt : float, optional id : int)
	{
		totalTime += dt;
		
		// Create only one instance to ensure that obstacle is hit only once
		if(!waveProjectile)
		{
			waveProjectile = (W3WhiteFrostWaveProjectile)theGame.CreateEntity(waveProjectileTemplate, GetWorldPosition());			
			waveProjectile.Init(this);
			waveProjectile.SetWhiteFrost(this);
			
			collisionMask.PushBack('Character');
			collisionMask.PushBack('Static');
			collisionMask.PushBack('RigidBody');
			collisionMask.PushBack('Corpse');
		}
		
		waveProjectile.SphereOverlapTest( totalTime * shaderSpeed, collisionMask );
		
		//debug visualisation
		thePlayer.GetVisualDebug().AddSphere(EffectTypeToName(RandRange((int)EET_EffectTypesSize)), totalTime * shaderSpeed, GetWorldPosition(), true, Color(0,0,255), 0.15);
		
		//when reached max stop timer and schedule destruction of last projectile
		if(totalTime >= impactParams.surfaceFX.fxFadeInTime)
		{
			RemoveTimer('WaveProjectile');			
			waveProjectile.Destroy();
		}		
	}
	
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{
		var spikeEnt : CEntity;
		var entityTemplate : CEntityTemplate;
		var rot : EulerAngles;
		var pos, basePos : Vector;
		var i : int;
		var angle, radius : float;
		
		super.ProcessMechanicalEffect( targets, isImpact, dt );
		
		if( isImpact && impactNormal.Z >= 0.8f )
		{
			//large, central spike
			entityTemplate = (CEntityTemplate) LoadResource( 'ice_spikes_large' );	
			if ( entityTemplate )
			{
				pos = GetWorldPosition();
				pos = TraceFloor( pos );
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				spikeEnt = theGame.CreateEntity( entityTemplate, pos, rot );
				spikeEnt.DestroyAfter( 40.f );
			}
			
			//smaller, side spikes
			entityTemplate = (CEntityTemplate) LoadResource( 'ice_spikes' );
			basePos = GetWorldPosition();
			for( i=0; i<3; i+=1 )
			{
				// 3.0 - 4.0 m
				radius = RandF() + 3.0;
				
				// every 120 deg +/- 20 deg
				angle = i * 2 *( Pi() / 3 ) + RandRangeF( Pi()/18, -Pi()/18 );
				
				pos = basePos + Vector( radius * CosF( angle ), radius * SinF( angle ), 0 );
				pos = TraceFloor( pos );
				
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				spikeEnt = theGame.CreateEntity( entityTemplate, pos, rot );
				spikeEnt.DestroyAfter( 40.f );
			}			
		}
	}
	
	//called when wave projectile detects collision with something
	public function Collided(ent : CGameplayEntity)
	{
		var ents : array<CGameplayEntity>;
		var owner : CEntity;
	
		if(collidedEntities.Contains(ent))
			return;
			
		owner = EntityHandleGet(ownerHandle);
		if(owner && IsRequiredAttitudeBetween(ent, owner, false, false, true))
			return;
			
		collidedEntities.PushBack(ent);
		ents.PushBack(ent);
		ProcessMechanicalEffect(ents, true);
		ent.OnFrostHit(this);
	}
}

//wave projectile used by frost bomb
class W3WhiteFrostWaveProjectile extends CProjectileTrajectory
{
	private var frostEntity : W3WhiteFrost;
	
	public function SetWhiteFrost(f : W3WhiteFrost)
	{
		frostEntity = f;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var ent : CGameplayEntity;
	
		if(collidingComponent)
		{
			ent = (CGameplayEntity)collidingComponent.GetEntity();
			if(ent)
				frostEntity.Collided(ent);
		}
	}
}