// CExplorationSkatingIdle
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 04/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingIdle extends CExplorationStateAbstract
{		
	private				var	skateGlobal		: CExplorationSkatingGlobal;
	
	private editable	var	turnSpeed			: float;		default	turnSpeed			= 700.0f;
	private editable	var	turnStartTolerance	: float;		default	turnStartTolerance	= 10.0f;
	
	// Hack Ciri
	private editable	var hackCiri			: bool;			default	hackCiri			= true;
	private editable	var behEventStart		: name;			default	behEventStart		= 'Skate_StartStep';
	private editable	var behEventEnd			: name;			default	behEventEnd			= 'AnimEndAux';
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateIdle';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		// for testing purposes
		return m_ExplorationO.GetStateTypeCur() != EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{				
		m_ExplorationO.m_MoverO.StopAllMovement();
		
		// Ciri hack
		if( hackCiri )
		{		
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
			theGame.ChangePlayer( "Ciri" );
			
			thePlayer.GotoState('Skating');
			hackCiri	= false;
		}
		
		skateGlobal.SetActive( true );
		
		thePlayer.SetBIsCombatActionAllowed( false );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{				
		// Attack
		skateGlobal.UpdateRandomAttack();
		
		// Start step
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{		
			m_ExplorationO.SendAnimEvent( behEventStart );
			
			// Set the direction
			HackDirectionSet();
		}
		
		// Temp hack for idle jump, we'll have a specific jump for idle
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= m_ExplorationO.m_OwnerE.GetWorldForward();
		
		// Beh
		skateGlobal.SetBehParams( 0, 0, 0 );
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{		
		thePlayer.SetBIsCombatActionAllowed( true );
	}	
	
	//---------------------------------------------------------------------------------
	private function HackDirectionSet()
	{
		var l_DirectionV		: Vector;
		var l_CamDirectionF		: float;
		var l_DirectionF		: float;
		
		
		// Cam heading and player heading on cam space
		l_DirectionV 	= theCamera.GetCameraDirection();			
		l_DirectionV.Z 	= 0;
		
		l_CamDirectionF = VecHeading( l_DirectionV );
		l_DirectionF	= thePlayer.GetHeading() - l_CamDirectionF;
		
		thePlayer.SetBehaviorVariable( 'rawPlayerHeading', l_DirectionF - 180);
		
		l_DirectionF = l_DirectionF - m_ExplorationO.m_InputO.GetHeadingOnPadF();
		
		//l_DirectionF = l_DirectionF / 180.0f;
		
		thePlayer.GetMovingAgentComponent().SetGameplayMoveDirection( l_DirectionF );
		//
		// WRONG: m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'playerDir', l_DirectionF ); //Skate_Input
	}
	
	//---------------------------------------------------------------------------------
	// Anim events
	//---------------------------------------------------------------------------------
	
	//------------------------------------------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behEventEnd )
		{
			SetReadyToChangeTo( 'SkateRun' );
			
			// Get speed from animation
			m_ExplorationO.m_MoverO.SetSpeedFromAnim();
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
	function CanInteract( ) :bool
	{		
		return false;
	}
}