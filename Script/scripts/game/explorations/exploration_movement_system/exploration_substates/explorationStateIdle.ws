// CExplorationStateIdle
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 21/11/2013 )	 
//------------------------------------------------------------------------------------------------------------------

enum EPlayerIdleSubstate
{
	PIS_None	,
	PIS_Idle	,
	PIS_Walk	,
	PIS_Run		,
	PIS_Sprint	
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateIdle extends CExplorationStateAbstract
{		
	private				var m_SubStateLasE					: EPlayerIdleSubstate;
	private				var m_SubStateE						: EPlayerIdleSubstate;
	private editable	var	m_SpeedMaxConsideredSprintF		: float;				default	m_SpeedMaxConsideredSprintF		= 8.0f;
	private editable	var	m_SpeedMaxConsideredRunF		: float;				default	m_SpeedMaxConsideredRunF		= 4.0f;
	private editable	var	m_SpeedMaxConsideredWalkF		: float;				default	m_SpeedMaxConsideredWalkF		= 2.0f;
	private editable	var	m_FallSpeedCoefF				: float;				default	m_FallSpeedCoefF				= 0.7f;
	private editable	var	m_FallExtraVerticalImpulseF		: float;				default	m_FallExtraVerticalImpulseF		= 5.0f;
	private editable	var	m_FallHorizontalImpulseF		: float;				default	m_FallHorizontalImpulseF		= 0.95f;
	private editable	var	m_FallHorizontalImpulseCancelF	: float;				default	m_FallHorizontalImpulseCancelF	= 0.2f;// 0.15f;
	
	// slide histeresys
	private editable	var	m_TimeToSlideNeededF			: float;				default	m_TimeToSlideNeededF			= 0.1f;
	private editable	var	m_TimeToSlideCurF				: float;
	
	// Camera collisions
	private editable	var m_CameraExtraOffsetF			: float;				default	m_CameraExtraOffsetF			= 0.5f;
	private editable	var m_CameraOffsetExtraVertLowF		: float;				default	m_CameraOffsetExtraVertLowF		= 1.4f;
	private editable	var m_CameraOffsetExtraVertHighF	: float;				default	m_CameraOffsetExtraVertHighF	= 2.1f;
	private editable	var m_CameraOffsetBlend				: float;				default	m_CameraOffsetBlend				= 3.5f;
	private 			var m_CameraOffsetVertF				: float;
	
	// Camera anims
	private				var m_CurentCameraAnimationN		: name;
	private editable	var m_CameraAnimIdleS				: SCameraAnimationData;
	private editable	var m_CameraAnimWalkS				: SCameraAnimationData;
	private editable	var m_CameraAnimRunS				: SCameraAnimationData;
	private editable	var m_CameraAnimSprintS				: SCameraAnimationData;
	
	
	//------------------------------------------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= _Exploration.GetDefaultStateName();
		}
		
		m_CameraOffsetVertF	= m_CameraOffsetExtraVertLowF;
		m_StateTypeE		= EST_Idle;
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Climb');
		AddStateToTheDefaultChangeList('Interaction');
		AddStateToTheDefaultChangeList('Jump');
		AddStateToTheDefaultChangeList('CombatExploration');
		AddStateToTheDefaultChangeList('Pushed');
		AddStateToTheDefaultChangeList('Swim');
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{			
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{		
		m_ExplorationO.m_MoverO.Reset();
		
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();
		
		if( thePlayer )
		{
			thePlayer.SetBIsCombatActionAllowed( true );
			//thePlayer.GoToCombatIfWanted();
		}
		
		m_TimeToSlideCurF	= 0.0f;
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
		
		m_SubStateE					= PIS_None;
		m_CurentCameraAnimationN	= 'None';
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{	
		// Fall: check here before we can jump or interact
		if( m_ExplorationO.GetStateTimeF() > 0.0f && !m_ExplorationO.IsOnGround() )
		{
			//PrepareFallFromIdle();
			return 'StartFalling';
		}
		
		// Slide
		if( m_TimeToSlideCurF >= m_TimeToSlideNeededF )
		{
			return 'Slide';
		}
		
		return super.StateChangePrecheck();
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		UpdateMacVelocity();		
		
		UpdateSlideHysteresys( _Dt );
		
		UpdateSubstate();
		
		UpdateCamera( _Dt );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{	
		// Conserve inertia
		if( nextStateName == 'StartFalling' )
		{
			PrepareFallFromIdle();
		}
		
		// Crouch add
		m_ExplorationO.m_SharedDataO.LandCrouchCancel();
		
		// Stop camera
		StopLastCamera();
		
		m_SubStateLasE	= PIS_None;
	}	
	
	//---------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		return " " + m_SubStateE + ", 		cam anim: " + m_CurentCameraAnimationN;
	}
	
	
	//------------------------------------------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		if( m_ExplorationO.GetStateTimeF() > 0.1f )
		{
			// To swim?
			if( thePlayer.IsSwimming() )
			{
				SetReadyToChangeTo( 'Swim' );
			}
			else if( !m_ExplorationO.IsOnGround() )
			{
				//PrepareFallFromIdle();
				SetReadyToChangeTo( 'StartFalling' );
			}
		}
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function PrepareRollHack()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'RollTo' );
		
		// we want reasonably quickly to turn in requested direction
		movAdj.AdjustmentDuration( ticket, 0.1f );
		// we want to jump exactly where we want - anytime, without any limitations
		movAdj.RotateTo( ticket, m_ExplorationO.m_InputO.GetHeadingOnPlaneF() );
		//movAdj.LockMovementInDirection( ticket, m_OrientationInitialF );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function PrepareFallFromIdle()
	{
		var macVelocity	: Vector;
		var impulse		: Vector;
		var maxSpeed	: float;
		
		impulse			= m_ExplorationO.m_OwnerE.GetWorldForward();
		impulse.Z		= 0.0f;
		
		
		// Impulse strength
		// No input
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			impulse *= m_FallHorizontalImpulseCancelF;
		}
		// Countering
		if( VecDot( impulse, m_ExplorationO.m_InputO.GetMovementOnPlaneV() ) < 0.0f )
		{
			impulse *= m_FallHorizontalImpulseCancelF;
		}
		// Moving forward
		else
		{
			impulse	*= m_FallHorizontalImpulseF;
		}
		
		// Get the MAC Velocity we are interested in
		macVelocity		= m_ExplorationO.m_OwnerMAC.GetVelocity();
		macVelocity.Z	= 0.0f;	
		
		if( thePlayer.GetIsSprinting() )
		{
			maxSpeed	= m_SpeedMaxConsideredSprintF;
		}
		else if( thePlayer.GetIsRunning() )
		{
			maxSpeed	= m_SpeedMaxConsideredRunF;
		}
		else
		{
			maxSpeed	= m_SpeedMaxConsideredWalkF;
		}
		
		if( VecLengthSquared( macVelocity ) > maxSpeed * maxSpeed )
		{
			macVelocity	= VecNormalize( macVelocity ) * maxSpeed;
		}
		
		// Add it to the impulse		
		impulse			+= macVelocity * m_FallSpeedCoefF;
		
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		m_ExplorationO.m_MoverO.SetVerticalSpeed( -AbsF( m_FallExtraVerticalImpulseF ) );
		//m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0f);
		
		m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
	}
	
	
	//---------------------------------------------------------------------------------
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	function CanInteract( ) : bool
	{
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateMacVelocity()
	{
		var macVelocity : Vector;
		var speed		: float;
		var	maxSpeed	: float;
		
		
		//Limit the velocity we get from the mac
		macVelocity	= m_ExplorationO.m_OwnerMAC.GetVelocity();
		//m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'Speed', 0.0f );
		speed	= VecLength( macVelocity );
		if( thePlayer.GetIsSprinting() )
		{
			maxSpeed	= m_SpeedMaxConsideredSprintF;
		}
		else if( thePlayer.GetIsRunning() )
		{
			maxSpeed	= m_SpeedMaxConsideredRunF;
		}
		else
		{
			maxSpeed	= m_SpeedMaxConsideredWalkF;
		}
		if( speed > maxSpeed )
		{
			macVelocity *= maxSpeed / speed;
		}
		
		m_ExplorationO.m_MoverO.SetVelocity( macVelocity );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateSubstate()
	{
		if( thePlayer.GetIsSprinting() )
		{
			m_SubStateE = PIS_Sprint;
		}
		else if ( thePlayer.GetIsRunning() )
		{
			m_SubStateE = PIS_Run;
		}
		else if( thePlayer.GetIsWalking() ) // VecLengthSquared( thePlayer.GetMovingAgentComponent().GetVelocity() ) > 0.10f )
		{
			m_SubStateE = PIS_Walk;
		}
		else
		{
			m_SubStateE = PIS_Idle;
		}
		
		// State changed
		if( m_SubStateLasE	!= m_SubStateE )
		{
			if( m_SubStateLasE == PIS_Run )
			{
				m_ExplorationO.m_SharedDataO.LandCrouchSpeedUp();
			}
		}
		
		// Save last state
		m_SubStateLasE	= m_SubStateE;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateSlideHysteresys( _Dt : float )
	{
		if( m_ExplorationO.StateWantsAndCanEnter( 'Slide' ) )
		{
			m_TimeToSlideCurF	= MinF( m_TimeToSlideCurF + _Dt, m_TimeToSlideNeededF );
		}
		else
		{
			//m_TimeToSlideCurF	= MaxF( m_TimeToSlideCurF - _Dt * 3.0f , 0.0f );
			m_TimeToSlideCurF	= 0.0f;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCamera( _Dt : float )
	{
		//UpdateCameraOffset( _Dt );
		
		//UpdateTestCameraAnim();
		
		// Animation
		/*if( m_SubStateLasE != m_SubStateE )
		{
			StopLastCamera();
			PlayNewCamera();
		}*/
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCameraOffset( _Dt : float)
	{
		var camera		: CCustomCamera;
		var	camDistance	: float;
		var	auxVector	: Vector;
		var offset		: Vector;
		var offsetVert	: float;
		
		
		if( !m_ExplorationO.m_SharedDataO.CameraOffsetEnabled() )
		{
			m_ExplorationO.RessetCameraOffset();
			
			return;
		}
		
		
		// Offset
		camera			= theGame.GetGameCamera();
		auxVector		= camera.GetWorldPosition() - thePlayer.GetWorldPosition();
		camDistance		= VecLength( auxVector );
		if( camDistance > 2.7f )
		{
			offset	= auxVector / camDistance * m_CameraExtraOffsetF;
		}
		else
		{
			offset	= Vector( 0, 0, 0 );
		}
		
		// Decide offset height
		auxVector.Z		= 0.0f;
		if( camDistance < 2.0f )
		{
			offsetVert	= m_CameraOffsetExtraVertHighF;
		}
		else
		{
			offsetVert	= m_CameraOffsetExtraVertLowF;
		}		
		m_CameraOffsetVertF	= LerpF( _Dt * m_CameraOffsetBlend, m_CameraOffsetVertF, offsetVert );
		offset.Z			= m_CameraOffsetVertF;
		
		//Set it to the camera
		camera.SetCollisionOffset( offset );
	}
	
	
	//---------------------------------------------------------------------------------
	private function UpdateTestCameraAnim()
	{
		var camera 		: CCustomCamera = theGame.GetGameCamera();
		var animation	: SCameraAnimationDefinition;
		
		if( m_ExplorationO.m_InputO.IsSprintJustPressed() )
		{		
			animation.animation	= 'vault_idle_300';
			//animation.animation	= 'camera_shake_hit_lvl3_1';
			animation.weight	= 1.0f;
			animation.priority	= CAP_High;
			animation.blendIn	= 0.1f;
			animation.blendOut	= 0.1f;
			animation.additive	= false;
			animation.speed		= 1.0f;
			animation.reset		= true;
			animation.loop		= false;
			
			camera.PlayAnimation( animation );
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function PlayNewCamera()
	{
		var camera			: CCustomCamera;
		var newAnimation	: SCameraAnimationData;
		var animation		: SCameraAnimationDefinition;
		
		// Find camera to play
		switch( m_SubStateE )
		{
			case PIS_None	:
				return;
			case PIS_Idle	:
				newAnimation	= m_CameraAnimIdleS;
				break;
			case PIS_Walk	:
				newAnimation	= m_CameraAnimWalkS;
				break;
			case PIS_Run	:
				newAnimation	= m_CameraAnimRunS;
				break;
			case PIS_Sprint	:
				newAnimation	= m_CameraAnimSprintS;
				break;
		}
		
		// Can we set it to the camera?
		if( IsNameValid( newAnimation.animation ) && newAnimation.animation != m_CurentCameraAnimationN )
		{
			camera	= theGame.GetGameCamera();
			
			animation.animation = newAnimation.animation;
			animation.priority = newAnimation.priority;
			animation.blendIn = newAnimation.blend;
			animation.blendOut = newAnimation.blend;
			animation.weight = newAnimation.weight;
			animation.speed	= 1.0f;
			animation.loop = true; // this anims should all loop
			animation.additive = true;
			animation.reset = true;
			
			camera.PlayAnimation( animation );
			
			// Save the animation name
			m_CurentCameraAnimationN	= newAnimation.animation;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function StopLastCamera()
	{
		var camera	: CCustomCamera = theGame.GetGameCamera();
		
		if( m_CurentCameraAnimationN != 'None')
		{
			camera.StopAnimation( m_CurentCameraAnimationN );
		}
	}
}
