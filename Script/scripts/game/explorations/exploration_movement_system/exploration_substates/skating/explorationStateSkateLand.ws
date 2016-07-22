// CExplorationSkateLand
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 11/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationSkateLand extends CExplorationStateAbstract
{
	private					var	skateGlobal				: CExplorationSkatingGlobal;
	
	protected editable		var	behLandCancel			: name;			default	behLandCancel 		= 'LandEnd';	
	protected editable		var	timePrevToChain			: float;		default	timePrevToChain		= 0.3f;
	protected editable		var	timeToChainJump			: float;		default	timeToChainJump		= 0.1f;
	protected editable		var	timeSafetyEnd			: float;		default	timeSafetyEnd		= 0.3f;
	
	private 				var actionChained			: bool;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateLand';
		}
		
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
		// Flow
		skateGlobal.StartFlowTimeGap();
		
		// Action Chain
		CheckStartActionChain();
		
		// Check damage
		CheckFallingDamage();
		
		// Movement
		m_ExplorationO.m_MoverO.StopVerticalMovement();
		skateGlobal.ApplyDefaultParams( );
		skateGlobal.ApplyCurLevelParams( );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{	
		// Attack
		skateGlobal.UpdateRandomAttack();
		
		// Action change
		CheckUpdateActionChain();
		
		// Jump combo
		if( m_ExplorationO.GetStateTimeF() >= timeToChainJump )
		{
			if( actionChained )
			{
				ApplyQueuedChain();
			}
			
			// Safety end
			else if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'SkateRun' ) )
			{
				if( m_ExplorationO.GetStateTimeF() >= timeSafetyEnd )
				{
					LogExplorationError( GetStateName() + " Exited by safety time out." );
					return 'SkateRun';
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{	
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		
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
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	private function CheckStartActionChain()
	{	
		var dashPressTime	: float;
		var driftPressTime	: float;
		var jumpPressTime	: float;
		
		
		dashPressTime	= m_ExplorationO.m_InputO.GetDashLastPressedTime();
		driftPressTime	= m_ExplorationO.m_InputO.GetDriftLastPressedTime();
		jumpPressTime	= m_ExplorationO.m_InputO.GetSkateJumpLastPressedTime();		
		
		// Check if dash or drift are pressed, and which is first
		actionChained	=  MinF( dashPressTime, MinF( jumpPressTime, driftPressTime ) ) < timePrevToChain;
	}
	
	//---------------------------------------------------------------------------------
	private function CheckUpdateActionChain()
	{	
		if( !actionChained )
		{
			if( m_ExplorationO.GetStateTimeF() < skateGlobal.GetMaxFlowTimeGap() )
			{
				actionChained	= m_ExplorationO.m_InputO.IsDashJustPressed() 
								|| m_ExplorationO.m_InputO.IsDriftJustPressed() 
								|| m_ExplorationO.m_InputO.IsSkateJumpJustPressed();
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function ApplyQueuedChain()
	{
		var dashPressTime	: float;
		var driftPressTime	: float;
		var jumpPressTime	: float;
		
		if( !actionChained )
		{
			return;
		}
		
		dashPressTime	= m_ExplorationO.m_InputO.GetDashLastPressedTime();
		driftPressTime	= m_ExplorationO.m_InputO.GetDriftLastPressedTime();
		jumpPressTime	= m_ExplorationO.m_InputO.GetSkateJumpLastPressedTime();
		
		
		// Jump perfect flow
		if( jumpPressTime < dashPressTime && jumpPressTime < driftPressTime )
		{
			SetReadyToChangeTo( 'SkateJump' );
		}
		
		// Dash perfect flow
		else if( dashPressTime <= driftPressTime )
		{
			SetReadyToChangeTo( 'SkateDash' );
		}
		
		// Drift perfect flow
		else
		{
			if( m_ExplorationO.StateWantsAndCanEnter( 'SkateSlide' ) )
			{
				SetReadyToChangeTo( 'SkateSlide' );
			}
			else if( m_ExplorationO.StateWantsAndCanEnter( 'SkateStopFast' ) )
			{
				SetReadyToChangeTo( 'SkateStopFast' );
			}
			else
			{
				SetReadyToChangeTo( 'SkateDrift' );
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function CheckFallingDamage()
	{
		var fallDiff		: float;
		var jumpTotalDiff	: float;
		var damagePerc		: float;
		var intoWater		: bool;
		var	position		: Vector;
		
		
		position		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		// Get the falling heights
		m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
		
		// Into Water ?
		intoWater		= false;
		
		
		// Apply Damage
		//damagePerc	= m_ExplorationO.m_OwnerE.ApplyFallingDamage( fallDiff, m_RollingB || intoWater || sliding );
		damagePerc		= 0.0f;
		
		// Movement adjustor
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		
		// Log
		LogExploration( "Landed height difference " + jumpTotalDiff );
		if ( damagePerc >= 1.0f )
		{
			LogExploration( "DEAD from falling" );
		}
		else if( damagePerc > 0.0f )
		{
			LogExploration( "Damaged: " + damagePerc * 100.0f + "%" );
		}
		else
		{
			LogExploration( "Not Damaged from falling" );
		}
	}
	
	//---------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == behLandCancel )
		{		
			SetReadyToChangeTo( 'SkateRun' );
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}	
}
