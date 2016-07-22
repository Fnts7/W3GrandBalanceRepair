/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Tomek Kozera
/***********************************************************************/

// Base class for 'critical state' effects (effects that cause animation effect e.g. knockdown, stun, burn)
//   WHENEVER EDITING THIS CLASS REMEMBER ABOUT W3CriticalDOTEffect !!!!!
//
// Setting timeLeft to 0 makes effect request anim stop. Setting isActive to false removed the buff instantly, ignorin animation behaviors.
abstract class W3CriticalEffect extends CBaseGameplayEffect
{
	protected var criticalStateType 		: ECriticalStateType;				//type of critical state
	protected saved var allowedHits 		: array<bool>;						//flags for allowed hit anims
	protected var timeEndedHandled 			: bool;
	private var isDestroyedOnInterrupt 		: bool;								//if set then the buff will be removed when interrupted (actor will not get back to this state)
	private var canPlayAnimation 			: bool;								//set in some ocasions to false - when character finishes some action, this critical will not play it's animation again but it will work
	protected var blockedActions 			: array<EInputActionBlock>;			//list of actions blocked when in this critical state
	protected var postponeHandling 			: ECriticalHandling;				//what to do with the buff if it has to be postponed on add (cannot start anim imidiately)
	protected var airHandling 				: ECriticalHandling;				//what to do with the buff if target is in air while it's being applied
	protected var attachedHandling 			: ECriticalHandling;				//what to do with the buff if player is attached (boat, ladder, ledge)
	protected var onHorseHandling 			: ECriticalHandling;				//what to do with the buff if player is on horse
	public var explorationStateHandling 	: ECriticalHandling;				//what to do with the buff if player is in a complex state like sliding or rolling
	private var usesFullBodyAnim			: bool;
	
		default criticalStateType 			= ECST_None;						//non-critical by default
		default isNegative 					= true;
		default timeEndedHandled 			= false;
		default isDestroyedOnInterrupt 		= false;
		default canPlayAnimation 			= true;
		default postponeHandling 			= ECH_Postpone;
		default airHandling 				= ECH_Postpone;
		default attachedHandling			= ECH_HandleNow;
		default onHorseHandling				= ECH_HandleNow;
		default	explorationStateHandling	= ECH_Postpone;
		default usesFullBodyAnim			= false;
		
	public function CacheSettings()
	{
		var i :int;
		
		super.CacheSettings();
		
		allowedHits.Grow( EnumGetMax('EHitReactionType')+1 );
		for(i=0; i<allowedHits.Size(); i+=1)
			allowedHits[i] = true;
			
		//default blocked actions		
		blockedActions.PushBack(EIAB_ExplorationFocus);
		blockedActions.PushBack(EIAB_Dive);
		blockedActions.PushBack(EIAB_Interactions);
		blockedActions.PushBack(EIAB_FastTravel);
	}
	
	public function OnTimeUpdated(deltaTime : float)
	{
		if ( isActive )
		{
			timeActive += deltaTime;
		}
		
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
		}
		
		// Deactivate the finisher if the time in critical effect left is too short to play the finish animation
		/*if( timeLeft <= 1 )
		{
			target.SignalGameplayEvent('DisableFinisher');
		}*/
		
		if(timeLeft <= 0 && !timeEndedHandled)
		{
			target.SignalGameplayEvent('DisableFinisher');
			timeEndedHandled = true;
		
			//if this effect is currently animated
			if(isActive && this == target.GetCurrentlyAnimatedCS())
			{				
				target.RequestCriticalAnimStop();
			}
			else
			{
				LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
				isActive = false;			
			}
		}
	}
	
	public function GetCriticalStateType() : ECriticalStateType			{return criticalStateType;}	
	public function IsHitAllowed(hit : EHitReactionType) : bool			{return allowedHits[hit];}
	public function IsDestroyedOnInterrupt() : bool						{return isDestroyedOnInterrupt;}
	public function CanPlayAnimation() : bool							{return canPlayAnimation;}
	public function DisallowPlayAnimation()								{canPlayAnimation = false;}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var i : int;
		var animHandling : ECriticalHandling;
		var veh : CGameplayEntity;
		var horseComp : W3HorseComponent;
		var boatComp : CBoatComponent;
		
		super.OnEffectAdded(customParams);
			
		//block input actions
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.BlockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		//block stamina regen
		if(!isOnPlayer)
			target.PauseStaminaRegen('in_critical_state');

		//---------starting to play the animation of buff - select handling
		if(target.IsCriticalTypeHigherThanAllCurrent(criticalStateType))
		{
			if(target.IsInAir())
			{
				animHandling = airHandling;
			}			
			else
			{
				if(isOnPlayer)
				{
					thePlayer.OnRangedForceHolster( true, false, false );
					
					if( !thePlayer.CanReactToCriticalState() )
					{
						animHandling = explorationStateHandling;
					}
					else
					{
						veh = thePlayer.GetUsedVehicle();
						if((W3Boat)veh)
						{
							//boatComp = (CBoatComponent)veh.GetComponentByClassName( 'CBoatComponent' );
							//boatComp.IssueCommandToDismount( DT_normal );
							animHandling = attachedHandling;
						}
						else if(veh)
						{
							//horse						
							horseComp = ((CNewNPC)veh).GetHorseComponent();
							horseComp.OnCriticalEffectAdded( criticalStateType );
							animHandling = onHorseHandling;
						}		
						else
						{
							//normal anim start
							animHandling = ECH_HandleNow;
						}
					}
				}
				else
				{
					//normal anim start
					animHandling = ECH_HandleNow;
				}
			}
		}
		else
		{
			//higher priority buff is already being played
			animHandling = postponeHandling;
		}
		
		//handle anim
		if(animHandling == ECH_HandleNow)
		{
			target.StartCSAnim(this);
		}
		else if(animHandling == ECH_Abort)
		{
			LogCritical("Cancelling CS <<" + criticalStateType + ">> as it cannot play anim right now and its handling wishes to abort in such case");
			isActive = false;
		}
		//else if ECH_Postpone - do nothing now
		
		if(isOnPlayer)
			theGame.VibrateControllerVeryHard();	//player got CS
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
	
	//cumulate and readd health regen reduction buff
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
	}
	
	event OnEffectRemoved()
	{
		var i : int;
	
		super.OnEffectRemoved();
	
		//block input actions
		if(isOnPlayer)
		{
			for(i=0; i<blockedActions.Size(); i+=1)
			{
				thePlayer.UnblockAction( blockedActions[i], EffectTypeToName( effectType ) );
			}
		}
		
		//unblock stamina regen
		target.ResumeStaminaRegen('in_critical_state');
		
		if(isOnPlayer)
		{
			LogCriticalPlayer("Critical.OnEffectRemoved() | " + this);
			LogCriticalPlayer("");
		}
		
		if(this == target.GetCurrentlyAnimatedCS())
			target.RequestCriticalAnimStop();
	}
	
	public final function UsesFullBodyAnim() : bool
	{
		return usesFullBodyAnim;
	}
}