// CExplorationStateSkatingRun
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 03/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingRun extends CExplorationStateAbstract
{		
	// Speed levels
	private	var	skateGlobal		: CExplorationSkatingGlobal;
	
	private	var m_Sprinting		: bool;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateRun';
		}		
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		// Set the type
		m_StateTypeE	= EST_Skate;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
		//AddStateToTheDefaultChangeList( 'SkateBackwards' );
		//AddStateToTheDefaultChangeList( 'SkateSlide' );
		//AddStateToTheDefaultChangeList( 'SkateStopFast' );
		//AddStateToTheDefaultChangeList( 'SkateDrift' );
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateDash' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		return m_ExplorationO.m_InputO.IsModuleConsiderable();
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		// Set the default params again
		skateGlobal.ApplyDefaultParams( );
		skateGlobal.ApplyCurLevelParams( );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{		
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
		UpdateBaseSpeed();
		
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		// Anim		
		skateGlobal.SetBehParams( accel, braking, turn );
		
		// Iddle?
		if( skateGlobal.ShouldStop( braking ) )
		{
			SetReadyToChangeTo( 'SkateIdle' );
		}		
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{		
		thePlayer.SetBIsCombatActionAllowed( true );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateBaseSpeed()
	{
		if( m_ExplorationO.m_InputO.IsDashPressed() )
		{
			if( !m_Sprinting )
			{
				m_Sprinting	= true;
				skateGlobal.SetSpeedLevel( 1, true );
			}
		}
		else if( m_Sprinting )
		{
			m_Sprinting	= false;
			skateGlobal.SetSpeedLevel( 0, true );
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