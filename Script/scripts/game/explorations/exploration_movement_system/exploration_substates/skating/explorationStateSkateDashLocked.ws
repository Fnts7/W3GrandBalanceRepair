// CExplorationStateSkatingDashLocked
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 04/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingDashLocked extends CExplorationInterceptorStateAbstract
{		
	private				var	skateGlobal				: CExplorationSkatingGlobal;
	
	// Target aquire
	private 			var target					: CEntity;
	private				var	isInFlow				: bool;
	private editable	var	targetMaxAngle			: float;		default	targetMaxAngle		= 25.0f;
	private editable	var	targetMaxAngleFlow		: float;		default	targetMaxAngleFlow	= 45.0f;
	private editable	var	reachSideDistance		: float;		default	reachSideDistance	= 2.0f;
	private editable	var	targetSideDistance		: float;		default	targetSideDistance	= 1.0f;
	private	editable	var inputAngleInfluence		: float;		default	inputAngleInfluence	= 30.0f;
	
	// Movement
	private				var	speed					: float;
	private				var	speedMinMax				: float;		default	speedMinMax			= 8.0f;
	private				var	impulseMax				: float;		default	impulseMax			= 5.5f;
	private				var	impulseMaxFlow			: float;		default	impulseMaxFlow		= 6.5f;
	
	// Turn
	private editable	var	aimSpeed				: float;		default	aimSpeed			= 100.0f;
	private editable	var adjustorTicket			: SMovementAdjustmentRequestTicket;
	
	// Hit
	private editable	var	attackDistGap			: float;		default	attackDistGap		= 4.0f;
	private editable	var	attackDistGapPerfect	: float;		default	attackDistGapPerfect= 3.0f;
	private 			var	toTargetDistanceInit	: float;
	private				var toTargetDistance		: float;
	private 			var	targetDirLast			: Vector;
	private 			var	attacked				: bool;
	
	// Time max
	protected editable	var timeTotalMax			: float;		default	timeTotalMax		= 1.0f;
	protected editable	var timeTotalMaxFlow		: float;		default	timeTotalMaxFlow	= 1.5f;
	protected editable	var timeToChainMin			: float;		default	timeToChainMin		= 0.2f;
	
	// Time scale
	protected editable	var	useTimeScale			: bool;			default	useTimeScale		= false;
	protected editable	var	timeScaleSpeed			: float;		default	timeScaleSpeed		= 0.15f;
	protected			var	timeScaled				: bool;
	
	
	// Prototype HACK	
	private editable	var	afterAttackTime		: float;	default	afterAttackTime				= 0.5f;
	private 			var timeToEndCur		: float;
	public	editable 	var	behParamAttackName	: name;		default	behParamAttackName			= 'Skate_Attack';
	
	private editable	var	afterAttackImpulse	: float;	default	afterAttackImpulse			= 5.0f;
	private editable	var	isEnabled			: bool;		default isEnabled					= false;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateDashLocked';
		}
		
		m_InterceptStateN	= 'SkateDashAttack';
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		//AddStateToTheDefaultChangeList( 'SkateSlide' );
		//AddStateToTheDefaultChangeList( 'SkateStopFast' );
		//AddStateToTheDefaultChangeList( 'SkateDrift' );
		//AddStateToTheDefaultChangeList( 'SkateBackwards' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{			
		return false;
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !isEnabled )
		{
			return false;
		}
		
		return GetAValidTarget();
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{	
		// Dash increases one level
		skateGlobal.IncreaseSpeedLevel( true, false );
		
		// Perfect Flow
		isInFlow	= skateGlobal.CheckIfIsInFlowGapAndConsume();
		if( isInFlow )
		{
			skateGlobal.IncreaseSpeedLevel( true, true );
		}
		
		// Get the starting dir to target
		targetDirLast			= GetTargetPosition() - m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		toTargetDistance		= VecLength( targetDirLast );
		toTargetDistanceInit	= toTargetDistance;
		
		// Start orientation
		OrientToTarget();
		
		// And speed
		m_ExplorationO.m_MoverO.SetVelocity( VecNormalize( targetDirLast ) * speed );
		
		
		// Flags
		attacked	= false;
		timeScaled	= false;
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeTotalMax )
		{
			return 'SkateRun';
		}
		// Don't allow for auto state changes if the time is not enough
		else if( m_ExplorationO.GetStateTimeF() < timeToChainMin )
		{
			return GetStateName();
		}
		
		
		return super.StateChangePrecheck();
	}
	
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{				
		// Target
		UpdateTargetLocation();
		
		// Attack
		UpdateAttack( _Dt );
		
		// Move
		UpdateTimeScale( _Dt );
		
		// Translate
		m_ExplorationO.m_MoverO.UpdateMovementLinear( m_ExplorationO.m_MoverO.GetMovementVelocity(), _Dt );
		
		// Beh
		skateGlobal.SetBehParams( 1.0f, false, 0.0f );
		
		UpateDebug();
	}
	
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		thePlayer.GetVisualDebug().RemoveBar( 'Skate Attack gap' );
		thePlayer.GetVisualDebug().RemoveBar( 'Skate Attack separator' );
		thePlayer.GetVisualDebug().RemoveBar( 'Skate Attack separator2' );
		thePlayer.GetVisualDebug().RemoveBar( 'Skate Attack separator3' );
		
		theGame.RemoveTimeScale( 'SkateDash' );
		
		// Push enemies while attacking
		((CActor) thePlayer ).SetInteractionPriority( IP_Prio_0 );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateTargetLocation()
	{		
		var targetPos	: Vector;
		var toTarget	: Vector;
		
		
		// Get direction to target
		targetPos	= GetTargetPosition();
		toTarget	= targetPos - m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		// Target reach
		if( VecDot( targetDirLast, toTarget ) < 0.0f ) //|| VecLengthSquared( toTarget ) <= reachSideDistance * reachSideDistance )
		{
			SetReadyToChangeTo( 'SkateRun' );
		}
		else
		{				
			//targetYaw	= VecHeading( toTarget );
			//UpdateOrientation();
		}
		
		// Save the vector to target
		targetDirLast	= toTarget;
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateAttack( _Dt : float )
	{
		if( attacked )
		{
			timeToEndCur -= _Dt;
			if( timeToEndCur <= 0.0f )
			{
				SetReadyToChangeTo( 'SkateRun' );
			}
		}
		
		else if( !m_ExplorationO.m_InputO.IsSkateAttackPressed() )
		{
			m_ExplorationO.SendAnimEvent( behParamAttackName );
			attacked		= true;
			timeToEndCur	= afterAttackTime;
			skateGlobal.ImpulseNotExceedingMaxSpeedLevel( afterAttackImpulse );
			
			// Push enemies while attacking
			((CActor) thePlayer ).SetInteractionPriority( IP_Prio_14 );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateAttackFlow()
	{
		var attacking	: bool;
		var animation : SCameraAnimationDefinition;
		
		toTargetDistance	= VecDistance( m_ExplorationO.m_OwnerE.GetWorldPosition(), target.GetWorldPosition() );
		
		// attack
		if( !attacked )
		{
			skateGlobal.UpdateRandomAttack();
			attacking	= skateGlobal.UpdateDashAttack();
			
			// Pwrfect time
			if( toTargetDistance < attackDistGapPerfect )
			{
				if( attacking )
				{
					skateGlobal.StartFlowTimeGap();
					skateGlobal.IncreaseSpeedLevel( true, true );
					
					// Camera shake
					animation.animation = 'camera_shake_hit_lvl3_1';
					animation.priority = 0;
					animation.blendIn = 0.25f;
					animation.blendOut = 0.25f;
					animation.weight = 0.25f;
					animation.speed	= 1.0f;
					animation.additive = true;
					animation.reset = true;
					
					theGame.GetGameCamera().PlayAnimation( animation );
				}
			}
			// Acceptable time
			else if( toTargetDistance < attackDistGap )
			{
				if( attacking )
				{
					skateGlobal.StartFlowTimeGap();
					
					// Camera shake
					animation.animation = 'camera_shake_hit_lvl3_1';
					animation.priority = 0;
					animation.blendIn = 0.15f;
					animation.blendOut = 0.15f;
					animation.weight = 0.15f;
					animation.additive = true;
					animation.reset = true;
					
					theGame.GetGameCamera().PlayAnimation( animation );
				}
			}
			
			if( attacking )
			{	
				//m_ExplorationO.SendAnimEvent( skateGlobal.behParamAttackName );
				attacked	= true;
				SetReadyToChangeTo( 'SkateRun' );
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateTimeScale( _Dt : float )
	{		
		if( useTimeScale && !timeScaled && toTargetDistance < attackDistGap )
		{
			theGame.SetTimeScale( timeScaleSpeed, 'SkateDash', 0 );
			timeScaled	= true;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpateDebug()
	{
		var bar			: float;
		var width		: int;
		
		width	= 60 * ( int ) toTargetDistanceInit;
		
		// attack
		if( !attacked )
		{
			bar		= ClampF( toTargetDistance / toTargetDistanceInit, 0.0f, 1.0f );
			
			thePlayer.GetVisualDebug().AddBar( 'Skate Attack separator', 350, 344, width, 2, 1.0f, Color(255,0,0), "", 0.0f );
			thePlayer.GetVisualDebug().AddBar( 'Skate Attack separator2', 350, 346, width, 2, attackDistGap / toTargetDistanceInit, Color(0,0,255), "", 0.0f );
			thePlayer.GetVisualDebug().AddBar( 'Skate Attack separator3', 350, 348, width, 2, attackDistGapPerfect / toTargetDistanceInit, Color(0,255,255), "", 0.0f );
			
			// Pwrfect time
			if( toTargetDistance < attackDistGapPerfect )
			{
				thePlayer.GetVisualDebug().AddBar( 'Skate Attack gap', 350, 350, width, 10, bar, Color(0,255,255), "Perfect Attack", 0.0f );
			}
			// Acceptable time
			else if( toTargetDistance < attackDistGap )
			{
				thePlayer.GetVisualDebug().AddBar( 'Skate Attack gap', 350, 350, width, 10, bar, Color(0,0,255), "Attack", 0.0f );
			}
			// Bad time
			else
			{
				thePlayer.GetVisualDebug().AddBar( 'Skate Attack gap', 350, 350, width, 10, bar, Color(255,0,0), "Wait", 0.0f );
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function OrientToTarget()
	{
		var movAdj 		: CMovementAdjustor;
		var direction	: float;
		
		direction	= VecHeading( targetDirLast );
		
		// setup movement adjustment
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		adjustorTicket = movAdj.CreateNewRequest( 'turnOnDash' );
		
		// we want reasonably quickly to turn in requested direction
		movAdj.AdjustmentDuration( adjustorTicket, 0.3f );
		// we want to jump exactly where we want - anytime, without any limitations
		movAdj.RotateTo( adjustorTicket, direction );
		// we want to move in that direction immediately
		//movAdj.LockMovementInDirection( ticket, direction );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateOrientation()
	{
		var movAdj 		: CMovementAdjustor;
		var direction	: float;
		
		direction	= VecHeading( targetDirLast );
		
		// we want reasonably quickly to turn in requested direction
		movAdj.AdjustmentDuration( adjustorTicket, 0.3f );
		// we want to jump exactly where we want - anytime, without any limitations
		movAdj.RotateTo( adjustorTicket, direction );
	}
	
	//---------------------------------------------------------------------------------
	private function GetAValidTarget() : bool
	{
		var targets				: array <CEntity>;
		
		var ownerPosition		: Vector;
		var ownerSpeedHeading	: float;
		var	targetMaxDistance	: float;
		var distanceSqr			: float;
		var angleDif			: float;
		var angleTolerance		: float;
		var impulseResulting	: float;
		
		var results				: int;
		var	i					: int;
		
		
		// Get the closest enemy
		//targets	= GetActorsInRange( this, targetMaxDistance );
		theGame.GetEntitiesByTag( 'SkateTarget', targets);
		results	= targets.Size();
		
		ownerPosition		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		ownerSpeedHeading	= m_ExplorationO.m_MoverO.GetMovementSpeedHeadingF();
		// Add input control
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			ownerSpeedHeading	+= ClampF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF(), -inputAngleInfluence, inputAngleInfluence );
		}
		
		// angle tolerance
		if( isInFlow )
		{
			angleTolerance		= targetMaxAngleFlow;
			impulseResulting	= impulseMaxFlow;
		}
		else
		{
			angleTolerance		= targetMaxAngle;
			impulseResulting	= impulseMax;
		}
		
		// Reach is based on speed
		speed				= ClampF( m_ExplorationO.m_MoverO.GetMovementSpeedF() + impulseResulting, speedMinMax, skateGlobal.GetSpeedMax() );
		targetMaxDistance	= speed * timeTotalMax;
		targetMaxDistance	*= targetMaxDistance;
		
		/*
		selectionWeights.angleWeight = 0.75f;
		selectionWeights.distanceWeight = 0.125f;
		selectionWeights.distanceRingWeight = 0.125f;

		InternalFindTargetsInCone( targets, selectionHeading );
		selectedTarget = thePlayer.SelectTarget( targets, false, theCamera.GetCameraHeading(), selectionWeights, true );	
		*/
		
		// TODO: Use aim help from Cyberpunk
		// Now we get the first target in range
		for( i = 0; i < results; i+= 1 )
		{
			target	= targets[i];
			
			if( target )
			{
				// don't target yourself
				if( target == m_ExplorationO.m_OwnerE )
				{
					continue;
				}
				
				// Close enough
				targetDirLast	= target.GetWorldPosition() - ownerPosition;
				distanceSqr		= VecLengthSquared( targetDirLast );
				if( distanceSqr > targetMaxDistance )
				{
					continue;
				}
				
				// Not too close
				if( distanceSqr < targetSideDistance * targetSideDistance )
				{
					continue;
				}
				
				// Angularly close enough
				angleDif		= AngleDistance( VecHeading( targetDirLast ), ownerSpeedHeading );
				angleDif		= AbsF( angleDif );
				if( angleDif > angleTolerance )
				{
					continue;
				}
				
				// Acceptable target
				return true;
			}
		}
		// No target found
		return false;
	}
	
	//---------------------------------------------------------------------------------
	private function GatherTargetAttackData()
	{
		var distanceRemaining	: float;
		
		distanceRemaining	= VecLength( GetTargetPosition()	-	m_ExplorationO.m_OwnerE.GetWorldPosition() );
		//attackGapStart
	}
	
	//---------------------------------------------------------------------------------
	private function GetTargetPosition() : Vector
	{
		var targetPos	: Vector;
		var toTarget	: Vector;
		
		
		if( !target)
		{
			return m_ExplorationO.m_OwnerE.GetWorldPosition();
		}
		
		// get the target pos
		targetPos	= target.GetWorldPosition();
		
		// Get the displacement to the side
		toTarget	= targetPos - m_ExplorationO.m_OwnerE.GetWorldPosition();
		if( VecDot( toTarget, m_ExplorationO.m_OwnerE.GetWorldRight() ) < 0.0f )
		{
			toTarget	= VecCross( toTarget, target.GetWorldUp() );
		}
		else 
		{
			toTarget	= -VecCross( toTarget, target.GetWorldUp() );
		}
		toTarget	= VecNormalize( toTarget ) * targetSideDistance;
		
		// get the final target position
		targetPos	= targetPos + toTarget;
		
		return targetPos;
	}
}
