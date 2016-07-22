// CExplorationSkatingGlobal
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 07/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationSkatingGlobal extends CObject
{		
	private						var m_ExplorationO			: CExplorationStateManager;
	
	// Speed levels
	private						var	speedLevelCur			: int;
	private	editable			var	speedLevelCapDefault	: int;							default	speedLevelCapDefault	= 3;
	private						var	speedLevelCap			: int;
	private	editable			var	speedLevelTotal			: int;							default	speedLevelTotal			= 4;
	private	editable 			var	maxSpeedTotal			: float;						default	maxSpeedTotal			= 18.0f;
	private	editable 			var	minSpeedTotal			: float;						default	minSpeedTotal			= 7.0f;
	private						var	speedPerLevel			: float;
	private						var	movementParamsLevels	: array< SSkatingLevelParams >;
	private editable inlined	var movementLevelsSpeedCurve: CCurve;
	private	editable inlined	var	movementParams			: SSkatingMovementParams;
	
	
	private	editable 			var	turnSpeedBase			: float;						default	turnSpeedBase			= 170.0f;
	
	// Dash
	protected editable			var dashCooldownTotal		: float;						default	dashCooldownTotal		= 0.5f;
	protected editable			var dashCooldownCur			: float;
	
	// Stop	
	private	editable 			var	speedToBrake			: float;						default	speedToBrake			= 3.0f;
	private	editable 			var	speedToStop				: float;						default	speedToStop				= 0.5f;
	
	// Turn
	public						var	m_TurnF					: float;
	
	// Drift
	public						var	m_Drifting				: bool;
	public						var	m_DrifIsLeft			: bool;
	
	// Flow time gaps
	protected					var	flowComboCur			: int;
	protected					var flowGapTimeCur			: float;
	protected editable			var	flowGapTimeTotal		: float;						default	flowGapTimeTotal		= 0.5f;
	protected editable			var	flowSuccesfullTimeTotal	: float;						default	flowSuccesfullTimeTotal	= 0.4f;
	protected 					var	flowSuccesfullTime		: float;
	
	// Behavior
	private	editable 			var	behParamTurnName		: name;							default	behParamTurnName		= 'Skate_Turn';
	private	editable 			var	behParamAccelName		: name;							default	behParamAccelName		= 'Skate_Accel';
	private	editable 			var	behParamSpeedName		: name;							default	behParamSpeedName		= 'Skate_Speed';
	public	editable 			var	behParamAttackName		: name;							default	behParamAttackName		= 'Skate_Attack';
	public	editable 			var	behParamRandAttackName	: name;							default	behParamRandAttackName	= 'Skate_RandomHit';
	public	editable 			var	behParamJumpAttackName	: name;							default	behParamJumpAttackName	= 'Skate_Attack_Jump';
	private	editable 			var behParamTurnMax			: float;						default	behParamTurnMax			= 1.5f;
	
	private editable			var	behIncreasedSpeed		: name;							default	behIncreasedSpeed		= 'SkateIncreaseSpeed';
	private editable			var	behIncreasedFwdSpeed	: name;							default	behIncreasedFwdSpeed	= 'SkateIncreaseSpeedForward';
	
	private						var	active					: bool;
	
	
	//---------------------------------------------------------------------------------
	public function Initialize(_Exploration : CExplorationStateManager )
	{
		var aux		: float;
		var i		: int;
		
		m_ExplorationO	= _Exploration;
		
		flowGapTimeCur	= flowGapTimeTotal + 1.0f;
		
		// Gather speed levels
		speedPerLevel	= ( maxSpeedTotal - minSpeedTotal ) / ( float ) ( speedLevelTotal - 1 );
		movementParamsLevels.Resize( speedLevelTotal );
		if( movementLevelsSpeedCurve )
		{
			for ( i = 0; i < speedLevelTotal; i += 1)
			{
				aux	= ( float ) i / ( float ) ( speedLevelTotal - 1 );
				aux	= minSpeedTotal + ( maxSpeedTotal - minSpeedTotal ) * movementLevelsSpeedCurve.GetValue( aux );
				movementParamsLevels[i].speedMax		= aux;
				movementParamsLevels[i].reflectInput	= true;
			}	
		}
		else
		{
			for ( i = 0; i < speedLevelTotal; i += 1)
			{
				movementParamsLevels[i].speedMax		= minSpeedTotal + speedPerLevel * i;
				movementParamsLevels[i].reflectInput	= true;
			}	
		}
		movementParamsLevels[0].reflectInput		= false;
		
		m_ExplorationO.m_MoverO.SetSkatingAbsoluteMaxSpeed( maxSpeedTotal );
		
		Reset();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function Reset()
	{
		speedLevelCap	= speedLevelCapDefault;
		
		CancelFlowTimeGap() ;
		SetSpeedLevel( 0, true );
		ApplyDefaultParams();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function PostUpdate( _Dt : float )
	{
		if( !active )
		{
			return;
		}
		
		// Speed levels
		UpdateSpeedLevelReduction( _Dt );
		
		
		// Flow
		if( flowGapTimeCur < flowGapTimeTotal )
		{
			flowGapTimeCur += _Dt;			
			if( flowGapTimeCur >= flowGapTimeTotal )
			{
				LostFlowCombo();
			}
		}		
		
		// Jump	
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV		= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
		
		
		// Debug
		UpdateDebug( _Dt );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateSpeedLevelReduction( _Dt : float )
	{
		// Speed levels
		var decreaseLevel	: bool	= false;
		
		
		// Check slowing down to previous speed
		if( m_ExplorationO.m_MoverO.GetAccelerationnLastF() < 0.0f )
		{
			if( speedLevelCur > 0 )
			{
				if( m_ExplorationO.m_MoverO.GetMovementSpeedF() <= movementParamsLevels[ speedLevelCur - 1 ].speedMax )
				{
					decreaseLevel	= true;
				}
			}
		}
		
		if( decreaseLevel )
		{
			DecreaseSpeedLevel( true, true );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateDebug( _Dt : float )
	{
		var height	: int;
		
		height	= 450;
		
		// Speed
		thePlayer.GetVisualDebug().AddBar( 'SpeedLevelSeparator', 150, height, 200, 5, 1.0f, Color(0,255,0), "", 0.0f );
		height	+= 5;
		thePlayer.GetVisualDebug().AddBar( 'SpeedLevel', 150, height, 200, 10, ( float ) speedLevelCur / ( float ) speedLevelTotal, Color(255,255,0), "SpeedLevel: " + speedLevelCur + " cap at: " + speedLevelCap, 0.0f );
		height	+= 12;
		thePlayer.GetVisualDebug().AddBar( 'Speed', 150, height, 200, 10, m_ExplorationO.m_MoverO.GetMovementSpeedF() / maxSpeedTotal, Color(100,255,100), "Speed: " + m_ExplorationO.m_MoverO.GetMovementSpeedF(), 0.0f );
		height	+= 15;
		
		// Flow combo
		thePlayer.GetVisualDebug().AddBar( 'Skate flow combo', 150, height, 200, 5, 1.0f, Color(255,255,0), "Combo " + flowComboCur, 0.0f );
		height	+= 15;
		
		
		// Flow gap
		height	= 450;		
		
		// Flow successful
		if( flowSuccesfullTime > 0.0f )
		{
			flowSuccesfullTime	-= _Dt;
			thePlayer.GetVisualDebug().AddBar( 'Skate flow success', 750, height, 500, 30, 1.0f, Color(0,255,0), "FLOW SUCCESS!!!", 0.0f );
		}
		else
		{
			thePlayer.GetVisualDebug().AddBar( 'Skate flow success', 750, height, 500, 30, 0.0f, Color(0,255,0), "", 0.0f );
		}
		height	+= 30;
		
		// Flow gap time
		thePlayer.GetVisualDebug().AddBar( 'Skate flow separator', 750, height, 500, 2, 1.0f, Color(255,255,0), "Flow", 0.0f );
		if( flowGapTimeCur <= flowGapTimeTotal )
		{
			thePlayer.GetVisualDebug().AddBar( 'Skate flow gap', 750, height + 5, 500 , 30, 1.0f - ClampF( flowGapTimeCur / flowGapTimeTotal, 0.0f, 1.0f ), Color(255,255,0), "", 0.0f );
		}
		else
		{
			thePlayer.GetVisualDebug().AddBar( 'Skate flow gap', 750, height + 5, 500, 30, 0.0f, Color(255,255,0), "", 0.0f );
		}
	}
	
	//---------------------------------------------------------------------------------
	public function SetActive( enable : bool )
	{
		active	= enable;
		if( enable )
		{
			// Input context
			theInput.SetContext( 'Skating' );
		}
	}
	
	//---------------------------------------------------------------------------------
	//	Attack
	//---------------------------------------------------------------------------------
	public function UpdateRandomAttack() : bool
	{
		// TEMP HACK
		return false;
		
		// Attack
		if( m_ExplorationO.m_InputO.IsSkateAttackJustPressed() )
		{
			m_ExplorationO.SendAnimEvent( behParamRandAttackName );
			
			return true;
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function UpdateDashAttack() : bool
	{
		// TEMP HACK
		return false;
		
		// Attack
		if( m_ExplorationO.m_InputO.IsSkateAttackJustPressed() )
		{
			m_ExplorationO.SendAnimEvent( behParamAttackName );
			
			return true;
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function UpdateJumpAttack() : bool
	{
		// Attack
		if( m_ExplorationO.m_InputO.IsSkateAttackJustPressed() )
		{
			m_ExplorationO.SendAnimEvent( behParamJumpAttackName );
			
			return true;
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	//	 Speed levels
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	public function GetSpeedLevel() : int
	{
		return speedLevelCur;
	}
	
	//---------------------------------------------------------------------------------
	public function GetSpeedMax() : float
	{
		// One extra speed level
		return maxSpeedTotal + speedPerLevel;
	}
	
	//---------------------------------------------------------------------------------
	public function GetSpeedMaxCur() : float
	{
		return GetSpeedLevelParamSpeedMax( speedLevelCur );
	}
	
	//---------------------------------------------------------------------------------
	public function GetSpeedLevelParamSpeedMax( level : int ) : float
	{
		level	= Clamp( level, 0 ,speedLevelTotal );
		return movementParamsLevels[ level ].speedMax;
	}
	
	//---------------------------------------------------------------------------------
	public function ApplyDefaultParams()
	{
		m_ExplorationO.m_MoverO.SetSkatingParams( movementParams );
		m_ExplorationO.m_MoverO.SetSkatingTurnSpeed( turnSpeedBase );
	}
	
	//---------------------------------------------------------------------------------
	public function ApplyCurLevelParams()
	{
		m_ExplorationO.m_MoverO.SetSkatingLevelParams( movementParamsLevels[ speedLevelCur ] );
	}
	
	//---------------------------------------------------------------------------------
	public function ImpulseToNextSpeedLevel( baseImpulse : float )
	{
		var speedLevelNext	: int;
		var speedLevelNow	: int;
		var speedMax		: float;
		var speedCur		: float;
		var aux				: float;
		
		
		speedCur		= m_ExplorationO.m_MoverO.GetMovementSpeedF();
		
		// Get the next level if not the max already
		speedLevelNext	= Min( speedLevelCur + 1, speedLevelTotal - 1 );
		
		speedMax		= movementParamsLevels[ speedLevelNext ].speedMax;
		aux				= speedMax - speedCur;
		aux				= ClampF( baseImpulse, 0.0f, aux );
		
		m_ExplorationO.m_MoverO.AddSpeed( aux );
	}
	
	//---------------------------------------------------------------------------------
	public function ImpulseNotExceedingMaxSpeedLevel( baseImpulse : float )
	{
		var speedMax		: float;
		var speedCur		: float;
		var aux				: float;
		
		
		speedCur		= m_ExplorationO.m_MoverO.GetMovementSpeedF();
		speedMax		= movementParamsLevels[ speedLevelTotal - 1 ].speedMax;
		aux				= speedMax - speedCur;
		aux				= ClampF( baseImpulse, 0.0f, aux );
		
		m_ExplorationO.m_MoverO.AddSpeed( aux );
	}
	
	//---------------------------------------------------------------------------------
	public function IncreaseSpeedLevel( applyNow : bool, increaseLevelCapIfNeeded : bool ) : bool
	{
		if( speedLevelCur < speedLevelTotal )
		{	
			// Special increase level cap
			if( speedLevelCur >= speedLevelCap )
			{
				if( increaseLevelCapIfNeeded )
				{
					speedLevelCap	+= 1;
				}
				else
				{
					return false;
				}
			}
			
			speedLevelCur	+= 1;
			
			return SetSpeedLevel( speedLevelCur, applyNow );
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function DecreaseSpeedLevel( applyNow : bool, decreaseLevelCapIfNeeded : bool ) : bool
	{
		if( speedLevelCur > 0 )
		{			
			speedLevelCur	-= 1;
			
			// Lower the level cap
			if( decreaseLevelCapIfNeeded )
			{
				speedLevelCap	= Max( speedLevelCur, speedLevelCapDefault );
			}
			
			return SetSpeedLevel( speedLevelCur, applyNow );
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function SetSpeedLevel( level : int, applyNow : bool ) : bool
	{
		if( level >= speedLevelTotal || level < 0 )
		{
			LogExplorationError( "Trying to set a speed level that does not exist" );
			return false;
		}
		
		// Set the level
		speedLevelCur	= level;
		
		LogExploration( "Speed level set to:" + speedLevelCur );
		
		if( applyNow )
		{		
			ApplyCurLevelParams();
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function ShouldStop( braking : bool ) : bool
	{
		var accel	: float;
		
		accel	= m_ExplorationO.m_MoverO.GetAccelerationnLastF();
		if( accel < 0.0f )
		{
			if( GetSpeedLevel() <= 0 )
			{
				if( braking )
				{
					if ( m_ExplorationO.m_MoverO.GetMovementSpeedF() <= speedToBrake )
					{
						return true;
					}
				}
				else
				{
					if ( m_ExplorationO.m_MoverO.GetMovementSpeedF() <= speedToStop )
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	// Flow time gap
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	public function StartFlowTimeGap()
	{
		flowGapTimeCur	= 0.0f;
	}
	
	//---------------------------------------------------------------------------------
	public function CancelFlowTimeGap() 
	{
		flowGapTimeCur 	= flowGapTimeTotal + 1.0f;
	}
	
	//---------------------------------------------------------------------------------
	public function CheckIfIsInFlowGapAndConsume() : bool
	{
		var result : bool;
		
		result	= flowGapTimeCur <= flowGapTimeTotal;
		
		CancelFlowTimeGap();
		
		// Debug feedback
		if( result )
		{
			flowSuccesfullTime	= flowSuccesfullTimeTotal;
			ChainedFlowCombo();
		}
		
		return result;
	}
	
	//---------------------------------------------------------------------------------
	public function GetMaxFlowTimeGap() : float
	{
		return flowGapTimeTotal;
	}
	
	
	//---------------------------------------------------------------------------------
	// Flow Combos
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	private function LostFlowCombo()
	{
		flowComboCur	= 0;
	}
	
	//---------------------------------------------------------------------------------
	private function ChainedFlowCombo()
	{
		flowComboCur	+= 1;
	}
	
	//---------------------------------------------------------------------------------
	private function GetCurFlowCombo() : int
	{
		return flowComboCur;
	}
	
	
	//---------------------------------------------------------------------------------
	//	 Dash
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	public function IsDashReady() : bool
	{ 
		// If in flow gap, cooldown can be surpassed
		return dashCooldownCur >= dashCooldownTotal || flowGapTimeCur <= flowGapTimeTotal;
	}
	
	//---------------------------------------------------------------------------------
	function UpdateDashCooldown( _Dt : float )
	{
		dashCooldownCur += _Dt;
	}
	
	//---------------------------------------------------------------------------------
	function ConsumeDashCooldown()
	{
		dashCooldownCur	= 0.0f;
	}
	
	//---------------------------------------------------------------------------------
	function SetDashReady()
	{
		dashCooldownCur	= dashCooldownTotal;
	}
	
	//---------------------------------------------------------------------------------
	//	 Animation
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	public function SetBehParams( accel : float, braking : bool, turn : float )
	{		
		var speed			: float;
		var directionDot	: float;
		
		
		// Speed level
		if( speedLevelCur > 1 )
		{
			speed	= 1.0f;
		}
		else
		{
			speed	= 0.0f;
		}
		
		// Clamp turn
		turn	= ClampF( turn, -1.0f, 1.0f );
		
		
		// Set the accel manually
		directionDot	= VecDot( m_ExplorationO.m_InputO.GetMovementOnPlaneV(), m_ExplorationO.m_OwnerE.GetWorldForward() );
		if( directionDot > -0.25f  )
		{
			accel	= 1.0f;
		}
		else if( braking ) // directionDot < -0.45f )
		{
			accel	= -1.0f;
		}
		else
		{
			accel	= 0.0f;
		}
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behParamSpeedName, speed );		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behParamAccelName, accel );	
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behParamTurnName, -turn );	
		
		// Save the turn to consult
		m_TurnF	= turn;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == behIncreasedSpeed )
		{
			m_ExplorationO.m_MoverO.SetSpeedFromAnim( maxSpeedTotal );
		}
		if ( animEventName == behIncreasedFwdSpeed )
		{
			m_ExplorationO.m_MoverO.SetSpeedFromAnimFrontal( maxSpeedTotal );
		}
	}
}