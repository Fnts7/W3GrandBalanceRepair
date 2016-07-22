// CExplorationStateStartFalling
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 06/12/2013 )	 
//------------------------------------------------------------------------------------------------------------------

enum EFallType
{
	FT_Idle		,
	FT_Walk		,
	FT_Run		,
	FT_Sprint	,
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateStartFalling extends CExplorationStateAbstract
{
	private editable	var	timeToJump		: float;		default timeToJump	= 0.2f;
	private				var fallCancelled	: bool;
	private				var fallType		: EFallType;
	private				var behFallType		: name;			default	behFallType	= 'FallType';
	
	private				var cameraFallIsSet : bool;
	private				var q704_gravit_shift : bool;
	
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'StartFalling';
		}
		
		m_StateTypeE				= EST_OnAir;
		m_InputContextE				= EGCI_JumpClimb; 
		
		
		SetCanSave( false );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{
		return false;
	}

	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{
		/*if( curStateName == 'Idle' && thePlayer.IsActionBlockedBy( EIAB_Jump, 'q704_gravity_shift' ) )
		{
			return false;
		}*/
		
		return curStateName != 'Jump' && curStateName != 'Swim';
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		fallCancelled	= false;
		cameraFallIsSet = false;
		
		if( thePlayer.IsActionBlockedBy( EIAB_Jump, 'q704_gravity_shift' ) )
		{
			q704_gravit_shift = true;
		}
		else
		{
			q704_gravit_shift = false;
		}
		
		// Force holster
		thePlayer.OnRangedForceHolster( true );
		
		// Check the fall type
		if( prevStateName == 'Idle' )
		{
			if( thePlayer.GetIsSprinting() )
			{
				fallType	= FT_Sprint;
			}
			else if( thePlayer.GetIsRunning())
			{
				fallType	= FT_Run;
			}
			else if( thePlayer.IsMoving() )
			{
				fallType	= FT_Walk;
			}
			else
			{
				fallType	= FT_Idle;
			}
		}
		else 
		{
			fallType	= FT_Idle;
		}
		
		// Set it to the behavior graph
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behFallType, ( float ) ( int ) fallType );		
		
		//Abort all signs
		thePlayer.AbortSign();	
		
		if( q704_gravit_shift )
		{
			m_ExplorationO.m_MoverO.SetManualMovement( true );
		}
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		// while gravity is shifting stay in this falling state
		if( q704_gravit_shift )
		{
			return '';
		}
		
		// Swimming
		if( thePlayer.IsSwimming() )
		{
			return 'Swim';
		}
		
		// Keep running
		if( fallCancelled )
		{
			if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{
				return 'Idle';
			}
		}
		
		// Jump
		return 'Jump';
		/*
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Jump' ) )
		{
			if( true )//if( m_ExplorationO.GetStateTimeF() >= timeToJump )
			{
				return 'Jump';
			}
		}
		*/
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		if( q704_gravit_shift && !thePlayer.IsActionBlockedBy( EIAB_Jump, 'q704_gravity_shift' ) )
		{
			q704_gravit_shift = false;
		}
		
		/*if( q704_gravit_shift )
		{
			ChangeCameraToFall();
		}*/
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		if( q704_gravit_shift )
		{
			m_ExplorationO.m_MoverO.SetManualMovement( false );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function ChangeCameraToFall()
	{
		var camera	: CCustomCamera = theGame.GetGameCamera();
		
		//camera.ChangePivotRotationController( 'Jump' );
		camera.ChangePivotPositionController( 'Jump' );
		
		cameraFallIsSet = true;
	}
	
	//---------------------------------------------------------------------------------
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		return q704_gravit_shift;
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
		fallCancelled	= true;
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) :bool
	{		
		return false;
	}
}