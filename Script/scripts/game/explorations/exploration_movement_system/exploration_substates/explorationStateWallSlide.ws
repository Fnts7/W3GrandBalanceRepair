// CExplorationStateWallSlide
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 20/01/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateWallSlide extends CExplorationStateSlide
{	
	private	var	wallSlideGenericCoef	: float;	default	wallSlideGenericCoef	= 0.7f;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'WallSlide';
		}
		
		// HACK: Wallslide does not update materials atm
		updateMaterials				= false;
		useWideTerrainCheckToEnter	= false;
		
		// If we have this state, disable sliding by default, till we enter here
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		m_StateTypeE	= EST_Idle;
		
		SetCanSave( false );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		//AddStateToTheDefaultChangeList('Jump');
	}
	
	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		var coef	: float;
		
		
		// Wont slide on air
		if( !m_ExplorationO.IsOnGround() )
		{
			return false;
		}
		
		// slide coef
		coef	= m_ExplorationO.m_MoverO.GetRawSlideCoef( true );
		
		// For debug purposes
		if( coef > wallSlideGenericCoef )
		{ 
			return true;
		}
		
		return false;
	}	
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		return false;
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( !StateWantsToEnter() )
		{
			// Slide
			if( m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) )
			{
				return 'Slide';
			}
			// Fall			
			if( !m_ExplorationO.IsOnGround() )
			{
				if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'StartFalling' ) )
				{
					return 'StartFalling';
				}
			}
			// Land	
			else if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Land' ) )
			{
				return 'Land';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		super.StateUpdateSpecific( _Dt );
		
		// When wallsliding we also get damage
		m_ExplorationO.m_SharedDataO.UpdateFallHeight();
	}
	
	//---------------------------------------------------------------------------------
	protected  function CheckLandingDamage()
	{
		// No landing damage on wall sliding, we just keep increasing the speed
		return;
	}
}