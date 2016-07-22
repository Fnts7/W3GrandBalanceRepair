/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014-2015 CDProjektRed
/** Author : Tomek Kozera
/***********************************************************************/

state Meditation in W3PlayerWitcher extends MeditationBase
{
	private var meditationPointHeading : float;				//heading towards meditation point - Geralt will turn in that direction
	private var meditationHeadingSet : bool;				//set to indicate that heading has been set by external source
	private var stopRequested : bool;						//set to true when something is requesting state stop	
	private var isSitting : bool;							//true when sat down and inside the sitting loop		
	//public var meditationMenu : CR4MeditationMenu;			// #B reference to opened menu, in case of externaly close. !!! Exception !!!
	//public var meditationMenu : CR4PreparationMenu;			// #Y For E3 we need only Preparation
	private var closeUIOnStop : bool;						//close UI on meditation stop
	private var cameraIsLeavingState : bool;				//set when we are leaving state to inform the camera to start blending to default cam
	private var isEntryFunctionLocked : bool;				//set when we are inside InitState() entry function lock and cannot change state
	private var scheduledGoToWaiting : bool;				//if set, after InitState() will enter meditation waiting rather than going to Loop
	private var changedContext : bool;						//whether input context was changed on entering state or not
	
		default scheduledGoToWaiting = false;
	
	/////////////////////////////////////////  INIT  /////////////////////////////////////////////////////

	event OnEnterState( prevStateName : name )
	{
		parent.AddAnimEventCallback('OpenUI','OnAnimEvent_OpenUI');
		
		super.OnEnterState(prevStateName);
		
		meditationHeadingSet = false;
		cameraIsLeavingState = false;
		
		if(prevStateName != 'MeditationWaiting')
		{
			stopRequested = false;
			closeUIOnStop = false;
		}
		
		// Holster weapons
		thePlayer.OnMeleeForceHolster( true );
		thePlayer.OnRangedForceHolster( true );
		
		InitState(prevStateName);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		//quest fact
		if(nextStateName != 'MeditationWaiting')
		{
			FactsAdd('MeditationWaitFinished', 1, 1);					
		}
			
		//unlock weapon draw
		virtual_parent.UnblockAction(EIAB_DrawWeapon, 'Meditation');
		
		virtual_parent.SetBehaviorVariable( 'MeditateAbort', 0 );
		
		super.OnLeaveState(nextStateName);
		
		//parent.RemoveAnimEventCallback('OpenUI');
	}
	
	entry function InitState(prevStateName : name)
	{
		var actionSuccess : bool;
		
		virtual_parent.LockEntryFunction( true );
		isEntryFunctionLocked = true;
		
		virtual_parent.SetBehaviorVariable('MeditateAbort', 0);		//init
		
		if(prevStateName != 'MeditationWaiting')
		{
			isSitting = false;
			
			//block input
			virtual_parent.BlockAllActions('Meditation', true, ,false);
						
			//wait for data passed
			while(!meditationHeadingSet)
			{
				Sleep(0.1);
			}
			
			//holster weapon
			virtual_parent.BlockAction(EIAB_DrawWeapon, 'Meditation', false);
			virtual_parent.OnMeleeForceHolster(true);
			virtual_parent.OnRangedForceHolster(true);
			
			//block all but sword draw
			virtual_parent.BlockAllActions('Meditation', false);
			virtual_parent.BlockAction(EIAB_DrawWeapon, 'Meditation', false);
			
			if(!theGame.GetGuiManager().IsAnyMenu())
			{
				changedContext = true;
				theInput.StoreContext( 'Meditation' );
			}
			else
			{
				changedContext = false;
			}
			
			if( !((W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' )).GetWasUsed() )
			{
				//start kneeling anim
				virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 0);
				actionSuccess = virtual_parent.PlayerStartAction(PEA_Meditation);
			}
			else
			{
				actionSuccess = true;
			}
		}
		else
		{
			actionSuccess = true;
			
			if(!stopRequested)
			{
				// #Y check it
				//meditationMenu.MeditatingEnd();
			}
		}
		
		virtual_parent.LockEntryFunction( false );
		isEntryFunctionLocked = false;
		
		//abort if did not perform kneeling animation
		if(!actionSuccess)
		{
			StopRequested(true);
		}
		
		//go to loop or to meditation waiting if scheduled
		if(scheduledGoToWaiting)
		{
			scheduledGoToWaiting = false;
			virtual_parent.PushState('MeditationWaiting');
		}
		else
		{
			Loop();
		}
	}
	
	public function SetMeditationPointHeading(head : float)
	{
		meditationPointHeading = head;
		meditationHeadingSet = true;
	}
	
	public function IsSitting() : bool
	{
		return isSitting;
	}
	
	event OnAnimEvent_OpenUI( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var mutagen : CBaseGameplayEffect;
		
		if( !stopRequested )	//stop might be requested if we get hit between anim start and this event call
		{
			isSitting = true;
			cameraIsLeavingState = false;
						
			// Remove Mutagen 6 bonus
			if(thePlayer.HasBuff(EET_Mutagen06))
			{
				mutagen = thePlayer.GetBuff(EET_Mutagen06);
				thePlayer.RemoveAbilityAll(mutagen.GetAbilityName());
			}
			
			//UI
			//theGame.RequestMenu( 'MeditationMenu', this );	//#Y Disabled, just open preparation:
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu' );
		}
	}
	
	/////////////////////////////////////////  LOOP  /////////////////////////////////////////////////////
	
	public function StopRequested(optional closeUI : bool)
	{
		stopRequested = true;
		closeUIOnStop = closeUI;
		virtual_parent.SetBehaviorVariable('MeditateAbort', 1);
	}
	
	private entry function Loop()
	{
		while(!stopRequested)
		{
			Sleep(0.2);
		}
		StopMeditation();
	}
	
	/////////////////////////////////////////  DEINIT  /////////////////////////////////////////////////////
	public latent function StopMeditation()
	{
		var commonMenuRef 	: CR4CommonMenu;
		var l_bed			: W3WitcherBed;
	
		cameraIsLeavingState = true;
		
		//close UI if we have any (e.g. forced stop)
		if(closeUIOnStop)
		{
			commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
			if (commonMenuRef)
			{
				commonMenuRef.CloseMenu();
			}
		}		
	
		virtual_parent.SetBehaviorVariable('HasCampfire', 0);
		
		l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
		
		if( !l_bed.GetWasUsed() )
		{
			virtual_parent.PlayerStopAction(PEA_Meditation);
		}
		else
		{
			virtual_parent.PlayerStopAction( PEA_GoToSleep );
		}
		
		if( l_bed.GetWasUsed() )
		{
			l_bed.SetWasUsed( false );
		}
		
		//unlock input and set context
		if(changedContext)
		{
			theInput.RestoreContext('Meditation', false);
		}
								
		//wait for stand up anim to finish (the event name is bullshit, don't ask why but I leave it as it seems to be used by other cases?)
		virtual_parent.WaitForBehaviorNodeDeactivation( 'PlayerActionEnd', 10);
		
		if(virtual_parent.GetCurrentStateName() == 'Meditation')
			virtual_parent.PopState(true);		
	}
	
	////////////////////////////////////  WAITING  ////////////////////////////////////////////////////////
	public function MeditationWait(targetHour : int)
	{
		LogChannel( 'CLOCK', "MeditationWait, targetHour "+targetHour);
		virtual_parent.SetWaitTargetHour(targetHour);
		
		//goto wait immediately or after finishing InitState()
		if(!isEntryFunctionLocked)
			virtual_parent.PushState('MeditationWaiting');
		else
			scheduledGoToWaiting = true;
	}
		
	////////////////////////////////////  CAMERA  ////////////////////////////////////////////////////////
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = parent.GetWorldRotation();
		
		theGame.GetGameCamera().ChangePivotRotationController( 'Exploration' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
		
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();		
		
		if(!cameraIsLeavingState)
		{
			moveData.pivotRotationController.SetDesiredHeading( rotation.Yaw + 180.f, 0.1f );
			moveData.pivotRotationController.SetDesiredPitch(-15, 0.3);
			moveData.pivotPositionController.offsetZ = 0.5;
			moveData.pivotDistanceController.SetDesiredDistance( 3.8f );
			
			super.OnGameCameraTick(moveData, dt);

			return true;
		}
		
		return false;
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = parent.GetWorldRotation();
		
		if( cameraIsLeavingState )
		{
			moveData.pivotRotationController.SetDesiredHeading( rotation.Yaw, 0.1f );
		}
	}
}
