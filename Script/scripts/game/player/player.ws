/***********************************************************************/
/** Copyright © 2009-2014
/** Author : ?
/***********************************************************************/

enum EPlayerDeathType
{
	PDT_Normal		= 0,
	PDT_Fall		= 1,
	PDT_KnockBack	= 2,
}

statemachine import abstract class CPlayer extends CActor
{		
	// DEBUG
	private var _DEBUGDisplayRadiusMinimapIcons : bool;
	private var debug_BIsInputAllowedLocks : array<name>;			//list of locks on BIsInputAllowed
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//Swimming
	public const var ENTER_SWIMMING_WATER_LEVEL : float;
	default ENTER_SWIMMING_WATER_LEVEL = -1.45;
	
	// CAMERA
	public var useSprintingCameraAnim	: bool;		default	useSprintingCameraAnim	= false;
	public var oTCameraOffset 			: float;	default oTCameraOffset 			= 0.f;	
	public var oTCameraPitchOffset 		: float;	default oTCameraPitchOffset		= 0.f;
	

	// COMBAT
	public				var bIsRollAllowed				: bool;
	protected			var bIsInCombatAction			: bool;
	protected			var bIsInCombatActionFriendly	: bool;
	private				var bIsInputAllowed				: bool;
	public 				var bIsFirstAttackInCombo		: bool;
	protected			var bIsInHitAnim				: bool;
	import				var enemyUpscaling				: bool;
	
	public editable		var FarZoneDistMax				: float;
	public editable 	var DangerZoneDistMax			: float;
			
		default	FarZoneDistMax = 30;
		default	DangerZoneDistMax = 50;
		
	// COMMENTARIES, VOICESETS
	private 			var commentaryCooldown			: float;
	private				var commentaryLastTime			: EngineTime;
	
	private				var	canPlaySpecificVoiceset		: bool;
		default canPlaySpecificVoiceset = true;
 	
	// HUD VARIABLES FOR PROCESSING GUI EVENTS
	public				var isHorseMounted				: bool; // #B
	public				var isCompanionFollowing		: bool; // #B 
	public				var bStartScreenIsOpened		: bool; //#B
	public				var bEndScreenIsOpened			: bool; //#B
	public				var fStartScreenFadeDuration	: float;//#B
	public				var bStartScreenEndWithBlackScreen : bool; // #B
	public				var fStartScreenFadeInDuration	: float;//#B
	const 				var DEATH_SCREEN_OPEN_DELAY		: float; //#B
		
		default bStartScreenIsOpened = false;	//#B
		default bEndScreenIsOpened = false;	//#B
		default DEATH_SCREEN_OPEN_DELAY = 4.f; // #B
		default fStartScreenFadeDuration = 3.0; // [ms] #B
		default fStartScreenFadeInDuration = 3.0; // [ms] #B
		default bStartScreenEndWithBlackScreen = false; // #B

	// INPUT
	public 				var bLAxisReleased				: bool;
	public 				var bRAxisReleased				: bool;
	private 			var bUITakesInput				: bool; //#B
	protected	saved	var inputHandler 				: CPlayerInput;
	public				var sprintActionPressed			: bool;
	private				var inputModuleNeededToRun		: float;
	
		default bUITakesInput = false;//#B
		default bLAxisReleased = true;
		default inputModuleNeededToRun = -1.0;
		
	// INTERACTIVE OBJECTS
	private				var bInteractionPressed			: bool;	
		
	// MOVEMENT
	public				var rawPlayerSpeed 				: float; // protected
	public	 			var rawPlayerAngle		 		: float; // protected
	public	 			var rawPlayerHeading			: float; // protected
	//public				var lAxisPushedTimeStamp		: float;
	public				var cachedRawPlayerHeading		: float;
	public				var cachedCombatActionHeading 			: float;
	public				var canResetCachedCombatActionHeading 	: bool;	
	protected			var combatActionHeading			: float;
	public				var rawCameraHeading			: float; 
	private	 			var isSprinting 				: bool;
	protected			var	isRunning					: bool;
	protected			var	isWalking					: bool;
	public	 			var playerMoveType				: EPlayerMoveType;
	private				var sprintingTime				: float;
	private 			var walkToggle 					: bool;		default walkToggle = false;
	private 			var sprintToggle 				: bool;		default sprintToggle = false;
	import public 		var isMovable 					: bool;

	public				var moveTarget					: CActor;
	public				var nonActorTarget				: CGameplayEntity;
	public				var tempLookAtTarget			: CGameplayEntity;
	public				var lockTargetSelectionHeading	: float;
		
	protected 			var rawLeftJoyRot 				: float;	
	protected 			var rawRightJoyRot  			: float;
	protected			var rawLeftJoyVec 				: Vector;
	protected			var rawRightJoyVec 				: Vector;
	protected			var prevRawLeftJoyVec 			: Vector;
	protected			var prevRawRightJoyVec 			: Vector;
	protected			var lastValidLeftJoyVec 		: Vector;
	protected			var lastValidRightJoyVec 		: Vector;
	
	public				var allowStopRunCheck			: bool;
	public				var moveTargetDampValue			: float;
	
	//public 				var orientationTargetCustomHeading 	: float;
	
	public 				var interiorCamera 				: bool;
	public 				var movementLockType			: EPlayerMovementLockType;
	public	 			var scriptedCombatCamera 		: bool;
	public				var modifyPlayerSpeed			: bool;
	public saved		var autoCameraCenterToggle 		: bool;
	
	default interiorCamera = false;
	default scriptedCombatCamera =  true;
		
	// OTHER
	public				var inv 						: CInventoryComponent;
	// Array to store what was equipped in slots when we take items out of them.
	public				saved var equipmentSlotHistory			: array<SItemUniqueId>;
	
	// Quest Tracker	#B
	private var currentTrackedQuestSystemObjectives : array<SJournalQuestObjectiveData>;
	private var currentTrackedQuestObjectives : array<SJournalQuestObjectiveData>;
	private var currentTrackedQuestGUID : CGUID;
	private var HAXNewObjTable : array<CGUID>;
	
	// SIGNS
	public				var handAimPitch				: float;
	private saved		var vehicleCachedSign			: ESignType;
	
	default vehicleCachedSign = ST_None;
	
	// SOFT LOCK TARGETING
	public editable		var softLockDist				: float;
	public editable		var softLockFrameSize			: float;			//% frame scale of camera to see if npcs are visible. E.g. 1.25 means the softlockframe 25% larger than the viewcam
	public	 			var findMoveTargetDist			: float;
	public				var softLockDistVehicle			: float;
	private				var bBIsLockedToTarget			: bool;				//Is CAMERA locked to the target
	private				var bActorIsLockedToTarget		: bool;				//Is GERALT locked to the target
	private				var bIsHardLockedTotarget		: bool;				//Did player trigger hard lock, can only be released through input or cinematics/dialogue
	
		default softLockDist =  12.f;
		default softLockFrameSize = 1.25f;
		default softLockDistVehicle = 30.f;
		
	// TERRAIN TYPES - someone please elaborate what this is actually
	private var terrTypeOne : ETerrainType;
	private var terrTypeTwo : ETerrainType;
	private var terrModifier : float;			// 0 - fully blended to terrTypeOne; 1 - fully blended to terrTypeTwo
	private var prevTerrType : ETerrainType;
	
		default terrTypeOne = TT_Normal;
		default terrTypeTwo = TT_Normal;
		default terrModifier = 0.f;
		default prevTerrType = TT_Normal;
		
	// USABLE ITEMS
	protected var currentlyUsedItem 			 : W3UsableItem;
	protected var currentlyEquipedItem 			 : SItemUniqueId;
	protected var currentlyUsedItemL 		     : W3UsableItem;
	public saved   var currentlyEquipedItemL 		 : SItemUniqueId;
	protected var isUsableItemBlocked   		 : bool;
	protected var isUsableItemLtransitionAllowed : bool;
	protected var playerActionToRestore			 : EPlayerActionToRestore; default playerActionToRestore =  PATR_Default;
	
	public saved var teleportedOnBoatToOtherHUB : bool;
	default teleportedOnBoatToOtherHUB = false;
	
	///////////////////////////////////////
	
	public var isAdaptiveBalance : bool;
	default isAdaptiveBalance = false;

	function IsAdaptiveBalance() : bool
	{
		return isAdaptiveBalance;
	}
	function SetAdaptiveBalance( val : bool )
	{
		Log("Adaptive balance: " + val );
		isAdaptiveBalance = val;
	}
	
	public function SetTeleportedOnBoatToOtherHUB( val : bool )
	{
		teleportedOnBoatToOtherHUB = val;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////  IMPORTED C++ FUNCTIONS  ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	// Lock player's button interaction - use in EnterState
	import final function LockButtonInteractions( channel : int );
	
	// Unlock player's button interaction - use in LeaveState
	import final function UnlockButtonInteractions( channel : int );

	import final function GetActiveExplorationEntity() : CEntity;
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
		Called when this player is spawned
	*/		
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var conf : int;
		
		inv = GetInventory();
		
		super.OnSpawned( spawnData );
		
		RegisterCollisionEventsListener();		
		AddTimer( 'PlayerTick', 0.f, true );
		InitializeParryType();
		SetCanPlayHitAnim( true );
		
		// books ?
		if(inv)
			inv.Created();	//replacer might not have an inventory
				
		if(!spawnData.restored)
			inputHandler = new CPlayerInput in this;
			
		inputHandler.Initialize(spawnData.restored );
		SetAutoCameraCenter( ((CInGameConfigWrapper)theGame.GetInGameConfigWrapper()).GetVarValue( 'Gameplay', 'AutoCameraCenter' ) );
		
		if( !IsNameValid(GetCurrentStateName()) )
		{
			GotoStateAuto();
		}
		
		isRunning	= false;
		SetIsWalking( false );
		
		//Reactions
		EnableBroadcastPresence(true);
		
		//Anim Event Callbacks
		AddAnimEventCallback('EquipItem',			'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('UseItem',				'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('HideItem',			'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('EquipItemL',			'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('UseItemL',			'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('HideItemL',			'OnAnimEvent_QuickSlotItems');
		AddAnimEventCallback('AllowInput',			'OnAnimEvent_AllowInput');
		AddAnimEventCallback('DisallowInput',		'OnAnimEvent_DisallowInput');
		AddAnimEventCallback('DisallowHitAnim',		'OnAnimEvent_DisallowHitAnim');
		AddAnimEventCallback('AllowHitAnim',		'OnAnimEvent_AllowHitAnim');
		//AddAnimEventCallback('AllowBlend',			'OnAnimEvent_AllowBlend');
		AddAnimEventCallback('SetRagdoll',			'OnAnimEvent_SetRagdoll');
		AddAnimEventCallback('InAirKDCheck',		'OnAnimEvent_InAirKDCheck');
		AddAnimEventCallback('EquipMedallion',		'OnAnimEvent_EquipMedallion');
		AddAnimEventCallback('HideMedallion',		'OnAnimEvent_HideMedallion');
		
		//failsafe - restore stamina lock
		ResumeStaminaRegen( 'Sprint' );
	}
	
	//Dont use in game - debbugging and qa only 
	public function Debug_ResetInput()
	{
		inputHandler = new CPlayerInput in this;
		inputHandler.Initialize(false);
	}
	
	//---------------------------------------------- @BLOCKING @ACTIONS --------------------------------------------------------
	
	public function GetTutorialInputHandler() : W3PlayerTutorialInput
	{
		return (W3PlayerTutorialInput)inputHandler;
	}
	
	public function BlockAction( action : EInputActionBlock, sourceName : name, optional keepOnSpawn : bool, optional isFromQuest : bool, optional isFromPlace : bool ) : bool
	{
		if ( inputHandler )
		{
			inputHandler.BlockAction(action, sourceName, true, keepOnSpawn, this, isFromQuest, isFromPlace);
			return true;
		}		
		return false;
	}
	
	public function UnblockAction( action : EInputActionBlock, sourceName : name) : bool
	{
		if ( inputHandler )
		{
			inputHandler.BlockAction(action, sourceName, false);
			return true;
		}		
		return false;
	}
	
	public final function TutorialForceUnblockRadial() : array<SInputActionLock>
	{
		var null : array<SInputActionLock>;
		
		if ( inputHandler )
		{
			return inputHandler.TutorialForceUnblockRadial();
		}
		
		return null;
	}
	
	public final function TutorialForceRestoreRadialLocks(radialLocks : array<SInputActionLock>)
	{
		if ( inputHandler )
		{
			inputHandler.TutorialForceRestoreRadialLocks(radialLocks);
		}
	}
	
	public function GetActionLocks( action : EInputActionBlock ) : array< SInputActionLock >
	{
		return inputHandler.GetActionLocks( action );
	}
	
	public function GetAllActionLocks() : array< array< SInputActionLock > >
	{
		return inputHandler.GetAllActionLocks();
	}
	
	public function IsActionAllowed( action : EInputActionBlock ) : bool
	{
		if ( inputHandler )
		{
			return inputHandler.IsActionAllowed( action );
		}
		return true;
	}
	
	public function IsActionBlockedBy( action : EInputActionBlock, sourceName : name ) : bool
	{
		if ( inputHandler )
		{
			return inputHandler.IsActionBlockedBy(action,sourceName);
		}
		return false;	
	}
	
	public function IsWeaponActionAllowed( weapon : EPlayerWeapon ) : bool
	{
		if ( inputHandler )
		{
			//if fists and a fistfist action then check if action allowed
			//otherwise this is just a transition exploration -> fists -> something else, so it's ok!!
			if ( weapon == PW_Fists )
			{
				return inputHandler.IsActionAllowed( EIAB_Fists );
			}
			else
			{
				return inputHandler.IsActionAllowed( EIAB_DrawWeapon );
			}
		}
		return true;
	}
	
	public function BlockAllActions(sourceName : name, lock : bool, optional exceptions : array<EInputActionBlock>, optional exceptUI : bool, optional saveLock : bool, optional onSpawnedNullPointerHackFix : CPlayer, optional isFromPlace : bool)
	{
		if(inputHandler)
		{
			if(exceptUI)
			{
				exceptions.PushBack(EIAB_OpenInventory);
				exceptions.PushBack(EIAB_MeditationWaiting);
				exceptions.PushBack(EIAB_FastTravel);
				exceptions.PushBack(EIAB_OpenMap);
				exceptions.PushBack(EIAB_OpenCharacterPanel);
				exceptions.PushBack(EIAB_OpenJournal);
				exceptions.PushBack(EIAB_OpenAlchemy);
			}
			inputHandler.BlockAllActions(sourceName, lock, exceptions, saveLock, onSpawnedNullPointerHackFix, false, isFromPlace);
		}
		if(lock)
		{
			//DisableCombatState();
		}
	}
	
	public final function BlockAllQuestActions(sourceName : name, lock : bool)
	{
		inputHandler.BlockAllQuestActions(sourceName, lock);
	}
	
	public function BlockAllUIQuestActions(sourceName : name, lock : bool)
	{
		inputHandler.BlockAllUIQuestActions(sourceName, lock);
	}
			
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function GetInputHandler() : CPlayerInput
	{
		return inputHandler;
	}

		
	public function CheatGod2(on : bool)
	{
		if(on)
			SetImmortalityMode( AIM_Immortal, AIC_Default, true );
		else
			SetImmortalityMode( AIM_None, AIC_Default, true );	
		
		StaminaBoyInternal(on);
	}
	
	public function IsInCombatState() : bool
	{
		var stateName : name;
		stateName = thePlayer.GetCurrentStateName();
		if ( stateName == 'Combat' || stateName == 'CombatSteel' || stateName == 'CombatSilver' || stateName == 'CombatFists' )
		{
			return true;
		}
		return false;	
	}
	
	public function DisableCombatState()
	{
		if ( IsInCombatState() )
		{
			GotoState( 'Exploration' );
		}
	}
	
	protected function SetAbilityManager()
	{
		abilityManager = new W3PlayerAbilityManager in this;	
	}
	
	//FIXME - what's this? 
	event OnDamageFromBoids( damage : float )
	{		
		var damageAction : W3DamageAction = new W3DamageAction in theGame.damageMgr;
		
		damageAction.Initialize(NULL,this,NULL,'boid',EHRT_None,CPS_AttackPower,false,false,false,true);
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL,6.f);		//FIXME URGENT - fixed value
		damageAction.SetHitAnimationPlayType(EAHA_ForceNo);
		
		// FIXME - Temp? This is to prevent the sword sound from playing 
		// when attacked by boids.
		damageAction.SetSuppressHitSounds(true); 
		
		Log( "DAMAGE FROM BOID!!!!! " + damage );
		
		
		theGame.damageMgr.ProcessAction( damageAction );
		
		delete damageAction;
	}
	
	//FIXME shouldn't this be in gameParams? Is this different for different player characters?
	function InitializeParryType()
	{
		var i, j : int;
		
		parryTypeTable.Resize( EnumGetMax('EAttackSwingType')+1 );
		for( i = 0; i < EnumGetMax('EAttackSwingType')+1; i += 1 )
		{
			parryTypeTable[i].Resize( EnumGetMax('EAttackSwingDirection')+1 );
		}
		parryTypeTable[AST_Horizontal][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_Vertical][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Vertical][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Vertical][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Vertical][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_Jab][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Jab][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Jab][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Jab][ASD_RightLeft] = PT_None;	
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{	
	}
	
	timer function PlayerTick( deltaTime : float , id : int)
	{	
		deltaTime = theTimer.timeDeltaUnscaled;
		OnPlayerTickTimer( deltaTime );
		
		if( !IsActionAllowed( EIAB_RunAndSprint ) )
		{
			movementLockType	= PMLT_NoRun;
		}
		else if( !IsActionAllowed( EIAB_Sprint ) )
		{
			movementLockType	= PMLT_NoSprint;
		}
		else
		{
			movementLockType	= PMLT_Free;
		}	
	}
	
	// Override this in derived class
	function IsLookInputIgnored() : bool
	{
		return false;
	}

	private var inputHeadingReady : bool;
	public function SetInputHeadingReady( flag : bool )
	{
		inputHeadingReady =  flag;
	}
	
	public function IsInputHeadingReady() : bool
	{
		return inputHeadingReady;
	}	

	var lastAxisInputIsMovement : bool;
	function HandleMovement( deltaTime : float )
	{
		var leftStickVector 	: Vector;
		var rightStickVector 	: Vector; 
	
		var rawLengthL 	: float;
		var rawLengthR	: float;
	
		var len : float;
		var i : int;	
	
		prevRawLeftJoyVec = rawLeftJoyVec;
		prevRawRightJoyVec = rawRightJoyVec;

		rawLeftJoyVec.X = theInput.GetActionValue( 'GI_AxisLeftX' ); 
		rawLeftJoyVec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );

		if ( thePlayer.IsPCModeEnabled() )
		{
			rawRightJoyVec.X = theInput.GetActionValue( 'GI_MouseDampX' ); 
			rawRightJoyVec.Y = theInput.GetActionValue( 'GI_MouseDampY' ); 			
		}
		else
		{
			rawRightJoyVec.X = theInput.GetActionValue( 'GI_AxisRightX' ); 
			rawRightJoyVec.Y = theInput.GetActionValue( 'GI_AxisRightY' ); 
		}
			
		leftStickVector = rawLeftJoyVec;
		rightStickVector = rawRightJoyVec;
		// take care of situation where stick is released, jumps beyond 0,0 and lands back - it happens in one frame (or it may sometimes oscillate for two frames!)
		// for such cases use last valid
		if ( VecDot2D( prevRawLeftJoyVec, leftStickVector ) < 0.0f )
		{
			leftStickVector = lastValidLeftJoyVec;
		}
		else
		{
			lastValidLeftJoyVec = leftStickVector;
		}
		if ( VecDot2D( prevRawRightJoyVec, rightStickVector ) < 0.0f )
		{
			rightStickVector = lastValidRightJoyVec;
		}
		else
		{
			lastValidRightJoyVec = rightStickVector;
		}
		
		rawLengthL = VecLength( leftStickVector );
		rawLengthR = VecLength( rightStickVector );
		SetBehaviorVariable( 'lAxisLength', ClampF( rawLengthL, 0.0f, 1.0f ) );
		
		// no need to normalize stickVectors for VecHeading computations
		rawLeftJoyRot = VecHeading( leftStickVector );
		rawRightJoyRot = VecHeading( rightStickVector );
		
		if( rawLengthL > 0 )
		{
			bLAxisReleased = false;
			if( isSprinting )
			{
				if ( rawLengthL > 0.6 )
				{
					rawPlayerSpeed = 1.3;
					allowStopRunCheck = true;
					RemoveTimer( 'StopRunDelayedInputCheck' );
				}
				else
				{
					if ( allowStopRunCheck )
					{
						allowStopRunCheck = false;
						AddTimer( 'StopRunDelayedInputCheck', 0.25f, false );
					}
				}
			}
			else
			{
				if ( this.GetCurrentStateName() == 'Exploration' )
				{
					rawPlayerSpeed = 0.9*rawLengthL;
				}
				else
				{
					if ( rawLengthL > 0.6 )
					{
						rawPlayerSpeed = 0.8;
					}
					else
					{
						rawPlayerSpeed = 0.4;
					}
				}
			}
		}
		else
		{
			if ( isSprinting )
			{
				if  ( allowStopRunCheck )
				{
					allowStopRunCheck = false;
					AddTimer( 'StopRunDelayedInputCheck', 0.25f, false );
				}
			}
			else
			{	
				rawPlayerSpeed = 0.f;
			}
			bLAxisReleased = true;
		}
		
		if ( rawLengthR > 0 )
			bRAxisReleased = false;
		else
			bRAxisReleased = true;
		
		ProcessLAxisCaching();
		
		SetBehaviorVariable( 'moveSpeedWhileCasting', rawPlayerSpeed );

		if ( rawPlayerSpeed > 0.f )
		{
			rawPlayerHeading = AngleDistance( theCamera.GetCameraHeading(), -rawLeftJoyRot );
			if ( rawPlayerSpeed > 0.1f )
			{
				cachedRawPlayerHeading = rawPlayerHeading; //This is needed because when the analog stick is released the snap back unintentionally changes the heading
				//lAxisPushedTimeStamp = theGame.GetEngineTimeAsSeconds();
			}
			if ( IsInCombatAction() )
			{
				canResetCachedCombatActionHeading = false;
				cachedCombatActionHeading = cachedRawPlayerHeading;
			}
		}

		// PB: why do we need it at all?
		rawPlayerAngle = AngleDistance( rawPlayerHeading, GetHeading() );

		if ( !ProcessLockTargetSelectionInput( rightStickVector, rawLengthR ) )
			ProcessLockTargetSelectionInput( rightStickVector, rawLengthR );
	}

	protected function ProcessLAxisCaching()
	{
		if ( bLAxisReleased )
		{
			if ( GetBIsCombatActionAllowed() )
			{
				if ( !lAxisReleaseCounterEnabled )
				{
					lAxisReleaseCounterEnabled = true;
					AddTimer( 'LAxisReleaseCounter', 0.25f );
				}
			}
			
			if ( !lAxisReleaseCounterEnabledNoCA  )
			{
				lAxisReleaseCounterEnabledNoCA  = true;
				AddTimer( 'LAxisReleaseCounterNoCA', 0.2f );
			}

			if ( !bRAxisReleased )
			{
				if ( thePlayer.IsPCModeEnabled() )
				{
					if ( lAxisReleasedAfterCounter )
						lastAxisInputIsMovement = false;
				}
				else
					lastAxisInputIsMovement = false;
			}
		}
		else
		{
			lAxisReleasedAfterCounter = false;
			lAxisReleasedAfterCounterNoCA = false;
			RemoveTimer( 'LAxisReleaseCounter' );
			RemoveTimer( 'LAxisReleaseCounterNoCA' );
			lAxisReleaseCounterEnabled = false;
			lAxisReleaseCounterEnabledNoCA = false;
			
			lastAxisInputIsMovement = true;
		}		
	}

	public function ResetLastAxisInputIsMovement()
	{
		lastAxisInputIsMovement = true;
	}

	private var bRAxisReleasedLastFrame 	: bool;
	private var selectTargetTime 			: float;
	
	private var swipeMouseTimeStamp : float;
	private var swipeMouseDir 		: Vector;
	private var swipeMouseDist		: float;
	private var enableSwipeCheck  	: bool;
	protected function ProcessLockTargetSelectionInput( rightStickVector : Vector, rawLengthR : float ) : bool
	{
		var currTime	: float;
		var rightStickVectorNormalized : Vector;
		var dot	: float;
		
		if ( this.IsCameraLockedToTarget() )
		{
			currTime = theGame.GetEngineTimeAsSeconds();
		
			if ( thePlayer.IsPCModeEnabled() )
			{
				if ( rawLengthR > 0.f )
				{
					rightStickVectorNormalized = VecNormalize( rightStickVector );
				
					if ( enableSwipeCheck )
					{
						enableSwipeCheck = false;
						swipeMouseTimeStamp = currTime;
						swipeMouseDir = rightStickVector;
						swipeMouseDist = 0.f;
					}

					dot = VecDot( swipeMouseDir, rightStickVector );
					
					if ( dot > 0.8 )
					{
						swipeMouseDist += rawLengthR;
					}
					else
					{
						enableSwipeCheck = true;
						return false;
					}
					
					swipeMouseDir = rightStickVector;					
											

					if ( currTime > swipeMouseTimeStamp + 0.2f )
					{
					/*	LogChannel( 'Swipe', "TimeStamp" );
						if ( swipeMouseDist > 0 ) 
							LogChannel( 'Swipe', "swipeMouseDist: " + swipeMouseDist );
					*/		
						swipeMouseDist = 0.f;
						enableSwipeCheck = true;
					}

				}
				else
				{
				/*	LogChannel( 'Swipe', "rawLengthR = 0.f" );
					if ( swipeMouseDist > 0 ) 
						LogChannel( 'Swipe', "swipeMouseDist: " + swipeMouseDist );
				*/		
					swipeMouseDist = 0.f;
					enableSwipeCheck = true;
				}
				
				if ( swipeMouseDist <= 350.f )
					return true;
				else
				{
					rightStickVector = rightStickVectorNormalized;
					rawLengthR = VecLength( rightStickVector );
				}
			}
			
			if ( bRAxisReleasedLastFrame )
			{
				if ( rawLengthR >= 0.3 )
				{
					inputHandler.OnCbtSelectLockTarget( rightStickVector );
					selectTargetTime = currTime;
				}
			}
			else if ( rawLengthR >= 0.3 && currTime > ( selectTargetTime + 0.5f ) )
			{
				inputHandler.OnCbtSelectLockTarget( rightStickVector );
				selectTargetTime = currTime;	
			}
		}

		if ( rawLengthR < 0.3 )
			bRAxisReleasedLastFrame = true;
		else
			bRAxisReleasedLastFrame = false;
			
		return true;	
	}
	
	public var lAxisReleasedAfterCounter 	: bool;
	public var lAxisReleaseCounterEnabled 	: bool;
	private timer function LAxisReleaseCounter( time : float , id : int)
	{
		//time = theTimer.timeDeltaUnscaled;
		if ( bLAxisReleased )
			lAxisReleasedAfterCounter = true;
	}
	
	public var lAxisReleasedAfterCounterNoCA 	: bool; //MS: L-Axis counter that considers combatActionAllowed
	public var lAxisReleaseCounterEnabledNoCA 	: bool;
	private timer function LAxisReleaseCounterNoCA( time : float , id : int)
	{
		//time = theTimer.timeDeltaUnscaled;
		if ( bLAxisReleased )
			lAxisReleasedAfterCounterNoCA = true;
	}
	
	/**
	
	*/
	timer function StopRunDelayedInputCheck( time : float, id : int)
	{
		//StopRun();
		allowStopRunCheck = true;
	}	
	
	public function IsUITakeInput() : bool //#B
	{
		return bUITakesInput;
	}

	public function SetUITakeInput ( val : bool ) //#B
	{
		bUITakesInput = val;
	}
	
	public function GetRawLeftJoyRot() : float
	{
		return rawLeftJoyRot;
	}
	
	public function SetIsActorLockedToTarget( flag : bool )
	{
		bActorIsLockedToTarget = flag;
	}
	
	public function IsActorLockedToTarget() : bool
	{
		return bActorIsLockedToTarget;
	}	
	
	//MS: Also serves as SetIsLockedToTarget
	public function SetIsCameraLockedToTarget( flag : bool )
	{
		bBIsLockedToTarget = flag;
	}
	
	public function IsCameraLockedToTarget() : bool
	{
		return bBIsLockedToTarget;
	}	
	
	public function IsLockedToTarget() : bool
	{
		return false;//bBIsLockedToTarget;
	}
	
	public function EnableHardLock( flag : bool )
	{
		if ( !flag )
			Log( "EnableHardLock : false" );
		
		bIsHardLockedTotarget = flag;
	}
	
	public function IsHardLockEnabled() : bool
	{
		return bIsHardLockedTotarget;
	}	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//@REACTIONS
	
	function EnableBroadcastPresence( enable : bool )
	{
		if ( enable )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'PlayerPresenceAction', -1.f , 10.0f, 3.f, -1, true); //reactionSystemSearch
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'PlayerPresenceActionFar', -1.f , 20.0f, 3.f, -1, true); //reactionSystemSearch
		}
		else
		{
			theGame.GetBehTreeReactionManager().RemoveReactionEvent(this, 'PlayerPresenceAction');
			theGame.GetBehTreeReactionManager().RemoveReactionEvent(this, 'PlayerPresenceActionFar');
		}
	}
	
	function RemoveReactions()
	{
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'DrawSwordAction' );
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'CombatNearbyAction' );
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'AttackAction' );
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'CastSignAction' );
		EnableBroadcastPresence(false);
	}
	
	function RestartReactionsIfNeeded()
	{
		EnableBroadcastPresence(true);
		
		//not needed for now
		/*if ( thePlayer.GetCurrentMeleeWeaponType() == PW_Steel || thePlayer.GetCurrentMeleeWeaponType() == PW_Silver )
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'DrawSwordAction', -1, 8.0f, 1.f, 99, true); //reactionSystemSearch
		else
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( this, 'DrawSwordAction' );*/
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// DIALOGUE STATE EVENTS
	
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		super.OnBlockingSceneStarted( scene );
		ClearAttitudes( true, false, false );
		RaiseForceEvent( 'ForceIdle' );
		RemoveReactions();
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'PlayerInScene', -1.f, 60.0f, -1, -1, true ); //reactionSystemSearch
		PushState( 'PlayerDialogScene' );		//TODO - Exiting Work, fast finishing all tasks

	}

	event OnBlockingSceneStarted_OnIntroCutscene( scene: CStoryScene )
	{
		SetImmortalityMode( AIM_Invulnerable, AIC_Scene );
		SetTemporaryAttitudeGroup( 'geralt_friendly', AGP_Scenes);
	}
	
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		var exceptions : array<EInputActionBlock>;
		
		super.OnBlockingSceneEnded( output );
		
		RestartReactionsIfNeeded();
		
		exceptions.PushBack(EIAB_Movement);
		exceptions.PushBack(EIAB_RunAndSprint);
		exceptions.PushBack(EIAB_Sprint);
		this.BlockAllActions('SceneEnded',true,exceptions);
		
		this.AddTimer('RemoveSceneEndedActionBlock',1.f,false);
	}
	
	private timer function RemoveSceneEndedActionBlock( dt : float , id : int)
	{
		this.BlockAllActions('SceneEnded',false);
		if ( !thePlayer.IsInCombat() )
			thePlayer.SetPlayerCombatStance( PCS_Normal );
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	
	public function SetDeathType( type : EPlayerDeathType )
	{
		SetBehaviorVariable( 'DeathType', (float) (int) type );
	}
	
	public function ResetDeathType()
	{
		SetDeathType( PDT_Normal );
	}
	
	/**
		Called when player is dead
	*/
	event OnDeath( damageAction : W3DamageAction  )
	{
		var attacker : CGameplayEntity;
		var hud : CR4ScriptedHud;
		var radialModule : CR4HudModuleRadialMenu;
		var depth : float;
		var guiManager : CR4GuiManager;
		
		var allowDeath : bool;
		
		super.OnDeath( damageAction );
		
		ClearAttitudes( true, false, false );
		
		attacker = damageAction.attacker;
		
		depth = ((CMovingPhysicalAgentComponent)this.GetMovingAgentComponent()).GetSubmergeDepth();
		
		if ( (W3ReplacerCiri)this )
		{	
			allowDeath = true;
		}
		else if ( !IsUsingVehicle() && depth > -0.5 && !IsSwimming() && attacker && ((CNewNPC)attacker).GetNPCType() == ENGT_Guard )
		{
			((CR4PlayerStateUnconscious)GetState('Unconscious')).OnKilledByGuard();
			PushState( 'Unconscious' );
		}
		else if ( !IsUsingVehicle() && depth > -0.5 && !IsSwimming() && (W3Elevator)attacker )
		{
			((CR4PlayerStateUnconscious)GetState('Unconscious')).OnKilledByElevator();
			PushState( 'Unconscious' );
		}
		else if ( !IsUsingVehicle() && depth > -0.5 && !IsSwimming() && WillBeUnconscious() )
		{
			PushState( 'Unconscious' );
		}
		else
		{
			allowDeath = true;
		}
		
		if ( allowDeath )
		{
			SetAlive(false);
			
			if ( IsUsingHorse( true ) || IsUsingBoat() )
			{
			}
			else
			{
				RaiseForceEvent( 'Death' );
				//RaiseForceEvent( 'Ragdoll' );			
				SetBehaviorVariable( 'Ragdoll_Weight', 1.f );
			}
			
			theGame.FadeOutAsync(DEATH_SCREEN_OPEN_DELAY - 0.1 );
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			guiManager = theGame.GetGuiManager();
			if (guiManager && guiManager.IsAnyMenu())
			{
				guiManager.GetRootMenu().CloseMenu();
			}
			
			// #J Unplugging for TRC's as a paused game will result in this giving :S results since the timer may fall WAYYYY behind the fade
			// {
			if (hud)
			{
				hud.StartDeathTimer(DEATH_SCREEN_OPEN_DELAY);
			}
			else
			{
				AddTimer('OpenDeathScreen',DEATH_SCREEN_OPEN_DELAY,false); // Just in case hud isn't up for some strange reason
			}
			//}
			
			if( hud )
			{
				radialModule = (CR4HudModuleRadialMenu)hud.GetHudModule("RadialMenuModule");
				if (radialModule && radialModule.IsRadialMenuOpened())
				{
					radialModule.HideRadialMenu();
				}
			}
			theTelemetry.LogWithLabel(TE_FIGHT_PLAYER_DIES, damageAction.attacker.ToString());
		}
	}
	
	//timer function OpenDeathScreen(dt : float, id : int)
	//{
	//	
	//	theGame.RequestMenu( 'DeathScreenMenu' );
	//	
	//	theInput.StoreContext('Death');
	//}


	event OnUnconsciousEnd()
	{
		if( GetCurrentStateName() == 'Unconscious' )
		{
			GotoStateAuto();
		}
	}

	/**
		Called when player is
 in the water
	*/
	/*event OnEnterWater(){}
	event OnLeaveWater(){}*/
	
	event OnDodgeBoost(){}
		
	// Currently used for inputs but should be merged somewhere else in scripts
	function StopRun()
	{
		SetSprintActionPressed(false,true);
		SetIsSprinting( false );
	}
	
	function IsRunPressed() : bool
	{
		return true;
		/*
		var action : SInputAction = theInput.GetAction( 'Sprint' );
		return action.value > 0.7;*/
	}
	
	
	private var sprintButtonPressedTimestamp : float;
	
	function SetSprintActionPressed( enable : bool, optional dontClearTimeStamp : bool )
	{
		sprintActionPressed = enable;
		if ( !dontClearTimeStamp )
			sprintButtonPressedTimestamp = theGame.GetEngineTimeAsSeconds();
	}
	
	public function GetHowLongSprintButtonWasPressed() : float
	{
		var duration : float;
		
		if ( !sprintActionPressed || sprintButtonPressedTimestamp <= 0)
			return -1;
		
		duration = theGame.GetEngineTimeAsSeconds() - sprintButtonPressedTimestamp;
		
		return duration;
	}
	
	function SetIsSprinting( flag : bool )
	{
		// If we are not changing anything, skip this
		if( flag == isSprinting )
		{
			if ( flag && disableSprintingTimerEnabled )
			{
				disableSprintingTimerEnabled = false;
				RemoveTimer( 'DisableSprintingTimer' );
			}
			return;
		}
		
		if ( flag )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'PlayerSprintAction', -1, 10.0f, 0.5f, -1, true); //reactionSystemSearch
			BreakPheromoneEffect();
			RemoveTimer( 'DisableSprintingTimer' );
			AddTimer('SprintingTimer', 0.01, true);
			PauseStaminaRegen( 'Sprint' );
		}
		else 
		{
			sprintingTime = 0.0f;
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( thePlayer, 'PlayerSprintAction' ); //reactionSystemSearch
			ResumeStaminaRegen( 'Sprint' );
			EnableSprintingCamera( false );
		}
		
		isSprinting = flag;	
		SetBehaviorVariable( 'isSprinting', (int)isSprinting );
	}
	
	var sprintingCamera : bool;
	function EnableSprintingCamera( flag : bool )
	{
		var camera 	: CCustomCamera;
		var animation : SCameraAnimationDefinition;
		var vel : float;

		if( !theGame.IsUberMovementEnabled() && !useSprintingCameraAnim )
		{
			return;
		}

		if ( IsSwimming() || OnCheckDiving() )
			flag = false;
		
		camera = theGame.GetGameCamera();
		if ( flag )
		{
			
			vel = VecLength( this.GetMovingAgentComponent().GetVelocity() );
			if ( !sprintingCamera && vel > 6.5 )
			{
				if( useSprintingCameraAnim )
				{
					animation.animation = 'camera_shake_loop_lvl1_1';
					animation.priority = CAP_High;
					animation.blendIn = 1.f;
					animation.blendOut = 1.f;
					animation.weight = 1.5f;
					animation.speed	= 1.0f;
					animation.loop = true;
					animation.additive = true;
					animation.reset = true;
					camera.PlayAnimation( animation );
				}
				
				sprintingCamera = true;
			}
		}
		else
		{	
			sprintingCamera = false;
			camera.StopAnimation('camera_shake_loop_lvl1_1');
		}
	}
	
	var runningCamera : bool;
	function EnableRunCamera( flag : bool )
	{
		var camera 	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		var vel : float;
		
		if ( IsSwimming() || OnCheckDiving() )
			flag = false;
		
		if ( flag )
		{
			animation.animation = 'camera_shake_loop_lvl1_5';
			animation.priority = CAP_High;
			animation.blendIn = 1.f;
			animation.blendOut = 1.f;
			animation.weight = 0.7f;
			animation.speed	= 0.8f;
			animation.loop = true;
			animation.additive = true;
			animation.reset = true;
			camera.PlayAnimation( animation );
		}
		else
		{
			camera.StopAnimation('camera_shake_loop_lvl1_5');
		}
		
		runningCamera = flag;
	}
	
	//called in loop while the player is sprinting
	protected timer function SprintingTimer(dt : float, id : int)
	{
		if ( !thePlayer.modifyPlayerSpeed )
		{
			sprintingTime	+= dt;
			
			//first 3.0 sec of sprinting is free;
			if ( ShouldDrainStaminaWhileSprinting() )
			{
				DrainStamina(ESAT_Sprint, 0, 0, '', dt);
			}
		}
	}
	
	protected function ShouldDrainStaminaWhileSprinting() : bool
	{
		var currentStateName : name;
		
		if ( sprintingTime >= 3.0 || GetStaminaPercents() < 1.0 )
		{
			currentStateName = GetCurrentStateName();
			
			if( currentStateName == 'Exploration' || currentStateName == 'CombatSteel' || currentStateName == 'CombatSilver' || currentStateName == 'CombatFists' )
			{
				return true;
			}
		}
		return false;
	}
	
	protected function ShouldUseStaminaWhileSprinting() : bool
	{
		return true;
	}
	
	function GetIsSprinting() : bool
	{
		return isSprinting;
	}
	
	function GetSprintingTime() : float
	{
		if( !GetIsSprinting() )
		{
			return 0.0f;
		}
		
		return sprintingTime;
	}
	
	
	var disableSprintingTimerEnabled	: bool;
	timer function DisableSprintingTimer ( time : float , id : int)
	{
		disableSprintingTimerEnabled = false;
		if ( !thePlayer.CanSprint( VecLength( rawLeftJoyVec ) ) )
		{
			thePlayer.RemoveTimer('SprintingTimer');
			thePlayer.SetIsSprinting(false);
		}
	}
	
	public function IsSprintActionPressed() : bool
	{
		return theInput.IsActionPressed('Sprint') || sprintToggle;
	}
	
	public function SetSprintToggle( flag : bool )
	{	
		sprintToggle = flag;
	}
	
	public function GetIsSprintToggled() : bool
	{	
		return sprintToggle;
	}

	public function SetWalkToggle( flag : bool )
	{	
		walkToggle = flag;
	}
	
	public function GetIsWalkToggled() : bool
	{	
		return walkToggle;
	}
	
	public function GetIsRunning() : bool
	{
		return isRunning;
	}
	
	public function SetIsRunning( flag : bool )
	{
		isRunning = flag;
	}
	
	function GetIsWalking() : bool
	{
		return isWalking;
	}
	
	function SetIsWalking( walking : bool )
	{
		isWalking	= walking;
	}
	
	final function SetIsMovable( flag : bool )
	{
		isMovable = flag;
	}
	
	public function SetManualControl( movement : bool, camera : bool ) 
	{ 
		if( movement == false )
		{
			RaiseForceEvent( 'Idle' );
		}
		SetIsMovable( movement ); 
		SetShowHud( movement );
	}
	
	final function GetIsMovable() : bool
	{
		return isMovable && inputHandler.IsActionAllowed(EIAB_Movement);
	}
	
	function SetBInteractionPressed( flag : bool )
	{
		bInteractionPressed = flag;
	}
	
	function GetBInteractionPressed() : bool 
	{
		return bInteractionPressed;
	}
	
	function IsInCombatAction()  : bool
	{
		return bIsInCombatAction;
	}
	
	function IsInCombatActionFriendly()  : bool
	{
		return bIsInCombatActionFriendly;
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		return false;
	}
	
	public function SetBIsInCombatAction(flag : bool)
	{
		if( flag )
		{
			thePlayer.SetBehaviorVariable( 'inJumpState', 1.f );
			//BlockAction(EIAB_Interactions, 'InsideCombatAction' );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'inJumpState', 0.f );
			//UnblockAction(EIAB_Interactions, 'InsideCombatAction' );
		}
		
		bIsInCombatAction = flag;
		SetBehaviorVariable( 'isInCombatActionForOverlay', (float)bIsInCombatAction );
		//LogChannel('xxx', flag);
	}
	
	public function SetBIsInCombatActionFriendly(flag : bool)
	{
		bIsInCombatActionFriendly = flag;
	}
	
	public function RaiseCombatActionFriendlyEvent() : bool
	{
		if ( CanRaiseCombatActionFriendlyEvent() )
		{
			if( RaiseEvent('CombatActionFriendly') )
			{
				SetBIsInCombatActionFriendly( true ); 
				return true;
			}
		}
		
		return false;
	}
	
	public function CanRaiseCombatActionFriendlyEvent( optional isShootingCrossbow : bool ) : bool
	{
		var raiseEvent 		: bool = false;
		var playerWitcher 	: W3PlayerWitcher;
		var itemId 			: SItemUniqueId;
		
		playerWitcher = (W3PlayerWitcher)this;
	
		if ( !playerWitcher )
			return true;
		else if ( isShootingCrossbow )
			return true;
		else if ( thePlayer.IsOnBoat() && !thePlayer.IsCombatMusicEnabled() )
			return true; 
		else
		{
			itemId = thePlayer.GetSelectedItemId();
			if ( !( playerWitcher.IsHoldingItemInLHand() && inv.IsIdValid(itemId) && !inv.IsItemCrossbow(itemId) && !inv.IsItemBomb(itemId) ) )
 				return true;
		}
			
		thePlayer.DisplayActionDisallowedHudMessage( EIAB_Undefined,,, true );	
		return false;		
	}
	
	//returns true if player can parry given attack type
	final function CanParryAttack() : bool
	{		
		return inputHandler.IsActionAllowed(EIAB_Parry) && ParryCounterCheck() && !IsCurrentlyDodging() && super.CanParryAttack(); 
	}
	
	//returns true if player can perform parry or counter actions
	protected function ParryCounterCheck() : bool
	{
		var combatActionType  : int;
		combatActionType = (int)GetBehaviorVariable( 'combatActionType'); 
		
		if ( combatActionType == (int)CAT_Parry )
			return true;
			
		if ( GetBIsCombatActionAllowed() )
			return true;
			
		if ( thePlayer.IsInCombatAction() && combatActionType == (int)CAT_Dodge )
		{
			if ( thePlayer.CanPlayHitAnim() && thePlayer.IsThreatened() )
			{
				return true;
			}
		}
		
		return false;
	}
	
	//IF PLAYER IS MOUNTED
	function SetIsHorseMounted( isOn : bool )
	{
		isHorseMounted = isOn;
	}
	
	function GetIsHorseMounted() : bool
	{
		return isHorseMounted;
	}
	
	//IF PLAYER HAS A COMPANION
	function SetIsCompanionFollowing( isOn : bool )
	{
		isCompanionFollowing = isOn;
	}
	function GetIsCompanionFollowing() : bool
	{
		return isCompanionFollowing;
	}

	function SetStartScreenIsOpened( isOpened : bool) : void // #B
	{
		bStartScreenIsOpened = isOpened;
		
		// this should be moved to more appropriate place
		if( isOpened )
			theSound.EnterGameState( ESGS_MusicOnly );
		else
			theSound.LeaveGameState( ESGS_MusicOnly );
	}
	
	function GetStartScreenIsOpened( ) : bool //#B
	{
		return bStartScreenIsOpened;
	}
	
	function SetEndScreenIsOpened( isOpened : bool) : void // #B
	{
		bEndScreenIsOpened = isOpened;
		
		// this should be moved to more appropriate place
		if( isOpened )
			theSound.EnterGameState( ESGS_MusicOnly );
		else
			theSound.LeaveGameState( ESGS_MusicOnly );
	}
	
	function GetEndScreenIsOpened( ) : bool //#B
	{
		return bEndScreenIsOpened;
	}

	function SetStartScreenFadeDuration( fadeTime : float) : void // #B
	{
		fStartScreenFadeDuration = fadeTime;
	}	

	function GetStartScreenFadeDuration( ) : float // #B
	{
		return fStartScreenFadeDuration;
	}
	
	function SetStartScreenFadeInDuration( fadeTime : float) : void // #B
	{
		fStartScreenFadeInDuration = fadeTime;
	}	

	function GetStartScreenFadeInDuration( ) : float // #B
	{
		return fStartScreenFadeInDuration;
	}
	
	function SetStartScreenEndWithBlackScreen( value : bool ) : void // #B
	{
		bStartScreenEndWithBlackScreen = value;
	}	
	
	function GetStartScreenEndWithBlackScreen( ) : bool // #B
	{
		return bStartScreenEndWithBlackScreen;
	}
	
	//--------------------------------- Fast Travel Popup #B --------------------------------------
	//---------------------------------------------------------------------------------------------	
	public function CanStartTalk() : bool
	{
		var stateName : name;
		stateName = thePlayer.GetCurrentStateName();
		return ( stateName != 'CombatSteel' && stateName != 'CombatSilver' && stateName != 'CombatFists' );	
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// @movement
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public function UpdateRequestedDirectionVariables_PlayerDefault()
	{
		UpdateRequestedDirectionVariables( rawPlayerHeading, GetHeading() );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Combat Actions
	////////////////////////////////////////////////////////////////////////////////////////// 
	
	function SetGuarded( flag : bool )
	{
		super.SetGuarded(flag);
		SetParryEnabled(IsGuarded());
		
		if ( !thePlayer.IsInCombat() )
		{
			if ( flag )
				OnDelayOrientationChange();
			else
				thePlayer.EnableManualCameraControl( true, 'Guard' );
		}
		
		/*if ( (W3ReplacerCiri)this )
		{
			if ( flag )
			{
				specialParryEntityTemplate = (CEntityTemplate)LoadResource('ciri_force');
				specialParryEntity = theGame.CreateEntity(specialParryEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation());
				specialParryEntity.CreateAttachment(this);
			}
			else if( specialParryEntity )
			{
				specialParryEntity.Destroy();
				specialParryEntity = NULL;
			}
		}*/
	}
	
	//private var specialParryEntityTemplate : CEntityTemplate;
	//private var specialParryEntity : CEntity;
	
	/*
	public function IsGuarded() : bool
	{
		return IsLockedToTarget();
	}*/
	
	event OnDelayOrientationChange();
	
	function SetBIsInputAllowed( flag : bool, sourceName : name )
	{
		bIsInputAllowed = flag;
		
		if(flag)
		{
			debug_BIsInputAllowedLocks.Clear();
		}
		else
		{
			debug_BIsInputAllowedLocks.PushBack(sourceName);
		}
	}
	
	function GetBIsInputAllowed() : bool
	{
		return bIsInputAllowed;
	}
	
	function SetBIsFirstAttackInCombo( flag : bool )
	{
		bIsFirstAttackInCombo = flag;
	}
	
	function IsInHitAnim() : bool
	{
		return bIsInHitAnim;
	}
	
	function SetIsInHitAnim( flag : bool )
	{
		bIsInHitAnim = flag;
	}	
	
	function SetInputModuleNeededToRun( _inputModuleNeededToRun : float )
	{
		inputModuleNeededToRun = ClampF(_inputModuleNeededToRun, 0.5f, 1.f);
	}
	
	function GetInputModuleNeededToRun() : float
	{
		var configValue:string;
		
		if (inputModuleNeededToRun == -1.0)
		{
			configValue = ((CInGameConfigWrapper)theGame.GetInGameConfigWrapper()).GetVarValue('Controls', 'LeftStickSensitivity');
			inputModuleNeededToRun = StringToFloat(configValue, 0.7);
		}
		
		return inputModuleNeededToRun;
	}
	
/////////////////////////////////////////////////////////////////////////////////
	
	event OnAnimEvent_AllowInput( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart )
		{
			//LogChannel( 'AllowInput', "True: AET_DurationStart" );
			SetBIsInputAllowed( true, 'AnimEventAllowInputStart' );
		}
		/*else if ( animEventType == AET_DurationEnd )
		{
			//LogChannel( 'AllowInput', "False: AET_DurationEnd" );
			SetBIsInputAllowed( false, 'AnimEventAllowInputEnd' );
		}*/
	}
	
	event OnAnimEvent_DisallowInput( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart )
		{
			SetBIsInputAllowed( false, 'AnimEventDisallowInputStart' );
		}
		else if ( animEventType == AET_DurationEnd )
		{
			SetBIsInputAllowed( true, 'AnimEventDisallowInputEnd' );
		}
	}
	
	event OnAnimEvent_DisallowHitAnim( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationEnd )
		{
			SetCanPlayHitAnim( true );	
		}
		else if ( ( GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack && !this.bIsFirstAttackInCombo )
				|| ( GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Dodge && GetBehaviorVariable( 'isRolling' ) == 0.f ) )
		{
		}
		else
		{
			SetCanPlayHitAnim( false );
		}
	}
	
	event OnAnimEvent_AllowHitAnim( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetCanPlayHitAnim( true );
	}
	
	event OnAnimEvent_AllowBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetCanPlayHitAnim( true );	
	}
	
	event OnAnimEvent_QuickSlotItems( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var itemEntity : W3UsableItem;
		
		if( animEventName == 'EquipItem' && currentlyUsedItem )
		{
			inv.MountItem( currentlyEquipedItem, true );
		}
		else if( animEventName == 'UseItem' && currentlyUsedItem )
		{
			currentlyUsedItem.OnUsed( this );
		}
		else if( animEventName == 'HideItem' )
		{
			inv.UnmountItem( currentlyEquipedItem, true );
			currentlyEquipedItem = GetInvalidUniqueId();
		}
		else if( animEventName == 'EquipItemL'  )
		{
			if ( thePlayer.IsHoldingItemInLHand() ) 
			{
				inv.MountItem( currentlyEquipedItemL, true );
				
				// Start task, that will wait until item is spawned, then it will call OnUsed() on spawned item in case,
				// that it will be allowed to do so.
				// One allows to use item when calls AllowUseSelectedItem().
				thePlayer.StartWaitForItemSpawnAndProccesTask();
			}
		}
		else if( ( animEventName == 'UseItemL' || animEventName == 'ItemUseL') )
		{
			// Flag that we want to use selected item ASAP.
			// This will be catched by WaitForItemSpawnAndProccesTask.
			thePlayer.AllowUseSelectedItem();
		}
		else if( animEventName == 'HideItemL' )
		{
			// Kill the task.
			thePlayer.KillWaitForItemSpawnAndProccesTask();
		
			if ( currentlyUsedItemL )
			{
				currentlyUsedItemL.OnHidden( this );
				currentlyUsedItemL.SetVisibility( false );
			}
			inv.UnmountItem( currentlyEquipedItemL, true );
			
		}
	}
	
	event OnAnimEvent_SetRagdoll( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( ( ( CMovingPhysicalAgentComponent ) this.GetMovingAgentComponent() ).HasRagdoll() )
		{
			if ( this == thePlayer && !thePlayer.IsOnBoat() )
			{
				TurnOnRagdoll();
				//enabledRagdoll = true;
			}
		}
	}
	
	//called from Knockdown anim to trigger ragdoll earlier if player is in air (no tripping anim part)
	event OnAnimEvent_InAirKDCheck( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if(IsInAir())
		{
			TurnOnRagdoll();
		}
	}
	
	private var illusionMedallion : array<SItemUniqueId>;
	
	event OnAnimEvent_EquipMedallion( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		illusionMedallion.Clear();
		illusionMedallion = inv.GetItemsByName( 'Illusion Medallion' );
		inv.MountItem( illusionMedallion[0], true );
	}
	
	event OnAnimEvent_HideMedallion( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		inv.UnmountItem( illusionMedallion[0], true );
		illusionMedallion.Clear();
	}
	
/////////////////////////////////////////////////////////////////////////////////

	
	event OnDiving(dir : int){}
	event OnDive(){}
	
	//it's handled only inside swimming state, so it will return false while in AimThrow state
	event OnCheckDiving()				{ return false; }
	event OnAllowShallowWaterCheck()	{ return true; }
	event OnCheckUnconscious()			{ return false; }
	event OnAllowSwimmingSprint()		{ return false; }
	event OnAllowedDiveDown()			{ return true; }
	event OnDiveInput( divePitch : float ){}
	
	event OnIsCameraUnderwater()
	{
		//uncomment if you want this check to work all the time, otherwise it will be only checked when geralt is in swimming state
		/*
		var cameraPosition : Vector;
		var waterLevel : float;
		var diff : float;
		
		cameraPosition = theCamera.GetCameraPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel(cameraPosition);
		diff = cameraPosition.Z - waterLevel;
		
		if ( diff >= 0 )
		{
			return true;
		}
		else if ( diff < 0 )
		{
			return false;
		}
		*/
		return false;
	}
	
			
	////////////////////////////////////0////////////////////////////////////
	//
	// Jumping
	//
	///////////////////////////////////////////////////////////////////////////
	
	event OnHitGround()
	{
	}
	
	event OnHitCeiling()
	{		
	}
	
	///////////////////////////////////////////////////////////////////////////
	//
	// Different terrain types handling
	//
	///////////////////////////////////////////////////////////////////////////
	
	private function SetTerrModifier( val : float )
	{
		SetBehaviorVariable( 'TerrainModifier', val );
		terrModifier = val;
	}
	
	private function SetTerrTypeOne( type : ETerrainType )
	{
		SetBehaviorVariable( 'TerrainType', (int)type );
		terrTypeOne = type;
	}
	
	private function SetTerrTypeTwo( type : ETerrainType )
	{
		SetBehaviorVariable( 'TerrainTypeBlended', (int)type );
		terrTypeTwo = type;
	}
	
	public function SteppedOnTerrain( type : ETerrainType )
	{	
		// Check if we stepped on different terrain
		if( type != terrTypeOne && type != terrTypeTwo )
		{
			if( terrTypeOne == prevTerrType )
			{
				// We just stepped off terrain with type 'terrTypeOne' - blend from it to the new one
				SetTerrTypeTwo( type );
				SetTerrModifier( 0.01f );
			}
			else if( terrTypeTwo == prevTerrType )
			{
				SetTerrTypeOne( type );
				SetTerrModifier( 0.99f );
			}
		}
		
		if( type == terrTypeOne )
		{
			terrModifier -= 0.1f;
		}
		else if( type == terrTypeTwo )
		{
			terrModifier += 0.1f;
		}
		
		terrModifier = ClampF( terrModifier, 0.01f, 0.99f );
		
		SetBehaviorVariable( 'TerrainModifier', terrModifier );
		
		prevTerrType = type;
	}
	
	/////////////////////////////////////////////////////////
	//
	// Players comments
	//
	/////////////////////////////////////////////////////////
	
	function PlayerCanComment() : bool
	{
		var time : EngineTime;
		time = commentaryLastTime + commentaryCooldown;
		
		return theGame.GetEngineTime() > time;
	}
	
	function PlayerCanPlayMonsterCommentary() : bool
	{
		var time : EngineTime;
		var commentaryMonsterCooldown : float;
		
		commentaryMonsterCooldown = 120.0f;
		time = commentaryLastTime + commentaryMonsterCooldown;
		
		return theGame.GetEngineTime() > time;
	}
	
	function PlayerCommentary( commentaryType : EPlayerCommentary, optional newCommentaryCooldown : float ) 
	{
		var actor		: CPlayer = thePlayer;
		var activeActor : CEntity;
		var hud : CR4ScriptedHud;

		hud = (CR4ScriptedHud)theGame.GetHud();
		activeActor = (CEntity) actor;
		
		commentaryLastTime = theGame.GetEngineTime();
		
		if( newCommentaryCooldown > 0.0f )
		{
			commentaryCooldown = newCommentaryCooldown;
		}
		else
		{
			commentaryCooldown = 20.0f;
		}
		if( commentaryType == PC_MedalionWarning /*&& !thePlayer.IsNotGeralt()*/ )
		{
			PlayVoiceset( 1, "warning" /*input name*/ );
			hud.ShowOneliner( "My medallion", activeActor );
			AddTimer( 'TurnOffOneliner', 3.5f );
			
		}
		else if( commentaryType == PC_MonsterReaction /*&& !thePlayer.IsNotGeralt()*/ )
		{
			PlayVoiceset( 1, "monster" );
		}
		/*else if ( commentaryType == PC_NCFMClueCommentTrace )
		{
			PlayVoiceset( 1, "over there" );
			hud.ShowOneliner( "I found a trace!", activeActor );
			AddTimer( 'TurnOffOneliner', 3.5f );
			
		}
		else if ( commentaryType == PC_NCFMClueCommentRemainings )
		{
			PlayVoiceset( 1, "what is it" );
			hud.ShowOneliner( "What's that?", activeActor );
			AddTimer( 'TurnOffOneliner', 3.5f );
		}
		else if ( commentaryType == PC_NCFMClueSoundDetected )
		{
			PlayVoiceset( 1, "sound detected" );
			hud.ShowOneliner( "So, there you're hiding!", activeActor );
			AddTimer( 'TurnOffOneliner', 3.5f );
		}*/
		else if( commentaryType == PC_ColdWaterComment )
		{
			//PlayVoiceset( 1, "I am freezing" );
			hud.ShowOneliner( "Damn, it's cold!", activeActor );
			AddTimer( 'TurnOffOneliner', 3.5f );
		}
	}
	
	timer function TurnOffOneliner( deltaTime : float , id : int)
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		hud.HideOneliner( this );
	}
	
	///////////////////////////////////////////////////////////////////////
	//
	// Other
	//
	///////////////////////////////////////////////////////////////////////
	
	public function CanPlaySpecificVoiceset() : bool 					{ return canPlaySpecificVoiceset; }
	public function SetCanPlaySpecificVoiceset( val : bool ) 			{ canPlaySpecificVoiceset = val; }
	timer function ResetSpecificVoicesetFlag( dt : float, id : int )	{ SetCanPlaySpecificVoiceset( true ); }
	
	function GetThreatLevel() : int
	{
		return 5;
	}
	
	function GetBIsCombatActionAllowed() : bool
	{
		return true;
	}
	
	import function SetEnemyUpscaling( b : bool );
	import public function GetEnemyUpscaling() : bool;
	
	public function SetAutoCameraCenter( on : bool ) { autoCameraCenterToggle = on; }
	public function GetAutoCameraCenter() : bool
	{
		return autoCameraCenterToggle || IsCameraLockedToTarget();
	}

	public function SetVehicleCachedSign( sign : ESignType ) { vehicleCachedSign = sign; }
	public function GetVehicleCachedSign() : ESignType { return vehicleCachedSign; }
		
	public function GetMoney() : int
	{
		return inv.GetMoney();
	}
	
	public function AddMoney(amount : int) 
	{
		inv.AddMoney(amount);
	}
	
	public function RemoveMoney(amount : int) 
	{
		inv.RemoveMoney(amount);
	}

	function GetThrowItemMode() : bool //#B
	{
		return false;
	}
	
	function GetEquippedSign() : ESignType
	{
		return ST_None;
	}
	
	function GetCurrentlyCastSign() : ESignType
	{
		return ST_None;
	}
	
	function IsCastingSign() : bool
	{
		return false;
	}
	
	function IsCurrentSignChanneled() : bool
	{
		return false;
	}
	
	// #B
	function OnRadialMenuItemChoose( selectedItem : string )
	{
		// abstract
	}
	
	// #B
	public function UpdateQuickSlotItems() : bool // #B deprecated
	{
		return false;
	}
	
	// #B
	public function SetUpdateQuickSlotItems(bUpdate : bool )  // #B deprecated
	{
		// abstract
	}
	
	public function RemoveAllPotionEffects(optional skip : array<CBaseGameplayEffect>)
	{
		effectManager.RemoveAllPotionEffects(skip);
	}
	
	public function BreakPheromoneEffect() : bool
	{
		if( thePlayer.HasBuff( EET_PheromoneNekker ) || thePlayer.HasBuff( EET_PheromoneDrowner ) || thePlayer.HasBuff( EET_PheromoneBear ) )
		{
			thePlayer.RemoveBuff( EET_PheromoneNekker );
			thePlayer.RemoveBuff( EET_PheromoneDrowner );
			thePlayer.RemoveBuff( EET_PheromoneBear );
		}
		
		return true;
	}
	
	//--------------------------------- QUEST TRACKER #B --------------------------------------
		
	public function GetCurrentTrackedQuestSystemObjectives() : array<SJournalQuestObjectiveData>
	{
		return currentTrackedQuestSystemObjectives;
	}

	public function SetCurrentTrackedQuestSystemObjectives(cTQO : array<SJournalQuestObjectiveData>) : void
	{
		var i : int;
		
		currentTrackedQuestSystemObjectives = cTQO;
		
		for(i = 0; i < cTQO.Size(); i+=1)
		{
			currentTrackedQuestSystemObjectives[i] = cTQO[i];
		}
	}
	
	public function GetCurrentTrackedQuestObjectives() : array<SJournalQuestObjectiveData>
	{
		return currentTrackedQuestObjectives;
	}

	public function SetCurrentTrackedQuestObjectives(cTQO : array<SJournalQuestObjectiveData>) : void
	{
		var i : int;
	
		currentTrackedQuestObjectives = cTQO;
		
		for(i = 0; i < cTQO.Size(); i+=1)
		{
			currentTrackedQuestObjectives[i] = cTQO[i];
		}
	}

	public function GetCurrentTrackedQuestGUID() : CGUID
	{
		return currentTrackedQuestGUID;
	}
	
	public function SetCurrentTrackedQuestGUID(cTQG : CGUID) : void
	{
		currentTrackedQuestGUID = cTQG;
	}
	
	//@FIXME BIDON - fix the journal to send proper data to ui.
	public function HAXCheckIfNew(checkGUID : CGUID ):bool
	{
		var i : int;
		for( i = 0; i < HAXNewObjTable.Size(); i += 1)
		{
			if( HAXNewObjTable[i] == checkGUID)
			{
				return false;
			}
		}
		
		HAXNewObjTable.PushBack(checkGUID);
		return true;
	}
			
	public function GetShowHud() : bool //#B
	{
		return true;
	}

	public function SetShowHud( value : bool ) : void
	{
		//abstract
	}
	
	//--------------------------------- COMPANION MODULE #B --------------------------------------
	
	//--------------------------------- DEBUG --------------------------------------
	
	function DebugKillAll()
	{
		var i, enemiesSize : int;
		var actors : array<CActor>;
		
		actors = GetNPCsAndPlayersInRange(20, 20, '', FLAG_Attitude_Hostile);
		enemiesSize = actors.Size();
		
		for( i = 0; i < enemiesSize; i += 1 )
			actors[i].Kill( 'Debug', false, this);					
	}
	
	public function DebugTeleportToPin( optional posX : float , optional posY : float )
	{
		var mapManager 		: CCommonMapManager = theGame.GetCommonMapManager();
		var rootMenu		: CR4Menu;
		var mapMenu			: CR4MapMenu;
		var currWorld		: CWorld = theGame.GetWorld();
		var destWorldPath	: string;
		var id				: int;
		var area			: int;
		var type			: int;
		var position		: Vector;
		var rotation 		: EulerAngles;
		var goToCurrent		: Bool = false;
		
		rootMenu = (CR4Menu)theGame.GetGuiManager().GetRootMenu();
		
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			
			if ( mapMenu )
			{
				position.X = posX;
				position.Y = posY;
				destWorldPath = mapManager.GetWorldPathFromAreaType( mapMenu.GetShownMapType() );
				
				if ( mapMenu.IsCurrentAreaShown() )
				{
					goToCurrent = true;
				}
				
				rootMenu.CloseMenu();
			}
		}
		else
		{	
			mapManager.GetUserMapPinByIndex( 0, id, area, position.X, position.Y, type );		
			destWorldPath = mapManager.GetWorldPathFromAreaType( area );
			
			if (destWorldPath == "" || destWorldPath == currWorld.GetPath() )
			{
				goToCurrent = true;
			}
		}
		
		if ( goToCurrent )
		{
			currWorld.NavigationComputeZ(position, -500.f, 500.f, position.Z);
			currWorld.NavigationFindSafeSpot(position, 0.5f, 20.f, position);
				
			Teleport( position );
		
			if ( !currWorld.NavigationComputeZ(position, -500.f, 500.f, position.Z) )		
			{
				AddTimer( 'DebugWaitForNavigableTerrain', 1.f, true );
			}
		}
		else
		{
			theGame.ScheduleWorldChangeToPosition( destWorldPath, position, rotation );
			AddTimer( 'DebugWaitForNavigableTerrain', 1.f, true, , , true );
		}
	}
	
	timer function DebugWaitForNavigableTerrain( delta : float, id : int )
	{
		var position 	: Vector = GetWorldPosition();
		
		if ( theGame.GetWorld().NavigationComputeZ(position, -1000.f, 1000.f, position.Z) )
		{
			RemoveTimer( 'DebugWaitForNavigableTerrain' );
			theGame.GetWorld().NavigationFindSafeSpot(position, 0.5f, 20.f, position);
			Teleport( position );
		}
	}
	
	event OnHitByObstacle( obstacleComponent : CComponent )
	{
		obstacleComponent.SetEnabled( false );
	}
	
	public function DEBUGGetDisplayRadiusMinimapIcons():bool //#B
	{
		return _DEBUGDisplayRadiusMinimapIcons;
	}

	public function DEBUGSetDisplayRadiusMinimapIcons(inValue : bool):void //#B
	{
		_DEBUGDisplayRadiusMinimapIcons = inValue;
	}
	
	public function Dbg_UnlockAllActions()
	{
		inputHandler.Dbg_UnlockAllActions();
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////  @critical states  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnCriticalStateAnimStopGlobalHack()
	{
		var buff : CBaseGameplayEffect;
		
		if(!csNormallyStoppedBuff)
		{
			if(effectManager)
			{
				buff = effectManager.GetCurrentlyAnimatedCS();
				if(buff)
					OnCriticalStateAnimStop();
			}						
		}
		else
		{
			csNormallyStoppedBuff = false;
		}
	}
	
	private var csNormallyStoppedBuff : bool;
	
	//called when critical buff's animation ends
	event OnCriticalStateAnimStop()
	{
		csNormallyStoppedBuff = true;
			
		SetBehaviorVariable( 'bCriticalState', 0);
		CriticalStateAnimStopped(false);
		if ( this.IsRagdolled() ) // failSafe
			this.RaiseForceEvent('RecoverFromRagdoll');
		return true;
	}
	
	event OnRecoverFromRagdollEnd()
	{
		if ( this.IsRagdolled() ) // failSafe
			this.SetKinematic(true);
	}
	
	public function ReapplyCriticalBuff() 
	{
		var buff : CBaseGameplayEffect;
		
		//reapply critical buff if any
		buff = ChooseCurrentCriticalBuffForAnim();
		if(buff)
		{
			LogCritical("Reapplying critical <<" + buff.GetEffectType() + ">> after finished CombatAction (End)");
			StartCSAnim(buff);
		}
	}
	
	timer function ReapplyCSTimer(dt : float, id : int)
	{
		ReapplyCriticalBuff();
	}
	
	public function IsInAgony() : bool					{return false;}
	
	public function GetOTCameraOffset() : float
	{
		return oTCameraOffset;
	}
	
	public function IsKnockedUnconscious() : bool	
	{
		return OnCheckUnconscious();
	}
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	
	function IsSailing() : bool
	{
		return IsUsingVehicle() && GetCurrentStateName() == 'Sailing';
	}
	
	final function spawnBoatAndMount()
	{
		var entities : array<CGameplayEntity>;
		var vehicle : CVehicleComponent;
		var i : int;
		var boat : W3Boat;
		var ent : CEntity;
		var player : Vector;
		var rot : EulerAngles;
		var template : CEntityTemplate;
		
		FindGameplayEntitiesInRange( entities, thePlayer, 10, 10, 'vehicle' );
		
		for( i = 0; i < entities.Size(); i = i + 1 )
		{
			boat = ( W3Boat )entities[ i ];
			if( boat )
			{
				vehicle = ( CVehicleComponent )( boat.GetComponentByClassName( 'CVehicleComponent' ) );
				if ( vehicle )
				{
					vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
				}
				
				return;
			}
		}

		rot = thePlayer.GetWorldRotation();	
		player = thePlayer.GetWorldPosition();
		template = (CEntityTemplate)LoadResource( 'boat' );
		player.Z = 0.0f;

		ent = theGame.CreateEntity(template, player, rot, true, false, false, PM_Persist );
		
		if( ent )
		{
			vehicle = ( CVehicleComponent )( ent.GetComponentByClassName( 'CVehicleComponent' ) );
			if ( vehicle )
			{
				vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
				boat = ( W3Boat )ent;
				if( boat )
				{
					boat.SetTeleportedFromOtherHUB( true );
				}
			}
		}
	}
	
	timer function DelayedSpawnAndMountBoat( delta : float, id : int )
	{
		spawnBoatAndMount();
		RemoveTimer( 'DelayedSpawnAndMountBoat' );
	}
}
