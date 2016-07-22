/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Tomek Kozera
/***********************************************************************/

state MeditationWaiting in W3PlayerWitcher extends MeditationBase
{
	private const var TARGET_HOURS_PER_MINUTE : float;		//desired speed up for waiting
	private const var BLEND_TIME_SECONDS_REAL : float;		//blending time (in real world seconds)
	
	private var storedHoursPerMinute : float;				//stored when we start waiting	
	private var waitStartTime : GameTime;					//timestamp of moment when we started waiting
	private var requestedTargetTime : GameTime;				//requested target time
	private var abortRequested : bool;						//set to true when abort request has been made
	
		default TARGET_HOURS_PER_MINUTE = 320.0;
		default BLEND_TIME_SECONDS_REAL = 2;

	event OnEnterState( prevStateName : name )
	{
		var requestedTargetHour : int;
		var fastForward : CGameFastForwardSystem;
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.BeginFastForward();
	
		virtual_parent.LockEntryFunction( true );
		
		storedHoursPerMinute = theGame.GetHoursPerMinute();
		waitStartTime = theGame.GetGameTime();
		requestedTargetHour = virtual_parent.GetWaitTargetHour();
		
		if(requestedTargetHour > GameTimeHours(waitStartTime))
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime), requestedTargetHour, 0, 0);
		else
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime) + 1, requestedTargetHour, 0, 0);
				
		//facts for quest block
		FactsSet('MeditationWaitStartDay', GameTimeDays(waitStartTime));		
		FactsSet('MeditationWaitStartHour', GameTimeHours(waitStartTime));
		FactsSet('MeditationStarted', 1);
		
		virtual_parent.LockEntryFunction( false );
		
		MeditationWaiting_Loop();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var fastForward : CGameFastForwardSystem;
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.AllowFastForwardSelfCompletion();
		//cutscenes don't handle meditation stop properly and instead force state change
		FactsSet('MeditationStarted', 0);
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		
		if(abortRequested)
		{
			LatentHackMeditationWaitingAbort();
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	entry function LatentHackMeditationWaitingAbort()
	{
		var medd : W3PlayerWitcherStateMeditation;
		
		medd = (W3PlayerWitcherStateMeditation)thePlayer.GetState('Meditation');
		medd.StopMeditation();
	}
	
	private entry function MeditationWaiting_Loop()
	{
		var blendInTime : float;
	
		blendInTime = BlendIn();
		
		if(!abortRequested)
			KeepWaiting(theGame.GetGameTime() - waitStartTime);
		
		BlendOut(2 * BLEND_TIME_SECONDS_REAL - blendInTime);
		
		//--== leave waiting state
		
		//force reset HPM
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		
		//force set current time - in case if we waited few minutes too long to avoid confusion as to why waiting finished after target hour
		//the case is we don't know how much 1 tick will last so we cannot stop at the precise time - we might be late by 1 tick worth of time
		if(!abortRequested)
			theGame.SetGameTime(requestedTargetTime, false);
		
		//restoring
		GetWitcherPlayer().MeditationRestoring( FinalHack_GetSimulateBuffTime() );				
		
		//get back to meditation state
		abortRequested = false;
		virtual_parent.PopState();
		virtual_parent.PushState('Meditation');	//somehow pop does not get us back to meditation??
	}
	
	//Blends in hours per minute from defalut to waiting target HPM. Returns amount of time (real seconds) spent in this function
	private latent function BlendIn() : float
	{
		var blendStartTime, currentEngineTime : EngineTime;
		var totalBlendTimeSecsReal, blendedHPM : float;
		var halfMeditationTime  : GameTime;
	
		blendStartTime = theGame.GetEngineTime();
		
		//Timestamp of half of target meditation time. If this is smaller than blend time we'll have to finish before finishing the blend
		halfMeditationTime = waitStartTime + GameTimeCreateFromGameSeconds( (GameTimeToSeconds(requestedTargetTime) - GameTimeToSeconds(waitStartTime)) / 2);
		
		while(true)
		{
			currentEngineTime = theGame.GetEngineTime();
			totalBlendTimeSecsReal = EngineTimeToFloat(currentEngineTime - blendStartTime);
							
			//exit if blend time elapsed or we already reached half of wait time
			if(totalBlendTimeSecsReal >= BLEND_TIME_SECONDS_REAL || theGame.GetGameTime() >= halfMeditationTime || abortRequested)
				break;
			
			blendedHPM = storedHoursPerMinute + (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / BLEND_TIME_SECONDS_REAL;
			blendedHPM = MinF(TARGET_HOURS_PER_MINUTE, blendedHPM);
			
			theGame.SetHoursPerMinute(blendedHPM);
			
			SleepOneFrame();
		}
		
		return totalBlendTimeSecsReal;
	}
	
	//Blends out of current hours per minute to default value.
	private latent function BlendOut(estimatedBlendTimeReal : float)
	{
		var blendStartTime, currentEngineTime : EngineTime;
		var totalBlendTimeSecsReal, blendedHPM : float;
		var currentGameTime : GameTime;
	
		blendStartTime = theGame.GetEngineTime();
		
		while(true)
		{
			currentGameTime = theGame.GetGameTime();
			currentEngineTime = theGame.GetEngineTime();
			totalBlendTimeSecsReal = EngineTimeToFloat(currentEngineTime - blendStartTime);
				
			//if we reached end of wait
			if(currentGameTime >= requestedTargetTime)
				break;
			
			//if we are aborting wait then make the blend 4* faster
			if(abortRequested)
				blendedHPM = TARGET_HOURS_PER_MINUTE - 4 * (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / estimatedBlendTimeReal;
			else
				blendedHPM = TARGET_HOURS_PER_MINUTE - (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / estimatedBlendTimeReal;
			
			blendedHPM = MaxF(storedHoursPerMinute, blendedHPM);
			
			//if we reached target hours per minute then exit
			if(blendedHPM == storedHoursPerMinute)
				break;
			
			theGame.SetHoursPerMinute(blendedHPM);
			
			SleepOneFrame();
		}
	}
	
	//Keeps waiting
	private latent function KeepWaiting(blendTime : GameTime)
	{
		var currentTime : GameTime;
		var commonMenuRef : CR4CommonMenu;
	
		while(true)
		{
			currentTime = theGame.GetGameTime();
			
			//stop if aborted or when we reach a point when we need to start blending out
			if((currentTime + blendTime > requestedTargetTime) || abortRequested)
				break;
				
			if ( thePlayer.IsThreatened() )
			{
				commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
				if (commonMenuRef)
				{
					commonMenuRef.CloseMenu();
				}
			}
				
			SleepOneFrame();
		}
	}
	
	//requests to stop waiting but does not stop the meditation itself
	public function RequestWaitStop()
	{		
		abortRequested = true;
	}
	
	//Called when the MEDITATION is supposed to finish (not just waiting, the whole thing)
	public function StopRequested(optional closeUI : bool)
	{
		var medd : W3PlayerWitcherStateMeditation;
	
		//set flag to stop waiting
		RequestWaitStop();
		
		//set flag to force meditation state exit when we switch back to it
		medd = (W3PlayerWitcherStateMeditation)(thePlayer.GetState('Meditation'));
		medd.StopRequested(closeUI);
	}
	
	//simulates passing of time for buffs on witcher
	private final function FinalHack_GetSimulateBuffTime() : float
	{
		var passedSecondsInGameTime, passedSecondsInRealTime : float;
		var currTime : GameTime;
		
		//if time wrapped around while meditating
		currTime = theGame.GetGameTime();
		if( waitStartTime > currTime )
		{
			return 0.f;
		}
		
		passedSecondsInGameTime = GameTimeToSeconds(currTime - waitStartTime);
		passedSecondsInRealTime = ConvertGameSecondsToRealTimeSeconds(passedSecondsInGameTime);
		
		return passedSecondsInRealTime;
	}
}
