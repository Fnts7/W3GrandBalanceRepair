// CExplorationStateSkateJump
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 14/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkateJump extends CExplorationStateJump
{
	private				var	skateGlobal		: CExplorationSkatingGlobal;
	
	// Attack
	private 			var attacked				: bool;
	private editable	var attacktimeMin			: float;				default	attacktimeMin			= 0.0f;
	private editable	var attackVertSpeedMin		: float;				default	attackVertSpeedMin		= 8.0f;
	private editable	var attackVertSpeedImpulse	: float;				default	attackVertSpeedImpulse	= 3.0f;
	
	
	//---------------------------------------------------------------------------------
	protected function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateJump';
		}
		
		m_StateTypeE	= EST_OnAir;
		
		super.InitializeSpecific(_Exploration);
	}
		
	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{			
		// No jumping on interactions
		if( thePlayer.IsInsideInteraction() && thePlayer.IsActionAllowed( EIAB_Interactions ) )
		{
			return false;
		}
		
		if(	m_ExplorationO.m_InputO.IsSkateJumpJustPressed() )
		{
			return true;
		}
		
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	protected function StateEnterSpecific( prevStateName : name )	
	{	
		attacked	= false;
		
		super.StateEnterSpecific( prevStateName );
	}	
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		// Check for an aerial attack
		// TODO: There is something very wrong at calling this function, a bug in the engine?
		//if( skateGlobal.UpdateJumpAttack() )
		UpdateJumpAttack();
		
		
		super.StateUpdateSpecific( _Dt );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateJumpAttack()
	{
		var newVertSpeed	: float;
		
		if( attacked )
		{
			return;
		}
		
		if( m_ExplorationO.GetStateTimeF() <= attacktimeMin )
		{
			return;
		}
		if( !m_ExplorationO.m_InputO.IsSkateAttackPressedInTime( 0.2f ) )
		{
			return;
		}
		
		newVertSpeed	= m_ExplorationO.m_MoverO.GetMovementVerticalSpeedF();
		newVertSpeed	= MaxF( newVertSpeed + attackVertSpeedImpulse, attackVertSpeedMin ); 
		
		m_ExplorationO.m_MoverO.SetVerticalSpeed( newVertSpeed );
		
		
		m_ExplorationO.SendAnimEvent( 'Skate_Attack_Jump' );
		
		attacked	= true;
	}
}
