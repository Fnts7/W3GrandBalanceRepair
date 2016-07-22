// CExplorationStateSprint
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 22/11/2013 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSprint extends CExplorationStateAbstract
{	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Sprint';
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
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		// Idle
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
		{
			if( !m_ExplorationO.m_InputO.IsSprintPressed() )
			{
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
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