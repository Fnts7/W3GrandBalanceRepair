/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

// Base class for all buffs
// TODO: convert this object to IScriptable (right not not possible because Clone() is used)
// All properties with values different than it's default value are saved despite the "saved" keyword.
class CBaseGameplayEffect extends CObject
{
	// TIMING & UPDATE
	protected var timeActive : float;							//how long it is in ragdoll
	protected saved var initialDuration : float;				//base initial duration before power stat and resists are taken into account
	protected var duration : float;								//calculated final duration time in realtime secs, -1 means infinite
	protected var timeLeft : float;								//remaining duration
	protected var pauseCounters : array<SBuffPauseLock>;		//pause/resume locks for buff
	protected var isActive : bool;								//if the effect is active, if not then it's bound to be removed in next EffectManager's Update call
	private   var resistStat : ECharacterDefenseStats;			//resistance stat
	protected var resistance : float;	 						//resistance stat value in percents [0-1]
	protected var creatorPowerStat : SAbilityAttributeValue;	//creator's power stat value, used with resists to determine final duration
	protected var isPausedDuringDialogAndCutscene : bool;		//if true then effect is paused during cutscenes and dialogs
	protected var dontAddAbilityOnTarget : bool;				//if set then ability won't be added on target for the duration of the buff
	protected var canBeAppliedOnDeadTarget : bool;				//if buff can be applied if target is already dead
	protected var effectManager : W3EffectManager;				//target's effect manager
		
		default isActive = false;
		default duration = 0;
		default resistance = 0;
		default isPausedDuringDialogAndCutscene = true;
		default dontAddAbilityOnTarget = false;
		default canBeAppliedOnDeadTarget = false;

	//  STATS & CACHING	
	protected var isPositive : bool;							//if the effect is considered positive (buff)
	protected var isNeutral : bool;							// or neutral
	protected var isNegative : bool;							// or negative (debuff)
	
		default isPositive = false;
		default isNeutral = false;
		default isNegative = false;
	
	protected var isOnPlayer : bool;								//is this effect on player character?	
	protected var isSignEffect : bool;						//if true then this buff is a sign effect
	protected var isPotionEffect : bool;						//if true then this buff is a potion effect
	protected var abilityName : name;							//name of ability added on target
	protected  var attributeName : name;						//name of the attribute used to calculate effect value
	protected const var effectType : EEffectType;				//effect type
	protected var target : CActor;									//actor that has this effect applied
	protected var creatorHandle : EntityHandle;					//entity handle of the owner #DynSave check refs to GetOwner(), much issues, e.g. quest conditions won't work with damage buffs after load, etc.
	protected var effectValue : SAbilityAttributeValue;		//effect's strength (usage depends on buff type)
	protected var potionItemName : name;						//name of the potion which granted the buff if it's a potion buff

		default isPotionEffect = false;
		default isSignEffect = false;
		default abilityName = '';
		

	//  INTERACTION WITH OTHER EFFECTS
	protected var deny : array<EEffectType>;					//list of effects that this one denies
	protected var override : array<EEffectType>;				//list of effects that this one overrides
	protected var sourceName : string;						//source of this buff - same sources cumulate others create new instances of the same buff on target
	
	//  --==  UI  ==--
	
	//  FULLSCREEN CAMERA EFFECT
	protected var cameraEffectName : name;				//camera effect name
	protected var isPlayingCameraEffect : bool;			//if the effect is currently on, don't change in child classes, see below
	protected var switchCameraEffect : bool;			//set in child classes - if the camera effect should be switched (on -> off, off -> on)
	protected var isCameraEffectNameValid : bool;		//if the camera effect is set at all
	
		default isPlayingCameraEffect 	= false;
		default switchCameraEffect 		= true;
		
	//  HUD
	protected var iconPath : string;								//path to the icon file
	protected var showOnHUD : bool;									//if the icon should be shown on HUD
	protected var effectNameLocalisationKey : string;				//string database key for text holding this effect's name
	protected var effectDescriptionLocalisationKey : string;		//string database key for text holding this effect's description
	
		default showOnHUD = true;														//if we missed something in XMLs then this will help in catching it	
		default effectNameLocalisationKey = "MISSING_LOCALISATION_KEY_NAME";			//just to catch bugs
		default effectDescriptionLocalisationKey = "MISSING_LOCALISATION_KEY_DESC";		//just to catch bugs
	
	
	//  FX ON ACTOR
	protected var targetEffectName : name;						//name of the effect (particle) to attach to the target
	protected var shouldPlayTargetEffect : bool;				//if false then the effect should not be played for some reason
	
		default shouldPlayTargetEffect = true;
	
	//	SOUNDS
	private var onAddedSound, onRemovedSound : name;			//sounds to fire when effect is added/removed
	
	//  PAD RUMBLE
	protected var vibratePadLowFreq, vibratePadHighFreq : float;	//pad vibration params
	
		default vibratePadLowFreq = 0;
		default vibratePadHighFreq = 0;
		
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function Init(params : SEffectInitInfo)
	{
		var min, max, null : SAbilityAttributeValue;
		var durationSet : bool;
		var points : float;
		var dm : CDefinitionsManagerAccessor;
	
		EntityHandleSet(creatorHandle, params.owner);
		effectManager = params.targetEffectManager;
		target = params.target;	
		sourceName = params.sourceName;
		durationSet = false;
		isSignEffect = params.isSignEffect;
		
		if(params.vibratePadLowFreq > 0)
			vibratePadLowFreq = params.vibratePadLowFreq;
		if(params.vibratePadHighFreq > 0)
			vibratePadHighFreq = params.vibratePadHighFreq;
		
		//custom ability with stats
		if(IsNameValid(params.customAbilityName))
		{
			abilityName = params.customAbilityName;		
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributeValue(abilityName, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			durationSet = true;
		}
			
		if(params.duration != 0 && (!durationSet || (durationSet && duration == 0)) )	//duration might be set from ability which is more important than from inDuration in that case
			duration = params.duration;
			
		isOnPlayer = (CPlayer)target;
		target.GetResistValue(resistStat, points, resistance);
		
		if(params.powerStatValue == null)
			params.powerStatValue.valueMultiplicative = 1;					//if not set
		creatorPowerStat = params.powerStatValue;
			
		CalculateDuration(true);			//calculates duration based on time 'resistances' and duration bonus
		timeLeft = duration;
		
		if(!IsNameValid(params.customAbilityName) && (params.customEffectValue != null))
			effectValue = params.customEffectValue;		//if custom value but no custom ability
		else
			SetEffectValue();	
		
		if(IsNameValid(params.customFXName))
			targetEffectName = params.customFXName;
	}
		
	//called when the effect is loaded
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		target = t;
		effectManager = eff;
		isOnPlayer = (CR4Player)t;
		if(isOnPlayer && !IsPaused())
		{
			isPlayingCameraEffect 	= false;
			switchCameraEffect 		= true;
		}
	}
	
	// Calculates and sets final effect value
	protected function SetEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
	}
		
	/**
		SHOULD NOT BE CALLED from outside of effect manager !!!!
		
		Caches buff data read from XML
	*/
	public function CacheSettings()
	{
		var i,size : int;
		var tmpString : string;
		var dm : CDefinitionsManagerAccessor;
		var main,temp : SCustomNode;
		var tmpBool : bool;
		var tmpName, customAbilityName : name;
		var tmpFloat : float;		
		var type : EEffectType;		
							
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			EffectNameToType(tmpName, type, customAbilityName);
			if(effectType == type)
			{
				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', tmpName))
					iconPath = theGame.effectMgr.GetPathForEffectIconTypeName(tmpName);
				if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'showOnHUD', tmpBool))
					showOnHUD = tmpBool;
				
				//duration
				//cannot be cached since it can be random
								
				//ability name				
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'defaultAbilityName_name', tmpName))
					abilityName = tmpName;
									
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cameraEffectName_name', tmpName))
					cameraEffectName = tmpName;				
				if( !IsNameValid(targetEffectName) && dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'targetEffectName_name', tmpName))
					targetEffectName = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'resistStatName_name', tmpName))		
					resistStat = ResistStatNameToEnum(tmpName, tmpBool);
				if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'isPotionEffect', tmpBool))		
					isPotionEffect = tmpBool;
					
				//default potion stats, if potion and hostility not set at all
				if(isPotionEffect && !isPositive && !isNeutral && !isNegative)
				{
					isPositive = true;
					isNeutral = false;
					isNegative = false;
				}
					
				//sounds
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStartSound_name', tmpName))		
					onAddedSound = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStopSound_name', tmpName))		
					onRemovedSound = tmpName;	
					
				//localisation
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectNameLocalisationKey_name', tmpName))		
					effectNameLocalisationKey = tmpName;
				if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectDescriptionLocalisationKey_name', tmpName))		
					effectDescriptionLocalisationKey = tmpName;
					
				//buff interactions
				temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'denies');
				if(temp.values.Size() > 0)
				{
					size = temp.values.Size();
					for(i=0; i<size; i+=1)
					{
						if(IsNameValid(temp.values[i]))
						{
							EffectNameToType(temp.values[i], type, tmpName);
							deny.PushBack(type);
						}
					}
				}
				temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'overrides');
				if(temp.values.Size() > 0)
				{
					size = temp.values.Size();
					for(i=0; i<size; i+=1)
					{
						if(IsNameValid(temp.values[i]))
						{
							EffectNameToType(temp.values[i], type, tmpName);
							override.PushBack(type);
						}
					}
				}
	
				if(iconPath=="" && showOnHUD)
					LogEffects("BaseEffect.Initialize: Effect " + this + " should show in GUI but has no icon defined!");
					
				return;
			}			
		}

		//if here, then effect definition not found
		LogEffects("BaseEffect.Initialize: Cannot find GUI definitions in xml file for effect " + this);
	}
	
	//called when resists change and we need to recalc effect duration because of that
	public function RecalcDuration()
	{
		var prevDuration, points : float;
		
		if(duration == -1)
			return;
		
		//update resistance
		target.GetResistValue(resistStat, points, resistance);
		
		//update duration
		prevDuration = duration;
		CalculateDuration();
		
		//update time left		
		timeLeft = timeLeft * duration / prevDuration;
	}
	
	/**
		Calculates final duration of the effect
	*/
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var durationResistance : float;
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
		
		if(duration == 0)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributeValue(abilityName, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		
		if(setInitialDuration)
			initialDuration = duration;
	
		if( duration == -1)
			return;
			
		//multipliers of 'attacker' and 'defender'
		if(isNegative)
		{
			//for purpose of duration calculation we might have to cap resistances at 99%
			if(IsCriticalEffect(this))
				durationResistance = MinF(0.99f, resistance);
			else
				durationResistance = resistance;
				
			duration = MaxF(0, initialDuration * MaxF(0, creatorPowerStat.valueMultiplicative) * (1 - durationResistance) );
			LogEffects("BaseEffect.CalculateDuration: " + effectType + " duration with target resistance (" + NoTrailZeros(resistance) + ") and attacker power mul of (" + NoTrailZeros(creatorPowerStat.valueMultiplicative) + ") is " + NoTrailZeros(duration) + ", base was " + NoTrailZeros(initialDuration));
		}		
	}
	
	public function GetAbilityName() : name
	{
		return abilityName;
	}
	
	//called when effect was added on target, after making sure it added properly and EffectManger has added it to it's effects array
	event OnEffectAddedPost()
	{
		var localizationKey : string;
		
		if(target == thePlayer.GetTarget())
		{
			localizationKey = GetEffectNameLocalisationKey();
			
			if(localizationKey != "")
				target.ShowFloatingValue(EFVT_Buff, 0.f, false, localizationKey);
		}
	}
	
	/**
		Initializes instantiated buff data so IT MUST BE CALLED AS FIRST INSTRUCTION IF OVERRIDEN
		Called when the effect is being added to target. Actually it should be called OnEffectAdding()
	*/
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var i : int;
		var potParams : W3PotionParams;
			
		LogAssert(target, "OnEffectAdded: target is NULL!");
		isActive = true;		
		timeActive = 0.0f;
		
		//add abilities
		if(IsNameValid(abilityName) && !dontAddAbilityOnTarget)
			target.AddAbility(abilityName, true);	
				
		//character fx effect
		PlayTargetFX();
				
		//camera effect
		isCameraEffectNameValid = IsNameValid(cameraEffectName);		
		if(isOnPlayer && switchCameraEffect && isCameraEffectNameValid)
		{
			thePlayer.PlayEffectSingle(cameraEffectName);
			isPlayingCameraEffect = true;
			switchCameraEffect = false;
		}
		else
		{
			isPlayingCameraEffect = false;
		}
		
		//sound
		if(isOnPlayer && IsNameValid(onAddedSound))
			theSound.SoundEvent(onAddedSound);
				
		//pad vibration
		if(isOnPlayer && (vibratePadLowFreq > 0 || vibratePadHighFreq > 0) )
		{
			theGame.VibrateController(vibratePadLowFreq, vibratePadHighFreq, duration);
		}
		
		if(isPotionEffect)
		{
			potParams = (W3PotionParams)customParams;
			if(potParams)
				potionItemName = potParams.potionItemName;
		}
	
		LogEffects("BaseEffect.OnEffectAdded: effect " + this + " added to " + target + ", duration="+NoTrailZeros(duration));
	}
	
	/*
		Checks conditions and plays given target FX if possible. Makes sure that given FX won't be played
		more than once on target even if it is from different effects or same effects of different source type.
	*/
	protected function PlayTargetFX()
	{
		if(IsNameValid(targetEffectName) && shouldPlayTargetEffect)
		{				
			//play it only if not played already
			if(!effectManager.IsPlayingFX(targetEffectName))
			{
				target.DestroyEffectIfActive(targetEffectName);
				target.PlayEffect(targetEffectName);
			}
				
			//inform effect manager that we want to play fx
			effectManager.AddPlayedFX(targetEffectName, sourceName);
		}
	}
	
	/*
		Stops given FX effect.
	*/	
	protected function StopTargetFX()
	{
		if(IsNameValid(targetEffectName) && !shouldPlayTargetEffect)
		{			
			//stop it only if nothing else is playing it
			if(effectManager.ShouldStopFx(targetEffectName))
				target.StopEffect(targetEffectName);
				
			//inform effect manager that we no longer need fx
			effectManager.RemovePlayedFX(targetEffectName, sourceName);
		}
	}
	
	// Called when buff is removed from target
	event OnEffectRemoved()
	{
		var i : int;
	
		isActive = false;
		
		//remove abilities
		if(IsNameValid(abilityName))
			target.RemoveAbility(abilityName);
		
		//disable camera effect
		if(isOnPlayer && isPlayingCameraEffect && isCameraEffectNameValid)
			thePlayer.StopEffect(cameraEffectName);
		
		//target fx effect
		shouldPlayTargetEffect = false;
		StopTargetFX();
						
		//sound
		if(isOnPlayer && IsNameValid(onRemovedSound))
			theSound.SoundEvent(onRemovedSound);
			
		if(isOnPlayer && theGame.IsSpecificRumbleActive(vibratePadLowFreq, vibratePadHighFreq))
			theGame.RemoveSpecificRumble(vibratePadLowFreq, vibratePadHighFreq);
		
		LogEffects("BaseEffect.OnEffectRemoved: effect <<" + this + ">> removed from <<" + target + ">>");
	}
	
	// Called by Effect Manager to update this buff's status
	event OnUpdate(dt : float)
	{
		SwitchCameraEffect();
		PlayTargetFX();		
	}
	
	// Switches camera effect (on -> off, off ->on)
	private function SwitchCameraEffect()
	{
		//camera effect handling
		if(isCameraEffectNameValid && isOnPlayer && switchCameraEffect)
		{
			if(isPlayingCameraEffect)
				thePlayer.StopEffect(cameraEffectName);
			else
				thePlayer.PlayEffectSingle(cameraEffectName);
			
			isPlayingCameraEffect = !isPlayingCameraEffect;
			switchCameraEffect = false;
		}
	}
	
	public function OnTargetDeath()
	{
		target.RemoveEffect(this, true);
	}
	
	public function OnTargetUnconscious()
	{
		target.RemoveEffect(this, true);
	}
	
	public function OnTargetDeathAnimFinished(){}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////  BUFF INTERACTIONS  //////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	/*
		Gets interaction between two effects (how THIS effect reacts to the other one).
	*/
	public final function GetInteraction( effect : CBaseGameplayEffect) : EEffectInteract
	{
		var i,size : int;
		var tmp : EEffectInteract;
		
		//denies are strongest
		size = deny.Size();
		for(i=0; i<size; i+=1)
		{
			if(deny[i] == effect.effectType)
				return EI_Deny;
		}
		
		//overrides
		size = override.Size();
		for(i=0; i<size; i+=1)
		{
			if(override[i] == effect.effectType)
				return EI_Override;
		}
		
		//interaction with the same effect
		if(effectType == effect.effectType)
		{
			tmp = GetSelfInteraction(effect);
			if(tmp != EI_Undefined)
				return tmp;
		}
				
		//pass by default
		return EI_Pass;
	}
	
	// Gets interaction with another effect of the same type as this one. Decides "What will I do with the other effect?"
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var thisVal, otherVal : float;
		
		//potion effects granted by skill need to be overriden if we drink that potion while the skill's buff is active
		if( isPotionEffect && e.isPotionEffect && e.sourceName == "alchemy_s4" )
		{
			return EI_Override;
		}
		
		//if different sources return to check overrides and denies, if ok then pass
		if(sourceName != e.sourceName)
		{
			return EI_Undefined;
		}

		thisVal = GetEffectStrength();
		otherVal = e.GetEffectStrength();
		
		if(thisVal > otherVal)
		{
			return EI_Override;
		}
		else if(thisVal < otherVal)
		{
			return EI_Pass;				//allow to be overriden
		}
		else
		{
			//special case - if this is a critical effect with timeLeft<=0 (finishing) then don't override it - the animation stop has already begun and we cannot redraw that
			if(timeLeft <= 0 && IsCriticalEffect(this))
				return EI_Pass;
		
			if(timeLeft > e.timeLeft)
				return EI_Override;
			
			return EI_Cumulate;
		}
	}
	
	/*
		Gets how much the effect value would gain if THIS effect would be applied to target. This is called
		when deciding if given created but not applied effect should be added to target. The effect 
		strength depends on many things so such a function is needed. It is also needed because we need
		the final value of the effect to e.g. decide if an effect would cumulate or override with other.
	*/
	protected function GetEffectStrength() : float
	{
		//default, otherwise override
		return CalculateAttributeValue(effectValue);
	}
	
	/*
		Cumulation occurs *only* if the new effect has longer duration and *the same value and type*.
		Practically kind of a copy constructor - we take the stats of the new effect (later that effect
		is destroyed). This way we don't have to remove this effect and apply the new one (optimization).
		Also doing that would cause all OnEffectAdded/Removed functions to be called and e.g. we would
		get the start/end particles shown which is not desired.
	*/
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		timeLeft = effect.timeLeft;
		duration = effect.duration;
		isPotionEffect = effect.isPotionEffect;
		creatorHandle = effect.creatorHandle;
		sourceName = effect.sourceName;
		
		if(abilityName != effect.abilityName && !dontAddAbilityOnTarget)
		{
			target.RemoveAbility(abilityName);
			target.AddAbility(effect.abilityName);
		}
		
		abilityName = effect.abilityName;	//might be different / custom from new buff
		
		if(isOnPlayer)
		{
			vibratePadLowFreq = effect.vibratePadLowFreq;
			vibratePadHighFreq = effect.vibratePadHighFreq;
			
			if(vibratePadLowFreq > 0 || vibratePadHighFreq > 0)
				theGame.OverrideRumbleDuration(vibratePadLowFreq, vibratePadHighFreq, timeLeft);
		}
		
		//sound
		if(isOnPlayer && IsNameValid(onAddedSound))
			theSound.SoundEvent(onAddedSound);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////  OTHER  ///////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
		
	/**
		Called to update the effect's logic. If the time runs out final update *is* performed and the
		isActive var is set to false. On next EffectManager update the buff will be removed.
	*/
	public function OnTimeUpdated(dt : float)
	{	
		var toxicityThreshold : float;
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += dt;	
			if( duration != -1 )
			{
				timeLeft -= dt;				
				if( timeLeft <= 0 )
				{
					if(isPotionEffect && isOnPlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && effectType != EET_WhiteRaffardDecoction )				
					{
						toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity) * (1 - CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Alchemy_s03, 'toxicity_threshold', false, true) ) * thePlayer.GetSkillLevel(S_Alchemy_s03));
						if(thePlayer.GetStat(BCS_Toxicity, true) > toxicityThreshold)
						{
							//keep it going for as long as there is some toxicity left
						}
						else
						{
							isActive = false;
						}						
					}
					else
					{
						isActive = false;		//this will be the last call
					}
				}
			}
			OnUpdate(dt);	
		}
	}
	
	// Increases the pause lock-counter. If singleLock is set then the lock does not have counter - only on/off state.
	public function Pause( sourceName : name, optional singleLock : bool )
	{
		var i : int;
		var counter : SBuffPauseLock;
		
		for(i=0; i<pauseCounters.Size(); i+=1)
		{
			if(pauseCounters[i].sourceName == sourceName)
			{
				if(singleLock)
					pauseCounters[i].counter = 1;
				else
					pauseCounters[i].counter += 1;
					
				return;
			}
		}
		
		counter.sourceName = sourceName;
		counter.counter = 1;
		pauseCounters.PushBack(counter);
		
		shouldPlayTargetEffect = false;
		StopTargetFX();
		
		if(isPlayingCameraEffect)
		{
			switchCameraEffect = true;
			SwitchCameraEffect();	//since update will not call as effect will be paused in next tick
		}
		
		OnPaused();
	}
	
	protected function OnPaused(){}
	protected function OnResumed(){}
	
	public final function Resume( sourceName : name )
	{
		ResumeInternal(sourceName);
	}
	
	//Forcefully removes all locks from buff
	public final function ResumeForced()
	{
		ResumeInternal('', true);
	}
	
	private final function ResumeInternal(optional sourceName : name, optional forced : bool)
	{
		var i : int;
		
		for(i=pauseCounters.Size()-1; i>=0; i-=1)
		{
			if(forced || pauseCounters[i].sourceName == sourceName)
			{
				if(pauseCounters[i].counter == 1)
				{
					pauseCounters.EraseFast(i);
					
					shouldPlayTargetEffect = true;
					PlayTargetFX();
					switchCameraEffect = true;
					OnResumed();
				}
				else
				{
					pauseCounters[i].counter -= 1;
				}
				
				if(!forced)
					return;
			}
		}
	}
	
	public function IsPaused( optional sourceName : name ) : bool
	{
		var i : int;
	
		if(sourceName == 'None' )
		{
			return pauseCounters.Size() > 0;
		}
			
		for(i=0; i<pauseCounters.Size(); i+=1)
			if(pauseCounters[i].sourceName == sourceName)
				return true;

		return false;
	}
		
	// Returns current remaining duration of this buff
	public function GetDurationLeft() : float							{return timeLeft;}	
	
	// Returns *initial* duration of this buff (after resists)
	public function GetInitialDurationAfterResists() : float			{return duration;}	
	
	// Returns initial duration of this buff without resistances taken into consideration
	public function GetInitialDuration() : float 						{return initialDuration;}
	
	// Returns the entity that created and applied the effect on target
	public function GetCreator() : CGameplayEntity
	{
		return (CGameplayEntity)EntityHandleGet(creatorHandle);
	}
	
	public function IsPositive() : bool									{return isPositive;}
	public function IsNegative() : bool									{return isNegative;}
	public function IsNeutral() : bool									{return isNeutral;}
	public function ShowOnHUD() : bool									{return showOnHUD;}
	public function SetShowOnHUD( b : bool )							{ showOnHUD = b; }
	public function GetShowOnHUD() : bool								{return showOnHUD;}
	public function GetIcon() : string									{return iconPath;}
	public function IsActive() : bool									{return isActive;}	
	public function GetEffectNameLocalisationKey() : string				
	{
		var str: string;
		
		switch( effectType )
		{
			case EET_Mutagen01 :
			case EET_Mutagen02 :
			case EET_Mutagen03 :
			case EET_Mutagen04 :
			case EET_Mutagen05 :
			case EET_Mutagen06 :
			case EET_Mutagen07 :
			case EET_Mutagen08 :
			case EET_Mutagen09 :
				str = StrReplace( effectNameLocalisationKey, "effect_Mutagen0", "item_name_mutagen_" );
				str = StrReplace( str, "Effect", "" );
				return str;
			case EET_Mutagen10 :
			case EET_Mutagen11 :
			case EET_Mutagen12 :
			case EET_Mutagen13 :
			case EET_Mutagen14 :
			case EET_Mutagen15 :
			case EET_Mutagen16 :
			case EET_Mutagen17 :
			case EET_Mutagen18 :
			case EET_Mutagen19 :
			case EET_Mutagen20 :
			case EET_Mutagen21 :
			case EET_Mutagen22 :
			case EET_Mutagen23 :
			case EET_Mutagen24 :
			case EET_Mutagen25 :
			case EET_Mutagen26 :
			case EET_Mutagen27 :
			case EET_Mutagen28 :
				str = StrReplace( effectNameLocalisationKey, "effect_Mutagen", "item_name_mutagen_" );
				str = StrReplace( str, "Effect", "" );
				return str;
				
			default:
				break;
		}
		
		return effectNameLocalisationKey;
	}	
	
	public function GetEffectDescriptionLocalisationKey() : string		{return effectDescriptionLocalisationKey;}	
	public function GetEffectType() : EEffectType						{return effectType;}	
	public function IsPotionEffect() : bool								{return isPotionEffect;}
	public function IsSignEffect() : bool								{return isSignEffect;}
	public function SetTimeLeft(t : float)								{timeLeft = t;}
	public function GetTimeLeft() : float								{return timeLeft;}
	public function IsPausedDuringDialogAndCutscene() : bool			{return isPausedDuringDialogAndCutscene;}
	public function GetSourceName() : string							{return sourceName;}
	public function IsOnPlayer() : bool									{return isOnPlayer;}
	public function GetTimeActive() : float								{return timeActive;}
	public function CanBeAppliedOnDeadTarget() : bool					{return canBeAppliedOnDeadTarget;}
	public function GetResistStat() : ECharacterDefenseStats			{return resistStat;}
	public function GetBuffResist() : float								{return resistance;}
	
	public function GetBuffLevel() : int
	{
		var level : string;
			
		level = StrAfterLast(abilityName, "_");
		
		if(level == "Level3" || level == "3")
			return 3;
		else if(level == "Level2" || level == "2")
			return 2;
		else
			return 1;
	}
	
	public final function Debug_HAX_FIX(t : CActor)
	{
		target=t;
		EntityHandleSet(creatorHandle, t);
	}
	
	public final function RecalcPotionDuration()
	{
		var leftRatio, newDuration : float;
		
		if(!isPotionEffect)
			return;
		
		leftRatio = timeLeft / duration;
		newDuration = GetWitcherPlayer().CalculatePotionDuration(GetInvalidUniqueId(), (W3Mutagen_Effect)this, potionItemName);
		
		duration = newDuration;
		timeLeft = newDuration * leftRatio;
	}
	
	public function GetTargetEffectName() : name
	{
		return targetEffectName;
	}
	
	public function GetCreatorPowerStat() : SAbilityAttributeValue
	{
		return creatorPowerStat;
	}
	
	public function GetVibratePadLowFreq() : float
	{
		return vibratePadLowFreq;
	}
	
	public function GetVibratePadHighFreq() : float
	{
		return vibratePadHighFreq;
	}
	public function GetEffectValue() : SAbilityAttributeValue
	{
		return effectValue;
	}
	
	public function IsAddedByPlayer() : bool
	{
		var gpEnt : CGameplayEntity;
		var sign : W3SignEntity;
		var petard : W3Petard;
		
		gpEnt = GetCreator();
		
		if( gpEnt == thePlayer )
		{
			return true;
		}
		
		petard = (W3Petard)gpEnt;
		if( petard && petard.GetOwner() == thePlayer )
		{
			return true;
		}
		
		sign = (W3SignEntity)gpEnt;
		if( sign && sign.GetOwner() == thePlayer )
		{
			return true;
		}
		
		return false;
	}
}
