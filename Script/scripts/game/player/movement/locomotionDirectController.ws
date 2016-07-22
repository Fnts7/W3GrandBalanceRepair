
import class CR4LocomotionDirectController extends CObject
{
	import protected var agent : CMovingAgentComponent;
	import protected var moveSpeed : float;
	import protected var moveRotation : float;
};

import class CR4LocomotionDirectControllerScript extends CR4LocomotionDirectController
{
	function Activate() : bool
	{
		return true;
	}
	
	function UpdateLocomotion()
	{
	}
	
	function Deactivate()
	{
	}
};

class CR4LocomotionPlayerControllerScript extends CR4LocomotionDirectControllerScript
{
	var player 					: CR4Player;
	var angularInputSpeed 		: float;
	var worldMoveDirection 		: float;
	var localMoveDirection 		: float;
	var previousInputVector 	: Vector;
	var timerValue				: float;
	var angularSpeed			: float;
	
	var _inputLocoEnabled		: bool;		default _inputLocoEnabled = true;
	var _inputVecCurr			: Vector;
	var _inputVecPrev			: Vector;
	var _inputHeading180Curr	: float;	default _inputHeading180Curr = 0.f;
	var _inputHeading180Prev	: float;	default _inputHeading180Prev = 0.f;
	var _inputHeading180LastCached : float;	default _inputHeading180LastCached = 0.f;
	var _inputMagCurr			: float;	default _inputMagCurr = 0.f;
	var _inputMagPrev			: float;	default _inputMagPrev = 0.f;
	var _inputMagDiffCurr		: float;	default _inputMagDiffCurr = 0.f;
	var _inputMagDiffPrev		: float;	default _inputMagDiffPrev = 0.f;
	var _inputMagLastCached		: float;	default _inputMagLastCached = 0.f;
	
	//var	inputModuleNeededToRun	: float;	default	inputModuleNeededToRun	= 0.8f;
	var speedSlowWalkingMax	 	: float;	default	speedSlowWalkingMax	 	= 0.3f;
	var speedWalkingMax			: float;	default	speedWalkingMax			= 0.6f;
	var speedRunning			: float;	default	speedRunning			= 1.0f;
	var speedSprinting			: float;	default	speedSprinting			= 1.5f;
	var speedSprintingWithPerk	: float;	default	speedSprintingWithPerk	= 1.6f;
	
	var	maxTerrainPitchToWalkUp	: float;	default	maxTerrainPitchToWalkUp	= 70.0f;
	
	//++DEBUG
	var prevPosition			: Vector;
	var prevRotation			: EulerAngles;
	//--
	
	function Activate() : bool
	{
		player = (CR4Player)agent.GetEntity();
	
		_inputVecCurr = Vector(0.f,0.f,0.f);
		_inputVecPrev = Vector(0.f,0.f,0.f);
		
		player.SetBehaviorVariable( 'AIControlled', 0.f ); // 0.f means do not block
		stopCheckEnabled = false;
	
		return super.Activate();
	}

	function Deactivate()
	{
		var movingAgentComponent 	: CMovingAgentComponent = player.GetMovingAgentComponent();
		
		player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); // 0.f means do not block
		player.SetBehaviorVariable( 'AIControlled', 1.f ); // 0.f means do not block
		
		player.UpdateRequestedDirectionVariables_PlayerDefault();
		
		player.SetIsRunning( false );
		player.SetIsWalking( false );
		
		movingAgentComponent.SetGameplayRelativeMoveSpeed( 0.0f );
		movingAgentComponent.SetGameplayMoveDirection( 0.0f );
		
		stopCheckEnabled = false;
			
		super.Deactivate();
	}
	
	
	var cachedMoveSpeed : float;
	var stoppedTimeStamp : float;
	var stopCheckEnabled : bool;
	var stoppedTimeStampDelta : float;
	function UpdateLocomotion()
	{
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//FIXME URGENT - THE SPEED IS SET EVEN IF YOU STAND STILL E.G. IN INVENTORY PANEL, RADIAL MENU ETC. !!!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
		var inputInCameraSpace, inputAngleToRotate, previousSpeed, haxStrafe, haxForward : float;		
		var playerYaw				: float;
		var forcedDirection			: float;
		var movingAgentComponent 	: CMovingAgentComponent = player.GetMovingAgentComponent();
		var currPosition, diffPosition	: Vector;
		var currRotation			: EulerAngles;
		var diffRotation			: float;
		var inputHeading180_WS, inputHeading360_WS, inputHeading180_CS, cameraHeading360_WS, inputMagDiff : float;
		var currentTime : float;
			
		// if RadialMenu is open igore input
		if ( player.IsUITakeInput() )
		{
			return;
		}
		
		previousSpeed = movingAgentComponent.GetRelativeMoveSpeed();
		
		// Input vector
		_inputVecPrev = _inputVecCurr;
		_inputVecCurr = CalculateInputVector();
		
		// Cache prev values
		_inputHeading180Prev = _inputHeading180Curr;
		_inputMagPrev = _inputMagCurr;
		
		// Convert input vector to heading and mag
		ConvertVecToHeadingWS180AndMag( _inputVecCurr, inputHeading180_WS, _inputMagCurr );
		inputHeading360_WS = AngleNormalize( inputHeading180_WS );
		
		// Convert heading WS to camera space (CS)
		cameraHeading360_WS = GetCameraHeading360WS();
		inputHeading180_CS = AngleNormalize180( inputHeading360_WS + cameraHeading360_WS );
		
		// Calc diff for input mag - no timedelta here because we use only sign
		_inputMagDiffPrev = _inputMagDiffCurr;
		_inputMagDiffCurr = _inputMagCurr - _inputMagPrev;
		
		// We move in camera space
		_inputHeading180Curr = inputHeading180_CS;
		
		// Player rotation
		playerYaw = player.GetHeading();
		
		// Is input valid?
		UpdateInputReadyness();
		
		// Check if everthing is ok - display data
		//player.GetVisualDebug().AddText( 'inputtext01', "Input heading:"+inputHeading180_WS, Vector(0,0,1.5), false, 0, Color(0,255,0), true );
		// Camera - green
		player.GetVisualDebug().AddArrow( 'input01', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( cameraHeading360_WS ), 1.f, 0.1f, 0.1f, true, Color(0,255,0), true );
		// Player entity heading - grey
		player.GetVisualDebug().AddArrow( 'input02', player.GetWorldPosition(), player.GetWorldPosition() + player.GetHeadingVector(), 1.f, 0.1f, 0.1f, true, Color(128,128,128), true );
		// Input - purple
		//if ( inputHeading180_WS != 0.f ) player.GetVisualDebug().AddArrow( 'input04b', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( cameraHeading360_WS + inputHeading180_WS ), 1.f, 0.2f, 0.2f, true, Color(255,128,255), true );
		player.GetVisualDebug().AddArrow( 'input04', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( _inputHeading180LastCached ), 1.f, 0.2f, 0.2f, true, Color(255,0,255), true );
		
		if( player.GetIsMovable() && player.GetCurrentStateName() != 'PlayerDialogScene' )
		{					
			// Forcing direction
			if( HasToForceToFall( forcedDirection ) )
			{
				localMoveDirection	= forcedDirection;
				moveSpeed			= MaxF( moveSpeed, 0.5f );
				
				// We need to cash the input if it comes from correction
				_inputHeading180Curr		= (localMoveDirection * -180.0f) + playerYaw;
				_inputHeading180LastCached	= _inputHeading180Curr;
				
				MakeInputReady();
			} 
			// Stop on heavy slope up
			else if( HasToStopBecauseOfSlope() )
			{
				moveSpeed					= 0.0f;
				_inputHeading180Curr		= playerYaw;
				_inputHeading180LastCached	= _inputHeading180Curr;
				
				MakeInputReady();
			}
			else
			{
				angularInputSpeed	= CalculateInputAngularSpeed();
				localMoveDirection	= CalculateLocalMoveDirection();
				moveSpeed 			= CalculateMoveSpeed();
				
				currentTime = theGame.GetEngineTimeAsSeconds();
				if ( moveSpeed <= 0 )
				{				
					if ( !stopCheckEnabled )
					{
						stopCheckEnabled = true;
						stoppedTimeStamp = currentTime;
						moveSpeed = cachedMoveSpeed;

						if ( theInput.LastUsedPCInput() )
							stoppedTimeStampDelta = 0.15f;
						else
							stoppedTimeStampDelta = 0.05f;
					}
					else if ( currentTime > stoppedTimeStamp + stoppedTimeStampDelta )
					{
						moveSpeed = 0;
					}
					else 
						moveSpeed = cachedMoveSpeed;	
				}
				else
				{
					stopCheckEnabled = false;
					cachedMoveSpeed = moveSpeed;
				}
				
				localMoveDirectionPrevFrame = localMoveDirection;
				
				//++ DEBUG
				currPosition = player.GetWorldPosition();
				currRotation = player.GetWorldRotation();
				
				diffPosition = currPosition - prevPosition;
				diffRotation = AngleDistance( currRotation.Yaw, prevRotation.Yaw );
				
				// Debug
				//player.GetVisualDebug().AddArrow( 'heading1', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( player.rawPlayerHeading ), 1.f, 0.2f, 0.2f, true, Color(255,0,255), true );
				//player.GetVisualDebug().AddArrow( 'heading2', player.GetWorldPosition(), player.GetWorldPosition() + player.GetHeadingVector(), 1.f, 0.2f, 0.2f, true, Color(255,255,255), true );
				//player.GetVisualDebug().AddArrow( 'heading3', player.GetWorldPosition(), player.GetWorldPosition() + theCamera.GetCameraDirection(), 1.f, 0.2f, 0.2f, true, Color(0,255,0), true );
				//player.GetVisualDebug().AddText( 'headingt1', "Input h: "+AngleNormalize180(GetInputHeading()), Vector(0,0,1.5), false, 0, Color(255,255,255), true );
				//player.GetVisualDebug().AddText( 'headingt2', "Diff WS: "+AngleNormalize180(GetHeadingInCamSpace(VecHeading(diffPosition))), Vector(0,0,1.5), false, 2, Color(255,255,255), true );
				//player.GetVisualDebug().AddText( 'headingt2', "Diff P: "+diffPosition.X+" "+diffPosition.Y+" "+diffPosition.Z, Vector(0,0,1.5), false, 4, Color(255,255,255), true );
				//player.GetVisualDebug().AddText( 'headingt3', "Diff R: "+diffRotation, Vector(0,0,1.5), false, 8, Color(255,255,255), true );
				
				prevPosition = currPosition;
				prevRotation = currRotation;
				//--
				
				ProcessMovementEvent();
				
				if( thePlayer.substateManager.m_MovementCorrectorO.ModifySpeedRequired( moveSpeed ) )
				{
					MakeInputReady();
				}	
				
				// OverEncumbered
				if( thePlayer.HasBuff( EET_OverEncumbered ) )
				{
					moveSpeed	= MinF( moveSpeed, speedWalkingMax );
				}
			}
		}
		else
		{
			player.playerMoveType 	= PMT_Idle;
			angularInputSpeed 		= 0;
			moveSpeed 				= 0;
			localMoveDirection 		= 0;
		}
		
		/* AK: removing on request from review
		// clamping speed so the player only walks in focusMode
		if( theGame.IsFocusModeActive() )
		{
			moveSpeed = ClampF( moveSpeed, 0.0, 0.55 );
		}*/
		
		// shallowWater check
		player.SetSubmergeDepth( ((CMovingPhysicalAgentComponent)player.GetMovingAgentComponent()).GetSubmergeDepth() );
		player.SetBehaviorVariable( 'submergeDepth', player.GetSubmergeDepth() );
		
		if ( player.OnAllowShallowWaterCheck() && !player.IsSwimming() && player.GetSubmergeDepth() <= -0.9 )
		{
			player.OnEnterShallowWater();
		}
		else
		{
			player.OnExitShallowWater();
		}
		
		
		// Locked input
		if ( _inputLocoEnabled )
		{
			worldMoveDirection = _inputHeading180LastCached;
		}
		// Update world dir opnly if input is acceptable
		else if ( moveSpeed > 0.f )
		{
			worldMoveDirection 	= (localMoveDirection * -180.0f) + playerYaw;
		}
		
		if( player.IsOnBoat() )
		{
			moveSpeed = MinF( speedSlowWalkingMax, moveSpeed );
		} 

		if ( !player.CanUpdateMovement() )
		{
			movingAgentComponent.SetGameplayRelativeMoveSpeed( 0.f );
			player.SetBehaviorVariable( 'test_moveSpeed', 0.f );
			
			if ( !player.IsInputHeadingReady() )
				moveSpeed = 0;
			
			if( VecLengthSquared( movingAgentComponent.GetVelocity() ) < 0.25f && player.GetCurrentStateName() != 'AimThrow' )
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', 0.0f, true );
			}
			else
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', moveSpeed, true );
			}
			movingAgentComponent.SetGameplayMoveDirection( playerYaw );
		}
		else
		{
			movingAgentComponent.SetGameplayRelativeMoveSpeed( moveSpeed );
			player.SetBehaviorVariable( 'test_moveSpeed', moveSpeed);
			
			if( VecLengthSquared( movingAgentComponent.GetVelocity() ) < 0.25f )
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', 0.0f, true );
			}
			else
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', moveSpeed, true );
			}
			movingAgentComponent.SetGameplayMoveDirection( worldMoveDirection );
		}
		
		// This ensures SetGameplayMoveDirection will never be damped
		movingAgentComponent.SetDirectionChangeRate( 10000.0f );
		
		player.SetBehaviorVariable( 'playerInputAngSpeed', angularInputSpeed);
		
		UpdateRequestedDirectionVariables( worldMoveDirection, theCamera.GetCameraHeading());
		
		// Display final direction. This value is sent to behavior graph
		player.GetVisualDebug().AddArrow( 'heading1', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( worldMoveDirection ), 1.f, 0.4f, 0.2f, true, Color(255,0,0), true );
		
		player.SetBehaviorVariable( 'actorMoveDirection', localMoveDirection );
		
		//++MARWIN
		angularSpeed = 512.f;
		if ( inputAngleToRotate < 0.f )
		{
			angularSpeed = -angularSpeed;
		}
		player.SetBehaviorVariable( 'inputSpeedToRotate', angularSpeed );
		//--
		
		// Set the walking and running state			
		player.SetIsWalking( moveSpeed > 0.1f );
		player.SetIsRunning( moveSpeed > 0.85f ); // at this point we have already reduced the speed in all cases (walk toggle flag, running allowed etc... )
	}
	
	private function UpdateInputReadyness()
	{
		var inputHeadingReady, inputMagReady, canRecalcInputHeading : bool;
		
		
		inputHeadingReady = true;
		inputMagReady = true;
		canRecalcInputHeading = false;
		
		// Special mode 1. - wait for final input value, you move stick too fast so inbetween values can be wrong
		if ( AbsF( _inputMagDiffCurr ) > 0.2f ) // 0.4 magic value ( test it with high fps like 90 )
		{
			//LogChannel( 'locoInput', "input is skipped - input curr and prev frame difference is too high, case1, _inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			inputHeadingReady = false;
			inputMagReady = false;
			canRecalcInputHeading = true;
		}
		
		// Spacial mode 2. - like 1. but if you have 0 in this frame ( so difference can not be that high )
		if ( inputHeadingReady && _inputMagCurr < 0.001f && _inputMagPrev > 0.1f )
		{
			//LogChannel( 'locoInput', "input is skipped - input curr and prev frame difference is too high, case2, _inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			inputHeadingReady = false;
			canRecalcInputHeading = true;
			//inputMagReady = false; Zero is important for speed
		}
		
		// Spacial mode 3. - input value is decreasing and x is already 0 while y is still decreasing
		if ( inputHeadingReady && _inputMagDiffCurr < 0.f && AbsF( _inputVecCurr.X ) < 0.001f && AbsF( _inputVecCurr.Y ) > 0.001f && _inputVecCurr.Y < _inputVecPrev.Y  )
		{
			//LogChannel( 'locoInput', "input is skipped - input X is already 0 but Y is still going to 0, _inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			inputHeadingReady = false;
			//inputMagReady = false; Zero is important for speed
		}
		
		// Special mode 4. - drop small values for input
		if ( inputHeadingReady && _inputMagCurr < 0.1f )
		{
			//LogChannel( 'locoInput', "input is too small - to inputMagDiff is too high, _inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			inputHeadingReady = false;
			//inputMagReady = false; Zero is important for speed
		}
		
		// Special mode 5. - you just push stick, wait one frame because input value can be messy for first frame
		if ( inputHeadingReady && _inputMagPrev < 0.001f && _inputMagCurr > 0.001f )
		{
			//LogChannel( 'locoInput', "input is skipped - transition from 0 detected, _inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			inputHeadingReady = false;
			inputMagReady = false;
		}
		
		// Special mode 6. - support case when input is super fast and move back and forth
		if ( canRecalcInputHeading && _inputMagPrev > 0.001f && _inputMagDiffCurr > 0.001f && _inputMagDiffPrev < 0.001f )
		{
			//LogChannel( 'locoInput', "input is forced to be processed - fast stick movement back and forth, case1 : "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );	
				
			_inputHeading180Curr = _inputHeading180Prev;
				
			inputHeadingReady = true;
			inputMagReady = true;
		}
		//else if ( canRecalcInputHeading && _inputMagPrev > 0.001f && _inputMagCurr < 0.001f && _inputMagDiffCurr < 0.001f && _inputMagDiffPrev > 0.001f )
		else if ( canRecalcInputHeading && _inputMagPrev > 0.001f && _inputMagDiffCurr < 0.001f && _inputMagDiffPrev > 0.001f )
		{
			//LogChannel( 'locoInput', "input is forced to be processed - fast stick movement back and forth, case2 : "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );	
				
			_inputHeading180Curr = _inputHeading180Prev;
			_inputMagCurr = _inputMagPrev;
				
			inputHeadingReady = true;
			inputMagReady = true;
		}
		
		// Cache last valid input heading
		if ( inputHeadingReady )
		{
			_inputHeading180LastCached = _inputHeading180Curr;
			//LogChannel( 'locoInput', "YES - _inputHeading180Curr: "+ _inputHeading180Curr + "_inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			
			// Block/Unblock transitions which are based on direction - direction (is not)/is ready
			player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); // 0.f means do not block
		}
		else
		{
			//LogChannel( 'locoInput', "NO - _inputHeading180Curr: "+ _inputHeading180Curr + "_inputMagCurr: "+_inputMagCurr + " input: " + inputHeading180_WS + " input raw x:"+_inputVecCurr.X+" y: "+_inputVecCurr.Y );
			
			// Block/Unblock transitions which are based on direction - direction (is not)/is ready
			player.SetBehaviorVariable( 'inputDirectionIsNotReady', 1.f ); // 1.f means block
		}
		
		player.SetInputHeadingReady( inputHeadingReady );
		
		if ( inputMagReady )
		{
			_inputMagLastCached = _inputMagCurr;
		}
	}
	
	
	private function MakeInputReady()
	{
		player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); // 0.f means do not block
	}
	
	private function HasToForceToFall( out direction : float ) : bool
	{
		var fallingDir		: Vector;
		var thrownEntity	: CThrowable;
		
		thrownEntity = (CThrowable)EntityHandleGet( thePlayer.thrownEntityHandle );
		
		// Can we force fall?
		if( thePlayer.rangedWeapon && thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			return false;
		}		
		if( thrownEntity )
		{
			return false;
		} 
		
		// Do we have to force fall?
		if( thePlayer.substateManager.m_CollisionManagerO.GetHasToFallInDirection( direction ) )
		{			
			return true;
		}
		
		return false;
	}
	
	private function HasToStopBecauseOfSlope() : bool
	{
		//return 
		//return player.substateManager.m_CollisionManagerO.IsGoingUpSlopeInInputDir( 0.6f, 0.0f );
		
		var direction	: Vector;
		var	pitch		: float;
		
		
		pitch		= player.terrainPitch;
		if( pitch < 90.0f - maxTerrainPitchToWalkUp )
		//direction	= thePlayer.substateManager.m_OwnerMAC.GetTerrainNormal( false );
		//if( AbsF( direction.Z ) < 0.6f )
		//pitch		= player.substateManager.m_MoverO.GetRealSlideAngle();
		//if( pitch > 70.0f )
		{
			if(  thePlayer.substateManager.m_InputO.IsModuleConsiderable() )
			{
				direction	= thePlayer.substateManager.m_MoverO.GetSlideDir();
				if( VecDot( direction, thePlayer.substateManager.m_InputO.GetMovementOnPlaneNormalizedV() ) < -0.2f )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	function CalculateLocalMoveDirection() : float
	{
		var direction			: float;
		var playerDirCamSpace	: float;
		var moveDir				: Vector;
		var anyInput			: bool;
		var corrected			: bool;
		
		
		// Get player heading in camera space		
		playerDirCamSpace = GetPlayerHeadingInCamSpace();
		
		// Set the raw heading to the behabiour graph
		player.SetBehaviorVariable( 'rawPlayerHeading', playerDirCamSpace - 180);
		
		// Get the input in player space
		moveDir	= GetInputInPlayerSpace( playerDirCamSpace, anyInput );
		
		// Readjust direction based on prediction
		moveDir	= CorrectDirection( moveDir, anyInput, corrected ); 
		
		// Nothing else if there is no input
		if( !anyInput )
		{
			return 0.0f;
		}
		
		// We need to cash the input if it comes from correction
		if( corrected )
		{
			_inputHeading180Curr		= VecHeading( moveDir );
			_inputHeading180LastCached	= _inputHeading180Curr;
		}
		
		// Convert to player space
		direction	= -(VecHeading( moveDir ) - player.GetHeading()); 
		
		// Convert to -1, 1	
		direction	= AngleNormalize180( direction );
		direction	= direction / 180.0f;
		
		return direction;
	}
	

	public function ResetMoveDirection()
	{
		if(player)
			_inputHeading180LastCached = player.GetHeading();
	}
	
	private function GetCameraHeading360WS() : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		
		cameraDirection		= theCamera.GetCameraDirection();
		cameraDirection.Z	= 0.f;
		cameraDirection.W	= 1.f;
		cameraDirection 	= VecNormalize2D( cameraDirection );
		camHeading			= AngleNormalize( VecHeading( cameraDirection ) );
		
		return camHeading;
	}
	
	private function GetHeadingInCamSpace( heading : float ) : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		
		cameraDirection		= theCamera.GetCameraDirection();
		cameraDirection.Z	= 0.f;
		cameraDirection.W	= 1.f;
		cameraDirection 	= VecNormalize2D( cameraDirection );
		camHeading			= AngleNormalize( VecHeading( cameraDirection ) );
		heading				= AngleNormalize( heading );		
		
		return AngleNormalize( heading - camHeading );
	}
	
	private function GetPlayerHeadingInCamSpace() : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		var playerHeading	: float;
		
		
		cameraDirection			= theCamera.GetCameraDirection();
		cameraDirection.Z		= 0;
		camHeading				= AngleNormalize( VecHeading(cameraDirection) );
		playerHeading			= AngleNormalize( player.GetHeading() );		
		
		return AngleNormalize( playerHeading - camHeading );
	}
	
	private function GetInputHeading() : float
	{
		var inputVector	: Vector;
		
		inputVector.X = theInput.GetActionValue( 'GI_AxisLeftX' );//player.mainInput.aLeftJoyX;
		inputVector.Y = theInput.GetActionValue( 'GI_AxisLeftY' );//player.mainInput.aLeftJoyY;
		
		return AngleNormalize( VecHeading( inputVector ) );
	}
	
	private function GetInputInPlayerSpace( playerHeadingInCamSpace : float, out anyInput : bool ) : Vector
	{
		var inputVector			: Vector;
		var	relativeDirection	: Vector;
		var direction			: float;
		var inputHeading		: float;
		
		inputVector.X	= theInput.GetActionValue( 'GI_AxisLeftX' );//player.mainInput.aLeftJoyX;
		inputVector.Y	= theInput.GetActionValue( 'GI_AxisLeftY' );//player.mainInput.aLeftJoyY;
		
		anyInput		= inputVector.X != 0.0f || inputVector.Y != 0.0f; //VecLengthSquared( inputVector ) >= 0.1f;//
		
		// Transform the input 
		if( anyInput )
		{
			inputHeading		= AngleNormalize( VecHeading(inputVector) );		
			direction			= playerHeadingInCamSpace - inputHeading;
			relativeDirection	= VecFromHeading( -direction + player.GetHeading() );
		}
		else
		{
			relativeDirection	= VecFromHeading( player.GetHeading() );
		}
		
		return relativeDirection;
	}
	
	private function CorrectDirection( moveDir : Vector, out anyInput : bool, out corrected : bool ) : Vector
	{
		var	newDir	: Vector;
		
		
		if( thePlayer.substateManager.m_MovementCorrectorO.CorrectDirectionToAvoid( moveDir, newDir, anyInput ) )
		{
			anyInput	= true;
			moveDir		= newDir;
			corrected	= true;
		}
		else
		{
			corrected	= false;
		}
		
		return moveDir;
	}
	
	function CalculateInputVector() : Vector
	{
		var vec : Vector;
		
		vec.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		vec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );
		
		return vec;
	}
	
	function ConvertVecToHeadingWS180AndMag( vec : Vector, out heading180 : float, out mag : float )
	{
		var vecNorm : Vector;
		var heading : float;
		
		// Mag is simple length in 2d
		mag = VecLength2D( vec );
		
		// Heading (-180,180)
		vecNorm = VecNormalize2D( vec );
		heading = VecHeading( vecNorm );
		heading180 = AngleNormalize180( heading );
	}
	
	function CalculateInputAngularSpeed() : float
	{
		var inputVec : Vector;		
		var angSpeed : float;
		var inputHeading, previousInputHeading : float;
		
		inputVec.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		inputVec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );
		
		inputVec = VecNormalize2D(inputVec);
		
		inputHeading = VecHeading(inputVec);
		previousInputHeading = VecHeading(previousInputVector);
		
		if( inputHeading < 0.0f )
		{
			inputHeading += 360;
		}
		
		if ( previousInputHeading < 0.0f )
		{
			previousInputHeading += 360;
		}
		
		angSpeed = inputHeading - previousInputHeading;
		
		if ( angSpeed > 180 )
		{
			angSpeed = - ( 360 - angSpeed );
		}
	 
		if ( angSpeed < - 180 )
		{
			angSpeed = 360 + angSpeed;
		}
		
		angSpeed = AbsF(angSpeed);
	
		//timerValue += theTimer.timeDelta;
		
		
		
		//if( timerValue > 0.05 )
		//{
			//timerValue = 0;
			previousInputVector = inputVec;
		//}
		
		return angSpeed;
	}
	
	
	var doubleTapEnabled 				: bool;
	var localMoveDirectionPrevFrame		: float;
	var directionSwitchTimeStamp		: float;
	var directionCenteredTimeStamp		: float;
	var isCheckingCentered 				: bool;
	
	var isCheckingCommitToRightTurn		: bool;
	var isCheckingCommitToLeftTurn		: bool;
	var isTurningRight					: bool;
	var isTurningLeft					: bool;
	var commitToRightTurnTimeStamp		: float;
	var commitToLeftTurnTimeStamp		: float;
	var directionSwitchTimeStampDelta	: float;
	var startRightTurnTimeStamp			: float;
	var startLeftTurnTimeStamp			: float;
	var useRightTurnTimeStamp			: bool;
	var useLeftTurnTimeStamp			: bool;
	
	function CalculateMoveSpeed() : float
	{
		var speedVec 		: Vector;
		var speed 			: float;		
		var rawRightJoyVec	: Vector;		
		var tempInt			: int;		
		var terrainAngles	: EulerAngles;		
		var currentTime		: float;		
		var forceWalkSpeed	: bool;		
		
		
		
		if ( thePlayer.IsCameraControlDisabled( 'Finisher' ) )
		{
			speed = 0;
		}
		else if ( _inputLocoEnabled )
		{
			speed = _inputMagLastCached;
		}
		else
		{
			// Get speed from input
			/*speedVec.X = theInput.GetActionValue( 'GI_AxisLeftX' ); //player.mainInput.aLeftJoyX;
			speedVec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );//player.mainInput.aLeftJoyY;		
			
			speed = VecLength2D( speedVec );*/
			speed	= thePlayer.substateManager.m_InputO.GetModuleF();
		}
		
		//swim	
		if( thePlayer.IsSwimming() )
		{
			if ( thePlayer.rangedWeapon 
				&& thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait'
				&& thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponHolster' )
			{
				speed = 0;
			}
		}
		
		player.terrainPitch 		= 90.0f - player.substateManager.m_MoverO.GetRealSlideAngle();
		//terrainAngles				= VecToRotation( thePlayer.substateManager.m_OwnerMAC.GetTerrainNormal( false ) );
		//player.terrainPitch 		= terrainAngles.Pitch;
		//player.terrainPitch		= AbsF( player.terrainPitch );
		
		
		// Sprinting checks	
		if( thePlayer.CanSprint( speed ) )
		{
			if ( thePlayer.IsInCombat() 
				&& thePlayer.moveTarget 
				&& VecDistance( thePlayer.moveTarget.GetWorldPosition(), thePlayer.GetWorldPosition() ) < thePlayer.findMoveTargetDistMax )
			{
				thePlayer.SetIsSprinting(true);
				
				if ( thePlayer.modifyPlayerSpeed || thePlayer.interiorCamera )
					thePlayer.EnableSprintingCamera( false );
				else if ( thePlayer.GetSprintingTime() > 0.2 && !thePlayer.IsInCombatAction() )
					thePlayer.EnableSprintingCamera( true );
				else
					thePlayer.EnableSprintingCamera( false );
			}
			else 
			{
				thePlayer.SetIsSprinting(true);
				
				if ( thePlayer.modifyPlayerSpeed || thePlayer.interiorCamera  )
					thePlayer.EnableSprintingCamera( false );
				else
					thePlayer.EnableSprintingCamera( true );
			}
		}
		else
		{
			
			if ( !player.disableSprintingTimerEnabled && player.GetIsSprinting() )
			{
				player.disableSprintingTimerEnabled = true;
				player.AddTimer( 'DisableSprintingTimer', 0.25f );	
			}		
		}
		
		// Modified speed
		if ( player.modifyPlayerSpeed )
		{
			if ( speed > 0.0f )
			{
				if ( thePlayer.IsRunPressed() )
					speed = speedRunning;
				else
					speed = ClampF( speed, 0.f, speedWalkingMax );
			}
		}
		// Walk / run shift
		else if( !thePlayer.IsActionAllowed( EIAB_Sprint ) && thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && !thePlayer.IsCombatMusicEnabled() )
		{			
			if ( speed <= 0.f )
			{
				player.playerMoveType = PMT_Idle;
			}
			else if( thePlayer.IsSprintActionPressed() )
			{
				if ( speed > 0.8f )
				{
					speed = MinF( speed, speedRunning );
					player.playerMoveType = PMT_Run;
				}
				else
				{
					speed = speedWalkingMax;
					player.playerMoveType = PMT_Walk;
				}
			}
			else
			{
				speed = MapF( MinF( speed, speedRunning ), 0.0f, speedRunning, 0.0f,  speedWalkingMax );
				player.playerMoveType = PMT_Walk;
			}			
		}
		// Normal movement
		else
		{
			if ( theInput.LastUsedGamepad() )
			{
				thePlayer.SetWalkToggle(false);
				thePlayer.SetSprintToggle(false);
			}
			
			if ( speed <= 0.f )
			{
				player.playerMoveType = PMT_Idle;
			}
			else if (!theGame.IsFading() && !theGame.IsBlackscreen())
			{
				if ( player.GetIsSprinting() )
				{	
					speed = speedSprinting;
					player.playerMoveType = PMT_Sprint;
				}
				else if ( speed > thePlayer.GetInputModuleNeededToRun()
						&& ( thePlayer.IsActionAllowed( EIAB_RunAndSprint ) || thePlayer.IsCombatMusicEnabled() )
						&& ( ( thePlayer.GetPlayerCombatStance() == PCS_Normal && !thePlayer.GetIsWalkToggled() )
							|| thePlayer.GetPlayerCombatStance() == PCS_AlertFar 
							|| ( !thePlayer.GetIsWalkToggled() && !thePlayer.IsInCombat() && VecLength2D( speedVec ) > thePlayer.GetInputModuleNeededToRun() ) )
						)
				{
					speed =  MinF( speed, speedRunning );
					player.playerMoveType = PMT_Run;
					
					currentTime = EngineTimeToFloat( theGame.GetEngineTime() );
					
					if ( localMoveDirection > 0.7f )
					{
						if ( !isCheckingCommitToRightTurn )
						{
							isCheckingCommitToRightTurn = true;
							commitToRightTurnTimeStamp = currentTime;
						}
						
						if ( isCheckingCommitToRightTurn )
						{
							if ( currentTime >= commitToRightTurnTimeStamp + 0.25 )
							{
								directionSwitchTimeStampDelta = 0.f;
								isCheckingCommitToRightTurn = false;
								isTurningRight = true;
							}
						}
					}
					else if ( localMoveDirection < -0.7f )
					{				
						if ( !isCheckingCommitToLeftTurn )
						{
							isCheckingCommitToLeftTurn = true;
							commitToLeftTurnTimeStamp = currentTime;
						}
						
						if ( isCheckingCommitToLeftTurn )
						{
							if ( currentTime >= commitToLeftTurnTimeStamp + 0.25f )
							{
								directionSwitchTimeStampDelta = 0.f;
								isCheckingCommitToLeftTurn = false;
								isTurningLeft = true;
							}
						}	
					}
					
					if ( localMoveDirection > 0.f )
					{
						useLeftTurnTimeStamp = false;
						if ( isTurningLeft )
						{
							directionSwitchTimeStamp = currentTime;
							directionSwitchTimeStampDelta = 1.f;
							startRightTurnTimeStamp = currentTime;
							useRightTurnTimeStamp = true;
						}
						
						if ( useRightTurnTimeStamp && localMoveDirection > 0.3f )
						{
							if ( currentTime >= startRightTurnTimeStamp + 0.25 )
							{
								directionSwitchTimeStampDelta = 0.f;
							}
						}
							
						isTurningLeft = false;
						isCheckingCommitToLeftTurn = false;							
					}
					else if ( localMoveDirection < 0.f )
					{
						useRightTurnTimeStamp = false;
						if ( isTurningRight )
						{
							directionSwitchTimeStamp = currentTime;
							directionSwitchTimeStampDelta = 1.f;
							startLeftTurnTimeStamp = currentTime;
							useLeftTurnTimeStamp = true;
						}

						if ( useLeftTurnTimeStamp && localMoveDirection < -0.3f )
						{						
							if ( currentTime >= startLeftTurnTimeStamp + 0.25f )
							{
								directionSwitchTimeStampDelta = 0.f;
							}
						}
							
						isTurningRight = false;
						isCheckingCommitToRightTurn = false;							
					}					
					
					if ( currentTime < directionSwitchTimeStamp + directionSwitchTimeStampDelta )
					{
						if ( localMoveDirection >= -0.3f && localMoveDirection <= 0.3f )
						{
							if ( !isCheckingCentered )
							{
								isCheckingCentered = true;
								directionCenteredTimeStamp = currentTime;
							}
							else
							{
								if ( currentTime >= directionCenteredTimeStamp + 0.f )
								{
									isCheckingCentered = false;
									directionSwitchTimeStampDelta = 0.f;
									isCheckingCommitToRightTurn = false;
									isCheckingCommitToLeftTurn = false;
								}
							}
						}	
						else
							isCheckingCentered = false;				
					
						forceWalkSpeed = true;
						speed = speedWalkingMax;
					}
					else
						isCheckingCentered = false;
					
					if ( forceWalkSpeed )
						player.SetBehaviorVariable( 'forceWalkSpeed', 1 );
					else
						player.SetBehaviorVariable( 'forceWalkSpeed', 0 );
				}
				else
				{
					speed = speedWalkingMax; //MinF( speed, speedWalkingMax );
					player.playerMoveType = PMT_Walk;					
				}
			}
			else
			{
				speed = speedWalkingMax; //MinF( speed, speedWalkingMax );
				player.playerMoveType = PMT_Walk;
			}
		}
		
		if ( player.playerMoveType <= PMT_Walk )
		{
			thePlayer.SetSprintToggle( false );
		}
		
		
		/*
		if ( thePlayer.IsActionAllowed( EIAB_Sprint ) && thePlayer.movementLockType == PMLT_Free )
		{
			if( thePlayer.GetIsSprinting() && speed > 0 )
				thePlayer.PauseEffects(EET_AutoStaminaRegen, 'Sprint', true );
			else
				thePlayer.ResumeEffects(EET_AutoStaminaRegen, 'Sprint');
		}
		else
			thePlayer.ResumeEffects(EET_AutoStaminaRegen, 'Sprint');
		*/
			
		// Set beh vars
		tempInt = (int)( player.playerMoveType );
		player.substateManager.SetBehaviorParamBool(  'onSteepSlope', thePlayer.IsTerrainTooSteepToRunUp() );    //( player.terrainPitch <= player.steepSlopeNormalPitch )  );
		player.SetBehaviorVariable( 'terrainPitch', player.terrainPitch );
		player.SetBehaviorVariable( 'playerMoveType', tempInt );
		player.SetBehaviorVariable( 'playerMoveTypeForOverlay', tempInt );
		player.substateManager.SetBehaviorParamBool( 'runInputPressed', thePlayer.IsSprintActionPressed() );		
		player.substateManager.SetBehaviorParamBool( 'ikWeight',  player.playerMoveType == PMT_Walk || player.playerMoveType == PMT_Idle );
		
		
		// Camera speed
		rawRightJoyVec.X = theInput.GetActionValue( 'GI_AxisRightX' ); 
		rawRightJoyVec.Y = theInput.GetActionValue( 'GI_AxisRightY' );
		player.SetBehaviorVariable( 'cameraSpeed', VecLength2D( rawRightJoyVec ) );
		
		
		return speed;
	}	
	
	private var fastTurnEnabled : bool;
	private function ProcessMovementEvent()
	{
		var walkTurnDampSpeed : float;
		var dir :  float =  AbsF( localMoveDirection );
		if ( angularInputSpeed > 0 )
		{
			//LogChannel( 'angularInputSpeed', "angularInputSpeed" + angularInputSpeed );
			//LogChannel( 'angularInputSpeed', "localMoveDirection" + dir );
			if ( dir >= 0.8  && ( !player.rangedWeapon || player.rangedWeapon.GetCurrentStateName() == 'State_WeaponWait' ) )
			{
				player.SetBehaviorVariable( 'latchWalkDirection', 1.f );
				player.SetBehaviorVariable( 'walkTurnDampSpeed', 0.5f );
				fastTurnEnabled = false;
				player.RaiseEvent( 'QuickTurnWalk' );
				//LogChannel( 'angularInputSpeed', "Success!!!" );
			}
			else
			{
				if ( angularInputSpeed > 10.f && dir >= 0.25 && !player.lAxisReleasedAfterCounterNoCA )
					fastTurnEnabled = true;
			}
		}

		if ( dir <= 0.027f ) //5 degrees
		{
			player.SetBehaviorVariable( 'latchWalkDirection', 0.f );	
			fastTurnEnabled = false;
		}
		
		player.SetBehaviorVariable( 'fastTurnEnabled', (float)fastTurnEnabled );
	}
	
	private function UpdateRequestedDirectionVariables(playerHeadingWS : float, cameraHeadingWS : float)
	{
		var orientationTarget	: EOrientationTarget;
		var useHeadingWS		: float;
		var useFacingWS			: float;
		var target				: CGameplayEntity;
		
		var canFaceTarget		: bool;
		var playerToTargetVec	: Vector;

		useHeadingWS = playerHeadingWS;
		useFacingWS = cameraHeadingWS;

		orientationTarget = player.GetOrientationTarget();
		if ( orientationTarget == OT_Camera )
		{
			useFacingWS = cameraHeadingWS;
		}
		else if ( orientationTarget == OT_CameraOffset )
		{
			useFacingWS = cameraHeadingWS - player.GetOTCameraOffset();//
		}
		else if ( orientationTarget == OT_Actor )
		{
			target = player.GetTarget();
			
			if ( !target )
				target = player.moveTarget;
				
			if ( player.IsCurrentSignChanneled() && player.IsInCombatAction() )
			{
				if ( player.GetCurrentlyCastSign() == ST_Quen )
				{
					target = player.moveTarget;
					canFaceTarget = true;
				}
				else if ( player.GetCurrentlyCastSign() == ST_Igni )
					target = player.GetDisplayTarget();
					canFaceTarget = true;
			}

			if ( target )
			{		
				playerToTargetVec = target.GetWorldPosition()- player.GetWorldPosition();
			
				if ( !canFaceTarget )
				{
					if ( player.GetPlayerCombatStance() == PCS_AlertNear )
						canFaceTarget = true;
					else if ( player.GetPlayerCombatStance() == PCS_Guarded && VecLength( playerToTargetVec ) < player.findMoveTargetDist )
						canFaceTarget = true;
					else if ( player.IsActorLockedToTarget() && !player.IsHardLockEnabled() )
						canFaceTarget = true;
				}
			}
			
			if ( canFaceTarget && target )
				useFacingWS = VecHeading( playerToTargetVec );
			else
				useFacingWS = player.GetHeading();		
		}
		else if ( orientationTarget == OT_Player )
		{
			useFacingWS = player.GetHeading();
		}
		else if ( orientationTarget == OT_CustomHeading )
		{
			useFacingWS = player.GetOrientationTargetCustomHeading();
		}
		
		player.GetVisualDebug().AddArrow( 'heading5', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( useFacingWS ), 1.f, 0.4f, 0.2f, true, Color(0,0,255), true );
		player.UpdateRequestedDirectionVariables( useHeadingWS, useFacingWS );
	}

};
