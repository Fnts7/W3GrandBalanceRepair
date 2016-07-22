// Please keep this as empty as possible
// use RidingManager instead
state MountHorse in CR4Player extends MountTheVehicle
{
	var horseComp : W3HorseComponent;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState( prevStateName : name )
	{
		var instantMount : bool;
		instantMount = false;
		
		super.OnEnterState( prevStateName );
		
		thePlayer.HideUsableItem();
		
		thePlayer.AddBuffImmunity( EET_Pull, 'HorseRidingBuffImmunity', true );
		
		horseComp = (W3HorseComponent)vehicle;
		
		if( horseComp )
		{
			horseComp.canDismount = false;
			this.ProcessMountHorse();
		}
		else
		{
			LogAssert( vehicle, "MountHorse::ProcessMountTheVehicle, 'vehicle' is not set" );
		}
		
		if( mountType == MT_instant )
		{
			instantMount = true;
		}
		
		theGame.ActivateHorseCamera( true, 0.f, instantMount );
		
		if ( (W3ReplacerCiri)thePlayer )
		{
			theInput.SetContext( 'Horse_Replacer_Ciri' );
		}
		else
			theInput.SetContext( 'Horse' );
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
	}
	
	// This is called when the state was interupted ( ie the mount didn't have time to finish )
	cleanup function MountCleanup() 
	{
		super.MountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private var mountAnimStarted : bool;
	
	const var MOUNT_TIMEOUT : float;
	default MOUNT_TIMEOUT = 5.0;
	
	entry function ProcessMountHorse()
	{
		var riderData 			: CAIStorageRiderData;
		var distance			: float;
		var contextSwitchOffset	: float;
		var mountStartTimestamp : float;
		
		parent.SetCleanupFunction( 'MountCleanup' );
		
		mountAnimStarted = false;
		
		if ( mountType == MT_instant )
		{
			// Well this sounds stupid but if you're in the air and a cutscene or something forces you on a horse
			// then you're screwed... It also happens when you spawn & instantly mount since you're rarely spawning on ground
			parent.OnHitGround();
		}
		
		riderData = thePlayer.GetRiderData();
		// If vehicle is paired with another rider
		horseComp.Unpair(); // stealing horse from potential owner
		
		horseComp.PairWithRider( riderData.sharedParams );	// assign to player	
		riderData.sharedParams.rider 		= thePlayer;
		riderData.sharedParams.vehicleSlot  = vehicleSlot;
		
		parent.SignalGameplayEventParamInt( 'RidingManagerMountHorse', mountType );
		
		// HACK for what ? - when you pushstate in the same frame that entry function is called state machine will be fucked
		SleepOneFrame();
		
		mountStartTimestamp = theGame.GetEngineTimeAsSeconds();
		while( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_mounted )
			{
				break;
			}
			if ( mountAnimStarted )
			{
			
			}
			else if ( riderData.ridingManagerMountError == true || mountStartTimestamp + MOUNT_TIMEOUT < theGame.GetEngineTimeAsSeconds() )
			{
				OnMountingFailed();
				parent.PopState();
				break;
			}
			SleepOneFrame();
		}
		
		parent.ClearCleanupFunction();
		horseComp.IssueCommandToUseVehicle( );
	}
	
	event OnStartTraversingExploration( t : CScriptedExplorationTraverser )
	{
		//horseComp.PushState( 'Exploration' );
		return parent.OnStartTraversingExploration(t);
	}
	
	private function OnMountingFailed()
	{	
		super.OnMountingFailed();

		theGame.ActivateHorseCamera( false, 0.f );	
	}
	
	event OnMountAnimStarted()
	{
		mountAnimStarted = true;
	}
	
	event OnHorseRidingOn()
	{
		horseComp.PushState( 'Exploration' );
	}
	
	event OnDeath( damageAction : W3DamageAction )
	{
		parent.ActionCancelAll();
		
		parent.OnDeath( damageAction );
	}
}
