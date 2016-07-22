// CExplorationStateSkatingDash
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 04/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSkatingDash extends CExplorationStateAbstract
{		
	protected					var	skateGlobal			: CExplorationSkatingGlobal;
	
	// Speed
	protected editable			var impulse				: float;		default	impulse					= 3.0f;
	protected editable			var timeMax				: float;		default	timeMax					= 0.75f;
	protected editable			var timeToChainMin		: float;		default	timeToChainMin			= 0.2f;	
	
	
	// Turn
	protected editable			var sharpTurnSpeed		: float;		default	sharpTurnSpeed			= 300.0f;
	protected editable			var holdTurnSpeed		: float;		default	holdTurnSpeed			= 80.0f;
	protected					var sharpTurn			: bool;	
	protected editable			var sharpTurnTime		: float;		default	sharpTurnTime			= 0.2f;
	
	
	// Attack
	protected editable			var behAttackEvent		: name;			default	behAttackEvent			= 'Skate_Attack';
	protected editable			var behLeftFootParam	: name;			default	behLeftFootParam		= 'Skate_LeftFoot';
	
	
	// Bones
	protected 					var	boneRightFoot		: name;			default	boneRightFoot			= 'r_foot';
	protected 					var	boneLeftFoot		: name;			default	boneLeftFoot			= 'l_foot';
	protected 					var	boneIndexRightFoot	: int;
	protected 					var	boneIndexLeftFoot	: int;
	
	
	//Beh
	private editable			var behEventEnd			: name;			default	behEventEnd			= 'AnimEndAux';
	
	
	//---------------------------------------------------------------------------------
	protected function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateDash';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		
		// Get and store bone indexes
		boneIndexRightFoot	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneRightFoot );
		boneIndexLeftFoot	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneLeftFoot );
		
		
		// Set the type
		m_StateTypeE			= EST_Skate;
		m_UpdatesWhileInactiveB	= true;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		//AddStateToTheDefaultChangeList( 'SkateSlide' );
		////AddStateToTheDefaultChangeList( 'SkateStopFast' );
		//AddStateToTheDefaultChangeList( 'SkateDrift' );
		//AddStateToTheDefaultChangeList( 'SkateBackwards' );
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{	
		return m_ExplorationO.m_InputO.IsDashJustPressed();
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !HasEnoughStamina() )
		{
			return false;
		}
		
		return skateGlobal.IsDashReady();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateEnterSpecific( prevStateName : name )	
	{		
		var finalImpulse	: float;
		
		
		// Dash increases one level
		//skateGlobal.IncreaseSpeedLevel( true, false );
		
		// Perfect Flow
		/*
		if( skateGlobal.CheckIfIsInFlowGapAndConsume() )
		{
			skateGlobal.IncreaseSpeedLevel( true, true );
		}
		*/
		// Impulse not exceeding max
		//skateGlobal.ImpulseToNextSpeedLevel( impulse );
		//finalImpulse	= skateGlobal.ImpulseToNextSpeedLevel( impulse );
		//m_ExplorationO.m_MoverO.AddSpeed( finalImpulse );
		
		// Increases to the max level
		skateGlobal.SetSpeedLevel( 1, true );
		skateGlobal.ImpulseNotExceedingMaxSpeedLevel( impulse );
		
		// Stamina
		BlockStamina();
		
		// Turn
		m_ExplorationO.m_MoverO.SetSkatingTurnSpeed( sharpTurnSpeed );
		sharpTurn		= true;
		
		// Set the foot
		SetTheForwardFoot();
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateRun';
		}
		// Don't allow for auto state changes if the time is not enough
		else if( m_ExplorationO.GetStateTimeF() < timeToChainMin )
		{
			return GetStateName();
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
		skateGlobal.UpdateDashAttack();
		
		// Sharp turn
		if( sharpTurn && m_ExplorationO.GetStateTimeF() >= sharpTurnTime )
		{
			skateGlobal.ApplyDefaultParams();
			sharpTurn	= false;
		}
		
		// Movement
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		// Anim
		skateGlobal.SetBehParams( accel, braking, turn );
	}

	//---------------------------------------------------------------------------------
	function StateUpdateInactive( _Dt : float )
	{
		skateGlobal.UpdateDashCooldown( _Dt );
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{		
		skateGlobal.ConsumeDashCooldown();
		skateGlobal.StartFlowTimeGap();
	}	
	
	//---------------------------------------------------------------------------------
	private function SetTheForwardFoot()
	{
		var startRightFoot	: bool;
		
		startRightFoot	= m_ExplorationO.m_MoverO.IsRightFootForward();
		
		m_ExplorationO.SetBehaviorParamBool( behLeftFootParam, !startRightFoot );
	}	
	
	//---------------------------------------------------------------------------------
	private function HasEnoughStamina() : bool
	{
		return thePlayer.HasStaminaToUseAction( ESAT_Sprint );
	}
	
	//---------------------------------------------------------------------------------
	private function BlockStamina()
	{
		thePlayer.DrainStamina(ESAT_Sprint);
	}
	
	//---------------------------------------------------------------------------------
	// Anim events
	//---------------------------------------------------------------------------------
	/*
	//------------------------------------------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behEventEnd )
		{		
			m_ExplorationO.m_MoverO.SetSpeedFromAnim();
		}
	}
	*/
	//---------------------------------------------------------------------------------
	// Collision events
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{		
		return true;
	}	
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) :bool
	{		
		return false;
	}
}
