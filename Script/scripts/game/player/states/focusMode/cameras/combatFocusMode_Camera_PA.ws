/*
enum FocusModeCameraDirector_PlayAnimation_State
{
	FMCD_PA_Init,
	FMCD_PA_Sliding,
	FMCD_PA_PlayingAnimation,
	FMCD_PA_NewCoolAnimation,
}

class FocusModeCameraDirector_PlayAnimation
{
	var vState : W3PlayerWitcherStateCombatFocusMode_PlayAnimation;
	var vPlayer : W3PlayerWitcher;
	
	var shotHelper : FocusModeCameraShotHelper;
	var currState : FocusModeCameraDirector_PlayAnimation_State;
	var syncTime : float;
	var cachedDestPoint : Matrix;
	var cameraTimer : float;
	var coolAnimation : name;
	
	var enemy : CNewNPC;
	var playingAttackTimer : float;
	
	var prevCamera_MovementController : name;
	var prevCamera_PivotController : name;
	
	default currState = FMCD_PA_Init;
	
	public function Init( s : W3PlayerWitcherStateCombatFocusMode_PlayAnimation, p : W3PlayerWitcher )
	{
		vState = s;
		vPlayer = p;
		
		if ( !shotHelper )
		{
			shotHelper = new FocusModeCameraShotHelper in this;
		}
	}
	
	public function Deinit()
	{
		vState = NULL;
		vPlayer = NULL;
		enemy = NULL;
		syncTime = 0.f;
		playingAttackTimer = 0.f;
	}

	public function Activate( e : CNewNPC )
	{
		currState = FMCD_PA_Init;
		
		enemy = e;
		playingAttackTimer = 0.f;
		
		shotHelper.Init( enemy, vPlayer );
		
		// Remember controllers
		CacheCameraControllers();
	}
	
	public function UpdateShotManually( time : float )
	{
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var mc2 : CFocusMode_PA_MC;
		//var s : SCombatCameraState;
		var l2w : Matrix;
		var dt : float;
		
		if ( currState == FMCD_PA_NewCoolAnimation )
		{
			UpdateCameraAnimation( time );
		}
		else if ( currState == FMCD_PA_Sliding )
		{
			UpdateCameraShotForSliding();
		}
		else if ( currState == FMCD_PA_PlayingAnimation )
		{
			/*if ( time > syncTime )
			{
				if ( playingAttackTimer <= syncTime )
				{
					dt = syncTime - playingAttackTimer;
				}
				else
				{
					dt = time - playingAttackTimer;
				}
				
				if ( dt >= 0.f )
				{
					mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
					if ( mc )
					{
						mc.ManualUpdate( dt );
					}
				}
				else
				{
					LogChannel( 'FM', "ERROR - FocusModeCameraDirector_PlayAnimation::UpdateShotManually - dt < 0.f ");
				}
			}
			
			playingAttackTimer = time;* /
			
			//TODO MR: 
			//mc2 = (CFocusMode_PA_MC)theGame.GetGameCamera().GetActiveMovementController();
			if ( mc2 )
			{
				l2w = vPlayer.GetLocalToWorld();
				//TODO MR: 
				//if ( theGame.GetGameCamera().CalcStateFromAnimationWS( time, 'camera_focus_attack_lp_456_mid', l2w, s ) )
				//{
					//mc2.SyncToAnimation( s );
				//}
			}
		}
	}
	
	public function ResetManualMode()
	{
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		
		//TODO MR: 
		//mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
		if ( mc )
		{
			mc.SetManualMode( false );
		}
	}
	
	public function State_SlidingToEnemy( duration : float, destPoint : Vector, h : float )
	{
		//currState = FMCD_PA_Sliding;
		
		//SetupCameraShotForSliding( duration, destPoint );
		
		StartPlayingCoolAnimation( destPoint, h );
	}
	
	public function State_PlayingAttack( sTime : float, stateDuration : float )
	{
		var h : float;
		
		h = vPlayer.GetHeading();
		
		h += 0.f;
		
		/*var mc2 : CFocusModeCombatCamera_CurveDamp_Rot_MC;
		var p : float;
		
		mc2 = (CFocusModeCombatCamera_CurveDamp_Rot_MC)theGame.GetGameCamera().GetActiveMovementController();
		if ( mc2 )
		{
			p = mc2.GetProgress();
		}
		
		currState = FMCD_PA_PlayingAnimation;
		
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Anim_PC' );
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Anim_MC' );
		
		CalcShot_PlayingAttack( 0.f );* /
	}
	
	public function StartPlayingCoolAnimation( destPoint : Vector, h : float )
	{
		//var dir : Vector;
		//var heading : float;
		//var pc : CCombatCameraSimpleScriptedPivotController;
		
		currState = FMCD_PA_NewCoolAnimation;
		
		//dir = VecNormalize( destPoint - vPlayer.GetWorldPosition() );
		//heading = VecHeading( dir );
		
		cachedDestPoint = MatrixBuiltTRS( destPoint, EulerAngles( 0.f, h, 0.f ) );
		
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Anim_PC' );
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Anim_MC' );
		
		cameraTimer = 0.f;
		
		PickCoolAnimation( destPoint );
		CalcShot_PlayingCoolAnimation();
		
		//TODO MR: 
		//pc = (CCombatCameraSimpleScriptedPivotController)theGame.GetGameCamera().GetActivePivotController();
		//if ( pc )
		//{
		//	pc.SetDesiredPosition( destPoint );
		//}
		
		//TODO MR: 
		//theGame.GetGameCamera().HACKStartInterpolationNow( 0.5f );
	}
	
	private function PickCoolAnimation( destPoint : Vector )
	{
		var direction, cameraHeading, cross : Vector;
		var front, right : bool;
		
		direction = VecNormalize2D( destPoint - vPlayer.GetWorldPosition() );
		cameraHeading = theGame.GetGameCamera().GetHeadingVector();
		cross = VecCross( direction, cameraHeading );
		
		front = VecDot2D( direction, cameraHeading ) > 0;
		right = cross.Z > 0;
		
		if( front )
		{
			if( right )
				coolAnimation = 'camera_focus_attack_lp_456_mid_rf';
			else
				coolAnimation = 'camera_focus_attack_lp_456_mid_lf';
		}
		else if( right )
			coolAnimation = 'camera_focus_attack_lp_456_mid_rb';
		else
			coolAnimation = 'camera_focus_attack_lp_456_mid_lb';
	}
	
	public function UpdateCameraAnimation( time : float )
	{
		//cameraTimer += theGame.GetTimeScale() * theTimer.timeDeltaUnscaled;
		cameraTimer += theTimer.timeDeltaUnscaled;
		
		CalcShot_PlayingCoolAnimation();
	}
	
	public function CalcShot_PlayingCoolAnimation()
	{
		var mc : CFocusMode_PA_MC;
		//var s : SCombatCameraState;
		
		//TODO MR: 
		//mc = (CFocusMode_PA_MC)theGame.GetGameCamera().GetActiveMovementController();
		//if ( mc && theGame.GetGameCamera().CalcStateFromAnimationWS( cameraTimer, coolAnimation, cachedDestPoint, s ) )
		//{
		//	mc.SyncToAnimation( s );
		//}
	}
	
	public function CalcShot_PlayingAttack( time : float )
	{
		//var s : SCombatCameraState;
		var l2w : Matrix;
		var mc : CFocusMode_PA_MC;
		//var pc : CCombatCameraSimpleScriptedPivotController;
		var pos : Vector;
		var a : EulerAngles;
		var h : float;
		
		l2w = vPlayer.GetLocalToWorld();
		
		pos = MatrixGetTranslation( l2w );
		a = MatrixGetRotation( l2w );
		h = a.Yaw;
		
		//TODO MR: 
		//if ( theGame.GetGameCamera().CalcStateFromAnimationWS( time, 'camera_focus_attack_lp_456_mid', l2w, s ) )
		//{
			//mc = (CFocusMode_PA_MC)theGame.GetGameCamera().GetActiveMovementController();
			//pc = (CCombatCameraSimpleScriptedPivotController)theGame.GetGameCamera().GetActivePivotController();
			
			//if ( mc && pc )
			//{
				//mc.SyncToAnimation( s );
				//pc.SetDesiredPosition( vPlayer.GetWorldPosition() );
			//}
		//}
	}
	
	/*public function State_PlayingAttack_Prev( sTime : float, stateDuration : float )
	{
		var currHeading, heading, distance : float;
		var position : Vector;
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var cameraTransition : float;
		
		currState = FMCD_PA_PlayingAnimation;
		
		syncTime = 0.15f;
		currHeading = theGame.GetGameCamera().GetActiveMovementController().GetHeading();
		
		heading = AngleNormalize180( currHeading - 90.f );
		position = CalcFinalPoint();
		
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Anim_MC' );
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Anim_PC' );
		
		// Set new params
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( heading );
		
		//theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( distance );
		//theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( position );
		
		mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
		if ( mc && stateDuration > 0.f )
		{
			cameraTransition = 0.83f - syncTime;
			if ( cameraTransition > 0.f )
			{
				mc.SetTimeScale( 1.f / cameraTransition );
			}
		}
	}* /
	
	public function Deactivate()
	{
		shotHelper.Deinit();
		
		// Set prev camera controllers
		BackToPrevCameraControllers();
		
		//TODO MR: 
		//theGame.GetGameCamera().HACKStartInterpolationNow( 0.5f );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private function SetupCameraShotForSliding( duration : float, destPoint : Vector )
	{
		var position, dir : Vector;
		var currHeading, heading : float;
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var mc2 : CFocusModeCombatCamera_CurveDamp_Rot_MC;
		var pc : CFocusModeCombatCamera_CurveDamp_PC;
		//var s : SCombatCameraState;
		var l2w : Matrix;
		
		//TODO MR: 
		currHeading = theGame.GetGameCamera().GetHeading();
		
		/*shotHelper.StartBlendingSSShot( currHeading, duration );
		
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Slide_MC' );
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Slide_PC' );
		
		theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( shotHelper.ssShot_pivot );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( shotHelper.ssShot_yaw );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( shotHelper.ssShot_distance );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredPitch( shotHelper.ssShot_pitch );*/
		
		/*shotHelper.FindLastSSShot( currHeading, destPoint );
		
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Slide2_MC' );
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Slide2_PC' );
		
		theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( shotHelper.ssShot_pivot );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( shotHelper.ssShot_yaw );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( shotHelper.ssShot_distance );
		theGame.GetGameCamera().GetActiveMovementController().SetDesiredPitch( shotHelper.ssShot_pitch );
		
		mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
		pc = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
		if ( pc && mc )
		{
			mc.SetTimeScale( 1.f / duration );
			pc.SetTimeScale( 1.f / duration );
		}* /
		
		position = vPlayer.GetWorldPosition();
		position = destPoint;
		
		dir = VecNormalize( destPoint - vPlayer.GetWorldPosition() );
		heading = VecHeading( dir );
		
		theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_PA_Slide3_MC' );
		theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_PA_Slide2_PC' );
		
		//l2w = vPlayer.GetLocalToWorld();
		
		l2w = MatrixBuiltTRS( position , EulerAngles( 0.f, heading, 0.f ) );
		
		//TODO MR: 
		//if ( theGame.GetGameCamera().CalcStateFromAnimationWS( 0.f, 'camera_focus_attack_lp_456_mid', l2w, s ) )
		//{
			theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( position );
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( s.yaw );
			//TODO MR: 
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( s.distance );
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredPitch( s.pitch );
			
			//TODO MR: 
			//mc2 = (CFocusModeCombatCamera_CurveDamp_Rot_MC)theGame.GetGameCamera().GetActiveMovementController();
			//pc = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
			if ( pc && mc2 )
			{
				mc2.SetTimeScale( 1.f / duration );
				pc.SetTimeScale( 1.f / duration );
				
				//mc2.SyncToAnimation( s );
			}
		//}
		
		//theGame.GetGameCamera().SetFov( 40.f );
	}
	
	private function UpdateCameraShotForSliding()
	{
		/*var mc : CCombatCameraSimpleScriptedMovementController;
		var pc : CCombatCameraSimpleScriptedPivotController;
		
		mc = (CCombatCameraSimpleScriptedMovementController)theGame.GetGameCamera().GetActiveMovementController();
		pc = (CCombatCameraSimpleScriptedPivotController)theGame.GetGameCamera().GetActivePivotController();
		
		if ( pc && mc )
		{
			shotHelper.UpdateBlendingSSShot();
			
			pc.ManualSetDesiredPosition( shotHelper.ssShot_pivot );
			mc.ManualSetDesiredYaw( shotHelper.ssShot_yaw );
			mc.ManualSetDesiredPitch( shotHelper.ssShot_pitch );
			mc.ManualSetDesiredDistance( shotHelper.ssShot_distance );
		}*/
		
		/*var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var pc : CFocusModeCombatCamera_CurveDamp_PC;
		
		mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
		pc = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
		
		if ( pc && mc )
		{
			shotHelper.UpdateBlendingSSShot();
			
			pc.ResetValue( shotHelper.ssShot_pivot );
			mc.ResetValues( shotHelper.ssShot_yaw, shotHelper.ssShot_pitch, shotHelper.ssShot_distance );
		}* /
	}
	
	private function CacheCameraControllers()
	{
		prevCamera_MovementController = theGame.GetGameCamera().GetActiveMovementController().controllerName;
		prevCamera_PivotController = theGame.GetGameCamera().GetActivePivotController().controllerName;
	}
	
	private function BackToPrevCameraControllers()
	{
		theGame.GetGameCamera().ChangeMovementController( prevCamera_MovementController );
		theGame.GetGameCamera().ChangePivotController( prevCamera_PivotController );
		theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( CalcFinalPoint() );
	}
	
	private final function CalcMidPoint() : Vector
	{
		var pPos, ePos : Vector;
		
		pPos = vPlayer.GetWorldPosition();
		ePos = enemy.GetWorldPosition();
		
		return pPos + ( ePos - pPos ) / 2.f;
	}
	
	private final function CalcFinalPoint() : Vector
	{
		var pos, ePos : Vector;
		
		ePos = enemy.GetWorldPosition();
		
		pos = vPlayer.GetNearestPoint( ePos, 1.f ) + Vector( 0.f, 0.f, 1.0f );
		//pos = ePos + Vector( 0.f, 0.f, 1.0f );
		
		return pos;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

class CFocusMode_PA_MC //extends CCombatCameraSimpleScriptedMovementController
{
	var cRotation 	: EulerAngles;
	var cPosition 	: Vector;
	var cFov 		: float;
	
	/*protected function ControllerActivate( data : SCombatCameraMoveCtrlActivationData )
	{
		cRotation = data.currentRotation;
		
		super.ControllerActivate( data );
	}* /
	
	/*public function SyncToAnimation( data : SCombatCameraState )
	{
		cRotation 	= data.rotation;
		cPosition 	= data.position;
		cFov		= data.fov;
	}* /
	
	protected function ControllerGetPosition( out position : Vector )
	{
		position = cPosition;
	}
	
	protected function ControllerGetRotation( out rotation : EulerAngles ) 
	{
		rotation = cRotation;
	}
	
	protected function ControllerGetFov( out outFov : float )
	{
		outFov = cFov;
	}
}
*/