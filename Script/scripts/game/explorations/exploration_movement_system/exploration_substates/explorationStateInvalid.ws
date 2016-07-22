// CExplorationStateInvalid
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 21/11/2013 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateInvalid extends CExplorationStateAbstract
{		
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{
		m_ExplorationO = _Exploration;
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Invalid';
		}
		m_StateTypeE	= EST_Idle;
		
		//SetCanSave( false );
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
		//Abort all signs
		thePlayer.AbortSign();
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
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
	function CanInteract( ) : bool
	{
		return true;
	}
}