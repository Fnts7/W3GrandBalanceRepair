import abstract class CProjectileTrajectory extends CGameplayEntity
{
	import var caster 					: CEntity;
	import var projectileName 			: name;
	import var radius 					: float;
	import var bounceOfVelocityPreserve : float;
	import var doWaterLevelTest			: bool;
	
	protected editable var alarmRadius	: float;
	
	public var victim	 				: CGameplayEntity;
	public var yrdenAlternate			: W3YrdenEntity;
	
	default alarmRadius = 15;
	
	// Initializes the projectile
	import final function Init( caster : CEntity );
	
	// Shoots the projectile at the specified position
	import function ShootProjectileAtPosition( angle : float, velocity : float, target : Vector, optional range : float, optional collisionGroups : array<name> );
	
	// Shoots projectile at given node, projectile will follow the node
	import function ShootProjectileAtNode( angle : float, velocity : float, target : CNode, optional range : float, optional collisionGroups : array<name> );
	
	// Shoots projectile at given bone of given entity, projectile will follow this bone position
	import function ShootProjectileAtBone( angle : float, velocity : float, target : CEntity, targetBone : name, optional range : float, optional collisionGroups : array<name> );
	
	// Shoots the projectila at specified position using cake shape overlap test
	import function ShootCakeProjectileAtPosition( cakeAngle : float, cakeHeight : float, shootAngle : float, velocity : float, target : Vector, range : float, optional collisionGroups : array<name> );
	
	// Does projectile bounce off after collision according to given collision normal and collision point
	import final function BounceOff( collisionNormal : Vector, colliisonPosition : Vector );
	
	// Does a raycast from projectile start position to testComponent global position and searches if any object of type specified in collisionGroupsNames stands in the way
	import final function IsBehindWall( testComponent : CComponent, optional collisionGroupsNames : array<name> ) : bool;
	
	// Stops the projectile
	import final function StopProjectile();
	
	// Is not in motion
	import final function IsStopped() : bool;
	
	// Do sphere overlap test
	import final function SphereOverlapTest( radius : float, optional collisionGroups : array<name> );
	
	/////////////////////////////////////////////////////////////
	//Events
	
	// Collision event. REMEMBER when colliding with terrain no collidingComponent is returned ( collidingComponent == NULL )!!
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var beehive 		: CBeehiveEntity;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventCustomCenter( caster, 'Danger', 30, alarmRadius, 2, -1, true, true, pos );
		
		//HACK
		//beehive hax since we cannot get functionality from engine to get collision event on the other object - beehive hit by bolt/arrow
		if(collidingComponent)
		{
			beehive = (CBeehiveEntity)(collidingComponent.GetEntity());
			if(beehive && ((CThrowable)this) )
				beehive.OnShotByProjectile();
			
			victim = (CGameplayEntity)collidingComponent.GetEntity();
			
			ProcessProjectileRepulsion( pos, normal );
		}
	}
	
	public function ProcessProjectileRepulsion( pos, normal : Vector ) : bool
	{
		// for enemies reflecting projectiles
		if ( victim.HasAbility( 'RepulseProjectiles' ) )
		{
			this.Init( victim );
			bounceOfVelocityPreserve = 0.8;
			BounceOff( normal, pos );
			((CActor)victim).SignalGameplayEvent( 'RepulsedProjectile' );
			return true;
		}
		
		return false;
	}
	
	public function SetVictim( entity : CGameplayEntity )
	{
		victim = entity;
	}
	
	// Range rached event
	event OnRangeReached();
	
	public final function SetIsInYrdenAlternateRange(yrden : W3YrdenEntity)
	{
		yrdenAlternate = yrden;
	}
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		var s : W3YrdenEntityStateYrdenShock;
		
		if(yrdenAlternate)
		{
			s = (W3YrdenEntityStateYrdenShock)yrdenAlternate.GetCurrentState();
			if(s)
				s.ShootDownProjectile(this);
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh : CMeshComponent;
		
		super.OnAardHit(sign);
		
		if( IsStopped() )
		{
			return false;
		}
		
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
	}
}
