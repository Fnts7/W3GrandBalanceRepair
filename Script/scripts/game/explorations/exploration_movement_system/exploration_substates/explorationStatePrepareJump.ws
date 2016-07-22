// CExplorationStatePrepareJump
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 21/11/2013 )	 
//------------------------------------------------------------------------------------------------------------------

enum PrepareJumpSubState
{
	PJSS_Start	,
	PJSS_Loop	,
	PJSS_End	,
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStatePrepareJump extends CExplorationStateAbstract
{
	protected editable	var	m_JumpIsInstantB	: bool;		default	m_JumpIsInstantB	= true;
	protected editable	var	m_JumpTimeGapF		: float;	default	m_JumpTimeGapF		= 0.5f;
	protected editable	var	m_EndingTimeF		: float;	default	m_EndingTimeF		= 0.9f;
	protected editable	var	m_EndEventNameN		: name;		default m_EndEventNameN		= 'Jump_Prepare_End';
	protected editable	var	m_EndedEventNameN	: name;		default m_EndedEventNameN	= 'Jump_Prepare_Ended';
	protected editable	var	m_TimeEndedB		: bool;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'PrepareJump';
		}
		
		m_StateTypeE	= EST_Idle;
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
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		m_TimeEndedB	= false;
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		// Jump
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Jump' ) )
		{
			// instant jump
			if( m_JumpIsInstantB )
			{
				return 'Jump';
			}
			
			// Jump
			if( !m_TimeEndedB )
			{ 
				if( !m_ExplorationO.m_InputO.IsSprintPressed() ) // Considering that sprint and jump are the same button in this case
				{
					return 'Jump';
				}
			}
		}
		
		// Run, Sprint or idle
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Sprint' ) )
		{
			if ( m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				if( m_ExplorationO.m_InputO.IsSprintPressed() )
				{
					return 'Sprint';
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		// Check time end
		if( !m_TimeEndedB )
		{
			if( m_ExplorationO.GetStateTimeF() >= m_JumpTimeGapF )
			{			
				m_ExplorationO.SendAnimEvent( m_EndEventNameN );
				m_TimeEndedB	= true;
			}
		}
		
		// Cancell animation state
		else if ( m_ExplorationO.GetStateTimeF() >= m_JumpTimeGapF + m_EndingTimeF || m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			m_ExplorationO.SendAnimEvent( m_EndedEventNameN );
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) :bool
	{		
		return false;
	}
}