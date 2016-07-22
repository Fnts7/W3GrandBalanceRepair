// CExplorationStateSkatingHitFrontal
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 18/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingHitFrontal extends CExplorationInterceptorStateAbstract
{		
	private						var	skateGlobal		: CExplorationSkatingGlobal;
	
	protected editable			var behAnimEnd		: name;			default	behAnimEnd		= 'AnimEndAUX';
	protected editable			var timeMax			: float;		default	timeMax			= 0.5f;	
	protected editable			var dotCollToEnter	: float;		default	dotCollToEnter	= 0.75f;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateHitFrontal';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;		
		
		
		m_InterceptStateN	= 'SkateHitLateral';
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var direction		: Vector;
		
		direction	= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
		
		// Check collisions
		collisionNum = m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			collisionNormal += collisionData.normal;
		}
		if ( collisionNum > 0 )
		{
			collisionNormal = VecNormalize( collisionNormal );
			if( VecDot( collisionNormal, direction ) < -dotCollToEnter )
			{
				return true;
			}
		}
		return false;
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var direction		: Vector;
		
		direction	= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
		
		// Check collisions
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			collisionNormal += collisionData.normal;
		}
		if ( collisionNum > 0 )
		{
			collisionNormal = VecNormalize( collisionNormal );
			if( VecDot( collisionNormal, direction ) < -dotCollToEnter )
			{
				return true;
			}
		}
		return false;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{		
		m_ExplorationO.m_MoverO.StopAllMovement();
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateIdle';
		}
		
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{		
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{		
	}	
	
	
	//---------------------------------------------------------------------------------
	// Anim events
	//---------------------------------------------------------------------------------

	//------------------------------------------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behAnimEnd )
		{		
			SetReadyToChangeTo( 'SkateIdle' );
		}
	}
	
	//---------------------------------------------------------------------------------
	// Collision events
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{		
		return true;
	}		
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) : bool
	{		
		return false;
	}
}