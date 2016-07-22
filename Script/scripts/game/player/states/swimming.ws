﻿
state Swimming in CR4Player extends ExtendedMovable
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// const variables
	public const var START_SWIMMING_WATER_LEVEL 	: float;
	public const var LEAVE_STATE_WATER_LEVEL 		: float;
	public const var LEAVE_STATE_SUBMERGE_DEPTH 	: float;
	public const var WALK_DEEP_WATER_LEVEL 			: float;
	public const var MIN_WATER_LEVEL_FOR_DIVING 	: float;
	public const var ENTER_DIVING_WATER_LEVEL 		: float;
	public const var EXIT_DIVING_WATER_LEVEL 		: float;
	public const var MINIMAL_SUBMERGE_DEPTH 		: float;
	
	default START_SWIMMING_WATER_LEVEL 	= 1.3;
	default LEAVE_STATE_WATER_LEVEL 	= 1.3;
	default LEAVE_STATE_SUBMERGE_DEPTH 	= -0.9; // needs to be less then 1 - which is walkToSwimCapsule offset
	default WALK_DEEP_WATER_LEVEL 		= 1.10;
	default MIN_WATER_LEVEL_FOR_DIVING 	= 1.95;
	default ENTER_DIVING_WATER_LEVEL 	= -1.6; 
	default EXIT_DIVING_WATER_LEVEL 	= -1.2;
	default MINIMAL_SUBMERGE_DEPTH 		= -25.0;
	
	//anim distances
	private const var jumpToWaterAnimDist	: float;
	private const var swimToIdleAnimDist	: float;
	
	default jumpToWaterAnimDist	= 6.3f;
	default swimToIdleAnimDist	= 1.35f;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// resources
	private var splashEntityTemplate : CEntityTemplate;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// private variables
	private var walkDeep 				: bool;
	private var swimming				: bool;
	private var diving					: bool;
	private var divingStarting 			: bool;
	private var swimStart 				: bool;
	private var unlimitedDiving			: bool;
	private var swimStagger				: bool;
	private var minSubmergeDepthReached : bool;
	private var inDivingState 			: bool;
	private var divingEnd 				: bool;
	private var blockPopState 			: bool;
	private var usePredicitonDepth 		: bool;
	private var divingEffectPlaying 	: bool;
	private var jumpToWaterInProgress 	: bool;
	private var startSwimPos			: Vector;
	
	private var isCiri					: bool;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter/Leave events
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// enter swimming
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		SwimmingInitGeneral( prevStateName );
		
		SwimmingLatentInit();
	} 
	
	// leaving swimming
	event OnLeaveState( nextStateName : name )
	{
		var item : SItemUniqueId;
		
		StateBlockInputActions(false);
		
		usePredicitonDepth = false;
		
		if ( nextStateName == 'AimThrow' )
		{
			//swimming = false;		//not sure why but it was before return on purpose so I leave it this way
			return super.OnLeaveState( nextStateName );
		}
		
		parent.RemoveAnimEventCallback('TurnOnDiving');
		parent.RemoveAnimEventCallback('AllowSwitchToDiving');
		
		EnableBuffImmunities(false);
		
		//just in case
		ToggleDiving(false);
		ToggleSwimming(false);
		swimming = false;	
		diving = false;	//this has to be after ToggleDiving as it's used inside!
		
		if ( nextStateName == 'TraverseExploration' )
		{
			parent.GetMovingAgentComponent().ResetMoveRequests();
		}
		
		parent.StopEffect('underwater_swimming');
		divingEffectPlaying = false;
		
		theGame.GetGameCamera().ResetCollisionOffset();
		
		parent.SetIsSwimming(false);
		parent.OnCombatActionEndComplete();
		
		theSound.SoundEvent("fx_underwater_off");
		
		// Capsule
		SetCapsuleToSwim( false );
		
		// deinit
		parentMAC.SetSwimming( false );
		parentMAC.SetDiving( false );
		((W3PlayerWitcher)parent).SetBIsCombatActionAllowed(true);
		thePlayer.UnblockAction(EIAB_Crossbow,'Diving');
		
		ResetVariables();
		
		if ( !thePlayer.IsSwimming() )
		{
			EnableRadialSlots();
		}
		//LogSwimming("on leave swimming");
		
		//unequip bodkin/harpoon bolt and equip harpoon/bodkin bolt when getting in/out of water IF uses infinite bolts
		if ( nextStateName != 'AimThrow')
		{
			GetWitcherPlayer().AddAndEquipInfiniteBolt(true);
			GetWitcherPlayer().ClearPreviouslyUsedBolt();
		}
		
		parent.PlayEffect('dripping_water');
		
		parent.GetMovingAgentComponent().SetEnabledFeetIK(true);
		
		// leave state
		super.OnLeaveState( nextStateName );
		
		//parent.RemoveAnimEventCallback('TurnOnDiving');
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Init section
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	entry function SwimmingLatentInit()
	{
		//change behavior graph
		parent.ActivateAndSyncBehavior('PlayerSwimming');
		
		//turn on retarget animations for ciri
		if ( (W3ReplacerCiri)parent )
		{
			parent.SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
			isCiri = true;
		}
		else
			isCiri = false;
		
		if ( parent.IsRagdolled() )
		{
			parent.SetBehaviorVariable( 'recoverFromRagdoll', 1.f );
		}
		else
		{
			parent.SetBehaviorVariable( 'recoverFromRagdoll', 0.f );
			PredictWaterDepth(parent.GetWorldPosition() + parent.GetHeadingVector()* jumpToWaterAnimDist);
			if ( predictedWaterDepth < 9999 && predictedWaterDepth >= START_SWIMMING_WATER_LEVEL )
				parent.SetBehaviorVariable('bCanJumpToWater',1.f);
			else
				parent.SetBehaviorVariable('bCanJumpToWater',0.f);
		}
		
		if ( thePlayer.IsHoldingItemInLHand() )
		{
			HideUsableItemL();
		}
	}
	
	// swimming init
	function SwimmingInitGeneral( prevStateName : name )
	{
		theInput.SetContext( 'Swimming' );
		
		StateBlockInputActions(true);
		
		//setup camera
		TurnOnSwimmingCamera();
		
		parent.GetMovingAgentComponent().SetEnabledFeetIK(false);
		
		parent.SetBIsInCombatAction(false);
		
		parent.findMoveTargetDist = parent.findMoveTargetDistMax;
		
		//set required items
		parent.OnMeleeForceHolster(true);
		
		parent.HideUsableItem(true);
		
		// Hide weapon
		thePlayer.OnEquipMeleeWeapon( PW_None, true );
		
		if ( prevStateName == 'DismountHorse' )
		{
			parent.SetIsInAir( true );
		}
		
		if ( prevStateName == 'AimThrow' )
		{
			SwimmingInitAfterAimThrow();
		}
		else
		{
			SwimmingInitNormal( prevStateName );
		}
	}
	
	
	function SwimmingInitNormal( prevStateName : name )
	{
		if ( !splashEntityTemplate )
			splashEntityTemplate = (CEntityTemplate)LoadResource('water_splashes');
		
		// store start pos
		startSwimPos = parent.GetWorldPosition();
		
		if ( !thePlayer.IsSwimming() )
		{
			DisableRadialSlots();
		}
		
		parent.AddAnimEventCallback('TurnOnDiving','OnAnimEvent_TurnOnDiving');
		parent.AddAnimEventCallback('AllowSwitchToDiving','OnAnimEvent_AllowSwitchToDiving');
		
		parent.StopEffect('dripping_water');
		
		ResetVariables();
		
		EnableBuffImmunities(true);
		
		// Capsule
		SetCapsuleToSwim( true );
		
		theTelemetry.LogWithName(TE_STATE_SWIMMING);
		
		ShouldSpawnWaterSplash(prevStateName);
		
		if ( parent.IsRagdolled() )
		{
			ToggleDiving( true );
			theInput.SetContext('Diving');		
		}
		
		GetWitcherPlayer().AddAndEquipInfiniteBolt(false, true);
	}
	
	//swimming reinit when we get back from AimThrow state
	function SwimmingInitAfterAimThrow()
	{
		if ( diving )
		{
			TurnOnDivingCamera();
			theInput.SetContext('Diving');		
		}
	}
	
	private latent function HideUsableItemL ()
	{
		while ( true )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.OnUseSelectedItem( true );
				return;
			}
			Sleep( 0.1f );
		}
	}
	private function DisableRadialSlots()
	{
		var slotsToBlock : array<name>;
		
		slotsToBlock.PushBack( 'Yrden' );
		slotsToBlock.PushBack( 'Quen' );
		slotsToBlock.PushBack( 'Igni' );
		slotsToBlock.PushBack( 'Axii' );
		slotsToBlock.PushBack( 'Aard' );
		slotsToBlock.PushBack( 'Slot1' );
		slotsToBlock.PushBack( 'Slot2' );
		slotsToBlock.PushBack( 'Slot3' );
		slotsToBlock.PushBack( 'Slot4' );
		slotsToBlock.PushBack( 'Slot5' );
		
		
		parent.EnableRadialSlotsWithSource ( false, slotsToBlock, 'swimming' );
	}
	
	private function EnableRadialSlots()
	{
		var slotsToBlock : array<name>;
		
		slotsToBlock.PushBack( 'Yrden' );
		slotsToBlock.PushBack( 'Quen' );
		slotsToBlock.PushBack( 'Igni' );
		slotsToBlock.PushBack( 'Axii' );
		slotsToBlock.PushBack( 'Aard' );
		slotsToBlock.PushBack( 'Slot1' );
		slotsToBlock.PushBack( 'Slot2' );
		slotsToBlock.PushBack( 'Slot3' );
		slotsToBlock.PushBack( 'Slot4' );
		slotsToBlock.PushBack( 'Slot5' );
		
		
		parent.EnableRadialSlotsWithSource ( true, slotsToBlock, 'swimming' );
	}
	private function ResetVariables()
	{
		walkDeep 				= false;
		swimming				= false;
		diving					= false;
		divingStarting 			= false;
		swimStart 				= false;
		swimStagger				= false;
		minSubmergeDepthReached = false;
		inDivingState 			= false;
		divingEnd 				= false;
		blockPopState 			= false;
		usePredicitonDepth 		= false;
		jumpToWaterInProgress	= false;
		blockDiveDown			= false;
	}
	
	private function EnableBuffImmunities( enable : bool )
	{
		if ( enable )
		{
			parent.AddBuffImmunity_AllCritical('Swimming',true);
		}
		else
		{
			parent.RemoveBuffImmunity_AllCritical('Swimming');
		}
	}
	
	private function SetCapsuleToSwim( _swimming : bool )
	{
		var mac	: CMovingPhysicalAgentComponent;
		
		
		if( _swimming )
		{
			parent.GetMovingAgentComponent().SetVirtualRadius( 'SwimmingRadius' );
		}
		else
		{
			parent.GetMovingAgentComponent().ResetVirtualRadius();
		}
		
		parentMAC.EnableVirtualControllerCollisionResponse( 'Swimming', _swimming );	
	}
	
	
	
	//Block Input section
	private function StateBlockInputActions( toggle : bool )
	{
		if ( toggle )
		{
			parent.BlockAction(		EIAB_DrawWeapon,	'SwimmingState');
			parent.BlockAction(		EIAB_Signs,			'SwimmingState');
			parent.BlockAction(		EIAB_CallHorse,		'SwimmingState');
			parent.BlockAction(		EIAB_ThrowBomb,		'SwimmingState');
		}
		else
		{
			parent.BlockAllActions( 'SwimmingState', false );
		}
	}
	
	private function ShouldSpawnWaterSplash( optional prevState : name)
	{
		var fallDist : float;
		
		if ( prevState == 'AimThrow' )
			return;
		
		// check if player jumped to water
        if ( parent.GetFallDist(fallDist) )
        {
			if ( fallDist > 2.f && CheckWaterDepth(START_SWIMMING_WATER_LEVEL) )
			{
				SpawnWaterSplash('man_water_splash');
				if ( theInput.IsActionPressed('DiveDown') && CheckWaterDepth(MIN_WATER_LEVEL_FOR_DIVING) )
					parent.SetBehaviorVariable( 'divePitch',-1.0);
			}
			else
				SpawnWaterSplash('splash_small');
		}
		else if ( prevState == 'DismountHorse' )
		{
			SpawnWaterSplash('splash_small');
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Main loop section
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnPlayerTickTimer( deltaTime : float )
	{
		virtual_parent.OnPlayerTickTimer( deltaTime );
		
		SwimmingLoop(deltaTime);
		
		ProcessPlayerOrientation();
		
		if ( diving && theGame.GetGameCamera().GetActivePivotRotationController().controllerName != 'Diving' )
		{
			TurnOnDivingCamera();
		}
		
		if ( swimming && !CheckIdle() && !diving )
			UpdatePitch();
		
		if ( thePlayer.IsHoldingItemInLHand() )
		{
			thePlayer.HideUsableItem( true );
		}
	    if ( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'silversword' ) )
	    {
			// Hide weapon
			thePlayer.OnEquipMeleeWeapon( PW_None, true );
	    }
	    
		if (!diving)
			CalculateWindPower();
		else
			windPower = 0.f;
	}
	
	private var currentWaterDepth : float;
	private function SwimmingLoop( dt : float )
	{
		var waterDepth, submergeDepth : float;
		
		currentWaterDepth = GetWaterDepth();
		submergeDepth = GetSubmergeDepth();
		
		// get water level
		if ( usePredicitonDepth && predictedWaterDepth != 10000 )
		{
			waterDepth = this.predictedWaterDepth;
		}
		else
		{
			waterDepth = currentWaterDepth;
		}
		
		if ( parent.IsInAir() || jumpToWaterInProgress || divingStarting )
		{
			if( !diving && submergeDepth < ENTER_DIVING_WATER_LEVEL )
			{
				ToggleDiving(true);
			}
			if ( !diving )
			{
				if ( submergeDepth < LEAVE_STATE_SUBMERGE_DEPTH )
				{
					ToggleSwimming(true);
					parent.SetIsInAir(false);
				}
			}
			else if ( submergeDepth < ENTER_DIVING_WATER_LEVEL )
			{
				parent.SetIsInAir(false);
			}
		}
		else if ( waterDepth > 0 && submergeDepth <= LEAVE_STATE_SUBMERGE_DEPTH && waterDepth != 10000 )
		{
			if ( waterDepth <= LEAVE_STATE_WATER_LEVEL )//0.9
			{
				LogChannel( 'Swimming', "leaving water at depth: " + submergeDepth );
				
				if ( !swimming && !diving )
					TryToPopState();
					
				ToggleSwimming(false);
				ToggleWalkDeep(false);
				ToggleDiving(false);
				
			}
			else if ( waterDepth < WALK_DEEP_WATER_LEVEL )
			{
				ToggleSwimming(false);
				ToggleWalkDeep(false);
			}
			else if ( !IsSwimmingAllowed() )
			{
				return;
			}
			else if ( waterDepth < START_SWIMMING_WATER_LEVEL )
			{
				ToggleSwimming(false, true);
				ToggleWalkDeep(true);
			}
			else if ( !swimming )
			{
				/*if ( dt == 0 && id == 0 ) //first call only
				{
					if( !diving && submergeDepth < ENTER_DIVING_WATER_LEVEL )
					{
						ToggleDiving(true);
					}
					if ( !diving )
					{
						ToggleSwimming(true,true);
						parent.AddTimer('SetSwimming',0.1,false);
					}
				}
				else*/
				{
					ToggleSwimming(true);
				}
			}
		}
		else if ( submergeDepth > LEAVE_STATE_SUBMERGE_DEPTH ) 
		{
			LogChannel( 'Swimming', "leaving water at depth: " + submergeDepth );
			
			if ( !swimming && !diving )
				TryToPopState();
				
			ToggleSwimming(false);
			ToggleWalkDeep(false);
			ToggleDiving(false);
		}
		else if ( !IsSwimmingAllowed() )
		{
			return;
		}
		else if ( !swimming )
		{
			/*if ( dt == 0 && id == 0 ) //first call only
			{
				ToggleSwimming(true,true);
				parent.AddTimer('SetSwimming',0.1,false);
			}
			else*/
			{
				ToggleSwimming(true);
			}
			ToggleWalkDeep(false);
		}
		
		if ( swimming || diving )
		{
			FailSafeVerify();
			
			if ( !jumpToWaterInProgress )
				ShouldGoDiving(submergeDepth);
			
			if( diving )
			{
				if( submergeDepth < -3.0 )
				{
					if( !divingEffectPlaying )
					{
						parent.PlayEffect('underwater_swimming');
						divingEffectPlaying = true;
					}
				}
				else
				{
					parent.StopEffect('underwater_swimming');
					divingEffectPlaying = false;
				}
			}	
		}
		
		if ( !unlimitedDiving && submergeDepth < MINIMAL_SUBMERGE_DEPTH )
		{
			ReleaseDiveDown();
			minSubmergeDepthReached = true;
		}
		else
			minSubmergeDepthReached = false;
	}
	
	private function FailSafeVerify()
	{
		var currentContext : name = theInput.GetContext();
		
		//physcial state
		if ( parentMAC.GetPhysicalState() != CPS_Swimming )
		{
			if ( diving ) 
				parentMAC.SetDiving(true);
			else if ( swimming )
				parentMAC.SetSwimming(true);
		}
		
		// input context
		/*if ( diving )
		{
			if ( currentContext != 'Diving' )
			{
				theInput.SetContext('Diving');
			}
		}
		else if ( swimming )
		{
			if ( currentContext != 'Swimming' )
			{
				theInput.SetContext('Swimming');
			}
		}*/
	}
	
	private function UpdatePitch()
	{
		var currentPosition : Vector;
		var frontPoint		: Vector;
		var backPoint		: Vector;
		var frontWaterLevel : float;
		var backWaterLevel : float;
		var delta : float;
		var pitch : float;
		
		currentPosition = parent.GetWorldPosition();
		
		frontPoint = currentPosition + parent.GetHeadingVector()*0.5;
		backPoint = currentPosition - parent.GetHeadingVector()*0.5;
		
		frontWaterLevel = theGame.GetWorld().GetWaterLevel(frontPoint, true);
		backWaterLevel = theGame.GetWorld().GetWaterLevel(backPoint, true);
		
		if ( frontWaterLevel >= 10000 || backWaterLevel >= 10000 )
			pitch = 0.f;
		else
		{
			delta = frontWaterLevel - backWaterLevel;
			pitch = Rad2Deg( AtanF( delta, 1 ) );
		}
		//pitch *= 1.5;
		parent.SetBehaviorVariable('swimmingPitchCorrection',pitch);
		//LogSwimming("swimmingPitchCorrection: " + pitch);
	}
	
	private function TryToPopState()
	{
		if ( !blockPopState && !swimStart )
		{
			//we need OnEnterShallowWater couse we need to blend to proper anim
			parent.OnEnterShallowWater();
			parent.GotoStateAuto();
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @Functions
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	public function ShouldDrainStamina() : bool
	{
		var currentArea : EAreaName;
		
		currentArea = theGame.GetCommonMapManager().GetCurrentArea();
		
		//if ( !IsInTroubledWater() && ( currentWaterDepth < 8 || currentArea == AN_Prologue_Village ) )
		if ( !IsInTroubledWater() || currentArea == AN_Prologue_Village )
			return false;
		
		return true;
	}
	
	public function IsInColdWater() : bool
	{
		var currentArea : EAreaName;
		
		currentArea = theGame.GetCommonMapManager().GetCurrentArea();
		
		switch( currentArea )
		{
			case AN_Skellige_ArdSkellig:
				return true;
				
			case AN_Island_of_Myst:
				return true;
				
			default:
				return false;
		}
	}
	
	public function IsInTroubledWater() : bool
	{
		return windPower >= 0.5;
	}
	
	public function GetWindPower() : float
	{
		return windPower;
	}
	
	public function GetWaterDepth() : float
	{
		return theGame.GetWorld().GetWaterDepth(parent.GetWorldPosition(), true);
	}
	
	public function CheckIdle() : bool
	{
		return parent.rawPlayerSpeed == 0 && theInput.IsActionReleased('DiveDown') && theInput.IsActionReleased('DiveUp');
	}
	
	public function EnableUnlimitedDiving( enable : bool )
	{
		unlimitedDiving = enable;
	}
	
	public function IsSwimmingAllowed() : bool
	{
		return true;
		// if need we can check water type here
		/*var materialName : name;
		materialName = parentMAC.GetMaterialName();
		
		if ( materialName == 'SomeSwampMaterialName' )
			return false;
		
		return true;*/
	}
	
	private function ToggleWalkDeep( toggle : bool )
	{
		if( toggle && !walkDeep )
		{
			parent.SetBehaviorVariable( 'walkDeep', 1.0f);
			walkDeep = true;
		}
		else if( !toggle && walkDeep )
		{
			parent.SetBehaviorVariable( 'walkDeep', 0.0f);
			walkDeep = false;
		}
	}
	
	private function ToggleSwimming( toggle : bool, optional ignorePAC : bool )
	{
		if ( toggle && !swimming )
		{
			parent.OnRangedForceHolster( true );
			parent.SetIsSwimming(true);
			SetBehaviorGraphVariables( 1.f );
			ToggleWalkDeep(false);
			swimming = true;
			if ( !ignorePAC )
				parentMAC.SetSwimming( true );
			LogChannel( 'Swimming', "Swimming started.");
			parent.AddEffectDefault(EET_StaminaDrainSwimming, parent, 'Swimming');
		}
		else if ( !toggle && swimming )
		{
			parent.SetIsSwimming(false);
			SetBehaviorGraphVariables( 0.0f );
			swimming = false;
			swimStart = false;
			if ( !ignorePAC )
				parentMAC.SetSwimming( false );
			LogChannel( 'Swimming', "Swimming ended.");
			parent.RemoveBuff(EET_StaminaDrainSwimming);
		}
	}
	
	private var cachedVerCameraTimeout : float;
	
	private function ToggleDiving( toggle : bool )
	{
		var slotsToBlock : array<name>;
		var displayTargetActor : CActor;
			
		if ( toggle && !diving )
		{
			swimStart = false;
			parent.SetBehaviorVariable( 'diving', 1.f);
			diving = true;
			parent.StartAirRegen();
			parent.PauseEffects(EET_AutoAirRegen,'Diving',true);
			parent.AddEffectDefault(EET_AirDrainDive, NULL, 'Diving');
			parent.AddEffectDefault(EET_StaminaDrainSwimming, NULL, 'Swimming');
			parentMAC.SetDiving( true );
			LogSwimming("Entered Diving");
			TurnOnDivingCamera();
			theInput.SetContext('Diving');
			ToggleSwimStagger(false);
			
			cachedVerCameraTimeout = theGame.GetGameCamera().GetManualRotationVerTimeout();
			theGame.GetGameCamera().SetManualRotationVerTimeout(9999.f);
			
			slotsToBlock.PushBack( 'Slot3' );
			thePlayer.EnableRadialSlotsWithSource ( true, slotsToBlock, 'swimming' );
		}
		else if ( !toggle && diving )
		{
			parent.OnRangedForceHolster(false,true,true);
			if ( parent.RaiseEvent('DiveEnd') )
				divingEnd = true;
			
			thePlayer.UnblockAction(EIAB_Crossbow,'Diving');
			
			parent.SetBehaviorVariable( 'diving', 0.f);
			parent.SetBehaviorVariable( 'cameraPitch', 0.f);
			parent.SetBehaviorVariable( 'divePitch',0.f);
			if ( thePlayer.IsSprintActionPressed() )
				parent.SetIsSprinting(true);
			diving = false;
			parent.RemoveBuff(EET_AirDrainDive);
			parent.RemoveBuff(EET_Drowning);
			parent.ResumeEffects(EET_AutoAirRegen,'Diving');
			parent.RemoveBuff(EET_StaminaDrainSwimming);
			parentMAC.SetDiving( false );
			//parent.GetMovingAgentComponent().ResetHeight();
			theGame.GetGameCamera().ChangePivotRotationController( 'Swimming' );
			theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
			theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
			theInput.SetContext('Swimming');
			thePlayer.SoundEvent('g_swim_emerge');
			LogSwimming("Left Diving");
			theGame.GetGameCamera().SetManualRotationVerTimeout(cachedVerCameraTimeout);
			slotsToBlock.PushBack( 'Slot3' );
			thePlayer.EnableRadialSlotsWithSource ( false, slotsToBlock, 'swimming' );		
		}
		
		displayTargetActor = (CActor)( parent.GetDisplayTarget() );	
		
		if ( parent.IsHardLockEnabled() 
			&& displayTargetActor 
			&& !parent.CanBeTargetedIfSwimming( displayTargetActor ) )
			parent.HardLockToTarget( false );		
	}
	
	private timer function SetSwimming( dt : float, id : int )
	{
		if ( swimming )
			parentMAC.SetSwimming( true );
	}
	
	private function ShouldGoDiving( depth : float )
	{	
		if( !diving && !divingEnd && depth < ENTER_DIVING_WATER_LEVEL )
		{
			if ( swimming )
				OnDive();
			else
				ToggleDiving(true);
			
		}
		else if ( !divingStarting && diving )
		{
			if ( inDivingState && depth > EXIT_DIVING_WATER_LEVEL || !inDivingState && ( depth > EXIT_DIVING_WATER_LEVEL - 0.8 ) )
				ToggleDiving(false);
		}
		if ( diving )
		{
			if ( depth > EXIT_DIVING_WATER_LEVEL - 0.8 ) 
			{
				thePlayer.BlockAction(EIAB_Crossbow,'Diving');
			}
			else
			{
				thePlayer.UnblockAction(EIAB_Crossbow,'Diving');
			}
		}
	}
	/*private function ShouldGoSwimming()
	{
		var depth : float;
		depth = theGame.GetWorld().GetWaterDepth(parent.GetWorldPosition());
		if( !swimming && depth >= START_SWIMMING_WATER_LEVEL )
		{
			ToggleSwimming(true);
		}
	}*/
	
	private function SpawnWaterSplash( splash : name )
	{
		var splashPosition 	: Vector;
		var splashEntity 	: CEntity;
		
		if ( splashEntityTemplate )
		{
			splashPosition = parent.GetWorldPosition();
			splashPosition.Z = theGame.GetWorld().GetWaterLevel(splashPosition, true) - 0.1;
			
			splashEntity = theGame.CreateEntity(splashEntityTemplate, splashPosition, parent.GetWorldRotation());
			splashEntity.PlayEffect(splash);
			splashEntity.DestroyAfter(5.f);
		}
	}
	
	private function ReleaseDiveDown() : bool
	{
		if ( theInput.IsActionPressed('DiveDown') )
		{
			theInput.ForceDeactivateAction('DiveDown');
			parent.RaiseEvent('TouchedBottom');
			return true;
		}
		return false;
	}
	
	private function GetSubmergeDepth() : float
	{
		return parentMAC.GetSubmergeDepth();
	}
	
	private function CheckWaterDepth( minDepth : float ) : bool
	{
		var depth : float;
		
		depth = currentWaterDepth;
		if ( depth >= minDepth )
			return true;
		else if ( depth < 0 )
			return true;
		
		return false;
	}
	
	//emerge speed section
	private var defaultEmergeSpeed :  float;
	private function ChangeEmergeSpeed( value : float)
	{
		if ( defaultEmergeSpeed <= 0 )
			defaultEmergeSpeed = parentMAC.GetEmergeSpeed();
			
		parentMAC.SetEmergeSpeed( value );
	}
	private function ResetEmergeSpeed()
	{
		parentMAC.SetEmergeSpeed( defaultEmergeSpeed );
	}
	
	private var windPower : float;
	private function CalculateWindPower()
	{
		var tempWindPower : float;
		var water_depthDiff : float;

		water_depthDiff = PowF( ClampF( currentWaterDepth/12.0f, 0.0f, 1.0f ), 1.4f );
		tempWindPower = VecLength( theGame.GetWindAtPointForVisuals( parent.GetWorldPosition() ) );
		
		windPower = tempWindPower * LerpF( water_depthDiff, 0.05f, 1.0f );
		LogChannel('WindPower',windPower);
	}
	
	private function ToggleSwimStagger( toggle : bool )
	{
		if ( toggle && !diving )
		{
			parent.SetBehaviorVariable( 'swimStagger',1.f);
			parent.BlockAction( EIAB_Movement, 'swimStagger' );
		}
		else if ( !toggle && diving )
		{
			parent.SetBehaviorVariable( 'swimStagger',0.f);
			parent.BlockAllActions( 'swimStagger', false );
		}
	}
	
	timer function SwimmingStagger( dt : float , id : int)
	{
		ToggleSwimStagger(false);
	}
	
	private function SetBehaviorGraphVariables( f : float )
	{
		var animSpeedMult : float;
		
		if ( f <= 0.f )
			animSpeedMult = 1.f;
		else
			animSpeedMult = 0.75f;		//MS: Slow player crossbow overlay and crossbow anims down when in water
		
		parent.SetBehaviorVariable( 'isSwimming', f );
		parent.SetBehaviorVariable( 'animSpeedMultForOverlay', animSpeedMult );
	}
	
	private var predictedWaterDepth : float;
	function PredictWaterDepth( pos : Vector )
	{
		predictedWaterDepth = theGame.GetWorld().GetWaterDepth(pos);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @Events
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////
	////// from code events //////
	
	event OnOceanTriggerLeave()
	{
		virtual_parent.OnOceanTriggerLeave();
		
		SetBehaviorGraphVariables( 0.0f );
		parent.RaiseForceEvent( 'FromSwimming' );
		parent.RaiseForceEvent( 'SwimmingStop' );
		parent.GotoStateAuto();
	}
	
	event OnDivingEnd()
	{
		if ( !diving )
		{
			SpawnWaterSplash('man_surfacing_splash');
			parent.GetMovingAgentComponent().ResetHeight();
		}
	}
	
	event OnTeleportToStartPos()
	{
		parent.Teleport(startSwimPos);
		parent.RaiseForceEvent('ToAwake');
	}
	
	event OnTeleportToStartPosEnd()
	{
		parent.SetIsMovable(true);
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetSwimming( false );
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetAnimatedMovement( false );
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetGravity( true );
	}
	
	
	private var blockDiveDown : bool;
	event OnWaterBottomTouch()
	{
		if ( diving )
		{
			blockDiveDown = true;
			parent.AddTimer('ReleaseBlockDiveDown',0.1,false);
			if ( ReleaseDiveDown() )
			{
				LogSwimming("Touched Bottom");
			}
		}
	}
	
	timer function ReleaseBlockDiveDown( dt : float, id : int )
	{
		blockDiveDown = false;
	}
	
	////////////////////////////////
	////// from script events //////
	
	event OnParentSpawned()
	{
		if ( !splashEntityTemplate )
			splashEntityTemplate = (CEntityTemplate)LoadResource('water_splashes');
	}
	
	event OnDiveInput( divePitch : float )
	{
		//var rotController : ICustomCameraPivotRotationController;
		 
		if ( diving )
		{
			theGame.GetGameCamera().ForceManualControlVerTimeout();
			theGame.GetGameCamera().ForceManualControlHorTimeout();
		}
	}
	
	event OnEmptyStamina()
	{
		/*ToggleSwimStagger(true);
		parent.AddEffectDefault(EET_Drowning,parent,"NoStamina");*/
	}
	
	event OnAllowShallowWaterCheck()
	{
		return !swimming && !diving && !walkDeep;
	}
	
	event OnCheckDiving()
	{
		return diving;
	}
	
	event OnAllowSwimmingSprint()
	{
		return (swimming || diving) && !CheckIdle() && parent.IsRunPressed();
	}
	
	event OnAllowedDiveDown()
	{
		if ( !diving )
			return true;
			
		return !minSubmergeDepthReached && !blockDiveDown;
	}
	
	event OnDiving(dir : int)
	{
		return true;
	}
	
	event OnDive()
	{
		if ( !diving && swimming && !parent.HasBuff(EET_Drowning) )
		{
			theInput.ForceDeactivateAction('DiveUp');
			if ( CheckWaterDepth(MIN_WATER_LEVEL_FOR_DIVING) )
			{
				if ( !runJumpInProgress && parent.RaiseEvent( 'Dive' ) )
				{
					return true;
				}
			}
			else
			{
				if ( parent.RaiseEvent( 'DiveFail' ) )
				{
					SpawnWaterSplash('man_surfacing_splash');
					return false;
				}
			}
			
		}
		return false;
	}
	
	///////////////////////////////////
	////// Behavior graph events //////
	
	var runJumpInProgress : bool;
	
	event OnRunJumpStart()
	{
		runJumpInProgress = true;
	}
	
	event OnRunJumpEnd()
	{
		runJumpInProgress = false;
	}
	
	event OnHitAnimationStart()
	{
		if ( CheckWaterDepth(2.f) )
		{
			divingStarting = true;
			parent.SetBIsCombatActionAllowed( false );
			ToggleDiving(true);
		}
	}
	
	event OnDiveAnimationStart()
	{
		divingStarting = true;
		parent.SetBIsCombatActionAllowed( false );
		ToggleDiving(true);
		jumpToWaterInProgress = false;
	}
	
	event OnDiveAnimationEnd()
	{
		divingStarting = false;
		parent.SetBIsCombatActionAllowed( true );
		parent.SetBIsInCombatAction(false);
		parent.GetMovingAgentComponent().SetHeight( 1.0f );
	}
	
	event OnDivingStateStart()
	{
		inDivingState = true;
		parent.GetMovingAgentComponent().SetHeight( 1.0f );
	}
	
	event OnDivingStateStop()
	{
		inDivingState = false;
		parent.GetMovingAgentComponent().ResetHeight();
	}
	
	event OnSwimStart()
	{
		divingEnd = false;
		swimStart = true;
		if ( !swimming )
			parentMAC.SetSwimming( true );
	}
	
	event OnSwimEnd()
	{
		swimStart = false;
	}
	
	event OnIdleStart()
	{
		swimStart = false;
		parent.SetIsInAir(false);
		if ( !swimming )
		{
			parentMAC.SetSwimming( false );
		}
	}
	
	event OnIdleEnd()
	{
		
	}
	
	event OnDivingEndStart()
	{
		divingEnd = true;
	}
	
	event OnDivingEndStop()
	{
		divingEnd = false;
	}
	
	event OnJumpToWaterStart()
	{
		jumpToWaterInProgress = true;
	}
	
	event OnJumpToDiveStart()
	{
		divingStarting = true;
	}
	
	event OnJumpToWaterEnd()
	{
		parent.SetIsInAir(false);
		divingStarting = false;
		jumpToWaterInProgress = false;
	}
	
	
	event OnSwimToIdleStart()
	{
		blockPopState = true;
		PredictWaterDepth(parent.GetWorldPosition() + parent.GetHeadingVector()* swimToIdleAnimDist);
		usePredicitonDepth = true;
	}
	
	event OnSwimToIdleEnd()
	{
		blockPopState = false;
		usePredicitonDepth = false;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @Combat @Dodge
	/////////////////////////////////////////////////////////////////////////////////////////////
	event OnPerformEvade( playerEvadeType : EPlayerEvadeType )
	{
		if(!parent.HasStaminaToUseAction(ESAT_Dodge))
		{
			parent.SoundEvent("gui_ingame_low_stamina_warning");
		}
		else
		{
			if ( playerEvadeType == PET_Dodge )
				parent.bIsRollAllowed = true;
				
			return PerformEvade( playerEvadeType );
		}
		return false;
	}
	
	function PerformEvade( playerEvadeType : EPlayerEvadeType ) : bool
	{
		//return false;
		if ( !diving )
			return false;
		
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_Dodge );
			//parent.LockToMoveTarget( 0.5f );
			//parent.SetBehaviorVariable(	'playerEvadeDirection', (int)( dodgeDirection ) ) ;			
			//parent.RaiseForceEvent( 'CombatAction' );
			LogChannel( 'CombatAction', "CombatAction" );
			// do initial turn to look properly when moving in dodge direction
			//parent.SetCustomRotation( 'Dodge', GetDodgeHeading( playerEvadeType ), 0.0f, 0.2f, false ); // rotation speed is 0.0 as we want to rotate no matter what
			// lock movement to move always towards dodge direction
			//parent.CustomLockMovement( 'DodgeMovement', rawDodgeHeading );0
			//parent.BindMovementAdjustmentToEvent( 'DodgeMovement', 'Dodge' );
			
		OnDodgeBoost();
		parent.RaiseEvent( 'Dodge' );
		parent.DrainStamina(ESAT_Evade);
		return true;
	}
	
	event OnDodgeBoost()
	{
		parent.AddTimer('DodgeBoostTimeOut',1.0 );
		parent.SetBehaviorVariable('dodgeBoost', 1.0 );
		if ( parent.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
			parent.SetBehaviorVariable('dodgeBoostPlaySpeed', 3.0 );
		else
			parent.SetBehaviorVariable('dodgeBoostPlaySpeed', 1.0 );
	}
	
	timer function DodgeBoostTimeOut( dt : float , id : int)
	{
		parent.SetBehaviorVariable( 'dodgeBoost',0.0);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @PlayerOrientation
	/////////////////////////////////////////////////////////////////////////////////////////////
	private function ProcessPlayerOrientation()
	{
		var newOrientationTarget		: EOrientationTarget;
		var customOrientationInfo		: SCustomOrientationInfo;
		var customOrientationTarget		: EOrientationTarget;

		if ( parent.GetCustomOrientationTarget( customOrientationInfo ) )
			customOrientationTarget = customOrientationInfo.orientationTarget;
		else
			customOrientationTarget = OT_None;

		if ( parent.moveTarget && parent.moveTarget.IsAlive() )
			newOrientationTarget = OT_Actor;	
		else if ( (W3PlayerWitcher)parent && ( (W3PlayerWitcher)parent ).IsCastingSign() && !parent.IsInCombat() )
			newOrientationTarget = OT_CameraOffset;
		else if ( parent.GetTarget() && parent.IsInCombatAction() )
			newOrientationTarget = OT_Actor;
		else					
			newOrientationTarget = OT_Player;
						
		if ( parent.IsThrowingItemWithAim() )
			newOrientationTarget = OT_CameraOffset;	
			
		if ( customOrientationTarget != OT_None )
			newOrientationTarget = customOrientationTarget;

		if ( newOrientationTarget != parent.GetOrientationTarget() )
			parent.SetOrientationTarget( newOrientationTarget );
	}
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @Camera
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	function EnableSprintingCamera( flag : bool )
	{
		if ( parent.sprintingCamera )
		{
			parent.sprintingCamera = false;
			theGame.GetGameCamera().StopAnimation('camera_shake_loop_lvl1_1');
		}
	}
	
	function EnableRunCamera( flag : bool )
	{
		if ( parent.runningCamera )
		{
			parent.runningCamera = false;
			theGame.GetGameCamera().StopAnimation('camera_shake_loop_lvl1_5');
		}
	}
	
	private var cameraIsUnderwater : bool;
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		// focusMode camera
		if ( theGame.IsFocusModeActive() )
		{	
			return false;
		}
		else if( super.OnGameCameraTick( moveData, dt ) )
		{
			return true;
		}
		return false;
	}
	
	private var cameraPitch : float;
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var cameraRotation : EulerAngles;
		var cameraPosition : Vector;
		var waterLevel : float;
		var diff : float;
		
		var divePitch : float;
		var angleDistBetweenPlayerAndCamera : float;
		var playerToTargetVector : Vector;
		var playerToTargetAngles : EulerAngles;
		var playerToTargetPitch : float;
		
		cameraPosition = theCamera.GetCameraPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel(cameraPosition, true);
		diff = cameraPosition.Z - waterLevel;
		
		
		UpdateDivingPitch();
		
		if ( cameraIsUnderwater && diff >= 0 )
		{
			parent.PlayEffect('water_effect_surfacing');
			cameraIsUnderwater = false;
			theSound.SoundEvent("fx_underwater_off");
		}
		else if ( !cameraIsUnderwater && diff < 0 )
		{
			cameraIsUnderwater = true;
			theSound.SoundEvent("fx_underwater_on");
		}
		
		// camera pitch
		{
			cameraRotation = theCamera.GetCameraRotation();
			cameraPitch = AngleNormalize180(cameraRotation.Pitch);
			
			angleDistBetweenPlayerAndCamera = AbsF(AngleDistance(parent.GetHeading(),VecHeading(theCamera.GetCameraDirection())));
			
			if ( ( cameraPitch < 0 && !OnAllowedDiveDown() ) || angleDistBetweenPlayerAndCamera > 135 )
				parent.SetBehaviorVariable( 'cameraPitch', 0.f);
			else
				parent.SetBehaviorVariable( 'cameraPitch', cameraPitch);
		}
		
		
		
		// RotationController settings
		
		if ( parent.IsCameraLockedToTarget() )
		{
			playerToTargetVector = parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition();
			
			moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), 0.5f );
			
			playerToTargetAngles = VecToRotation( playerToTargetVector );
			playerToTargetPitch = playerToTargetAngles.Pitch + 10;
			moveData.pivotRotationController.SetDesiredPitch( playerToTargetPitch * -1, 0.5f );
		}
		else if ( moveData.pivotRotationController.controllerName == 'Diving' )
		{
			divePitch = parent.GetBehaviorVariable('divePitch');
			
			if ( divePitch <= -1.f )
			{
				moveData.pivotRotationController.SetDesiredPitch(-89.f);
				moveData.pivotRotationController.minPitch = -80.f;
				moveData.pivotRotationController.maxPitch = -60.f;
			}
			else if ( divePitch >= 1.f )
			{ 
				moveData.pivotRotationController.SetDesiredPitch(89.f);
				moveData.pivotRotationController.maxPitch = 80.f;
				moveData.pivotRotationController.minPitch = 60.f;
			}
			else
			{
				if ( !thePlayer.GetIsSprinting() )
					moveData.pivotRotationController.SetDesiredPitch(0.0);
					
				if ( isCiri )
				{
					moveData.pivotRotationController.minPitch = -45.f;
					moveData.pivotRotationController.maxPitch = 45.f;
				}
				else
				{
					moveData.pivotRotationController.minPitch = -70.f;
					moveData.pivotRotationController.maxPitch = 70.f;
				}
			}
			
			//moveData.pivotRotationController.SetDesiredHeading(parent.GetHeading());
		}
		else if ( divingEnd )
		{
			//theCamera.
			moveData.pivotRotationController.SetDesiredPitch(-10.0, 3.f);
			theGame.GetGameCamera().ForceManualControlHorTimeout();
		}
		else if ( moveData.pivotRotationController.controllerName == 'Swimming' )
		{
			moveData.pivotRotationController.SetDesiredPitch(-10.0);
		}
		// PositionController settings
		if ( moveData.pivotPositionController.controllerName == 'Diving' )
		{
			if ( parent.rawPlayerSpeed == 0 )
			{
				moveData.pivotPositionController.offsetZ = 1.75f;
			}
			else
			{
				moveData.pivotPositionController.offsetZ = 1.15f;
			}
		}
		if ( theGame.IsFocusModeActive() )
		{
			moveData.pivotDistanceController.SetDesiredDistance(1.f);
			moveData.pivotRotationController.SetDesiredHeading(VecHeading(theCamera.GetCameraDirection()));
		}
		// DistanceController settings
		else if ( moveData.pivotDistanceController.controllerName == 'Diving' )
		{
			if ( cameraPitch < 0 && diff >= -0.25 )
			{
				moveData.pivotDistanceController.SetDesiredDistance(0);
			}
			else if ( parent.rawPlayerSpeed == 0 )
			{
				moveData.pivotDistanceController.SetDesiredDistance(2.25);
			}
			else
			{
				moveData.pivotDistanceController.SetDesiredDistance(2.75);
			}
		}
		
		super.OnGameCameraPostTick( moveData, dt );
	}
	
	event OnIsCameraUnderwater()
	{
		return cameraIsUnderwater;
	}
	
	private function UpdateCameraShooting( out moveData : SCameraMovementData, timeDelta : float )
	{
	
	}
	
	private function UpdateDivingPitch()
	{
		if ( parent.rangedWeapon && parent.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
			thePlayer.SetBehaviorVariable( 'divePitch', 0.f );
		else if ( theInput.IsActionPressed('DiveUp') )
		{
			if ( thePlayer.bLAxisReleased )
				thePlayer.SetBehaviorVariable( 'divePitch', 1.0 );
			else
				thePlayer.SetBehaviorVariable( 'divePitch', 0.9 );
		}
		else if ( theInput.IsActionPressed('DiveDown') )
		{
			if ( thePlayer.bLAxisReleased )
				thePlayer.SetBehaviorVariable( 'divePitch',-1.0 );
			else
				thePlayer.SetBehaviorVariable( 'divePitch', -0.9 );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'divePitch', 0.f );
		}
	}
	
	private function TurnOnSwimmingCamera()
	{
		theGame.GetGameCamera().ChangePivotRotationController( 'Swimming' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
	}
	
	private function TurnOnDivingCamera()
	{
		theGame.GetGameCamera().ChangePivotRotationController( 'Diving' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Diving' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'Diving' );
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @AnimEvents
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnAnimEvent_TurnOnDiving( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		OnDiveAnimationStart();
	}
	
	event OnAnimEvent_AllowSwitchToDiving( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( CheckWaterDepth(MIN_WATER_LEVEL_FOR_DIVING) )
		{
			parent.SetBehaviorVariable('AllowSwitchToDiving',1.f);
		}
		else
		{
			parent.SetBehaviorVariable('AllowSwitchToDiving',0.f);
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	////// @Swimming @Debug
	/////////////////////////////////////////////////////////////////////////////////////////////
	private function LogSwimming( text : string )
	{
		LogChannel( 'Swimming', text );
	}
	
	
}
