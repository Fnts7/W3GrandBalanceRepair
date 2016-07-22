
// CExplorationStateSkateStopFast
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 17/02/2014 )	 

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkateStopFast extends CExplorationStateSkatingDrift
{		
	
	private editable			var inputRangeToEnter		: float;		default inputRangeToEnter	= 15.0f;
	private editable			var duration				: float;		default duration			= 0.75f;
	private editable inlined	var speedStopCurve			: CCurve;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateStopFast';
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
		inputHeadingAbs	= AngleDistance( 180.0f, inputHeadingAbs );
		inputHeadingAbs	= AbsF( inputHeadingAbs );
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() || inputHeadingAbs < inputRangeToEnter )// AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputRangeToEnter )
		{
			return m_ExplorationO.m_InputO.IsDriftPressed();
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var newVelocity	: Vector;
		var coef		: float;
		
		
		// Attack
		skateGlobal.UpdateRandomAttack();
		
		// Movement
		if( m_ExplorationO.GetStateTimeF() >= duration )
		{
			m_ExplorationO.m_MoverO.SetVelocity( Vector( 0,0,0 ) );
			SetReadyToChangeTo( 'SkateIdle' );
		}
		else
		{
			newVelocity	= m_ExplorationO.m_MoverO.GetMovementVelocity();
			coef	= m_ExplorationO.GetStateTimeF() / duration;
			if( speedStopCurve )
			{
				coef	= speedStopCurve.GetValue( coef );
			}
			
			newVelocity	= LerpV( newVelocity, Vector( 0,0,0 ), coef );
			
			m_ExplorationO.m_MoverO.UpdateMovementLinear( newVelocity, _Dt );
		}
	}
}