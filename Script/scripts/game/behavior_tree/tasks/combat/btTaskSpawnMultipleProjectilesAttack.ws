//>--------------------------------------------------------------------------
// CBTTaskSpawnMultipleProjectilesAttack
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Extension of btTaskSpawnMultipleEntitiesAttack to fire projectiles.
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// B.Lansford - 04-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class CBTTaskSpawnMultipleProjectilesAttack extends CBTTaskSpawnMultipleEntitiesAttack
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var projectileAngle				: float;
	var projectileAngleRandomness	: float;
	var projectileSpeed				: float;
	var projectileSpeedRandomness	: float;
	var dodgeable					: bool;
	// privates
	
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{
		var l_target 				: CActor = GetCombatTarget();
		var l_projectile 			: W3AdvancedProjectile;
		var l_angle 				: float;
		var l_velocity 				: float;
		var l_distanceToTarget		: float;
		var l_projectileFlightTime 	: float;
		var l_targetPos 			: Vector;
		
		l_angle = 0;
		l_targetPos = GetCombatTarget().GetWorldPosition();
		
		l_velocity 	= projectileSpeed + RandRangeF( projectileSpeedRandomness ) ;
		l_angle 	= projectileAngle + RandRangeF( projectileAngleRandomness ) ;
		
		l_projectile = (W3AdvancedProjectile) super.CreateEntity( _SpawnPos, _Rotation);
		
		if ( l_projectile )
		{
			l_projectile.ShootProjectileAtPosition ( projectileAngle, l_velocity, l_targetPos );
		}
		
		if ( dodgeable )
		{
			l_distanceToTarget = VecDistance( GetNPC().GetWorldPosition(), l_target.GetWorldPosition() );		
			
			// used to dodge projectile before it hits
			l_projectileFlightTime = l_distanceToTarget / l_velocity;
			l_target.SignalGameplayEventParamFloat('Time2DodgeProjectile', l_projectileFlightTime );
		}
		
		return l_projectile;
	}
}
class CBTTaskSpawnMultipleProjectilesAttackDef extends CBTTaskSpawnMultipleEntitiesAttackDef
{
	default instanceClass = 'CBTTaskSpawnMultipleProjectilesAttack';
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var projectileAngle				: float;
	editable var projectileAngleRandomness		: float;
	editable var projectileSpeed				: float;
	editable var projectileSpeedRandomness		: float;
	editable var dodgeable						: bool;
	
	default projectileSpeed = 1;
	// privates
	hint projectileAngleRandomness = "Random value to add to projectiles angle";
	hint projectileSpeedRandomness = "Random value to add to projectiles speed";
}