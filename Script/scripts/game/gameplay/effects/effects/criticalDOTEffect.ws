/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Tomek Kozera
/***********************************************************************/

// ALMOST COPY PASTE FROM criticalEffect.ws !!!!

// Base class for critical effect + DoT effect (no multibased polimorphism)
abstract class W3CriticalDOTEffect extends W3DamageOverTimeEffect
{
	protected var criticalStateType 		: ECriticalStateType;				//type of critical state
	protected saved var allowedHits 		: array<bool>;						//flags for allowed hit anims
	private var timeEndedHandled 			: bool;
	private var isDestroyedOnInterrupt 		: bool;								//if set then the buff will be removed when interrupted (actor will not get back to this state)
	private var canPlayAnimation 			: bool;								//set in some ocasions to false - when character finishes some action, this critical will not play it's animation again but it will work
	protected var blockedActions 			: array<EInputActionBlock>;			//list of actions blocked when in this critical state
	protected var postponeHandling 			: ECriticalHandling;				//what to do with the buff if it has to be postponed on add (cannot start anim imidiately)
	protected var airHandling 				: ECriticalHandling;				//what to do with the buff if target is in air while it's being applied
	protected var attachedHandling 			: ECriticalHandling;				//what to do with the buff if player is attached (boat, ladder, ledge)
	protected var onHorseHandling 			: ECriticalHandling;				//what to do with the buff if player is on horse
	public var explorationStateHandling 	: ECriticalHandling;				//what to do with the buff if player is in a complex state like sliding or rolling\
	private var usesFullBodyAnim			: bool;
	
		default criticalStateType 			= ECST_None;									//non-critical by default
		default isNegative 					= true;
		default timeEndedHandled 			= false;
		default isDestroyedOnInterrupt 		= false;
		default canPlayAnimation 			= true;
		default postponeHandling 			= ECH_Postpone;
		default airHandling 				= ECH_Postpone;
		default attachedHandling 			= ECH_HandleNow;
		default onHorseHandling 			= ECH_HandleNow;
		default	explorationStateHandling 	= ECH_Postpone;
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
	
	event OnUpdate(dt : float)
	{
		//if immune to all damage - finish the effect
		if(IsImmuneToAllDamage(dt))
		{
			timeLeft = 0;
			return true;
		}
		
		super.OnUpdate(dt);
	}
	
	public function OnTimeUpdated(deltaTime : float)
	{
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
			
			//if you have burning and some other higher priority CS, burning might get removed if you enter deep water
			if(!this)
				return;
		}
		
		// Deactivate the finisher if the time in critical effect left is too short to play the finish animation
		/*if( timeLeft <= 1 )
		{
			target.SignalGameplayEvent('DisableFinisher');
		}*/
		
		if(timeLeft <= 0 && !timeEndedHandled)
		{
			timeEndedHandled = true;
			target.SignalGameplayEvent('DisableFinisher');
			
			if(isOnPlayer)
				LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - timeout");
			
			//if this effect is currently animated
			if(isActive && this == target.GetCurrentlyAnimatedCS())
			{				
				target.RequestCriticalAnimStop();
			}
			else
			{
				LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
				
				if(isOnPlayer)
					LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - deactivating as it's not animated currently");
				
				isActive = false;			
			}
		}
		else if(timeLeft <= 0 && !target.IsAlive())
		{
			//if buff finished and target already dead
			if(isOnPlayer)
				LogCriticalPlayer("CriticalDOT.OnTimeUpdated() | " + this + " - isAlive set to false as target is dead");
				
			isActive = false;
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
		var params : W3BuffDoTParams;
		var perk20Bonus : SAbilityAttributeValue;
				
		//check if target is immune and don't add if so
		if(IsImmuneToAllDamage(100000))		//we need dt to calculate damage so here we pass INF dt to get INF damage to skip points terst and test only percent resist
		{
			isActive = false;
			return true;
		}
		//Perk 20 - decreases amount of bombs in stack, but increases their damage (including DoTs)
		params = (W3BuffDoTParams)customParams;
		
		if( params && params.isPerk20Active )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			effectValue.valueAdditive *= ( 1 + perk20Bonus.valueMultiplicative );
		}
			
		
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
				// Player
				if(isOnPlayer)
				{
					if( !thePlayer.CanReactToCriticalState() )
					{
						animHandling = explorationStateHandling;
					}
					// Vehicles
					else
					{
						veh = thePlayer.GetUsedVehicle();
						//boat
						if((W3Boat)veh)
						{
							//boatComp = (CBoatComponent)veh.GetComponentByClassName( 'CBoatComponent' );
							//boatComp.IssueCommandToDismount( DT_normal );
							animHandling = attachedHandling;
						}
						//horse
						else if(veh)
						{
							horseComp = ((CNewNPC)veh).GetHorseComponent();
							horseComp.OnCriticalEffectAdded( criticalStateType );
							animHandling = onHorseHandling;
						}	
						// No vehicle
						else
						{
							animHandling = ECH_HandleNow;
						}
					}
				}
				// Non player
				else
				{
					//normal anim start
					animHandling = ECH_HandleNow;
				}
			}
		}
		//higher priority buff is already being played
		else
		{
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
			theGame.VibrateControllerVeryHard();	//player got DoT CS
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
			LogCriticalPlayer("CriticalDOT.OnEffectRemoved() | " + this);
			LogCriticalPlayer("");
		}
			
		if(this == target.GetCurrentlyAnimatedCS())
			target.RequestCriticalAnimStop();
	}
	
	public final function UsesFullBodyAnim() : bool
	{
		return usesFullBodyAnim;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		//if duration is lower than used continuous DoT loop timer then don't apply DoT
		if(duration < 0.1f)
		{
			duration = 0.f;
			LogEffects("W3CriticalDOTEffect.CalculateDuration(): final duration is below 0.1, setting to 0");
		}
	}
}
