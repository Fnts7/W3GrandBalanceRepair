/***********************************************************************/
/** Copyright © 2012-2013
/** Authors: ?, Tomek Kozera
/***********************************************************************/

// state for item throwing in aiming mode (only, no aim does not enter this state)
state AimThrow in CR4Player extends ExtendedMovable // ABSTRACT
{
	// CAMERA
	protected var camera : CCustomCamera;
	protected var fovVel : float;
	protected var initialPitch : float;
	
	private var cachedHorTimeout : float;
	private var cachedVerTimeout : float;
	
	private var prevState		 : name;

	event OnEnterState( prevStateName : name )
	{
		prevState = prevStateName;
		super.OnEnterState(prevStateName);
		//LogChannel( 'States', "Changed state to: " + this + " from " + prevStateName);
		
		CreateNoSaveLock();
		
		theInput.SetContext( 'ThrowHold' );
		parent.lastAxisInputIsMovement = true;
		parent.SetCombatIdleStance( 1.f );
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		theGame.GetGameCamera().ChangePivotDistanceController('AimThrow');
		theGame.GetGameCamera().ChangePivotRotationController('AimThrow');
		
		camera.EnableScreenSpaceCorrection( false );
		
		OnEnterStateExtended();
		
		theTelemetry.LogWithName(TE_STATE_AIM_THROW);
		
		SearchForTargets();
		
		//theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CrossbowShotAction', 10.0, 8.0f, -1, -1, true); //reactionSystemSearch
		
		cachedHorTimeout = camera.GetManualRotationHorTimeout();
		cachedVerTimeout = camera.GetManualRotationVerTimeout();
		
		camera.SetManualRotationHorTimeout(1.0);
		camera.SetManualRotationVerTimeout(1.0);
		
		thePlayer.BreakPheromoneEffect();
	}
	
	function OnEnterStateExtended()
	{
		//theCamera.SetBehaviorVariable( 'cameraState', (int)CS_AimThrow );
		
		if( !parent.inv.IsItemCrossbow( parent.GetSelectedItemId() ) )
			virtual_parent.SetIsThrowingItemWithAim(true);			//not cleared on leave - cleared in player when we finish the throw anim and leave throwing at all
		else
		{
			initialPitch = ProcessInitialPitch();
			//followTarget = true;
		}
		
		virtual_parent.OnDelayOrientationChange();
	}
	
	entry function SearchForTargets()
	{
		var target : CActor;
		var thrownEntity		: CThrowable;
		
		thrownEntity = (CThrowable)EntityHandleGet( parent.thrownEntityHandle );
		
		target = parent.GetTarget();
		
		while( true )
		{
			if( target )
			{
				if( ((CNewNPC)( target )).IsShielded( thePlayer ) )
					((CNewNPC)( target )).OnIncomingProjectile( true );
			}
			
			if ( thrownEntity && (W3Petard)( thrownEntity ) )
				parent.ProcessCanAttackWhenNotInCombatBomb();
			else
				parent.rangedWeapon.ProcessCanAttackWhenNotInCombat();
			
			
			Sleep( 0.1 );
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.SetIsShootingFriendly( false );
		parent.playerAiming.StopAiming();
	
		// set current heading to where the bomb is being thrown and maintain a rotation in that direction even after exiting the state
		// this is to fix a case where you quickly aim-throw a bomb behind your back and you leave the state before completing the rotation
		// also the new heading should be set anyway to where you are facing
		
		camera.fov = 60.f;
		
		camera.EnableScreenSpaceCorrection( true );
		
		//virtual_parent.SetCustomRotation('PostThrowHoldUp', heading, 1080, 1, false);
		virtual_parent.rawPlayerHeading = theCamera.GetCameraHeading();
		virtual_parent.RemoveCustomOrientationTarget( 'AimThrow' );
		
		thePlayer.SetBehaviorVariable( 'walkInPlace', 0.f );
		
		camera.SetManualRotationHorTimeout(cachedHorTimeout);
		camera.SetManualRotationVerTimeout(cachedVerTimeout);
		
		if ( nextStateName == 'PlayerDialogScene' )
		{
			virtual_parent.crossbowDontPopStateHack = true;
			parent.OnRangedForceHolster( true, true );
			virtual_parent.crossbowDontPopStateHack = false;
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnDelayOrientationChangeOff()
	{
		//virtual_parent.SetCustomOrientationTargetForCombatActions( OT_None );
		virtual_parent.AddCustomOrientationTarget( OT_CameraOffset, 'AimThrow' );
		parent.SetSlideTarget( NULL );
		virtual_parent.OnDelayOrientationChangeOff();	
	}	
	
	private function ProcessInitialPitch() : float
	{
		var angles : EulerAngles;
		var aimingTarget	: CActor;
		var pos, playerpos : Vector;
		
		aimingTarget = (CActor)( parent.GetDisplayTarget() );
		playerpos = parent.GetWorldPosition();
		playerpos.Z += 1.8f;
		pos = MatrixGetTranslation( aimingTarget.GetBoneWorldMatrixByIndex( aimingTarget.GetTorsoBoneIndex() ) );
		pos.Z += 0.25f;
		angles = VecToRotation( pos - playerpos );
		//parent.GetVisualDebug().AddSphere( 'wha84t9e54998', 0.5f, pos, true, Color( 255, 0, 255 ), 12.f );
		return -angles.Pitch;
	}
	
	private var followTarget : bool;
	private var followPitch : float;
	var isRotating : bool;
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var cameraOffset : float;
		var currRotation : EulerAngles;
		var angledist : float;
		var rawToCamHeadingDiff	: float;
		var camOffsetVec 	: Vector;
		var heading			: float;
		var followPosition : Vector;
		
		var enableAimingLookAt : bool;
		
		theGame.GetGameCamera().ChangePivotRotationController( 'AimThrow' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'AimThrow' );
		
		// HACK
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
	
		moveData.pivotPositionController.SetDesiredPosition( virtual_parent.GetWorldPosition(), 100.f );
		
		if ( parent.inv.IsItemCrossbow( parent.GetSelectedItemId() ) )
		{
			//moveData.cameraLocalSpaceOffset = Vector( 0.6f, 0.75f, 0.15f );
			//DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( theGame.GetGameplayConfigFloatValue( 'debugA' ), theGame.GetGameplayConfigFloatValue( 'debugB' ), theGame.GetGameplayConfigFloatValue( 'debugC' ) ), 0.2f, dt );
			
			if ( parent.GetPlayerCombatStance() == PCS_AlertNear )
				followTarget = false;
			
			rawToCamHeadingDiff = AngleDistance( parent.rawPlayerHeading, moveData.pivotRotationValue.Yaw );

			if ( !parent.bLAxisReleased )
			{
				if ( rawToCamHeadingDiff > -45 && rawToCamHeadingDiff < 45 )
				{
					//With screenspace
					/*camOffsetVec.X = 0.5f;
					camOffsetVec.Y = 0.875f;
					camOffsetVec.Z = 0.18f;*/
					//Without screenspace
					camOffsetVec.X = 0.5f;
					camOffsetVec.Y = 0.5f;
					camOffsetVec.Z = 0.18f; 				
					/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
					camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
					camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/ 				
				}
				else if ( rawToCamHeadingDiff >= 45 && rawToCamHeadingDiff < 135 )
				{
					//With screenspace				
					/*camOffsetVec.X = 0.5f;
					camOffsetVec.Y = 0.95f;
					camOffsetVec.Z = 0.15f;*/
					//Without screenspace					
					camOffsetVec.X = 0.55f;
					camOffsetVec.Y = 0.55f;
					camOffsetVec.Z = 0.15f;
					/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
					camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
					camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/
				}
				else if ( rawToCamHeadingDiff <= -45 && rawToCamHeadingDiff > -135 )
				{
					//With screenspace
					/*camOffsetVec.X = 0.55f;
					camOffsetVec.Y = 0.875f;
					camOffsetVec.Z = 0.2f;*/
					//Without screenspace					
					camOffsetVec.X = 0.55f;
					camOffsetVec.Y = 0.45f;
					camOffsetVec.Z = 0.18f; 
					/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
					camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
					camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/
				}
				else
				{
					//With screenspace
					/*camOffsetVec.X = 0.55f;
					camOffsetVec.Y = 0.925f;
					camOffsetVec.Z = 0.2f;*/
					//Without screenspace
					camOffsetVec.X = 0.55f;
					camOffsetVec.Y = 0.6f;
					camOffsetVec.Z = 0.2f; 			
					/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
					camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
					camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/
				}
			}
			else
			{
				//With screenspace
				/*camOffsetVec.X = 0.43f;
				camOffsetVec.Y = 0.85f;
				camOffsetVec.Z = 0.22f;*/
				//Without screenspace
				camOffsetVec.X = 0.43f;
				camOffsetVec.Y = 0.52f;
				camOffsetVec.Z = 0.22f;
				/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
				camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
				camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/  
			}
			
			if ( parent.rangedWeapon && parent.rangedWeapon.GetCurrentStateName() == 'State_WeaponReload' )
			{
				//With screenspace
				/*camOffsetVec.X = 0.43f;
				camOffsetVec.Y = 0.65f;
				camOffsetVec.Z = 0.22f;*/
				//Without screenspace
				camOffsetVec.X = 0.43f;
				camOffsetVec.Y = 0.1f;
				camOffsetVec.Z = 0.22f;
				/*camOffsetVec.X = theGame.GetGameplayConfigFloatValue( 'debugA' );
				camOffsetVec.Y = theGame.GetGameplayConfigFloatValue( 'debugB' );
				camOffsetVec.Z = theGame.GetGameplayConfigFloatValue( 'debugC' );*/  
			}

			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( camOffsetVec.X, camOffsetVec.Y, camOffsetVec.Z ), 0.2f, dt );
			//DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.43f, 1.0f, 0.22f ), 0.2f, dt );
			virtual_parent.oTCameraOffset = 17.f;
			virtual_parent.oTCameraPitchOffset = 5.f;
			
			//initialPitch = 0.f;
			//if ( thePlayer.bLAxisReleased )
			{
				heading = VecHeading(theCamera.GetCameraDirection());
				angledist = AngleDistance( heading, VecHeading(thePlayer.GetHeadingVector()) );
				if ( angledist < -50 || angledist > 25 )
				{
					isRotating = true;
					parent.SetCustomRotation( 'Crossbow', heading, 0.0f, 0.4f, false );
					
					if ( parent.bLAxisReleased )
					{
						thePlayer.SetBehaviorVariable( 'playerSpeedForOverlay', 0.1);
						thePlayer.SetBehaviorVariable( 'walkInPlace', 1.f );
					}
				}
				else if ( isRotating && ( angledist < -35 || angledist > 5 ) )
				{
					parent.SetCustomRotation( 'Crossbow', heading, 0.0f, 0.4f, false );
					
					if ( parent.bLAxisReleased )
					{
						thePlayer.SetBehaviorVariable( 'playerSpeedForOverlay', 0.1);
						thePlayer.SetBehaviorVariable( 'walkInPlace', 1.f );
					}
				}
				else
				{
					thePlayer.SetBehaviorVariable( 'walkInPlace', 0.f );
					isRotating = false;
				}
			}
			
			/*if ( thePlayer.bRAxisReleased )
			{
				moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw);//, 100000.f );
				moveData.pivotRotationController.SetDesiredPitch( moveData.pivotRotationValue.Pitch);//, 100000.f );
				moveData.pivotRotationController.StopRotating();
			}*/
		}
		else
		{
			virtual_parent.oTCameraOffset = 32.f;
			virtual_parent.oTCameraPitchOffset = 0.f;
			initialPitch = -15.f;
			
			//initialPitch = 0.f;
			heading = VecHeading(theCamera.GetCameraDirection());
			angledist = AngleDistance( heading, VecHeading(thePlayer.GetHeadingVector()) );
			
			/*if ( isRotating || ( angledist < 0 || angledist > 90 ) )
			{
				isRotating = true;
				parent.SetCustomRotation( 'BombThrow', heading-45, 0.0f, 0.4f, false );
			}
			
			if ( angledist > 30 && angledist < 60 )
				isRotating = false;
			*/	
			//parent.SetCustomRotation( 'BombThrow', heading-45, 0.0f, 0.1f, false );

			if ( moveData.pivotRotationValue.Pitch < -20 )
				enableAimingLookAt =  false;

			if ( enableAimingLookAt )
				parent.SetBehaviorVariable( 'enableAimingLookAt', 1.f );
			else
				parent.SetBehaviorVariable( 'enableAimingLookAt', 0.f );

			if ( moveData.pivotRotationValue.Pitch < -20 )
			{
				parent.SetCustomRotation( 'BombThrow', heading-45, 0.0f, 0.1f, false );
			}
			else if ( isRotating || ( angledist < 30 || angledist > 60 ) )
			{
				isRotating = true;
				parent.SetCustomRotation( 'BombThrow', heading-45, 0.0f, 0.4f, false );
				parent.SetBehaviorVariable( 'enableAimingLookAt', 1.f );
			}
			
			if ( angledist > 40 && angledist < 50 )
				isRotating = false;	
				
			camOffsetVec.X = ( ( ( -20 - moveData.pivotRotationValue.Pitch )/100 ) - 0.85 ) * -1;
			camOffsetVec.X = ClampF( camOffsetVec.X, 0.65f, 0.85f );
			camOffsetVec.Y = ( ( ( -20 - moveData.pivotRotationValue.Pitch )/-8 ) - 0.5 ) * -1;
			camOffsetVec.Y = ClampF( camOffsetVec.Y, 0.5f, 0.9f );
			camOffsetVec.Z = ( ( ( -20 - moveData.pivotRotationValue.Pitch )/-74.07 ) ) * -1;
			camOffsetVec.Z = ClampF( camOffsetVec.Z, 0.f, 0.27f );	
		}
		
		if ( parent.GetDisplayTarget() )
			followPosition = GetAimPosition();
		
		if ( !( parent.GetPlayerCombatStance() == PCS_AlertNear && virtual_parent.delayOrientationChange ) || !parent.bRAxisReleased )
		{
			currRotation = VecToRotation( theCamera.GetCameraDirection() );
			moveData.pivotRotationController.SetDesiredPitch( moveData.pivotRotationValue.Pitch, 3.f );
		}
		else
			moveData.pivotRotationController.SetDesiredPitch( initialPitch, 3.f );
		
		if ( virtual_parent.delayOrientationChange )
		{
			if ( parent.GetPlayerCombatStance() == PCS_AlertNear && parent.GetDisplayTarget() )
				moveData.pivotRotationController.SetDesiredHeading( VecHeading( followPosition - theCamera.GetCameraPosition() ), 1.f );
			else
				moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw, 1.f );		
		}
		else if ( thePlayer.bRAxisReleased && parent.GetDisplayTarget() && followTarget )
		{
			moveData.pivotRotationController.SetDesiredHeading( VecHeading( followPosition - theCamera.GetCameraPosition() ), 1.f );
			//theGame.GetGameCamera().ForceManualControlHorTimeout();
			moveData.pivotRotationController.SetDesiredPitch( ProcessInitialPitch(), 1.f );
			//theGame.GetGameCamera().ForceManualControlVerTimeout();
		}
		else
			moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw, 1.f );			
		
		/*if ( !thePlayer.bRAxisReleased )
			followTarget = false;*/
		
		moveData.pivotDistanceController.SetDesiredDistance( 1.f );
		//moveData.pivotDistanceValue = 1.f;
			
		moveData.pivotPositionController.offsetZ = 1.5f;
	
		//Vector( 0.85f, 0.5f, 0.f ) Vector( 0.65f, 0.9f, 0.27f )
		DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( camOffsetVec.X, camOffsetVec.Y, camOffsetVec.Z ), 0.2f, dt );		
		
		return true;
	}
	
	private function GetAimPosition() : Vector
	{
		var aimVector : Vector;
		var target : CGameplayEntity;
		var angles : EulerAngles;
		
		target = parent.GetDisplayTarget();
		
		//aimVector = VecTransform( target.GetLocalToWorld(), target.aimVector );
		
		//if ( aimVector == Vector(0,0,0) )
			aimVector =  target.GetWorldPosition();
			
		angles = VecToRotation( aimVector - parent.GetWorldPosition() );
		
		followPitch = -angles.Pitch;
		
		return aimVector;
	}
	
	event OnStateCanUpdateExplorationSubstates()
	{
		return true;
	}
	
	event OnCheckDiving()
	{
		// MS: this is okay because you can't go to aiming when swimming above water
		return prevState == 'Swimming';
	}	
	event OnIsCameraUnderwater()
	{
		return prevState == 'Swimming';
	}
}
