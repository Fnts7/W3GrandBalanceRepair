// CExplorationStateSkatingPrepareJump
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 19/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingPrepareJump extends CExplorationInterceptorStateAbstract
{		
	private						var	skateGlobal		: CExplorationSkatingGlobal;
	
	protected editable			var behAnimEnd		: name;			default	behAnimEnd		= 'AnimEndAUX';
	protected editable			var timeMax			: float;		default	timeMax			= 0.5f;	
	
	// Flow
	private editable			var flowImpulse		: float;		default	flowImpulse		= 1.0f;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkatePrepareJump';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;		
		
		
		m_InterceptStateN	= 'SkateJump';
		
		// Set the type
		m_StateTypeE	= EST_Skate;
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
		if( skateGlobal.CheckIfIsInFlowGapAndConsume() )
		{
			skateGlobal.ImpulseToNextSpeedLevel( flowImpulse );	
		}
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateJump';
		}
		
		
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
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		// Anim		
		skateGlobal.SetBehParams( accel, braking, turn );
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{		
	}	
	
	
	//---------------------------------------------------------------------------------
	// Anim events
	//---------------------------------------------------------------------------------

	//------------------------------------------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behAnimEnd )
		{		
			SetReadyToChangeTo( 'SkateJump' );
		}
	}
	
	//---------------------------------------------------------------------------------
	// Collision events
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		//SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{		
		return true;
	}		
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) : bool
	{		
		return false;
	}
}