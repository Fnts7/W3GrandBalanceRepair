// CExplorationSkatingDrift
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 04/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingBackwards extends CExplorationStateAbstract
{		
	protected					var	skateGlobal			: CExplorationSkatingGlobal;
	
	//protected editable	inlined	var baseParamsDrift		: SSkatingMovementParams;
	
	protected editable			var impulse				: float;					default	impulse				= 0.75f;
	protected editable			var impulseSpeedMax		: float;					default	impulseSpeedMax		= 8.0f;
	
	// Sharp / normal turn
	protected					var sharpTurn			: bool;	
	protected editable			var sharpTurnTime		: float;					default	sharpTurnTime		= 0.15f;
	protected editable			var sharpTurnSpeed		: float;					default sharpTurnSpeed		= 100.0f;
	protected editable			var holdTurnSpeed		: float;					default holdTurnSpeed		= 70.0f;
	
	// Chain
	protected editable			var chainTimeToDrift	: float;					default	chainTimeToDrift	= 0.2f;
	
	// Ending
	protected 					var exiting				: bool;	
	protected editable			var timeEndingMax		: float;					default	timeEndingMax		= 0.2f;
	protected 					var timeEndingFlow		: bool;
	protected					var	timeEndingCur		: float;
	
	protected editable			var behDriftRestart		: name;						default	behDriftRestart		= 'Skate_DriftRestart';
	protected editable			var behDriftEnd			: name;						default	behDriftEnd			= 'Skate_DriftEnd';
	protected editable			var behDriftLeftSide	: name;						default	behDriftLeftSide	= 'Skate_DriftLeft';
	
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateBackwards';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{		
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateDash' );
		AddStateToTheDefaultChangeList( 'SkateDrift' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		if( skateGlobal.ShouldStop( true ) )
		{
			return false;
		}
		
		return m_ExplorationO.m_InputO.GetDoubleTapUp( ) || m_ExplorationO.m_InputO.GetDoubleTapDownB( );
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	//---------------------------------------------------------------------------------
	protected function StateEnterSpecific( prevStateName : name )	
	{		
		var impulseResulting	: float;
		
		
		//Impulse
		impulseResulting	= MaxF( 0.0f, impulseSpeedMax - m_ExplorationO.m_MoverO.GetMovementSpeedF() );
		impulseResulting	- MinF( impulse, impulseResulting );
		m_ExplorationO.m_MoverO.AddSpeed( impulseResulting );
		
		// Perfect Flow
		if( skateGlobal.CheckIfIsInFlowGapAndConsume() )
		{
			skateGlobal.DecreaseSpeedLevel( true, false );
		}
		// No flow
		else
		{
			skateGlobal.DecreaseSpeedLevel( false, true );
			//skateGlobal.DecreaseSpeedLevel( false, false );
		}
		
		//m_ExplorationO.m_MoverO.SetSkatingParams( baseParamsDrift );
		m_ExplorationO.m_MoverO.SetSkatingTurnSpeed( sharpTurnSpeed );
		
		exiting					= false;
		timeEndingCur			= 0.0f;
		sharpTurn				= true;
		timeEndingFlow			= false;
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( timeEndingCur > timeEndingMax )
		{
			return 'SkateRun';
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		// Attack
		skateGlobal.UpdateRandomAttack();
		
		// Movement
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		// Get the side
		//m_ExplorationO.SetBehaviorParamBool( behDriftLeftSide, turn > 0.0f );
		
		// Exit or not exit
		UpdateExit( _Dt, braking );
		
		// Anim		
		skateGlobal.SetBehParams( accel, braking, turn );
	}
	
	//---------------------------------------------------------------------------------
	protected function StateExitSpecific( nextStateName : name )
	{		
		skateGlobal.m_Drifting	= false;
		skateGlobal.StartFlowTimeGap();
	}	
	
	//---------------------------------------------------------------------------------
	protected function UpdateExit( _Dt : float, braking : bool )
	{
		// Iddle?
		if( skateGlobal.ShouldStop( braking ) )
		{
			SetReadyToChangeTo( 'SkateIdle' );
		}
		
		if( m_ExplorationO.GetStateTimeF() > .02f && StateWantsToEnter() )
		{
			SetReadyToChangeTo(	'SkateRun' );
		}
		
		/*
		// Exit time
		if( StateWantsToEnter() )
		{
			if( timeEndingCur > 0.0f  )
			{
				// Go to run so we can reenter the state
				if( m_ExplorationO.GetStateTimeF() >= chainTimeToDrift )
				{
					SetReadyToChangeTo(	'SkateRun' );
				}
				
				skateGlobal.CancelFlowTimeGap();
				m_ExplorationO.SendAnimEvent( behDriftRestart );
				
				timeEndingCur	= 0.0f;
				skateGlobal.m_Drifting	= true;
			}
		}
		else
		{
			timeEndingCur	+= _Dt;
			if( !timeEndingFlow && timeEndingCur > timeEndingMax - skateGlobal.GetMaxFlowTimeGap() )
			{
				timeEndingFlow	= true;
				m_ExplorationO.SendAnimEvent( behDriftEnd );
				skateGlobal.m_Drifting	= false;
			}
		}
		*/
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
	function CanInteract( ) :bool
	{		
		return false;
	}
}