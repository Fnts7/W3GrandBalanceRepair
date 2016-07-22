// CExplorationStateCombat
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 25/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSwim extends CExplorationStateAbstract
{	
	private editable	var	solveCollisionsForward	: bool;		default	solveCollisionsForward	= false;
	private editable	var	smoothPenetration		: bool;		default	smoothPenetration		= true;
	private editable	var collisionUpOffset		: float;	default	collisionUpOffset		= 0.8f;
	private editable	var collisionDistance		: float;	default	collisionDistance		= 0.45f; //1.3f;
	private editable	var collisionRadius			: float;	default	collisionRadius			= 0.4f;
	private editable	var	collisionPenetrationMax	: float;	default	collisionPenetrationMax	= 1.5f;
	private editable	var	collisionPenetration	: Vector;
	private editable	var	smoothSpeed				: float;	default	smoothSpeed				= 10.0f;
	private				var	zeroVec					: Vector;
	
	
	//------------------------------------------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Swim';
		}
		
		// TODO fix this
		//m_StateTypeE	= EST_Swim;
		//m_StateTypeE			= EST_Idle;
		m_StateTypeE			= EST_Unchanged;
		m_InputContextE			= EGCI_Swimming; 
		
		zeroVec					= Vector( 0.0f, 0.0f, 0.0f );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Interaction');
		//AddStateToTheDefaultChangeList('Climb');
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{
		if ( m_ExplorationO.GetSuperStateName() == 'Swimming' )
			return true;
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		//thePlayer.SetIsInAir( false );
		collisionPenetration	= zeroVec;		
		
		//Abort all signs
		thePlayer.AbortSign();	
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{	
		/*if( m_ExplorationO.StateWantsAndCanEnter( 'Interaction' ) )
		{
			return 'TransitionSwimToInteract';
		}*/
		
		return super.StateChangePrecheck();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		// solve collisions if we are moving forward
		if( solveCollisionsForward )
		{	
			UpdateCollisionSolving( _Dt );
		}
		
		// Rotation correction
		if( m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF != 0.0f )
		{
			m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF	= MinF( 0.0f, m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF + _Dt * 150.0f );
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'Slide_Inclination', m_ExplorationO.m_SharedDataO.m_JumpSwimRotationF );
		}
		
		// Safe position
		//thePlayer.CaptureSafePosition();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		return;
	}	
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCollisionSolving( _Dt : float )
	{
		var distance	: float;
		var normal		: Vector;
		
		
		// Get the distance of penetration
		if( !GetPenetrationDistanceAndNormal( distance, normal ) )
		{
			collisionPenetration	= zeroVec;
			return;
		}
		
		// Smooth it
		if( smoothPenetration )
		{
			collisionPenetration	= LerpV( collisionPenetration, distance * normal, smoothSpeed * _Dt );
		}
		
		// Apply it
		m_ExplorationO.m_MoverO.Translate( collisionPenetration ); //distance );
	}
		
	//------------------------------------------------------------------------------------------------------------------
	private function GetPenetrationDistanceAndNormal( out penetration : float, out normal : Vector ) : bool
	{
		var world 			: CWorld;
		var posCurrent		: Vector;
		var posTarget		: Vector;
		var	collisionPoint	: Vector;
		var penetrationMax	: float;
		var	vectorAux		: Vector;
		
		
		// Physics World 
		world	= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		// Get points to sweep
		posCurrent		= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp() * collisionUpOffset;
		
		vectorAux		= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( thePlayer.GetHeadBoneIndex() ) - posCurrent;
		penetrationMax	= VecDot( m_ExplorationO.m_OwnerE.GetWorldForward(), vectorAux  );
		//if( penetrationMax	> 0.5f )
		//{
			penetrationMax	+= collisionDistance;
		//}
		
		penetrationMax	= MinF( penetrationMax, collisionPenetrationMax );
		posTarget		= posCurrent + m_ExplorationO.m_OwnerE.GetWorldUp() * collisionUpOffset;
		posTarget		+=  m_ExplorationO.m_OwnerE.GetWorldForward() * penetrationMax;
		
		// Do the sweep
		if( world.SweepTest( posCurrent, posTarget, collisionRadius, collisionPoint, normal ) )
		{
			penetration	= VecDot( m_ExplorationO.m_OwnerE.GetWorldForward(), collisionPoint - posCurrent  );
			penetration	= ClampF( penetrationMax - penetration, 0.0f, penetrationMax );
			
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		return true;
	}	
	
	//---------------------------------------------------------------------------------
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function CanInteract( ) : bool
	{
		return true;
	}
}
