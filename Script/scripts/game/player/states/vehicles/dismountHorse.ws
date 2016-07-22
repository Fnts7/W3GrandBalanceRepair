

// Please keep this as empty as possible
// use RidingManager instead
state DismountHorse in CR4Player extends DismountTheVehicle
{
	public var horseComp : W3HorseComponent;
	
	//const variables
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		horseComp = (W3HorseComponent)vehicle;
		
		parent.AddAnimEventCallback( 'SlideBack', 'OnAnimEvent_SlideBack' );
		
		this.ProcessDismountHorse();
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		var horseRiderSharedParams : CHorseRiderSharedParams;
		
		thePlayer.RemoveBuffImmunity( EET_Pull, 'HorseRidingBuffImmunity' );
		
		parent.RemoveTimer( 'CheckSwimmingOnDismount' );
		//horseRiderSharedParams = thePlayer.GetRiderSharedParams();
		//horseRiderSharedParams.horse = NULL;
		//horseComp.riderSharedParams = NULL;
		
		parent.RemoveAnimEventCallback( 'SlideBack' );
		
		parent.EnableCollisions(true);
		
		super.OnLeaveState( nextStateName );
	}
	// This is called when the state was interupted ( ie the dismount didn't have time to finish )
	cleanup function DismountCleanup() 
	{
		super.DismountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	entry function ProcessDismountHorse()
	{
		var riderData : CAIStorageRiderData;
		var weaponType	: EPlayerWeapon;
		var target : CActor;
		var position : Vector;
		
		//var timeStamp : float;
		
		riderData = thePlayer.GetRiderData();
		parent.SetCleanupFunction( 'DismountCleanup' );
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', dismountType );
		
		parent.AddTimer( 'CheckSwimmingOnDismount', 0.f, true );
		// HACK for what ? - when you pushstate in the same frame that entry function is called state machine will be fucked
		SleepOneFrame();
		
		if ( dismountType == DT_shakeOff )
		{
			if ( parent.rangedWeapon && parent.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
			{
				//LogChannel( 'HorseShake', "shakeOffStart" );
				parent.WaitForBehaviorNodeActivation('shakeOffStart',0.5f);
				//LogChannel( 'HorseShake', "OnRangedForceHolster" );
				parent.OnRangedForceHolster( true, true );
			}
			
			//timeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
			parent.WaitForBehaviorNodeActivation('recoverStart',3.f);
			//LogChannel( 'HorseShake', EngineTimeToFloat( theGame.GetEngineTime() ) - timeStamp );
			target = (CActor)thePlayer.GetDisplayTarget();
			if ( target && thePlayer.IsInCombat() )
			{
				weaponType = thePlayer.GetMostConvenientMeleeWeapon( target, true );
				thePlayer.OnEquipMeleeWeapon( weaponType, false, false );
			}
		}
		else
		{
			parent.OnRangedForceHolster( true, true );
			theInput.SetContext( thePlayer.GetExplorationInputContext() );
			while( true )
			{
				if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_dismounted )
				{
					break;
				}
				if ( riderData.ridingManagerMountError == true )
				{
					parent.PopState();
					break;
				}
				SleepOneFrame();
			}
		}
		
		
		parent.ClearCleanupFunction();
		parent.PopState( true );
	}
	
	event OnAnimEvent_AllowFall( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		HACK_ActivatePhysicsRepresentation();
		//parent.EnableCollisions( true );
		//parent.PopState(true);
		//parent.OnAnimEvent_AllowFall(animEventName, animEventType, animInfo);
	}
	
	event OnAnimEvent_SlideBack( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var pointToSlide : Vector;
		var heading : Vector;
		var movementAdjustor : CMovementAdjustor;
		var ticket : SMovementAdjustmentRequestTicket;
		
		if( animEventType == AET_DurationStart )
		{
			pointToSlide = parent.GetWorldPosition();
			heading = parent.GetHeadingVector();
			pointToSlide -= heading * 1.0;
			
			movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			ticket = movementAdjustor.CreateNewRequest( 'SlideBack' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.ScaleAnimation( ticket );	
			movementAdjustor.SlideTo( ticket, pointToSlide );
			movementAdjustor.Continuous( ticket	);
		}
	}
	
	timer function CheckSwimmingOnDismount( dt : float , id : int)
	{
		var depth : float;
		var fallDist : float;
		var waterLevel : float;
		
		// start to swim
		if ( !thePlayer.IsSwimming() && thePlayer.IsAlive() ) //&& thePlayer.GetCurrentStateName() != 'AimThrow'
		{
			depth = ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).GetSubmergeDepth();
			
			if ( depth < parent.ENTER_SWIMMING_WATER_LEVEL )
			{
				parent.RemoveTimer( 'CheckSwimmingOnDismount' );
				parent.GotoState( 'Swimming' );
			}
		}
	}
}