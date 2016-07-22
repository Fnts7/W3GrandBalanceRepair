/*
state CombatFocusMode_PlayAnimation in W3PlayerWitcher extends ExtendedMovable
{
	private var selectedSpot		: SVitalSpotInfo;
	private var isOk				: bool;
	private var running				: bool;
	private var	timeScale			: float;
	private var animationController : AnimationTrajectoryPlayerScriptWrapper;
	private var playerSpeedMulId 	: int;
	private var cameraDirector		: FocusModeCameraDirector_PlayAnimation;
	private var sliderTransition	: float;
	private var	playerWasMovable	: bool;
	private var animProxy 			: CActionMoveAnimationProxy;
	private var sliderPos 			: Vector;
	private var sliderHeading		: float;
	
	default isOk = false;
	default running = false;
	default timeScale = 1.f; //0.05f;
	default playerSpeedMulId = -1;
	default sliderTransition = 0.1f;

	//private var freezingTimeScaleName     : name;
	//private var freezingTimeScalePriority : Int32;
    //default freezingTimeScaleName         = 'Freezing';
    //default freezingTimeScalePriority     = 100;
    
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );		
		
		if ( !animationController )
		{
			animationController = new AnimationTrajectoryPlayerScriptWrapper in this;
		}
		
		if ( !cameraDirector )
		{
			cameraDirector = new FocusModeCameraDirector_PlayAnimation in this;
		}
		
		SetupGameplayStuff_EnterState( selectedSpot.owner );
		
		MainEntryFunction();
	}
	
	event OnCanLeaveState( nextStateName : name )
	{
		return !running;
	}
	
	event OnLeaveState( nextStateName : name )
	{
		SetupGameplayStuff_LeaveState();
		
		animationController.Deinit();
		
		cameraDirector.Deactivate();
		
		cameraDirector.Deinit();
	
		parent.DetachBehavior( 'FocusMode' );
		
		animProxy = NULL;
		
		LogAssert( !isOk, "CombatFocusMode_PlayAnimations::OnLeaveState: isOk is true" );
		
		isOk = false;
		running = false;
		
		super.OnLeaveState( nextStateName );
	}
	
	private final function SetupGameplayStuff_EnterState( enemy : CNewNPC )
	{		
		playerWasMovable = thePlayer.GetIsMovable();
		thePlayer.SetIsMovable( false );
	}
	
	private final function SetupGameplayStuff_LeaveState()
	{
		// Disable player hit animations
		thePlayer.SetCanPlayHitAnim( true );
		
		thePlayer.SetIsMovable( playerWasMovable );
	}
	
	event OnAnimEvent_THIS_WILL_NOT_WORK( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == 'CombatStanceLeft' )
		{
			parent.SetCombatIdleStance( 0.0f );
		}		
		else if ( animEventName == 'CombatStanceRight' )
		{
			parent.SetCombatIdleStance( 1.0f );
		}
		parent.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	public final function SetupState( spot : SVitalSpotInfo )
	{
		LogAssert( !isOk, "CombatFocusMode_PlayAnimations::OnEnterState: isOk is true" );
	
		selectedSpot = spot;
		
		isOk = true;
	}
	
	entry function MainEntryFunction()
	{
		var attackToken : SAnimationTrajectoryPlayerToken;
		var behRet : bool;
		
		// This should be in OnEnterState but AttachBehavior is latent
		//{
			behRet = parent.AttachBehavior( 'FocusMode' );
			if ( !behRet )
			{
				LogAssert( behRet, "CombatFocusMode_PlayAnimations - parent.AttachBehavior( FocusMode ) is false" );
			}
			
			animationController.Init( parent, 'FM_ANIMATION' );
			
			cameraDirector.Init( this, parent );
			
			cameraDirector.Activate( selectedSpot.owner );
		//}
		
		LogAssert( isOk, "CombatFocusMode_PlayAnimations::MainEntryFunction: isOk is false" );
		
		if ( isOk )
		{
			running = true;
			
			// Select attack
			//attackToken = SelectAttack( selectedSpot.slotWorldPos, parent.GetLocalToWorld() );
			//if ( attackToken.isValid )
			{
				// 1. Send force idle event
				SendAISignal_ForceIdle( selectedSpot.owner );
				
				// 2. Start camera sliding - moved to SlideToStartingPlace
				// cameraDirector.State_SlidingToEnemy( 0.5f );
				
				// 3. Start player sliding
				attackToken = SlideToStartingPlace( selectedSpot );
				
				// 4. Freeze world
				FreezeWorld();
				
				// 5. Change camera state
				cameraDirector.State_PlayingAttack( attackToken.syncTime, attackToken.duration );
				
				// 6. Playing animations
				PlayAnimations( selectedSpot, attackToken );
			}
			//else
			//{
			//	LogChannel('FocusMode', "Error: MainEntryFunction - attackToken is invalid" );
			//}
		
			// 7. Unfreeze world
			UnfreezeWorld();
			
			// Debug
			//Sleep( 5.f );
			
			isOk = false;
			running = false;
			
		}
		parent.PopState();
	}
	
	private final function FreezeWorld()
	{
		//theGame.SetTimeScale( timeScale, freezingTimeScaleName, freezingTimeScalePriority );
		
		//playerSpeedMulId = thePlayer.SetAnimationSpeedMultiplier( 1.f / timeScale );
	}
	
	private final function UnfreezeWorld()
	{
		//theGame.RemoveTimeScale( freezingTimeScaleName );
		
		//thePlayer.ResetAnimationSpeedMultiplier( playerSpeedMulId );
	}
	
	private final function SetGlobalTimeScale( scale : float )
	{
		timeScale = scale;
		theGame.SetTimeScale( timeScale, theGame.GetTimescaleSource(ETS_CFM_PlayAnim), theGame.GetTimescalePriority(ETS_CFM_PlayAnim) );
		LogChannel( 'FM_TS', timeScale );
	}
	
	private final function ResetGlobalTimeScale()
	{
		timeScale = 1.f;
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_CFM_PlayAnim) );
	}
	
	private final function SelectAttack( pointWS : Vector, l2w : Matrix ) : SAnimationTrajectoryPlayerToken
	{
		var input : SAnimationTrajectoryPlayerInput;
		var output : SAnimationTrajectoryPlayerToken;
		
		input.localToWorld = l2w;
		input.pointWS = pointWS;
		input.directionWS = VecFromHeading( parent.GetHeading() + 90.f );
		input.selectorType = ATST_Blend2Direction;//Blend2;
		input.proxySyncType = AMAST_CrossBlendIn;
		input.proxy = animProxy;
		
		// Extra filters
		//input.attackId = 'focusMode';
		
		output = animationController.SelectAnimation( input );
		
		return output;
	}
	
	private final latent function SlideToStartingPlace( spot : SVitalSpotInfo ) : SAnimationTrajectoryPlayerToken
	{
		var currSyncPointWS, slotPos, slotPosWZ : Vector;
		var destPos, playerPos, slidePos, dirToSlot : Vector;
		var heading, slotHeading, distToSlot : float;
		var l2w, l2wToTest, l2wCurrent : Matrix;
		var newToken : SAnimationTrajectoryPlayerToken;
		var ret, shouldBeInLeftStance : bool;
		var slidingAnimationName : name;
		var sliderSettings : SAnimatedSlideSettings;
		var slotMatrix : Matrix;
		
		//{
			spot.owner.CalcEntitySlotMatrix( spot.ambientSound.slotName, slotMatrix );
			slotPos = MatrixGetTranslation( slotMatrix );
			slotPosWZ = slotPos;
			
			playerPos = parent.GetWorldPosition();
			slotPosWZ.Z = playerPos.Z;
			
			destPos = parent.GetNearestPoint( slotPos, 1.8f );
			destPos.Z = playerPos.Z;
			
			dirToSlot = VecNormalize( slotPosWZ - playerPos );
			heading = VecHeading( dirToSlot );
			
			l2wCurrent = parent.GetLocalToWorld();
			l2w = MatrixBuiltTRS( destPos , EulerAngles( 0.f, heading, 0.f ) );
			
			newToken = SelectAttack( slotPos, l2w );
			
			slotHeading = AngleNormalize180( heading - 180.f );
			l2wToTest = MatrixBuiltTRS( slotPos , EulerAngles( 0.f, slotHeading, 0.f ) );
			slidePos = VecTransform( l2wToTest, newToken.syncPointMS );
			slidePos.Z = playerPos.Z;
			
			distToSlot = VecDistance2D( slidePos, playerPos );
			
			// Visual debug	
			parent.GetVisualDebug().AddSphere( 'focusModeTargetPos1', 0.3f, slidePos, true, Color( 255, 0, 0 ), 30.f ); 
			
			// Sliding
			shouldBeInLeftStance = true;
			
			if ( IsPlayerInLeftStance() )
			{
				if ( shouldBeInLeftStance )
				{
					slidingAnimationName = 'man_geralt_sword_focus_dash_f_lp_lp';
				}
				else
				{
					slidingAnimationName = 'man_geralt_sword_focus_dash_f_lp_rp';
				}
			}
			else
			{
				if ( shouldBeInLeftStance )
				{
					slidingAnimationName = 'man_geralt_sword_focus_dash_f_rp_lp';
				}
				else
				{
					slidingAnimationName = 'man_geralt_sword_focus_dash_f_rp_rp';
				}
			}
			
			cameraDirector.State_SlidingToEnemy( 0.5f - sliderTransition, slidePos, heading );
			
			ResetAnimatedSlideSettings( sliderSettings );
			sliderSettings.animation = slidingAnimationName;
			sliderSettings.slotName = 'FM_SLIDE';
			sliderSettings.useGameTimeScale = false;
			sliderSettings.useRotationDeltaPolicy = true;
			ret = parent.ActionAnimatedSlideToStaticAsync_P( sliderSettings, slidePos, heading, true, true, animProxy );
			
			sliderPos = slidePos;
			sliderHeading = heading;
			
			if ( !ret )
			{
				LogChannel('FocusMode', "Error: SlideToStartingPlace - ActionAnimatedSlideToStatic returns false" );
			}
			
			if ( animProxy )
			{			
				cameraDirector.UpdateShotManually( theTimer.timeDeltaUnscaled );
				
				SleepOneFrame(); // Bacause of animProxy.IsInitialized()
				
				if ( animProxy.IsInitialized() && animProxy.IsValid() )
				{
					while ( !animProxy.WillBeFinished( sliderTransition ) )
					{
						cameraDirector.UpdateShotManually( theTimer.timeDeltaUnscaled );
						
						SleepOneFrame();
					}
				}
			}
			
			return newToken;
		//}
	}
	
	private final latent function PlayAnimations( spot : SVitalSpotInfo, prevAttackToken : SAnimationTrajectoryPlayerToken )
	{
		var attackToken : SAnimationTrajectoryPlayerToken;
		var ret : bool;
		var syncPointWS : Vector;
		var itemId : SItemUniqueId;
		var dt : float;
		var mat : Matrix;
		var prevTime, currTime, timeDelta, timeS : float;
		var size, i : int;
		var focusModeTargetVS : array<CVitalSpot>;
		var slotMatrix : Matrix;
		
		spot.owner.CalcEntitySlotMatrix( spot.ambientSound.slotName, slotMatrix );
		syncPointWS = MatrixGetTranslation( slotMatrix );
		
		mat = MatrixBuiltTRS( sliderPos , EulerAngles( 0.f, sliderHeading, 0.f ) );
		
		// Select attack, can be different then prev attack
		attackToken = SelectAttack( syncPointWS, mat );
		attackToken.blendIn = sliderTransition;
		attackToken.blendOut = 0.5f;
		attackToken.timeFactor = 1.f; //0.03f;
		
		// Is attack ok?
		if ( attackToken.isValid )
		{
			// Add debug sphere
			parent.GetVisualDebug().AddSphere( 'focusModeTarget', 0.1f, spot.slotWorldPos, true, Color( 255, 0, 255 ), 3.f ); 
			
			// Debug
			//attackToken.syncPointDuration = 1.f;
			
			// Play aniamation for player
			if ( !animationController.PlayAnimation( attackToken ) )
			{
				LogChannel('FocusMode', "Error: PlayAnimation returns false" );
			}
			else
			{
				ResetComboPlayerAndBackToIdle();
				
				// Wait for hit
				while( animationController.IsBeforeSyncTime() )
				{
					// Update point					
					spot.owner.CalcEntitySlotMatrix( spot.ambientSound.slotName, slotMatrix );
					syncPointWS = MatrixGetTranslation( slotMatrix );
					
					// Send data to controller
					if ( animProxy && animProxy.IsValid() && !animProxy.IsFinished() )
					{
						animationController.UpdateCurrentPointM( mat, syncPointWS );
					}
					else
					{
						animationController.UpdateCurrentPoint( syncPointWS );
					}
					
					// Tick
					animationController.Tick( theTimer.timeDeltaUnscaled );
					
					cameraDirector.UpdateShotManually( animationController.GetTime() );
					
					if ( !animationController.IsBeforeSyncTime() )
					{
						break;
					}
					
					// Go to next frame
					SleepOneFrame();
				}
			
				// Play hit for enemy
				SendAISignal_Hit( spot.owner, spot.hitReactionAnimation );
				
				// Apply gameplay effects
				size = spot.gameEffects.Size();
				for( i = 0; i < size; i += 1 )
				{
					spot.gameEffects[i].Execute( parent, spot.owner, "FocusMode" );
				}
				
				spot.owner.PlayEffect( 'focus_neck_fx', NULL );
				
				// Play sword effect
				{
					//FIXME TK: broken if we're fighting with silver sword
					GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, itemId);
				
					parent.GetInventory().PlayItemEffect( itemId, 'focus_blood_trail' );
					parent.GetInventory().PlayItemEffect( itemId, 'focus_blood_hit' );
				}
				
				// Go to next frame
				SleepOneFrame();
				
				currTime = animationController.GetTime();
				
				// Wait for finish
				while ( animationController.IsPlayingAnimation() )
				{
					// Tick
					animationController.Tick( theTimer.timeDeltaUnscaled );
					
					prevTime = currTime;
					currTime = animationController.GetTime();
					
					timeDelta = currTime - prevTime;
					if ( timeDelta > 0.f )
					{
						timeS = timeDelta / ( theTimer.timeDelta / timeScale );
						SetGlobalTimeScale( timeS );
					}
					else
					{
						timeS = 1.f;
					}
					
					if ( animationController.IsPlayingAnimation() )
					{
						cameraDirector.UpdateShotManually( animationController.GetTime() );
					}
					
					// Go to next frame
					SleepOneFrame();
				}
				
				ResetGlobalTimeScale();
				
				// Stop sword effect
				parent.GetInventory().StopItemEffect( itemId, 'focus_blood_trail' );
				parent.GetInventory().StopItemEffect( itemId, 'focus_blood_hit' );
				
				cameraDirector.ResetManualMode();
			}	
		}
		else
		{
			LogChannel('FocusMode', "Error: PlayAnimations attack token is invalid" );
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////
	
	private final function IsPlayerInLeftStance() : bool
	{
		return parent.GetBehaviorVariable( 'combatIdleStance' ) < 0.5f;
	}
	
	private final function ResetComboPlayerAndBackToIdle()
	{
		var s : W3PlayerWitcherStateCombatSteel;
		
		s = (W3PlayerWitcherStateCombatSteel)parent.GetState( 'CombatSteel' );
		if ( s )
		{
			s.ResetComboPlayerAndGoToIdle();
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////
	// AI part
	
	private final function SendAISignal_ForceIdle( enemy : CNewNPC )
	{
		enemy.SignalGameplayEvent( 'CombatFocusMode' );
	}
	
	private final function SendAISignal_ForceIdleEnd( enemy : CNewNPC )
	{
		enemy.SignalGameplayEvent( 'CombatFocusModeEnd' );
	}
	
	private final function SendAISignal_Hit( enemy : CNewNPC, hitReactionAnimation : name )
	{
		enemy.SignalGameplayEventParamCName( 'CombatFocusModeHitAnimation', hitReactionAnimation );
	}
}
*/