// CExplorationStateCombat
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 25/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateCombat extends CExplorationStateAbstract
{	
	// slide histeresys
	private editable	var	m_TimeToSlideNeededF			: float;	default	m_TimeToSlideNeededF			= 0.2f;
	private editable	var	m_TimeToSlideCurF				: float;
	
	private editable	var	m_FallHasToWaitForCombatAction	: bool;		default	m_FallHasToWaitForCombatAction	= false;
	private editable	var	m_SlideHasToWaitForCombatAction	: bool;		default	m_SlideHasToWaitForCombatAction	= true;
	private editable	var	m_FallHorizontalImpulseCancelF	: float;	default	m_FallHorizontalImpulseCancelF	= 2.0f;
	private editable	var	m_FallHorizontalImpulseF		: float;	default	m_FallHorizontalImpulseF		= 3.0f;
	private editable	var	m_FallExtraVerticalImpulseF		: float;	default	m_FallExtraVerticalImpulseF		= 2.0f;
	private editable	var	m_TurnAdjustTimeSprintF			: float;	default	m_TurnAdjustTimeSprintF			= 2.5f;
	
	
	//------------------------------------------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'CombatExploration';
		}
		
		m_StateTypeE			= EST_Idle;
		m_InputContextE			= EGCI_Combat; 
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		//AddStateToTheDefaultChangeList('Interaction');
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{
		return thePlayer.IsInCombatState();
		
		//return thePlayer.HasWeaponDrawn( true );
		/*
		if( !thePlayer.newCombatProto )
		{
			return thePlayer.HasWeaponDrawn( true );
		}
		else
		{
			if( thePlayer.HasWeaponDrawn( true ) )
			{
				return theInput.GetActionValue( 'Focus' ) > 0.2f;
			}
		}
		
		return false;		
		*/
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{			
		if( curStateName == 'Jump' || curStateName == 'Slide' || curStateName == 'Climb' || curStateName == 'Interaction' || curStateName == 'Land' || curStateName == 'Roll' )
		{
			return false;
		}
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		m_ExplorationO.m_MoverO.Reset();
		
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();
		
		m_TimeToSlideCurF	= 0.0f;
		
		ChangeToCombat();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{	
		// We can't fall or slide if the combat allowed is not ready to end
		if( !thePlayer.GetBIsCombatActionAllowed() )
		{		
			return super.StateChangePrecheck(); 
		}
		
		// Fall: check here before we can jump or interact
		if( !m_FallHasToWaitForCombatAction && !IsThisStatequeued( 'StartFalling' ) && !m_ExplorationO.IsOnGround() )
		{
			CancelToExploration();
			PrepareFall();
			return 'StartFalling';
		}
		
		// Slide
		if( !m_SlideHasToWaitForCombatAction && m_TimeToSlideCurF > m_TimeToSlideNeededF )
		{
			CancelToExploration();
			SetReadyToChangeTo( 'Slide' );
			return 'Slide';
		}
		
		// Holstered weapon
		/*if( !thePlayer.HasWeaponDrawn( true ) )
		{
			return 'Idle';
		}*/
		
		// Sprint away?
		// TODO
		
		return super.StateChangePrecheck(); 
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		// Parry input fix
		if( !thePlayer.IsGuarded() )
		{
			if( m_ExplorationO.m_InputO.IsGuardPressed() )
			{
				thePlayer.SetGuarded(true);				
				thePlayer.OnPerformGuard();
			}
		}
		
		// slide hysteresys
		if( m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) )
		{
			m_TimeToSlideCurF	= m_TimeToSlideCurF + _Dt;// MinF( m_TimeToSlideCurF + _Dt, m_TimeToSlideNeededF );
		}
		else
		{
			//m_TimeToSlideCurF	= MaxF( m_TimeToSlideCurF - _Dt * 3.0f , 0.0f );
			m_TimeToSlideCurF	= 0.0f;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		ChangeToExploration();
	}	
	
	//------------------------------------------------------------------------------------------------------------------
	private function ChangeToExploration()
	{	
		thePlayer.GoToExplorationIfNeeded();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CancelToExploration()
	{	
		thePlayer.GotoState('Exploration');
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function PrepareFall()
	{
		var macVelocity	: Vector;
		var impulse		: Vector;
		
		
		impulse			= m_ExplorationO.m_OwnerMAC.GetVelocity();
		impulse.Z		= 0.0f;
		impulse			= VecNormalize2D( impulse );
		
		
		// Impulse strength
		// No input
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			impulse *= m_FallHorizontalImpulseCancelF;
		}
		// Countering
		if( VecDot( impulse, m_ExplorationO.m_InputO.GetMovementOnPlaneV() ) < 0.0f )
		{
			impulse *= m_FallHorizontalImpulseCancelF;
		}
		// Moving forward
		else
		{
			impulse	*= m_FallHorizontalImpulseF;
		}
		
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		m_ExplorationO.m_MoverO.SetVerticalSpeed( -AbsF( m_FallExtraVerticalImpulseF ) );
		//m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0f);
		
		m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function ChangeToCombat()
	{
		// Go to combat if not there
		if( !m_ExplorationO.IsThisACombatSuperState( thePlayer.GetCurrentStateName() ) )
		{
			thePlayer.GoToCombatIfNeeded();
		}
	}
	
	//---------------------------------------------------------------------------------
	public function ReactToChanceToFallAndSlide() : bool
	{
		// Fall
		if( m_FallHasToWaitForCombatAction && !IsThisStatequeued( 'StartFalling' ) && !m_ExplorationO.IsOnGround() )
		{
			LogChannel( 'CombatExploration', "ChanceToFall Taken" );
			CancelToExploration();
			PrepareFall();
			SetReadyToChangeTo( 'StartFalling' );
			return true;
		}
		
		// Slide
		// In this case it is enough that we want to enter slide for just this frame
		if( m_SlideHasToWaitForCombatAction && ( m_TimeToSlideCurF > 0.0f || m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) ) )
		{
			LogChannel( 'CombatExploration', "ChanceToSlide Taken" );
			CancelToExploration();
			SetReadyToChangeTo( 'Slide' );
			SetReadyToChangeTo( 'Slide' );
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{	
		// We can't fall or slide if the combat allowed is not ready to end
		if( m_FallHasToWaitForCombatAction && !thePlayer.GetBIsCombatActionAllowed() )
		{		
			return true; 
		}
		
		PrepareFall();
		SetReadyToChangeTo('StartFalling');
		
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
	
	//---------------------------------------------------------------------------------
	public function GetTurnAdjustmentTime() : float
	{
		if( thePlayer.GetIsSprinting() || thePlayer.GetPlayerCombatStance() == PCS_AlertFar )
		{
			if( !thePlayer.IsInCombatAction() )
			{
				return m_TurnAdjustTimeSprintF;
			}
		}
		
		return m_TurnAdjustTimeF;
	}
}
