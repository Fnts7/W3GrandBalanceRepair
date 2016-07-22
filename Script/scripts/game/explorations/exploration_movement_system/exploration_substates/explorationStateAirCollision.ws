// CExplorationStateAirCollision
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 27/01/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
enum EAirCollisionSide
{
	EACS_Left	= 0,
	EACS_Center	= 1,
	EACS_Right	= 2,
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateAirCollision extends CExplorationStateAbstract
{
	editable			var	enabled						: bool;			default	enabled						= true;
	
	// Collisions
	editable			var	speedMinToCollide			: float;		default	speedMinToCollide			= 0.0f;
	editable			var	heightMinToCollide			: float;		default	heightMinToCollide			= 0.12f;
	private editable	var	heightMaxToStop				: float;		default	heightMaxToStop				= 3.0f;
	private editable	var	dotToHardHit				: float;		default	dotToHardHit				= 0.75f;
	
	private				var collisionAngle				: float;
	private				var	collisionSide				: EAirCollisionSide;
	
	public				var	m_NormalMaxZToHitF			: float;		default	m_NormalMaxZToHitF			= 0.85f;
	public				var angleMinToCollide			: float;		default	angleMinToCollide			= 90.0f;
	public				var angleMinToCollideFront		: float;		default	angleMinToCollideFront		= 45.5f;
	
	// Swipe check
	public	editable	var	swipeDistance				: float;		default	swipeDistance				= 0.3f;
	public	editable	var	swipeRadius					: float;		default	swipeRadius					= 0.6f;
	public	editable	var	swipeHeightRequired			: float;		default	swipeHeightRequired			= 0.4f;
	
	
	// Times
	private editable	var	timeStopped					: float;		default	timeStopped					= 1.5f;
	private editable	var	timeToRotate				: float;		default	timeToRotate				= 0.15f;
	private	editable	var	timeToCheckClimb			: float;		default	timeToCheckClimb			= 1.5f;
	private	editable	var	timeToCheckLand				: float;		default	timeToCheckLand				= 1.5f;
	
	// Movement
	private editable	var	exitAngleLeft				: float;		default	exitAngleLeft				= 45.0f;
	private editable	var	exitAngleRight				: float;		default	exitAngleRight				= 45.0f;
	private editable	var	exitAngleExtra				: float;		default	exitAngleExtra				= 20.0f;
	private editable	var	orientingSpeed				: float;		default	orientingSpeed				= 1000.0f;
	private 			var	targetYaw					: float;
	private editable	var	verticalSpeedConserveCoef	: float;		default	verticalSpeedConserveCoef	= 0.25f;
	private editable	var	verticalMovementParams		: SVerticalMovementParams;
	private editable	var	impulseForwardCenter		: float;		default	impulseForwardCenter		= -3.0f;
	private editable	var	impulseDownCenter			: float;		default	impulseDownCenter			= 8.0f;
	private editable	var	impulseForwardSide			: float;		default	impulseForwardSide			= 15.0f;
	private editable	var	impulseDownSide				: float;		default	impulseDownSide				= 7.0f;
	
	// Interaction
	protected editable	var	interactAlways				: bool;			default	interactAlways				= true;
	private	editable	var	interactionTimeMin			: float;		default	interactionTimeMin			= 0.2f;
	private	editable	var	interactionMaxHeight		: float;		default	interactionMaxHeight		= 2.8f;
	
	// Land
	editable			var	timeToHitToLand				: float;		default	timeToHitToLand				= 0.1f;
	editable			var	behEventHitToLand			: name;			default	behEventHitToLand			= 'HitWall_ToLand';
	editable			var	behVarSide					: name;			default	behVarSide					= 'AirCollisionSide';
	editable			var	behVarHands					: name;			default	behVarHands					= 'AirCollisionHands';
	private editable	var	behAnimCanFall				: name;			default	behAnimCanFall				= 'CanFall';
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'AirCollision';
		}
		
		m_StateTypeE		= EST_OnAir;
		m_InputContextE		= EGCI_JumpClimb; 
		//m_HolsterIsFastB	= true;
		//m_InputContextAlternativeB	= true;
		
		SetCanSave( false );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Climb');
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{
		var velocity		: Vector;
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var collisionNormal : Vector;
		var i				: int;
		var forwardestDot	: float;
		var currentDot		: float;
		
		
		// We have fallen too much
		if( m_ExplorationO.m_SharedDataO.GetFallingHeight() > heightMaxToStop )
		{
			return false;
		}
		
		// If we are we moving fast enough
		velocity	= m_ExplorationO.m_OwnerMAC.GetVelocity();
		velocity.Z	= 0.0f;
		if( VecLengthSquared( velocity ) < speedMinToCollide * speedMinToCollide )
		{
			return false;
		}
		
		// If there are collisions
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();
		if( collisionNum <= 0 )
		{
			return false;
		}
		
		// Front most collision
		forwardestDot	= -1.0f;
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			// If collision normal is vertical enough
			if( AbsF( collisionData.normal.Z ) <= m_NormalMaxZToHitF )
			{
				currentDot		= VecDot( -collisionData.normal, m_ExplorationO.m_OwnerE.GetWorldForward() );
				if( currentDot > forwardestDot )
				{
					collisionNormal = -collisionData.normal;
					currentDot		= forwardestDot;
				}
			}
		}
		
		// If collision direction is perpendicular enough
		collisionAngle		= AngleNormalize180( AngleDistance( VecHeading( collisionNormal ), m_ExplorationO.m_OwnerE.GetHeading() ) );
		if( AbsF( collisionAngle ) > angleMinToCollide )
		{
			return false;
		}
		if( !m_ExplorationO.m_SharedDataO.m_AirCollisionSideEnabledB && AbsF( collisionAngle ) > angleMinToCollideFront )
		{
			return false;
		}
		
		LogExploration( GetStateName() + " " + "angle " + collisionAngle );
		
		// If there is land just below our feet
		if( false ) //m_ExplorationO.m_CollisionManagerO.CheckLandBelow( heightMinToCollide ) )
		{
			return false;
		}
		
		// If there is ground high enough
		collisionNormal.Z	= 0.0f;
		collisionNormal		= VecNormalize( collisionNormal );		
		if( !m_ExplorationO.m_CollisionManagerO.CheckSwipeInDir( -collisionNormal, swipeDistance + 0.4f, swipeRadius, Vector( 0.f, 0.f, swipeRadius + swipeHeightRequired ) , true ) )
		{
			return false;
		}
		
		return true;
	}

	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		return enabled;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		var collisionDirectionDot	: float;
		var collisionData			: SCollisionData;
		var collisionNum			: int;
		var i						: int;
		var resultingNormal			: Vector;
		var tooMuchHeight			: bool;
		
		var movAdj 					: CMovementAdjustor;
		var ticket 					: SMovementAdjustmentRequestTicket;
		var extraAngle				: float;
		
		
		// Custom movement
		m_ExplorationO.m_MoverO.SetManualMovement( true );
		
		tooMuchHeight	= m_ExplorationO.m_SharedDataO.GetFallingHeight() > heightMaxToStop;
		
		// Stop horizontal movement		
		if( !tooMuchHeight && timeStopped > 0.0f )
		{
			m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0f );
		}
		else
		{
			if( tooMuchHeight )
			{
				LogExploration( GetStateName() + ": Can't stop cause of too much height fallen" );
			}
			
			m_ExplorationO.m_MoverO.SetVerticalSpeed( m_ExplorationO.m_MoverO.GetMovementVerticalSpeedF() * verticalSpeedConserveCoef );
		}
		//m_ExplorationO.m_MoverO.SetVelocity( Vector( 0,0,0 ) );
		m_ExplorationO.m_MoverO.SetVerticalMovementParams( verticalMovementParams );
		
		// Set the side
		if( AbsF( collisionAngle ) < angleMinToCollideFront )
		{
			collisionSide	= EACS_Center;
			extraAngle		= 0.0f;
		}
		else if( collisionAngle > 0.0f )
		{
			collisionSide	= EACS_Left;
			extraAngle		= -exitAngleLeft - exitAngleExtra;
		}
		else
		{
			collisionSide	= EACS_Right;
			extraAngle		= exitAngleRight + exitAngleExtra;
		}
		m_ExplorationO.m_SharedDataO.m_AirCollisionIsFrontal	= collisionSide == EACS_Center;
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarSide, ( float ) ( int ) collisionSide );
		
		
		
		// Hand collision
		if( m_ExplorationO.m_CollisionManagerO.CheckCollisionsForwardInHands( 0.2f ) )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarHands, 1.0f );
		}
		else
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarHands, 0.0f );
		}
		
		// Foot forward
		m_ExplorationO.m_SharedDataO.SetFotForward( true );
		
		// setup movement adjustment to face the wall
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'HitWall' );
		movAdj.AdjustmentDuration( ticket, timeToRotate );
		movAdj.RotateTo( ticket, m_ExplorationO.m_OwnerE.GetHeading() + collisionAngle + extraAngle );
	}
	
	//---------------------------------------------------------------------------------
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanFall, 'OnAnimEvent_SubstateManager' );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{	
		// Climb
		if( m_ExplorationO.GetStateTimeF() >= timeToCheckClimb && InputWantsToClimb() )
		{
			if( m_ExplorationO.StateWantsAndCanEnter( 'Climb' ) )
			{
				return 'Climb';
			}
		}
		
		/*
		// Exploration interaction
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Interaction' ) )
		{
			if( InputWantsToClimb() && WantsToInteractWithExploration() )
			{
				return 'Interaction';
			}
		}
		*/
		// Land
		if( m_ExplorationO.GetStateTimeF() >= timeToCheckLand && m_ExplorationO.m_CollisionManagerO.CheckLandBelow( 0.01f ) )
		{
			if( m_ExplorationO.GetStateTimeF() >= timeToHitToLand )
			{
				// Since we go directly to land, we have to set the jumptype
				m_ExplorationO.m_SharedDataO.m_JumpTypeE = EJT_Hit;
				m_ExplorationO.SendAnimEvent( behEventHitToLand );
				
				return 'Land';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		// Displacement
		if( m_ExplorationO.GetStateTimeF() >= timeStopped )
		{
			m_ExplorationO.m_MoverO.UpdatePerfectMovementVertical( _Dt );
		}
		
		// Rotation
		//m_ExplorationO.m_MoverO.RotateYawTowards( targetYaw, orientingSpeed * _Dt, 1.0f, false );
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		// Custom movement
		m_ExplorationO.m_MoverO.SetManualMovement( false );
		
		// Movement adjustor
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'HitWall' );
		
		
		if( nextStateName == 'Jump' )
		{	
			PrepareImpulseToJump();
		}
	}
	
	//---------------------------------------------------------------------------------
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanFall );
	}
	
	//---------------------------------------------------------------------------------
	private function PrepareImpulseToJump()
	{
		var impulse			: Vector;
		var verticalImpulse	: float;
		
		if( collisionSide == EACS_Center )
		{
			impulse	= m_ExplorationO.m_OwnerE.GetWorldForward() * impulseForwardCenter;
			verticalImpulse	= impulseDownCenter;
		}
		else
		{
			impulse	= m_ExplorationO.m_OwnerE.GetWorldForward() * impulseForwardSide;
			verticalImpulse	= impulseDownSide;
		}
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		m_ExplorationO.m_MoverO.SetVerticalSpeed( -verticalImpulse );
	}
	
	//---------------------------------------------------------------------------------
	private function InputWantsToClimb() : bool
	{
		// Do we want to interact ?
		if( !interactAlways )
		{
			return false;
		}
		
		// Min time
		if( m_ExplorationO.GetStateTimeF() < interactionTimeMin )
		{
			return false;
		}
		
		// Is input is pressed?
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function WantsToInteractWithExploration() : bool
	{
		var exploration					: SExplorationQueryToken;
		var queryContext				: SExplorationQueryContext;
		
		
		if( m_ExplorationO.m_SharedDataO.m_UseClimbB )
		{
			return false;
		}
		
		// Get input direction
		queryContext.inputDirectionInWorldSpace	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		
		// Mark that we're in the middle of jump now
		queryContext.forJumping = true;
		
		// Ingore Z and dist checks - we're going to find it on our own
		queryContext.dontDoZAndDistChecks = true;
		
		// Get the closest exploration
		exploration = theGame.QueryExplorationSync( m_ExplorationO.m_OwnerE, queryContext );
		
		// Is it valid?
		if ( !exploration.valid )
		{
			return false;
		}
		
		// Is it close enough ?
		if( VecDistanceSquared( exploration.pointOnEdge, m_ExplorationO.m_OwnerE.GetWorldPosition() ) > interactionMaxHeight * interactionMaxHeight )
		{
			return false;
		}
		
		// Save the exploration
		m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	// Collision events
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{	
		/*var direction	: Vector;
		var dot			: float;
		
		
		if( m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) )
		{
			SetReadyToChangeTo( 'Slide' );
			return true;
		}
		
		//SetReadyToChangeTo( 'Land' );
		*/
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		var text	: string;
		
		text = " Side: " + collisionSide + ", Angle: " + collisionAngle;
		
		return text;
	}
	
	//---------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{		
		if( animEventName == behAnimCanFall )
		{
			SetReadyToChangeTo( 'Jump' );
		}
	}
	
	//---------------------------------------------------------------------------------
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) :bool
	{		
		return false;
	}
}
