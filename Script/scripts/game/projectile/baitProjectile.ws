//----------------------------------------------------------------------
// W3BaitProjectile
//----------------------------------------------------------------------
//>---------------------------------------------------------------------
// Projectile that will generate a food source at collision
//----------------------------------------------------------------------
// Copyright © 2014 CDProjektRed
// Author : R.Pergent - 01-July-2014
//----------------------------------------------------------------------
class W3BaitProjectile extends W3BoltProjectile
{
	//>---------------------------------------------------------------------
	// Variables
	//----------------------------------------------------------------------
	// Editable
	private editable var foodSourceToGenerate		: CEntityTemplate;
	private editable var addScentToCollidedActors	: bool;	
	private editable var attractionDuration			: float;
	
	default	attractionDuration 			= 30;
	
	hint attractionDuration = "-1 means infinite";
	
	// Private
	private var m_BaitEntity	: CEntity;

	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var l_rotation 	: EulerAngles;
		var l_entityHit	: CEntity;
		var victim : CActor;

		victim = (CActor)collidingComponent.GetEntity();
		
		if ( !CanCollideWithVictim( victim ) )
			return true;
		
		if( !m_BaitEntity )
		{
			m_BaitEntity = theGame.CreateEntity( foodSourceToGenerate, pos, l_rotation );
			l_entityHit = collidingComponent.GetEntity();
			m_BaitEntity.CreateAttachment( l_entityHit );
			
			if( attractionDuration > 0 )
			{
				m_BaitEntity.StopAllEffectsAfter( MaxF( attractionDuration - 5, 0 ) );
				m_BaitEntity.DestroyAfter( attractionDuration );
			}
			else
			{
				m_BaitEntity.StopAllEffectsAfter( 55 );
				m_BaitEntity.DestroyAfter( 60 );
			}
		}		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
}