// CExplorationStateSkateSlide
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 11/02/2014 )	 

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkateSlide extends CExplorationStateSkatingDrift
{			
	private editable	var inputRangeToEnter		: float;		default inputRangeToEnter	= 15.0f;
	private editable	var height					: float;		default height				= 1.0f;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateSlide';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{		
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateDash' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		var inputHeadingAbs	: float;
		
		if( skateGlobal.ShouldStop( true ) )
		{
			return false;
		}
		
		inputHeadingAbs	= m_ExplorationO.m_InputO.GetHeadingOnPadF();
		inputHeadingAbs	= AbsF( inputHeadingAbs );
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() || inputHeadingAbs < inputRangeToEnter )// AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputRangeToEnter )
		{
			return m_ExplorationO.m_InputO.IsDriftPressed();
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	protected function StateEnterSpecific( prevStateName : name )
	{
		m_ExplorationO.m_OwnerMAC.SetHeight( height );
		
		super.StateEnterSpecific( prevStateName );
		
		// Not exactly drifting
		skateGlobal.m_Drifting = false;		
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
		
		
		// Exiting?
		UpdateExit( _Dt, braking );
	}
	
	//---------------------------------------------------------------------------------
	protected function StateExitSpecific( nextStateName : name )
	{
		m_ExplorationO.m_OwnerMAC.ResetHeight( );
		
		super.StateExitSpecific( nextStateName );
	}
}