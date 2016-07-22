/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Tomasz Czarny
/**			 Tomek Kozera
/**			 Marwin So
/***********************************************************************/

class CPlayerInput 
{
	private saved 	var actionLocks 	: array<array<SInputActionLock>>;		//locks for actions
	
	private	var	totalCameraPresetChange : float;		default totalCameraPresetChange = 0.0f;
	private var potAction 				: SInputAction;
	private var potPress 				: bool;
	private var	debugBlockSourceName	: name;			default	debugBlockSourceName	= 'PLAYER';
	private var holdFastMenuInvoked     : bool;			default holdFastMenuInvoked = false;			//to handle touchpad press/hold releases
	private var potionUpperHeld, potionLowerHeld : bool;		//set when potion switch button is being held
	private var potionModeHold : bool;							//set when potion switching mode is set to Hold
	
		default potionModeHold = true;
		
	public function Initialize(isFromLoad : bool, optional previousInput : CPlayerInput)
	{		
		var missingLocksCount, i : int;
		var dummy : array<SInputActionLock>;

		if(previousInput)
		{
			actionLocks = previousInput.actionLocks;
		}
		else
		{
			if(!isFromLoad)
			{
				actionLocks.Grow(EnumGetMax('EInputActionBlock')+1);
			}
			else
			{
				missingLocksCount = EnumGetMax('EInputActionBlock') + 1 - actionLocks.Size();
				for ( i = 0; i < missingLocksCount; i += 1 )
				{
					actionLocks.PushBack( dummy );
				}
			}
		}
		
		theInput.RegisterListener( this, 'OnCommSprint', 'Sprint' );
		theInput.RegisterListener( this, 'OnCommSprintToggle', 'SprintToggle' );
		theInput.RegisterListener( this, 'OnCommWalkToggle', 'WalkToggle' );
		theInput.RegisterListener( this, 'OnCommGuard', 'Guard' );
		
		// horse
		theInput.RegisterListener( this, 'OnCommSpawnHorse', 'SpawnHorse' );
		
		//potions
		//theInput.RegisterListener( this, 'OnCommDrinkPot', 'DrinkPotion' ); -not used anymore, handles one on tap and second on double tap
		theInput.RegisterListener( this, 'OnCommDrinkPotion1', 'DrinkPotion1' );
		theInput.RegisterListener( this, 'OnCommDrinkPotion2', 'DrinkPotion2' );
		theInput.RegisterListener( this, 'OnCommDrinkPotion3', 'DrinkPotion3' );
		theInput.RegisterListener( this, 'OnCommDrinkPotion4', 'DrinkPotion4' );
		theInput.RegisterListener( this, 'OnCommDrinkpotionUpperHeld', 'DrinkPotionUpperHold' );
		theInput.RegisterListener( this, 'OnCommDrinkpotionLowerHeld', 'DrinkPotionLowerHold' );
		
		//weapon draw/sheathe
		theInput.RegisterListener( this, 'OnCommSteelSword', 'SteelSword' );
		theInput.RegisterListener( this, 'OnCommSilverSword', 'SilverSword' );
		theInput.RegisterListener( this, 'OnCommSheatheAny', 'SwordSheathe' );
		theInput.RegisterListener( this, 'OnCommSheatheSilver', 'SwordSheatheSilver' );
		theInput.RegisterListener( this, 'OnCommSheatheSteel', 'SwordSheatheSteel' );
		
		theInput.RegisterListener( this, 'OnToggleSigns', 'ToggleSigns' );
		theInput.RegisterListener( this, 'OnSelectSign', 'SelectAard' );
		theInput.RegisterListener( this, 'OnSelectSign', 'SelectYrden' );
		theInput.RegisterListener( this, 'OnSelectSign', 'SelectIgni' );
		theInput.RegisterListener( this, 'OnSelectSign', 'SelectQuen' );
		theInput.RegisterListener( this, 'OnSelectSign', 'SelectAxii' );
		
		
		//character panels
		theInput.RegisterListener( this, 'OnCommDeckEditor', 'PanelGwintDeckEditor' );
		theInput.RegisterListener( this, 'OnCommMenuHub', 'HubMenu' );
		theInput.RegisterListener( this, 'OnCommPanelInv', 'PanelInv' );
		theInput.RegisterListener( this, 'OnCommHoldFastMenu', 'HoldFastMenu' );
		theInput.RegisterListener( this, 'OnCommPanelChar', 'PanelChar' );
		theInput.RegisterListener( this, 'OnCommPanelMed', 'PanelMed' );
		theInput.RegisterListener( this, 'OnCommPanelMap', 'PanelMap' );
		theInput.RegisterListener( this, 'OnCommPanelMapPC', 'PanelMapPC' );
		theInput.RegisterListener( this, 'OnCommPanelJour', 'PanelJour' );
		theInput.RegisterListener( this, 'OnCommPanelAlch', 'PanelAlch' );
		theInput.RegisterListener( this, 'OnCommPanelGlossary', 'PanelGlossary' );
		theInput.RegisterListener( this, 'OnCommPanelBestiary', 'PanelBestiary' );
		theInput.RegisterListener( this, 'OnCommPanelMeditation', 'PanelMeditation' );
		theInput.RegisterListener( this, 'OnCommPanelCrafting', 'PanelCrafting' );
		theInput.RegisterListener( this, 'OnShowControlsHelp', 'ControlsHelp' );
		theInput.RegisterListener( this, 'OnCommPanelUIResize', 'PanelUIResize' );
		
		theInput.RegisterListener( this, 'OnCastSign', 'CastSign' );
		theInput.RegisterListener( this, 'OnExpFocus', 'Focus' );
		theInput.RegisterListener( this, 'OnExpMedallion', 'Medallion' );
		
		//boat
		theInput.RegisterListener( this, 'OnBoatDismount', 'BoatDismount' );
		
		theInput.RegisterListener( this, 'OnDiving', 'DiveDown' );
		theInput.RegisterListener( this, 'OnDiving', 'DiveUp' );
		theInput.RegisterListener( this, 'OnDivingDodge', 'DiveDodge' );
		
		// PC only
		theInput.RegisterListener( this, 'OnCbtSpecialAttackWithAlternateLight', 'SpecialAttackWithAlternateLight' );
		theInput.RegisterListener( this, 'OnCbtSpecialAttackWithAlternateHeavy', 'SpecialAttackWithAlternateHeavy' );
		theInput.RegisterListener( this, 'OnCbtAttackWithAlternateLight', 'AttackWithAlternateLight' );
		theInput.RegisterListener( this, 'OnCbtAttackWithAlternateHeavy', 'AttackWithAlternateHeavy' );
		
		theInput.RegisterListener( this, 'OnCbtAttackLight', 'AttackLight' );
		theInput.RegisterListener( this, 'OnCbtAttackHeavy', 'AttackHeavy' );
		theInput.RegisterListener( this, 'OnCbtSpecialAttackLight', 'SpecialAttackLight' );
		theInput.RegisterListener( this, 'OnCbtSpecialAttackHeavy', 'SpecialAttackHeavy' );
		theInput.RegisterListener( this, 'OnCbtDodge', 'Dodge' );
		theInput.RegisterListener( this, 'OnCbtRoll', 'CbtRoll' );
		theInput.RegisterListener( this, 'OnMovementDoubleTap', 'MovementDoubleTapW' );
		theInput.RegisterListener( this, 'OnMovementDoubleTap', 'MovementDoubleTapS' );
		theInput.RegisterListener( this, 'OnMovementDoubleTap', 'MovementDoubleTapA' );
		theInput.RegisterListener( this, 'OnMovementDoubleTap', 'MovementDoubleTapD' );
		theInput.RegisterListener( this, 'OnCbtLockAndGuard', 'LockAndGuard' );
		theInput.RegisterListener( this, 'OnCbtCameraLockOrSpawnHorse', 'CameraLockOrSpawnHorse' );
		theInput.RegisterListener( this, 'OnCbtCameraLock', 'CameraLock' );
		theInput.RegisterListener( this, 'OnCbtComboDigitLeft', 'ComboDigitLeft' );
		theInput.RegisterListener( this, 'OnCbtComboDigitRight', 'ComboDigitRight' );
		
		
		// Ciri
		theInput.RegisterListener( this, 'OnCbtCiriSpecialAttack', 'CiriSpecialAttack' );
		theInput.RegisterListener( this, 'OnCbtCiriAttackHeavy', 'CiriAttackHeavy' );
		theInput.RegisterListener( this, 'OnCbtCiriSpecialAttackHeavy', 'CiriSpecialAttackHeavy' );
		theInput.RegisterListener( this, 'OnCbtCiriDodge', 'CiriDodge' );
		theInput.RegisterListener( this, 'OnCbtCiriDash', 'CiriDash' );
		
		//throwing items, casting signs
		theInput.RegisterListener( this, 'OnCbtThrowItem', 'ThrowItem' );
		theInput.RegisterListener( this, 'OnCbtThrowItemHold', 'ThrowItemHold' );
		theInput.RegisterListener( this, 'OnCbtThrowCastAbort', 'ThrowCastAbort' );
		
		//replacer only
		theInput.RegisterListener( this, 'OnCiriDrawWeapon', 'CiriDrawWeapon' );
		theInput.RegisterListener( this, 'OnCiriDrawWeapon', 'CiriDrawWeaponAlternative' );
		theInput.RegisterListener( this, 'OnCiriHolsterWeapon', 'CiriHolsterWeapon' );
		
		//debug
		if( !theGame.IsFinalBuild() )
		{
			theInput.RegisterListener( this, 'OnDbgSpeedUp', 'Debug_SpeedUp' );
			theInput.RegisterListener( this, 'OnDbgHit', 'Debug_Hit' );
			theInput.RegisterListener( this, 'OnDbgKillTarget', 'Debug_KillTarget' );
			theInput.RegisterListener( this, 'OnDbgKillAll', 'Debug_KillAllEnemies' );
			theInput.RegisterListener( this, 'OnDbgKillAllTargetingPlayer', 'Debug_KillAllTargetingPlayer' );
			theInput.RegisterListener( this, 'OnCommPanelFakeHud', 'PanelFakeHud' );
			theInput.RegisterListener( this, 'OnDbgTeleportToPin', 'Debug_TeleportToPin' );
		}
		
		// other
		theInput.RegisterListener( this, 'OnChangeCameraPreset', 'CameraPreset' );
		theInput.RegisterListener( this, 'OnChangeCameraPresetByMouseWheel', 'CameraPresetByMouseWheel' );
		theInput.RegisterListener( this, 'OnMeditationAbort', 'MeditationAbort');
		
		theInput.RegisterListener( this, 'OnFastMenu', 'FastMenu' );		
		theInput.RegisterListener( this, 'OnIngameMenu', 'IngameMenu' );		
		
		theInput.RegisterListener( this, 'OnToggleHud', 'ToggleHud' );
	}
	 
	// curently unused
	function Destroy()
	{
	}
	
	///////////////////////////
	// Action blocking
	///////////////////////////
	
	public function FindActionLockIndex(action : EInputActionBlock, sourceName : name) : int
	{
		var i : int;
	
		for(i=0; i<actionLocks[action].Size(); i+=1)
			if(actionLocks[action][i].sourceName == sourceName)
				return i;
				
		return -1;
	}

	// function to (un)block given input actions
	public function BlockAction(action : EInputActionBlock, sourceName : name, lock : bool, optional keepOnSpawn : bool, optional onSpawnedNullPointerHackFix : CPlayer, optional isFromQuest : bool, optional isFromPlace : bool)
	{		
		var index : int;		
		var isLocked, wasLocked : bool;
		var actionLock : SInputActionLock;
		
		if (action == EIAB_HighlightObjective)
		{
			index = FindActionLockIndex(action, sourceName);
		}
		
		index = FindActionLockIndex(action, sourceName);
		
		wasLocked = (actionLocks[action].Size() > 0);
		
		if(lock)
		{
			if(index != -1)
				return;
				
			actionLock.sourceName = sourceName;
			actionLock.removedOnSpawn = !keepOnSpawn;
			actionLock.isFromQuest = isFromQuest;
			actionLock.isFromPlace = isFromPlace;
			
			actionLocks[action].PushBack(actionLock);			
		}
		else
		{
			if(index == -1)
				return;
				
			actionLocks[action].Erase(index);
		}
		
		isLocked = (actionLocks[action].Size() > 0);
		if(isLocked != wasLocked)
			OnActionLockChanged(action, isLocked, sourceName, onSpawnedNullPointerHackFix);
	}
	
	//For toxic gas tutorial - we MUST open radial then so ALL locks are released
	public final function TutorialForceUnblockRadial() : array<SInputActionLock>
	{
		var ret : array<SInputActionLock>;
		
		ret = actionLocks[EIAB_RadialMenu];
		
		actionLocks[EIAB_RadialMenu].Clear();
		
		thePlayer.SetBIsInputAllowed(true, '');
		
		BlockAction( EIAB_Signs, 'ToxicGasTutorial', true, true, NULL, false);
		
		return ret;
	}
	
	//Toxic tutorial restoring of radial open locks
	public final function TutorialForceRestoreRadialLocks(radialLocks : array<SInputActionLock>)
	{
		actionLocks[EIAB_RadialMenu] = radialLocks;
		thePlayer.UnblockAction(EIAB_Signs, 'ToxicGasTutorial' );
	}
	
	private function OnActionLockChanged(action : EInputActionBlock, locked : bool, optional sourceName : name, optional onSpawnedNullPointerHackFix : CPlayer)
	{		
		var player : CPlayer;
		var lockType : EPlayerInteractionLock;
		var hud : CR4ScriptedHud;
		var guiManager : CR4GuiManager;
		var rootMenu : CR4MenuBase;
		
		// ED: Submited this to catch unknown blocking sources
		if( sourceName == debugBlockSourceName )
		{
			// Put a breakpoint here:
			sourceName	= sourceName;
		}
		
		//custom stuff
		if(action == EIAB_FastTravel)
		{
			theGame.GetCommonMapManager().EnableFastTravelling(!locked);
		}
		else if(action == EIAB_Interactions)
		{		
			//set lock flag
			if(sourceName == 'InsideCombatAction')
				lockType = PIL_CombatAction;
			else
				lockType = PIL_Default;
			
			if(!thePlayer)
				player = onSpawnedNullPointerHackFix;
			else
				player = thePlayer;
			
			if(player)
			{
				if(locked)
					player.LockButtonInteractions(lockType);
				else
					player.UnlockButtonInteractions(lockType);
			}
			
			//update interactions after flag change
			hud = (CR4ScriptedHud)theGame.GetHud(); 
			if ( hud ) 
			{ 
				hud.ForceInteractionUpdate(); 
			}
		}		
		else if(action == EIAB_Movement && locked && thePlayer)	//no thePlayer on session start
		{  
			//if we block movement then force Idle state, unless you are in air (jumping) - in that case wait for touch down and then force it
			if(thePlayer.IsUsingVehicle() && thePlayer.GetCurrentStateName() == 'HorseRiding')
			{
				((CActor)thePlayer.GetUsedVehicle()).GetMovingAgentComponent().ResetMoveRequests();
				thePlayer.GetUsedVehicle().SetBehaviorVariable( '2idle', 1);
				
				thePlayer.SetBehaviorVariable( 'speed', 0);
				thePlayer.SetBehaviorVariable( '2idle', 1);
			}
			else if(!thePlayer.IsInAir())
			{
				thePlayer.RaiseForceEvent( 'Idle' );
			}
		}
		else if (action == EIAB_DismountVehicle)
		{
			guiManager = theGame.GetGuiManager();
			
			if (guiManager)
			{
				guiManager.UpdateDismountAvailable(locked);
			}
		}
		else if (action == EIAB_OpenPreparation || action == EIAB_OpenMap || action == EIAB_OpenInventory ||
				 action == EIAB_OpenJournal	|| action == EIAB_OpenCharacterPanel || action == EIAB_OpenGlossary ||
				 action == EIAB_OpenAlchemy || action == EIAB_MeditationWaiting || action == EIAB_OpenMeditation)
		{
			guiManager = theGame.GetGuiManager();
			
			if (guiManager && guiManager.IsAnyMenu())
			{
				rootMenu = (CR4MenuBase)guiManager.GetRootMenu();
				
				if (rootMenu)
				{
					rootMenu.ActionBlockStateChange(action, locked);
				}
			}
		}
	}
	
	public function BlockAllActions(sourceName : name, lock : bool, optional exceptions : array<EInputActionBlock>, optional saveLock : bool, optional onSpawnedNullPointerHackFix : CPlayer, optional isFromQuest : bool, optional isFromPlace : bool)
	{
		var i, size : int;
		
		size = EnumGetMax('EInputActionBlock')+1;
		for(i=0; i<size; i+=1)
		{
			if ( exceptions.Contains(i) )
				continue;
			
			BlockAction(i, sourceName, lock, saveLock, onSpawnedNullPointerHackFix, isFromQuest, isFromPlace);
		}
	}
	
	//blocking all actions from all quest sources regardless of source
	public final function BlockAllQuestActions(sourceName : name, lock : bool)
	{
		var action, j, size : int;
		var isLocked, wasLocked : bool;
		var exceptions : array< EInputActionBlock >;
		
		if(lock)
		{
			//block works as regular block
			exceptions.PushBack( EIAB_FastTravelGlobal );
			BlockAllActions(sourceName, lock, exceptions, true, , true);
		}
		else
		{
			//release all quest locks, regardless of sourceName
			size = EnumGetMax('EInputActionBlock')+1;
			for(action=0; action<size; action+=1)
			{
				wasLocked = (actionLocks[action].Size() > 0);
				
				for(j=0; j<actionLocks[action].Size();)
				{
					if(actionLocks[action][j].isFromQuest)
					{
						actionLocks[action].EraseFast(j);		
					}
					else
					{
						j += 1;
					}
				}
				
				isLocked = (actionLocks[action].Size() > 0);
				if(wasLocked != isLocked)
					OnActionLockChanged(action, isLocked);
			}
		}
	}
	
	//blocking all UI actions from all quest sources regardless of source
	public function BlockAllUIQuestActions(sourceName : name, lock : bool)
	{
		var i, j, action, size : int;
		var uiActions : array<int>;
		var wasLocked, isLocked : bool;
		
		if( lock )
		{
			BlockAction(EIAB_OpenInventory, sourceName, true, true, NULL, false);
			BlockAction(EIAB_MeditationWaiting, sourceName, true, true, NULL, false);
			BlockAction(EIAB_OpenMeditation, sourceName, true, true, NULL, false);
			BlockAction(EIAB_FastTravel, sourceName, true, true, NULL, false);
			BlockAction(EIAB_OpenMap, sourceName, true, true, NULL, false);
			BlockAction(EIAB_OpenCharacterPanel, sourceName, true, true, NULL, false);
			BlockAction(EIAB_OpenJournal, sourceName, true, true, NULL, false);
			BlockAction(EIAB_OpenAlchemy, sourceName, true, true, NULL, false);
		}
		else
		{
			//release all quest locks, regardless of sourceName
			uiActions.Resize(8);
			uiActions[0] = EIAB_OpenInventory;
			uiActions[1] = EIAB_MeditationWaiting;
			uiActions[2] = EIAB_OpenMeditation;
			uiActions[3] = EIAB_FastTravel;
			uiActions[4] = EIAB_OpenMap;
			uiActions[5] = EIAB_OpenCharacterPanel;
			uiActions[6] = EIAB_OpenJournal;
			uiActions[7] = EIAB_OpenAlchemy;
			
			size = uiActions.Size();
			for(i=0; i<size; i+=1)
			{
				action = uiActions[i];
				
				wasLocked = (actionLocks[action].Size() > 0);
				
				for(j=0; j<actionLocks[action].Size();)
				{
					if(actionLocks[action][j].isFromQuest)
					{
						actionLocks[action].EraseFast(j);
					}
					else
					{
						j += 1;
					}
				}
				
				isLocked = (actionLocks[action].Size() > 0);
				if(wasLocked != isLocked)
					OnActionLockChanged(action, isLocked);
			}
		}
	}
	
	//forces releas of all action blocks
	public function ForceUnlockAllInputActions(alsoQuestLocks : bool)
	{
		var i, j : int;
	
		for(i=0; i<=EnumGetMax('EInputActionBlock'); i+=1)
		{
			if(alsoQuestLocks)
			{
				actionLocks[i].Clear();
				OnActionLockChanged(i, false);
			}
			else
			{
				for(j=actionLocks[i].Size()-1; j>=0; j-=1)
				{
					if(actionLocks[i][j].removedOnSpawn)
						actionLocks[i].Erase(j);
				}
				
				if(actionLocks[i].Size() == 0)
					OnActionLockChanged(i, false);
			}			
		}
	}
	
	public function RemoveLocksOnSpawn()
	{
		var i, j : int;
	
		for(i=0; i<actionLocks.Size(); i+=1)
		{
			for(j=actionLocks[i].Size()-1; j>=0; j-=1)
			{
				if(actionLocks[i][j].removedOnSpawn)
				{
					actionLocks[i].Erase(j);
				}
			}
		}
	}
	
	public function GetActionLocks(action : EInputActionBlock) : array< SInputActionLock >
	{
		return actionLocks[action];
	}
	
	public function GetAllActionLocks() : array< array< SInputActionLock > >
	{
		return actionLocks;
	}
	
	public function IsActionAllowed(action : EInputActionBlock) : bool
	{
		var actionAllowed : bool;
		actionAllowed = (actionLocks[action].Size() == 0);
		return actionAllowed;
	}
	
	public function IsActionBlockedBy( action : EInputActionBlock, sourceName : name ) : bool
	{
		return FindActionLockIndex( action, sourceName ) != -1;
	}
		
	public final function GetActionBlockedHudLockType(action : EInputActionBlock) : name
	{
		var i : int;
		
		if(action == EIAB_Undefined)
			return '';
			
		for(i=0; i<actionLocks[action].Size(); i+=1)
		{
			if(actionLocks[action][i].isFromPlace)
				return 'place';
		}
		
		if(actionLocks[action].Size() > 0)
			return 'time';
			
		return '';
	}

	///////////////////////////
	// Common Inputs
	///////////////////////////	
	event OnCommSprint( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			thePlayer.SetSprintActionPressed(true);
			
			if ( thePlayer.rangedWeapon )
				thePlayer.rangedWeapon.OnSprintHolster();
		}
		
		/*if( thePlayer.CanFollowNpc() )
		{
			if( IsPressed( action ) )
			{
				if( VecDistanceSquared( thePlayer.GetWorldPosition(), thePlayer.GetActorToFollow().GetWorldPosition() ) < 25.0 )
				{
					thePlayer.FollowActor( thePlayer.GetActorToFollow() );
				}
				else
				{
					thePlayer.SignalGameplayEvent( 'StopPlayerAction' );
					thePlayer.SetCanFollowNpc( false, NULL );
				}
			}
			else if( IsReleased( action ) )
			{
				thePlayer.SignalGameplayEvent( 'StopPlayerAction' );
				thePlayer.SetCanFollowNpc( false, NULL );
			}
		}*/
	}
	
	event OnCommSprintToggle( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			if ( thePlayer.GetIsSprintToggled() )
				thePlayer.SetSprintToggle( false );
			else
				thePlayer.SetSprintToggle( true );
		}
	}	
	
	event OnCommWalkToggle( action : SInputAction )
	{
		if( IsPressed(action) && !thePlayer.GetIsSprinting() && !thePlayer.modifyPlayerSpeed )
		{
			if ( thePlayer.GetIsWalkToggled() )
				thePlayer.SetWalkToggle( false );
			else
				thePlayer.SetWalkToggle( true );
		}
	}	
	
		
	event OnCommGuard( action : SInputAction )
	{
		if(thePlayer.IsCiri() && !GetCiriPlayer().HasSword())
			return false;
			
		if ( !thePlayer.IsInsideInteraction() )
		{
			if (  IsActionAllowed(EIAB_Parry) )
			{
				if( IsReleased(action) && thePlayer.GetCurrentStateName() == 'CombatFists' )
					thePlayer.OnGuardedReleased();	
				
				if( IsPressed(action) )
				{
					thePlayer.AddCounterTimeStamp(theGame.GetEngineTime());	//cache counter button press to further check counter button spamming by the thePlayer 		
					thePlayer.SetGuarded(true);
					thePlayer.OnPerformGuard();
				}
				else if( IsReleased(action) )
				{
					thePlayer.SetGuarded(false);
				}	
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Parry);				
			}
		}
	}	
	
	///////////////////////////
	// Horse
	///////////////////////////	
	
	private var pressTimestamp : float;
	private const var DOUBLE_TAP_WINDOW	: float;
	default DOUBLE_TAP_WINDOW = 0.4;
	
	event OnCommSpawnHorse( action : SInputAction )
	{
		var doubleTap : bool;
		
		if( IsPressed( action ) )
		{
			if( pressTimestamp + DOUBLE_TAP_WINDOW >= theGame.GetEngineTimeAsSeconds() )
			{
				doubleTap = true;
			}
			else
			{
				doubleTap = false;
			}
			
			if( IsActionAllowed( EIAB_CallHorse ) && !thePlayer.IsInInterior() && !thePlayer.IsInAir() )
			{
				
				if( doubleTap || theInput.LastUsedPCInput() )
				{
					if ( thePlayer.IsHoldingItemInLHand () )
					{
						thePlayer.OnUseSelectedItem(true);
						thePlayer.SetPlayerActionToRestore ( PATR_CallHorse );
					}
					else
					{
						theGame.OnSpawnPlayerHorse();
					}
				}				
			}
			else
			{
				if( thePlayer.IsInInterior() )
					thePlayer.DisplayActionDisallowedHudMessage( EIAB_Undefined, false, true );
				else
					thePlayer.DisplayActionDisallowedHudMessage( EIAB_CallHorse );
			}
			
			pressTimestamp = theGame.GetEngineTimeAsSeconds();
			
			return true;
		}
		
		return false;
	}
	
	///////////////////////////
	// Opening UI Panels
	///////////////////////////	
	
	// MenuHub (aka commonmenu.ws)
	event OnCommMenuHub( action : SInputAction )
	{
		if(IsReleased(action))
		{
			PushMenuHub();
		}
	}
	
	final function PushMenuHub()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		theGame.RequestMenu('CommonMenu');
	}
	
	//Character screen
	
	event OnCommPanelChar( action : SInputAction )
	{
		if(IsReleased(action))
		{
			PushCharacterScreen();
		}
	} 
	final function PushCharacterScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		
		if( IsActionAllowed(EIAB_OpenCharacterPanel) )
		{
			theGame.RequestMenuWithBackground( 'CharacterMenu', 'CommonMenu' );	
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenCharacterPanel);
		}
	}

	//Inventory screen
	event OnCommPanelInv( action : SInputAction )
	{		
		if (IsReleased(action))
		{
			PushInventoryScreen();
		}
	}
	
	final function PushInventoryScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenInventory) )		
		{
			theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenInventory);
		}
	}
	
	//Gwint screen
	event OnCommDeckEditor( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			if (theGame.GetGwintManager().GetHasDoneTutorial() || theGame.GetGwintManager().HasLootedCard())
			{
				if( IsActionAllowed(EIAB_OpenGwint) )		
				{
					theGame.RequestMenu( 'DeckBuilder' );
				}
				else
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenGwint);
				}
			}
		}
	}
	
	//Meditation screen
	event OnCommPanelMed( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			if( IsActionAllowed(EIAB_MeditationWaiting) )
			{
				GetWitcherPlayer().Meditate();
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_MeditationWaiting);
			}
		}
	}	
	
	event OnCommPanelMapPC( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushMapScreen();
		}
	}
	//Map screen
	event OnCommPanelMap( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			PushMapScreen();
		}
	}	
	final function PushMapScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenMap) )
		{
			theGame.RequestMenuWithBackground( 'MapMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenMap);
		}
	}

	//Journal screen
	event OnCommPanelJour( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushJournalScreen();
		}
	}
	final function PushJournalScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenJournal) )
		{
			//theGame.RequestMenu( 'QuestListMenu' );
			theGame.RequestMenuWithBackground( 'JournalQuestMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenJournal);
		}	
	}
	
	event OnCommPanelMeditation( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushMeditationScreen();
		}
	}
	
	final function PushMeditationScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenMeditation) )
		{
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenMeditation);
		}	
	}
	
	event OnCommPanelCrafting( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushCraftingScreen();
		}
	}
	
	final function PushCraftingScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		
		theGame.RequestMenuWithBackground( 'CraftingMenu', 'CommonMenu' );
	}
	
	//Bestiary screen
	event OnCommPanelBestiary( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushBestiaryScreen();
		}
	}
	
	final function PushBestiaryScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenGlossary) )
		{
			theGame.RequestMenuWithBackground( 'GlossaryBestiaryMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenGlossary);
		}
	}
	//Alchemy screen
	event OnCommPanelAlch( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushAlchemyScreen();
		}
	}
	final function PushAlchemyScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenAlchemy) )
		{
			theGame.RequestMenuWithBackground( 'AlchemyMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenAlchemy);
		}
	}
	//Alchemy screen
	event OnCommPanelGlossary( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			PushGlossaryScreen();
		}
	}
	final function PushGlossaryScreen()
	{
		if ( theGame.IsBlackscreenOrFading() )
		{
			return;
		}
		if( IsActionAllowed(EIAB_OpenGlossary) )
		{
			theGame.RequestMenuWithBackground( 'GlossaryEncyclopediaMenu', 'CommonMenu' );
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenGlossary);
		}
	}
	
	event OnShowControlsHelp( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			//theGame.RequestMenu( 'ControlsHelp' );
			//theGame.RequestMenu( 'JournalQuestMenu' );
		}
	}
	
	event OnCommPanelUIResize( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			theGame.RequestMenu( 'RescaleMenu' );
		}
	}	

	event OnCommPanelFakeHud( action : SInputAction )
	{
		if( IsReleased(action) )
		{
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			//theGame.RequestMenu( 'FakeHudMenu' );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////  WEAPON DRAW  ///////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private var processedSwordHold : bool;
	
	event OnCommSteelSword( action : SInputAction )
	{
		var duringCastSign : bool;
		
		if(IsPressed(action))
			processedSwordHold = false;
		
		if ( theInput.LastUsedGamepad() && theInput.IsActionPressed('Alternate') )
		{
			return false;
		}
		
		if ( IsReleased(action) || ( IsPressed(action) && (thePlayer.GetCurrentMeleeWeaponType() == PW_None || thePlayer.GetCurrentMeleeWeaponType() == PW_Fists) ) )
		{
			if( !processedSwordHold )
			{
				if ( IsActionAllowed(EIAB_DrawWeapon) && thePlayer.GetBIsInputAllowed() && thePlayer.GetWeaponHolster().IsMeleeWeaponReady() )
				{
					thePlayer.PushCombatActionOnBuffer( EBAT_Draw_Steel, BS_Pressed );
					if ( thePlayer.GetBIsCombatActionAllowed() )
						thePlayer.ProcessCombatActionBuffer();
				}
				processedSwordHold = true;
			}
		}
	}
	
	event OnCommSilverSword( action : SInputAction )
	{
		var duringCastSign : bool;
		
		if( IsPressed(action) )
			processedSwordHold = false;
		
		if ( theInput.LastUsedGamepad() && theInput.IsActionPressed('Alternate') )
		{
			return false;
		}
		
		if ( IsReleased(action) || ( IsPressed(action) && (thePlayer.GetCurrentMeleeWeaponType() == PW_None || thePlayer.GetCurrentMeleeWeaponType() == PW_Fists) ) )
		{
			if( !processedSwordHold )
			{
				if ( IsActionAllowed(EIAB_DrawWeapon) && thePlayer.GetBIsInputAllowed() && thePlayer.GetWeaponHolster().IsMeleeWeaponReady() )
				{
					thePlayer.PushCombatActionOnBuffer( EBAT_Draw_Silver, BS_Pressed );
					if ( thePlayer.GetBIsCombatActionAllowed() || duringCastSign )
						thePlayer.ProcessCombatActionBuffer();
				}
				processedSwordHold = true;
			}
			
		}
	}	
	
	event OnCommSheatheAny( action : SInputAction )
	{
		var duringCastSign : bool;
		
		if( IsPressed( action ) )
		{
			if ( thePlayer.GetBIsInputAllowed() && thePlayer.GetWeaponHolster().IsMeleeWeaponReady() )
			{
				thePlayer.PushCombatActionOnBuffer( EBAT_Sheathe_Sword, BS_Pressed );
				if ( thePlayer.GetBIsCombatActionAllowed() || duringCastSign )
				{
					thePlayer.ProcessCombatActionBuffer();
				}
			}
			processedSwordHold = true;
		}		
	}
	
	event OnCommSheatheSteel( action : SInputAction )
	{
		if( IsPressed( action ) && thePlayer.IsWeaponHeld( 'steelsword' ) && !processedSwordHold)
		{
			OnCommSheatheAny(action);
		}
	}
	
	event OnCommSheatheSilver( action : SInputAction )
	{
		if( IsPressed( action ) && thePlayer.IsWeaponHeld( 'silversword' ) && !processedSwordHold)
		{
			OnCommSheatheAny(action);
		}
	}
		
	event OnCommDrinkPot( action : SInputAction )
	{
		if(IsPressed(action))
		{
			if(!potPress)
			{
				potPress = true;
				potAction = action;
				thePlayer.AddTimer('PotDrinkTimer', 0.3);
			}
			else
			{
				PotDrinkTimer(true);
				thePlayer.RemoveTimer('PotDrinkTimer');
			}
		}
	}
	
	public function PotDrinkTimer(isDoubleTapped : bool)
	{
		thePlayer.RemoveTimer('PotDrinkTimer');
		potPress = false;
		
		if(isDoubleTapped)
			OnCommDrinkPotion2(potAction);
		else
			OnCommDrinkPotion1(potAction);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnCbtComboDigitLeft( action : SInputAction )
	{
		if ( theInput.IsActionPressed('Alternate') )
		{
			OnTogglePreviousSign(action);
		}
	}
	
	event OnCbtComboDigitRight( action : SInputAction )
	{
		if ( theInput.IsActionPressed('Alternate') )
		{
			OnToggleNextSign(action);
		}
	}
	
	
	event OnSelectSign(action : SInputAction)
	{
		if( IsPressed( action ) )
		{
			switch( action.aName )
			{
				case 'SelectAard' :
					GetWitcherPlayer().SetEquippedSign(ST_Aard);
					break;
				case 'SelectYrden' :
					GetWitcherPlayer().SetEquippedSign(ST_Yrden);
					break;
				case 'SelectIgni' :
					GetWitcherPlayer().SetEquippedSign(ST_Igni);
					break;
				case 'SelectQuen' :
					GetWitcherPlayer().SetEquippedSign(ST_Quen);
					break;
				case 'SelectAxii' :
					GetWitcherPlayer().SetEquippedSign(ST_Axii);
					break;
				default :
					break;
			}
		}
	}
	
	event OnToggleSigns( action : SInputAction )
	{
		var tolerance : float;
		tolerance = 2.5f;
		
		if( action.value < -tolerance )
		{
			GetWitcherPlayer().TogglePreviousSign();
		}
		else if( action.value > tolerance )
		{
			GetWitcherPlayer().ToggleNextSign();
		}
	}
	event OnToggleNextSign( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			GetWitcherPlayer().ToggleNextSign();
		}
	}
	event OnTogglePreviousSign( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			GetWitcherPlayer().TogglePreviousSign();
		}
	}
	
	event OnToggleItem( action : SInputAction )
	{
		if( !IsActionAllowed( EIAB_QuickSlots ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			return false;
		}
		
		if( IsReleased( action ) )
		{	
			if( theInput.GetLastActivationTime( action.aName ) < 0.3 )
				GetWitcherPlayer().ToggleNextItem();
		}
	}
	
	///////////////////////////
	// Potions
	///////////////////////////
	
	event OnCommDrinkpotionUpperHeld( action : SInputAction )
	{
		if(!potionModeHold)
			return false;
			
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
			
		if(IsReleased(action))
			return false;
		
		potionUpperHeld = true;
		GetWitcherPlayer().FlipSelectedPotion(true);
	}
	
	event OnCommDrinkpotionLowerHeld( action : SInputAction )
	{
		if(!potionModeHold)
			return false;
			
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
			
		if(IsReleased(action))
			return false;
		
		potionLowerHeld = true;
		GetWitcherPlayer().FlipSelectedPotion(false);
	}
	
	public final function SetPotionSelectionMode(b : bool)
	{
		potionModeHold = b;
	}
	
	private final function DrinkPotion(action : SInputAction, upperSlot : bool) : bool
	{
		var witcher : W3PlayerWitcher;
		
		if ( potionModeHold && IsReleased(action) )
		{
			if(!potionUpperHeld && !potionLowerHeld)
			{
				GetWitcherPlayer().OnPotionDrinkInput(upperSlot);
			}
			
			if(upperSlot)
				potionUpperHeld = false;
			else
				potionLowerHeld = false;
		}		
		else if(!potionModeHold && IsPressed(action))
		{
			witcher = GetWitcherPlayer();
			if(!witcher.IsPotionDoubleTapRunning())
			{
				witcher.SetPotionDoubleTapRunning(true, upperSlot);
				return true;
			}
			else
			{
				witcher.SetPotionDoubleTapRunning(false);
				witcher.FlipSelectedPotion(upperSlot);				
				return true;
			}
		}
		
		return false;
	}	
	
	//upper left slot
	event OnCommDrinkPotion1( action : SInputAction )
	{
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
		
		if( !IsActionAllowed( EIAB_QuickSlots ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			return false;
		}
		
		if ( theInput.LastUsedGamepad() )
		{
			return DrinkPotion(action, true);
		}
		else
		if ( IsReleased(action) )
		{
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(EES_Potion1);
			return true;
		}
		
		return false;
	}
	
	//lower left slot
	event OnCommDrinkPotion2( action : SInputAction )
	{
		var witcher : W3PlayerWitcher;
		
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
		
		if( !IsActionAllowed( EIAB_QuickSlots ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			return false;
		}
		
		if ( theInput.LastUsedGamepad() )
		{
			return DrinkPotion(action, false);
		}
		else
		if ( IsReleased(action) )
		{
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(EES_Potion2);
			return true;
		}
		
		return false;
	}
	
	//upper right slot
	event OnCommDrinkPotion3( action : SInputAction )
	{
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
		
		if( !IsActionAllowed( EIAB_QuickSlots ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			return false;
		}
		
		if ( IsReleased(action) )
		{
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(EES_Potion3);
			return true;
		}
		
		return false;
	}
	
	//lower right slot
	event OnCommDrinkPotion4( action : SInputAction )
	{
		var witcher : W3PlayerWitcher;
		
		//requested hack for Ciri using Geralt's input context
		if(thePlayer.IsCiri())
			return false;
		
		if( !IsActionAllowed( EIAB_QuickSlots ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			return false;
		}
		
		if ( IsReleased(action) )
		{
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(EES_Potion4);
			return true;
		}
		
		return false;
	}
	
	///////////////////////////
	// Exploration Inputs
	///////////////////////////
	
	event OnDiving( action : SInputAction )
	{
		if ( IsPressed(action) && IsActionAllowed(EIAB_Dive) )
		{
			if ( action.aName == 'DiveDown' )
			{
				if ( thePlayer.OnAllowedDiveDown() )
				{
					if ( !thePlayer.OnCheckDiving() )
						thePlayer.OnDive();
					
					if ( thePlayer.bLAxisReleased )
						thePlayer.SetBehaviorVariable( 'divePitch',-1.0);
					else
						thePlayer.SetBehaviorVariable( 'divePitch', -0.9);
					thePlayer.OnDiveInput(-1.f);
					
					if ( thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
					{
						thePlayer.OnRangedForceHolster( true, false );
						thePlayer.OnFullyBlendedIdle();
					}
				}			
			}
			else if ( action.aName == 'DiveUp' )
			{
				if ( thePlayer.bLAxisReleased )
					thePlayer.SetBehaviorVariable( 'divePitch',1.0);
				else
					thePlayer.SetBehaviorVariable( 'divePitch', 0.9);
					
				if ( thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
				{
					thePlayer.OnRangedForceHolster( true, false );
					thePlayer.OnFullyBlendedIdle();
				}
					
				thePlayer.OnDiveInput(1.f);
			}
		}
		else if ( IsReleased(action) )
		{
			thePlayer.SetBehaviorVariable( 'divePitch',0.0);
			thePlayer.OnDiveInput(0.f);
		}
		else if ( IsPressed(action) && !IsActionAllowed(EIAB_Dive) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Dive);
		}
	}
	
	event OnDivingDodge( action : SInputAction )
	{
		var isDodgeAllowed : bool;
		
		if( IsPressed(action) )
		{
			isDodgeAllowed = IsActionAllowed(EIAB_Dodge);
			if( isDodgeAllowed && IsActionAllowed(EIAB_Dive) )
			{
				if ( thePlayer.OnCheckDiving() && thePlayer.GetBIsInputAllowed() )
				{
					thePlayer.PushCombatActionOnBuffer( EBAT_Dodge, BS_Pressed );
					if ( thePlayer.GetBIsCombatActionAllowed() )
						thePlayer.ProcessCombatActionBuffer();
				}
			}
			else
			{
				if(!isDodgeAllowed)
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Dodge);
				else
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Dive);
			}
		}
	}
	
	/*
	Redundant with OnCbtCameraLockOrSpawnHorse
	event OnExpSpawnHorse( action : SInputAction )
	{
		var test : bool = false;
		if( IsPressed(action) && IsActionAllowed(EIAB_CallHorse))
		{
			test = false;
			//thePlayer.OnSpawnHorse();	
		}
	}	*/
	
	/*event OnMountHorse( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			if( thePlayer.IsMountingHorseAllowed() )
			{
				thePlayer.OnVehicleInteraction( (CVehicleComponent)thePlayer.horseInteractionSource.GetComponentByClassName( 'CVehicleComponent' ) );
			}
		}
	}*/
	
	event OnExpFistFightLight( action : SInputAction )
	{
		var fistsAllowed : bool;
		
		if( IsPressed(action) )
		{
			fistsAllowed = IsActionAllowed(EIAB_Fists);
			if( fistsAllowed && IsActionAllowed(EIAB_LightAttacks) )
			{
				//thePlayer.PrepareToAttack( );
				thePlayer.SetupCombatAction( EBAT_LightAttack, BS_Pressed );
			}
			else
			{
				if(!fistsAllowed)
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Fists);
				else
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);
			}
		}
	}
	
	event OnExpFistFightHeavy( action : SInputAction )
	{
		var fistsAllowed : bool;
		
		if( IsPressed(action) )
		{
			fistsAllowed = IsActionAllowed(EIAB_Fists);
			if( fistsAllowed && IsActionAllowed(EIAB_HeavyAttacks) )
			{
				//thePlayer.PrepareToAttack( );
				thePlayer.SetupCombatAction( EBAT_HeavyAttack, BS_Pressed );
			}
			else
			{
				if(!fistsAllowed)
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Fists);
				else
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_HeavyAttacks);
			}
		}
	}
		
	/*
	event OnExpMedallion( action : SInputAction )
	{
		if(IsActionAllowed(EIAB_ExplorationFocus))
		{
			if( IsPressed( action ) )
			{
				thePlayer.MedallionPing();
			}
		}
	}
	*/
	
	event OnExpFocus( action : SInputAction )
	{
		if(IsActionAllowed(EIAB_ExplorationFocus))
		{
			if( IsPressed( action ) )
			{
				// Let's turn focus into guard if the player should fight
				if( thePlayer.GoToCombatIfNeeded() )
				{
					OnCommGuard( action );
					return false;
				}
				theGame.GetFocusModeController().Activate();
				//thePlayer.MedallionPing();
			}
			else if( IsReleased( action ) )
			{
				theGame.GetFocusModeController().Deactivate();
			}
		}
		else
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_ExplorationFocus);
			theGame.GetFocusModeController().Deactivate();	
		}
	}
	
	///////////////////////////
	// Combat Inputs
	///////////////////////////
	
	private function ShouldSwitchAttackType():bool
	{
		var outKeys : array<EInputKey>;	
		
		if ( theInput.LastUsedPCInput() )
		{		
			theInput.GetPCKeysForAction('PCAlternate',outKeys);
			if ( outKeys.Size() > 0 )
			{
				if ( theInput.IsActionPressed('PCAlternate') )
				{
					return true;
				}
			}
		}
		return false;
	}
	
	event OnCbtAttackWithAlternateLight( action : SInputAction )
	{
		CbtAttackPC( action, false);
	}
	
	event OnCbtAttackWithAlternateHeavy( action : SInputAction )
	{
		CbtAttackPC( action, true);
	}
	
	function CbtAttackPC( action : SInputAction, isHeavy : bool )
	{
		var switchAttackType : bool;
		
		switchAttackType = ShouldSwitchAttackType();
		
		if ( !theInput.LastUsedPCInput() )
		{
			return;
		}
		
		if ( thePlayer.IsCiri() )
		{
			if ( switchAttackType != isHeavy) // XOR
			{
				OnCbtCiriAttackHeavy(action);
			}
			else
			{
				OnCbtAttackLight(action);
			}
		}
		else
		{
			if ( switchAttackType != isHeavy) // XOR
			{
				OnCbtAttackHeavy(action);
			}
			else
			{
				OnCbtAttackLight(action);
			}
		}
	}
	
	event OnCbtAttackLight( action : SInputAction )
	{
		var allowed, checkedFists 			: bool;
		
		if( IsPressed(action) )
		{
			if( IsActionAllowed(EIAB_LightAttacks)  )
			{
				if (thePlayer.GetBIsInputAllowed())
				{
					allowed = false;					
					
					if( thePlayer.GetCurrentMeleeWeaponType() == PW_Fists || thePlayer.GetCurrentMeleeWeaponType() == PW_None )
					{
						checkedFists = true;
						if(IsActionAllowed(EIAB_Fists))
							allowed = true;
					}
					else if(IsActionAllowed(EIAB_SwordAttack))
					{
						checkedFists = false;
						allowed = true;
					}
					
					if(allowed)
					{
						thePlayer.SetupCombatAction( EBAT_LightAttack, BS_Pressed );
					}
					else
					{
						if(checkedFists)
							thePlayer.DisplayActionDisallowedHudMessage(EIAB_Fists);
						else
							thePlayer.DisplayActionDisallowedHudMessage(EIAB_SwordAttack);
					}
				}
			}
			else  if ( !IsActionBlockedBy(EIAB_LightAttacks,'interaction') )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);
			}
		}
	}
	
	event OnCbtAttackHeavy( action : SInputAction )
	{
		var allowed, checkedSword : bool;
		var outKeys : array<EInputKey>;
		
		if ( thePlayer.GetBIsInputAllowed() )
		{
			if( IsActionAllowed(EIAB_HeavyAttacks) )
			{
				allowed = false;
				
				if( thePlayer.GetCurrentMeleeWeaponType() == PW_Fists || thePlayer.GetCurrentMeleeWeaponType() == PW_None )
				{
					checkedSword = false;
					if(IsActionAllowed(EIAB_Fists))
						allowed = true;
				}
				else if(IsActionAllowed(EIAB_SwordAttack))
				{
					checkedSword = true;
					allowed = true;
				}
				
				if(allowed)
				{
					if ( ( thePlayer.GetCurrentMeleeWeaponType() == PW_Fists || thePlayer.GetCurrentMeleeWeaponType() == PW_None ) && IsPressed(action)  )
					{
						thePlayer.SetupCombatAction( EBAT_HeavyAttack, BS_Released );				
					}
					else
					{
						if( IsReleased(action) && theInput.GetLastActivationTime( action.aName ) < 0.2 )
						{
							thePlayer.SetupCombatAction( EBAT_HeavyAttack, BS_Released );
						}
					}
				}
				else
				{
					if(checkedSword)
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_SwordAttack);
					else					
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_Fists);
				}
			}
			else if ( !IsActionBlockedBy(EIAB_HeavyAttacks,'interaction') )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_HeavyAttacks);
			}
		}
	}

	private function CheckFinisherInput() : bool
	{
		var enemyInCone 		: CActor;
		var npc 				: CNewNPC;
		var interactionTarget 	: CInteractionComponent;
		
		var isDeadlySwordHeld	: bool;	
	
		interactionTarget = theGame.GetInteractionsManager().GetActiveInteraction();
		if ( interactionTarget && interactionTarget.GetName() == "Finish" )//|| thePlayer.GetFinisherVictim() )
		{
			npc = (CNewNPC)( interactionTarget.GetEntity() );
			
			isDeadlySwordHeld = thePlayer.IsDeadlySwordHeld();
			if( ( theInput.GetActionValue( 'AttackHeavy' ) == 1.f || theInput.GetActionValue( 'AttackLight' ) == 1.f  )
				&& isDeadlySwordHeld )//
			{
				theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_FinisherInput) );
				npc.SignalGameplayEvent('Finisher');
				
			}
			else if ( !isDeadlySwordHeld )
			{
				if ( thePlayer.IsWeaponHeld( 'fist' ))
					thePlayer.SetBehaviorVariable( 'combatTauntType', 1.f );
				else
					thePlayer.SetBehaviorVariable( 'combatTauntType', 0.f );
					
				thePlayer.RaiseEvent( 'CombatTaunt' );
			}
			
			return true;
			
		}
		return false;
	}
	
	private function IsPlayerAbleToPerformSpecialAttack() : bool
	{
		if( ( thePlayer.GetCurrentStateName() == 'Exploration' ) && !( thePlayer.IsWeaponHeld( 'silversword' ) || thePlayer.IsWeaponHeld( 'steelsword' ) ) )
		{
			return false;
		}
		return true;
	}
	
	event OnCbtSpecialAttackWithAlternateLight( action : SInputAction )
	{
		CbSpecialAttackPC( action, false);
	}
	
	event OnCbtSpecialAttackWithAlternateHeavy( action : SInputAction )
	{
		CbSpecialAttackPC( action, true);
	}
	
	function CbSpecialAttackPC( action : SInputAction, isHeavy : bool ) // special attack for PC
	{
		var switchAttackType : bool;
		
		switchAttackType = ShouldSwitchAttackType();
		
		if ( !theInput.LastUsedPCInput() )
		{
			return;
		}
		
		if ( IsPressed(action) )
		{
			if ( thePlayer.IsCiri() )
			{
				// always heavy for Ciri
				OnCbtCiriSpecialAttackHeavy(action);
			}
			else
			{
				if (switchAttackType != isHeavy) // XOR
				{
					OnCbtSpecialAttackHeavy(action);
				}
				else
				{
					OnCbtSpecialAttackLight(action);
				}
			}
		}
		else if ( IsReleased( action ) )
		{
			if ( thePlayer.IsCiri() )
			{
				OnCbtCiriSpecialAttackHeavy(action);
			}
			else
			{
				// to release hold actions
				OnCbtSpecialAttackHeavy(action);
				OnCbtSpecialAttackLight(action);
			}
		}
	}
	
	event OnCbtSpecialAttackLight( action : SInputAction )
	{
		if ( IsReleased( action )  )
		{
			thePlayer.CancelHoldAttacks();
			return true;
		}
		
		if ( !IsPlayerAbleToPerformSpecialAttack() )
			return false;
		
		if( !IsActionAllowed(EIAB_LightAttacks) ) 
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);
			return false;
		}
		if(!IsActionAllowed(EIAB_SpecialAttackLight) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackLight);
			return false;
		}
		
		if( IsPressed(action) && thePlayer.CanUseSkill(S_Sword_s01) )	
		{	
			thePlayer.PrepareToAttack();
			thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
			thePlayer.AddTimer( 'IsSpecialLightAttackInputHeld', 0.00001, true );
		}
	}	

	event OnCbtSpecialAttackHeavy( action : SInputAction )
	{
		if ( IsReleased( action )  )
		{
			thePlayer.CancelHoldAttacks();
			return true;
		}
		
		if ( !IsPlayerAbleToPerformSpecialAttack() )
			return false;
		
		if( !IsActionAllowed(EIAB_HeavyAttacks))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_HeavyAttacks);
			return false;
		}		
		if(!IsActionAllowed(EIAB_SpecialAttackHeavy))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackHeavy);
			return false;
		}
		
		if( IsPressed(action) && thePlayer.CanUseSkill(S_Sword_s02) )	
		{	
			thePlayer.PrepareToAttack();
			thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
			thePlayer.AddTimer( 'IsSpecialHeavyAttackInputHeld', 0.00001, true );
		}
		else if ( IsPressed(action) )
		{
			if ( theInput.IsActionPressed('AttackHeavy') )
				theInput.ForceDeactivateAction('AttackHeavy');
			else if ( theInput.IsActionPressed('AttackWithAlternateHeavy') )
				theInput.ForceDeactivateAction('AttackWithAlternateHeavy');
		}
	}
	
	// CiriSpecialAttack
	event OnCbtCiriSpecialAttack( action : SInputAction )
	{
		if( !GetCiriPlayer().HasSword() ) 
			return false;
	
		if( thePlayer.GetBIsInputAllowed() && thePlayer.GetBIsCombatActionAllowed() && IsPressed(action) )	
		{
			if ( thePlayer.HasAbility('CiriBlink') && ((W3ReplacerCiri)thePlayer).HasStaminaForSpecialAction(true) )
				thePlayer.PrepareToAttack();
			thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack, BS_Pressed );
			thePlayer.ProcessCombatActionBuffer();	
		}
		else if ( IsReleased( action ) && thePlayer.GetCombatAction() == EBAT_Ciri_SpecialAttack && thePlayer.GetBehaviorVariable( 'isPerformingSpecialAttack' ) != 0 )
		{
			thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack, BS_Released );
			thePlayer.ProcessCombatActionBuffer();		
		}
	}
	
	// CiriSpecialAttackHeavy
	event OnCbtCiriAttackHeavy( action : SInputAction )
	{
		var specialAttackAction : SInputAction;
		
		if( !GetCiriPlayer().HasSword() ) 
			return false;
		
		specialAttackAction = theInput.GetAction('CiriSpecialAttackHeavy');
		
		if( thePlayer.GetBIsInputAllowed() && IsReleased(action) && thePlayer.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0  )	
		{	
			if( IsActionAllowed(EIAB_HeavyAttacks) && IsActionAllowed(EIAB_SwordAttack) )
			{
				if ( thePlayer.GetCurrentMeleeWeaponType() == PW_Steel )
				{
					thePlayer.PrepareToAttack();
					thePlayer.SetupCombatAction( EBAT_HeavyAttack, BS_Released );
					if ( thePlayer.GetBIsCombatActionAllowed() )
						thePlayer.ProcessCombatActionBuffer();
				}
			}
			else if ( !IsActionBlockedBy(EIAB_HeavyAttacks,'interaction') )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);				
			}
		}
	}
	
	// CiriSpecialAttackHeavy
	event OnCbtCiriSpecialAttackHeavy( action : SInputAction )
	{	
		if( !GetCiriPlayer().HasSword() ) 
			return false;
		
		if( thePlayer.GetBIsInputAllowed() && thePlayer.GetBIsCombatActionAllowed() && IsPressed(action) )	
		{
			theInput.ForceDeactivateAction('AttackWithAlternateHeavy');
			thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack_Heavy, BS_Pressed );
			thePlayer.ProcessCombatActionBuffer();
		}
		else if ( IsReleased( action ) && thePlayer.GetCombatAction() == EBAT_Ciri_SpecialAttack_Heavy && thePlayer.GetBehaviorVariable( 'isPerformingSpecialAttack' ) != 0  )
		{
			theInput.ForceDeactivateAction('CiriAttackHeavy');
			theInput.ForceDeactivateAction('AttackWithAlternateHeavy');
			thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack_Heavy, BS_Released );
			thePlayer.ProcessCombatActionBuffer();		
		}
	}
	
	event OnCbtCiriDodge( action : SInputAction )
	{	
		if( IsActionAllowed(EIAB_Dodge) && IsPressed(action) && thePlayer.IsAlive() )	
		{
			if ( thePlayer.IsInCombatAction() && thePlayer.GetCombatAction() == EBAT_Ciri_SpecialAttack && thePlayer.GetBehaviorVariable( 'isCompletingSpecialAttack' ) <= 0 )
			{
				thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_Dodge, BS_Pressed );
				thePlayer.ProcessCombatActionBuffer();			
			}
			else if ( thePlayer.GetBIsInputAllowed() )
			{
				thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_Dodge, BS_Pressed );
				if ( thePlayer.GetBIsCombatActionAllowed() )
					thePlayer.ProcessCombatActionBuffer();
			}
			else
			{
				if ( thePlayer.IsInCombatAction() && thePlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( thePlayer.CanPlayHitAnim() && thePlayer.IsThreatened() )
					{
						thePlayer.CriticalEffectAnimationInterrupted("CiriDodge");
						thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_Dodge, BS_Pressed );
						thePlayer.ProcessCombatActionBuffer();							
					}
					else
						thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_Dodge, BS_Pressed );
				}
			}
		}
		else if ( !IsActionAllowed(EIAB_Dodge) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Dodge);
		}
	}
	
	event OnCbtCiriDash( action : SInputAction )
	{
		if ( theInput.LastUsedGamepad() && IsPressed( action ) )
		{
			thePlayer.StartDodgeTimer();
		}
		else if( IsActionAllowed(EIAB_Dodge) && thePlayer.IsAlive() )	
		{
			if ( theInput.LastUsedGamepad() )
			{
				if ( !(thePlayer.IsDodgeTimerRunning() && !thePlayer.IsInsideInteraction() && IsReleased(action)) )
					return false;
			}
			
			if ( thePlayer.IsInCombatAction() && thePlayer.GetCombatAction() == EBAT_Ciri_SpecialAttack && thePlayer.GetBehaviorVariable( 'isCompletingSpecialAttack' ) <= 0 )
			{
				thePlayer.PushCombatActionOnBuffer( EBAT_Roll, BS_Released );
				thePlayer.ProcessCombatActionBuffer();			
			}
			else if ( thePlayer.GetBIsInputAllowed() )
			{
				thePlayer.PushCombatActionOnBuffer( EBAT_Roll, BS_Released );
				if ( thePlayer.GetBIsCombatActionAllowed() )
					thePlayer.ProcessCombatActionBuffer();
			}
			else
			{
				if ( thePlayer.IsInCombatAction() && thePlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( thePlayer.CanPlayHitAnim() && thePlayer.IsThreatened() )
					{
						thePlayer.CriticalEffectAnimationInterrupted("CiriDodge");
						thePlayer.PushCombatActionOnBuffer( EBAT_Roll, BS_Released );
						thePlayer.ProcessCombatActionBuffer();							
					}
					else
						thePlayer.PushCombatActionOnBuffer( EBAT_Roll, BS_Released );
				}
			}
		}
		else if ( !IsActionAllowed(EIAB_Dodge) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Dodge);
		}
	}
	
	event OnCbtDodge( action : SInputAction )
	{
		if ( IsPressed(action) )
			thePlayer.EvadePressed(EBAT_Dodge);
	}
	
	event OnCbtRoll( action : SInputAction )
	{
		if ( theInput.LastUsedPCInput() )
		{
			if ( IsPressed( action ) )
			{
				thePlayer.EvadePressed(EBAT_Roll);
			}
		}
		else
		{
			if ( IsPressed( action ) )
			{
				thePlayer.StartDodgeTimer();
			}
			else if ( IsReleased( action ) )
			{
				if ( thePlayer.IsDodgeTimerRunning() )
				{
					thePlayer.StopDodgeTimer();
					if ( !thePlayer.IsInsideInteraction() )
						thePlayer.EvadePressed(EBAT_Roll);
				}
				
			}
		}
	}
	
	
	var lastMovementDoubleTapName : name;
	
	event OnMovementDoubleTap( action : SInputAction )
	{
		if ( IsPressed( action ) )
		{
			if ( !thePlayer.IsDodgeTimerRunning() || action.aName != lastMovementDoubleTapName )
			{
				thePlayer.StartDodgeTimer();
				lastMovementDoubleTapName = action.aName;
			}
			else
			{
				thePlayer.StopDodgeTimer();
				
				thePlayer.EvadePressed(EBAT_Dodge);
			}
			
		}
	}
	
	event OnCastSign( action : SInputAction )
	{
		var signSkill : ESkill;
	
		if( !thePlayer.GetBIsInputAllowed() )
		{	
			return false;
		}
		
		if( IsPressed(action) )
		{
			if( !IsActionAllowed(EIAB_Signs) )
			{				
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs);
				return false;
			}
/*			if ( thePlayer.IsHoldingItemInLHand() && !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.SetPlayerActionToRestore ( PATR_CastSign );
				thePlayer.OnUseSelectedItem( true );
				return true;
			}
			else*/ if ( thePlayer.IsHoldingItemInLHand() && thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
				return false;
			}
			signSkill = SignEnumToSkillEnum( thePlayer.GetEquippedSign() );
			if( signSkill != S_SUndefined )
			{
				if(!thePlayer.CanUseSkill(signSkill))
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs, false, false, true);
					return false;
				}
			
				if( thePlayer.HasStaminaToUseSkill( signSkill, false ) )
				{
					if( GetInvalidUniqueId() != thePlayer.inv.GetItemFromSlot( 'l_weapon' ) && !thePlayer.IsUsableItemLBlocked())
					{
//						thePlayer.OnUseSelectedItem( true);
						//thePlayer.DropItemFromSlot( 'l_weapon', false );
						//thePlayer.RaiseEvent( 'ItemEndL' );
					}
					
					thePlayer.SetupCombatAction( EBAT_CastSign, BS_Pressed );
				}
				else
				{
					thePlayer.SoundEvent("gui_no_stamina");
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////  @BOMBS  ////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnThrowBomb(action : SInputAction)
	{
		var selectedItemId : SItemUniqueId;
	
		selectedItemId = thePlayer.GetSelectedItemId();
		if(!thePlayer.inv.IsItemBomb(selectedItemId))
			return false;
		
		if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 )
		{
			//sound to indicate you have no ammo
			if(IsPressed(action))
			{			
				thePlayer.SoundEvent( "gui_ingame_low_stamina_warning" );
			}
			
			return false;
		}
		
		if ( IsReleased(action) )
		{
			if ( thePlayer.IsThrowHold() )
			{
				if ( thePlayer.playerAiming.GetAimedTarget() )
				{
					if ( thePlayer.AllowAttack( thePlayer.playerAiming.GetAimedTarget(), EBAT_ItemUse ) )
					{
						thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Released );
						thePlayer.ProcessCombatActionBuffer();
					}
					else
						thePlayer.BombThrowAbort();
				}
				else
				{
					thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Released );
					thePlayer.ProcessCombatActionBuffer();				
				}
				
				thePlayer.SetThrowHold( false );
	
				return true;
		
			}
			else
			{
				if(!IsActionAllowed(EIAB_ThrowBomb))
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_ThrowBomb);
					return false;
				}
				
				if ( thePlayer.IsHoldingItemInLHand() && !thePlayer.IsUsableItemLBlocked() )
				{
					thePlayer.SetPlayerActionToRestore ( PATR_ThrowBomb );
					thePlayer.OnUseSelectedItem( true );
					return true;
				}
				if(thePlayer.CanSetupCombatAction_Throw() && theInput.GetLastActivationTime( action.aName ) < 0.3f )	//why last activation time?
				{
					//thePlayer.PrepareToAttack();
					thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Pressed );
					return true;
				}		
			
				thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Released );
				return true;
			}
		}
		
		return false;
	}
	
	event OnThrowBombHold(action : SInputAction)
	{
		var locks : array<SInputActionLock>;
		var ind : int;

		var selectedItemId : SItemUniqueId;
	
		selectedItemId = thePlayer.GetSelectedItemId();
		if(!thePlayer.inv.IsItemBomb(selectedItemId))
			return false;
		
		if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 )
		{
			//sound to indicate you have no ammo
			if(IsPressed(action))
			{			
				thePlayer.SoundEvent( "gui_ingame_low_stamina_warning" );
			}
			
			return false;
		}
			
		if( IsPressed(action) )
		{
			if(!IsActionAllowed(EIAB_ThrowBomb))
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_ThrowBomb);
				return false;
			}
			else if(GetWitcherPlayer().GetBombDelay(GetWitcherPlayer().GetItemSlot(selectedItemId)) > 0 )
			{
				//thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, , , true);					
				return false;
			}
			if ( thePlayer.IsHoldingItemInLHand() && !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.SetPlayerActionToRestore ( PATR_ThrowBomb );
				thePlayer.OnUseSelectedItem( true );
				return true;
			}
			if(thePlayer.CanSetupCombatAction_Throw() && theInput.GetLastActivationTime( action.aName ) < 0.3f )	//why last activation time?
			{
				if( thePlayer.GetBIsCombatActionAllowed() )
				{
					thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Pressed );
					thePlayer.ProcessCombatActionBuffer();
				}
			}		
		
			//get action locks, remove bomb throw lock and check if there any other more
			//the reason is that ThrowItem always sets the lock not knowing if we'll do a hold later or not, so we have to skip this one lock instance		
			locks = GetActionLocks(EIAB_ThrowBomb);
			ind = FindActionLockIndex(EIAB_ThrowBomb, 'BombThrow');
			if(ind >= 0)
				locks.Erase(ind);
			
			if(locks.Size() != 0)
				return false;
			
			thePlayer.SetThrowHold( true );
			return true;
		}

		return false;
	}
	
	event OnThrowBombAbort(action : SInputAction)
	{		
		if( IsPressed(action) )
		{		
			thePlayer.BombThrowAbort();
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////  END OF BOMBS  //////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnCbtThrowItem( action : SInputAction )
	{			
		var isUsableItem, isCrossbow, isBomb, ret : bool;
		var itemId : SItemUniqueId;		
		
		//disabled while in air
		if(thePlayer.IsInAir() || thePlayer.GetWeaponHolster().IsOnTheMiddleOfHolstering())
			return false;
			
		if( thePlayer.IsSwimming() && !thePlayer.OnCheckDiving() && thePlayer.GetCurrentStateName() != 'AimThrow' )
			return false;
				
		itemId = thePlayer.GetSelectedItemId();
		
		if(!thePlayer.inv.IsIdValid(itemId))
			return false;
		
		isCrossbow = thePlayer.inv.IsItemCrossbow(itemId);
		if(!isCrossbow)
		{
			isBomb = thePlayer.inv.IsItemBomb(itemId);
			if(!isBomb)
			{
				isUsableItem = true;
			}
		}
		
		//if ( ( isBomb || isUsableItem ) && thePlayer.rangedWeapon && thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		//	thePlayer.OnRangedForceHolster( true, false );
		
		if( isCrossbow )
		{
			if ( IsActionAllowed(EIAB_Crossbow) )
			{
				if( IsPressed(action))
				{
					if ( thePlayer.IsHoldingItemInLHand() && !thePlayer.IsUsableItemLBlocked() )
					{
/*						thePlayer.SetPlayerActionToRestore ( PATR_None );
						thePlayer.OnUseSelectedItem( true );
						
						if ( thePlayer.GetBIsInputAllowed() )
						{
							thePlayer.SetIsAimingCrossbow( true );
							thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Pressed );						
						}
						
						ret = true;*/
						
						thePlayer.SetPlayerActionToRestore ( PATR_Crossbow );
						thePlayer.OnUseSelectedItem( true );
						ret = true;						
					}
					else if ( thePlayer.GetBIsInputAllowed() && !thePlayer.IsCurrentlyUsingItemL() )//&& thePlayer.GetBIsCombatActionAllowed() )
					{
						thePlayer.SetIsAimingCrossbow( true );
						thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Pressed );
						//thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Pressed );
						//thePlayer.ProcessCombatActionBuffer();
						ret = true;
					}
				}
				else
				{
//					if ( thePlayer.GetIsAimingCrossbow() )
					if ( thePlayer.GetIsAimingCrossbow() && !thePlayer.IsCurrentlyUsingItemL() )
					{
						thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Released );
						//thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Released );
						//thePlayer.ProcessCombatActionBuffer();					
						thePlayer.SetIsAimingCrossbow( false );
						ret = true;
					}
				}
			}
			else
			{
				if ( !thePlayer.IsInShallowWater() )
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Crossbow);				
			}
			
			if ( IsPressed(action) )
				thePlayer.AddTimer( 'IsItemUseInputHeld', 0.00001, true );
			else
				thePlayer.RemoveTimer('IsItemUseInputHeld');
				
			return ret;
		}
		else if(isBomb)
		{
			return OnThrowBomb(action);
		}
		else if(isUsableItem && !thePlayer.IsSwimming() )
		{
			if( IsActionAllowed(EIAB_UsableItem) )
			{
				if(IsPressed(action) && thePlayer.HasStaminaToUseAction(ESAT_UsableItem))
				{
					thePlayer.SetPlayerActionToRestore ( PATR_Default );
					thePlayer.OnUseSelectedItem();
					return true;
				}
/*				else if ( IsReleased(action) )
				{
					thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Released );
					return true;
				}*/
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_UsableItem);
			}
		}
		
		return false;
	}
	
	event OnCbtThrowItemHold( action : SInputAction )
	{
		var isBomb, isCrossbow, isUsableItem : bool;
		var itemId : SItemUniqueId;
		
		//disabled while in air
		if(thePlayer.IsInAir() || thePlayer.GetWeaponHolster().IsOnTheMiddleOfHolstering() )
			return false;
			
		if( thePlayer.IsSwimming() && !thePlayer.OnCheckDiving() && thePlayer.GetCurrentStateName() != 'AimThrow' )
			return false;			
				
		itemId = thePlayer.GetSelectedItemId();
		
		if(!thePlayer.inv.IsIdValid(itemId))
			return false;
		
		isCrossbow = thePlayer.inv.IsItemCrossbow(itemId);
		if(!isCrossbow)
		{
			isBomb = thePlayer.inv.IsItemBomb(itemId);
			if(isBomb)
			{
				return OnThrowBombHold(action);
			}
			else
			{
				isUsableItem = true;
			}
		}
		
		//quit if action is blocked - for bomb we already checked actionLocks.Size() so there is no check here
		if(IsPressed(action))
		{
			if( isCrossbow && !IsActionAllowed(EIAB_Crossbow) )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Crossbow);
				return false;
			}
			
			if( isUsableItem)
			{
				if(!IsActionAllowed(EIAB_UsableItem))
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_UsableItem);
					return false;
				}
				else if(thePlayer.IsSwimming())
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
					return false;
				}
			}
		}
	
		if( IsPressed(action) )
		{
			thePlayer.SetThrowHold( true );
			return true;
		}
		else if( IsReleased(action) && thePlayer.IsThrowHold())
		{
			//thePlayer.PushCombatActionOnBuffer( EBAT_ItemUse, BS_Released );
			//thePlayer.ProcessCombatActionBuffer();
			thePlayer.SetupCombatAction( EBAT_ItemUse, BS_Released );
			thePlayer.SetThrowHold( false );
			return true;
		}
		
		return false;
	}
	
	event OnCbtThrowCastAbort( action : SInputAction )
	{
		var player : W3PlayerWitcher;
		var throwStage : EThrowStage;
		
		if(thePlayer.inv.IsItemBomb(thePlayer.GetSelectedItemId()))
		{
			return OnThrowBombAbort(action);							
		}
		
		if( IsPressed(action) )
		{
			player = GetWitcherPlayer();
			if(player)
			{
				if( player.IsCastingSign() )
				{
					player.CastSignAbort();
				}
				else
				{
					if ( thePlayer.inv.IsItemCrossbow( thePlayer.inv.GetItemFromSlot( 'l_weapon' ) ) )
					{
						thePlayer.OnRangedForceHolster();
					}
					else
					{
						throwStage = (int)thePlayer.GetBehaviorVariable( 'throwStage', (int)TS_Stop);
						
						if(throwStage == TS_Start || throwStage == TS_Loop)
							player.ThrowingAbort();
					}
				}
			}
		}
	}
	
	event OnCbtSelectLockTarget( inputVector : Vector )
	{
		var newLockTarget 	: CActor;
		var inputHeading	: float;
		var target			: CActor;
		
		inputVector.Y = inputVector.Y  * -1.f;
		inputHeading =	VecHeading( inputVector );
		
		newLockTarget = thePlayer.GetScreenSpaceLockTarget( thePlayer.GetDisplayTarget(), 180.f, 1.f, inputHeading );

		if ( newLockTarget )
			thePlayer.ProcessLockTarget( newLockTarget );
		
		target = thePlayer.GetTarget();
		if ( target )
		{
			thePlayer.SetSlideTarget( target );
			//thePlayer.LockToTarget( true );
		}
	}

	event OnCbtLockAndGuard( action : SInputAction )
	{
		if(thePlayer.IsCiri() && !GetCiriPlayer().HasSword())
			return false;
		
		// moved released to front due to bug where geralt would stay in guard stance if though the button is released
		if( IsReleased(action) )
		{
			thePlayer.SetGuarded(false);
			thePlayer.OnGuardedReleased();	
		}
		
		if( (thePlayer.IsWeaponHeld('fists') || thePlayer.GetCurrentStateName() == 'CombatFists') && !IsActionAllowed(EIAB_Fists))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Fists);
			return false;
		}
		
		if( IsPressed(action) )
		{
			if( !IsActionAllowed(EIAB_Parry) )
			{
				if ( IsActionBlockedBy(EIAB_Parry,'UsableItem') )
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_Parry);
				}
				return true;
			}
				
			if ( thePlayer.GetCurrentStateName() == 'Exploration' )
				thePlayer.GoToCombatIfNeeded();
				
			if ( thePlayer.bLAxisReleased )
				thePlayer.ResetRawPlayerHeading();
			
			if ( thePlayer.rangedWeapon && thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
				thePlayer.OnRangedForceHolster( true, true );
			
			thePlayer.AddCounterTimeStamp(theGame.GetEngineTime());	//cache counter button press to further check counter button spamming by the thePlayer 		
			thePlayer.SetGuarded(true);				
			thePlayer.OnPerformGuard();
		}	
	}		
	
	event OnCbtCameraLockOrSpawnHorse( action : SInputAction )
	{
		if ( OnCbtCameraLock(action) )
			return true;
			
		if ( OnCommSpawnHorse(action) )
			return true;
			
		return false;
	}
	
	event OnCbtCameraLock( action : SInputAction )
	{	
		if( IsPressed(action) )
		{
			if ( thePlayer.IsThreatened() || thePlayer.IsActorLockedToTarget() )
			{
				if( !IsActionAllowed(EIAB_CameraLock))
				{
					return false;
				}
				else if ( !thePlayer.IsHardLockEnabled() && thePlayer.GetDisplayTarget() && (CActor)( thePlayer.GetDisplayTarget() ) && IsActionAllowed(EIAB_HardLock))
				{	
					if ( thePlayer.bLAxisReleased )
						thePlayer.ResetRawPlayerHeading();
					
					thePlayer.HardLockToTarget( true );
				}
				else
				{
					thePlayer.HardLockToTarget( false );
				}	
				return true;
			}
		}
		return false;
	}
	
	event OnChangeCameraPreset( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			((CCustomCamera)theCamera.GetTopmostCameraObject()).NextPreset();
		}
	}
	
	event OnChangeCameraPresetByMouseWheel( action : SInputAction )
	{
		var tolerance : float;
		tolerance = 10.0f;
		
		if( ( action.value * totalCameraPresetChange ) < 0.0f )
		{
			totalCameraPresetChange = 0.0f;
		}
		
		totalCameraPresetChange += action.value;
		if( totalCameraPresetChange < -tolerance )
		{
			((CCustomCamera)theCamera.GetTopmostCameraObject()).PrevPreset();
			totalCameraPresetChange = 0.0f;
		}
		else if( totalCameraPresetChange > tolerance )
		{
			((CCustomCamera)theCamera.GetTopmostCameraObject()).NextPreset();
			totalCameraPresetChange = 0.0f;
		}
	}
	
	event OnMeditationAbort(action : SInputAction)
	{
		var med : W3PlayerWitcherStateMeditation;
		
		if (!theGame.GetGuiManager().IsAnyMenu())
		{
			med = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
			if(med)
			{
				// If meditation is stopped with b button (as of writing this, only plugged into player input and not gameplay systems)
				// the menu's should not be closed automatically.
				med.StopRequested(false);
			}
		}
	}
	
	public final function ClearLocksForNGP()
	{
		var i : int;
		
		for(i=actionLocks.Size()-1; i>=0; i-=1)
		{			
			OnActionLockChanged(i, false);
			actionLocks[i].Clear();
		}		
	}
	
	///////////////////////////
	// Debug
	///////////////////////////
	
	public function Dbg_UnlockAllActions()
	{
		var i : int;
		
		if( theGame.IsFinalBuild() )
		{
			return;
		}
			
		for(i=actionLocks.Size()-1; i>=0; i-=1)
		{			
			OnActionLockChanged(i, false);
		}
		actionLocks.Clear();
	}
	
	event OnDbgSpeedUp( action : SInputAction )
	{
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		if(IsPressed(action))
		{
			theGame.SetTimeScale(4, theGame.GetTimescaleSource(ETS_DebugInput), theGame.GetTimescalePriority(ETS_DebugInput));
		}
		else if(IsReleased(action))
		{
			theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_DebugInput) );
		}
	}
	
	event OnDbgHit( action : SInputAction )
	{
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		if(IsReleased(action))
		{
			thePlayer.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Back);
			thePlayer.SetBehaviorVariable( 'isAttackReflected', 0 );
			thePlayer.SetBehaviorVariable( 'HitReactionType', (int)EHRT_Heavy);
			thePlayer.SetBehaviorVariable( 'HitReactionWeapon', 0);
			thePlayer.SetBehaviorVariable( 'HitSwingDirection',(int)ASD_LeftRight);
			thePlayer.SetBehaviorVariable( 'HitSwingType',(int)AST_Horizontal);
			
			thePlayer.RaiseForceEvent( 'Hit' );
			thePlayer.OnRangedForceHolster( true );
			GetWitcherPlayer().SetCustomRotation( 'Hit', thePlayer.GetHeading()+180, 1080.f, 0.1f, false );
			thePlayer.CriticalEffectAnimationInterrupted("OnDbgHit");
		}
	}
	
	event OnDbgKillTarget( action : SInputAction )
	{
		var target : CActor;
		
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		target = thePlayer.GetTarget();
		
		if( target && IsReleased(action) )
		{
			target.Kill( 'Debug' );
		}
	}
	
	event OnDbgKillAll( action : SInputAction )
	{
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		if(IsReleased(action))
			thePlayer.DebugKillAll();
	}
	
	//Nuke - kills all actors targeting thePlayer on the entire level
	event OnDbgKillAllTargetingPlayer( action : SInputAction )
	{
		var i : int;
		var all : array<CActor>;
	
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		if(IsPressed(action))
		{
			all = GetActorsInRange(thePlayer, 10000, 10000, '', true);
			for(i=0; i<all.Size(); i+=1)
			{
				if(all[i] != thePlayer && all[i].GetTarget() == thePlayer)
					all[i].Kill( 'Debug' );
			}
		}
	}
	
	event OnDbgTeleportToPin( action : SInputAction )
	{
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		if(IsReleased(action))
			thePlayer.DebugTeleportToPin();
	}
	///////////////////////////
	// @Boat
	///////////////////////////
	event OnBoatDismount( action : SInputAction )
	{
		var boatComp : CBoatComponent;
		var stopAction : SInputAction;

		stopAction = theInput.GetAction('GI_Decelerate');
		
		if( IsReleased(action) && ( theInput.LastUsedPCInput() || ( stopAction.value < 0.7 && stopAction.lastFrameValue < 0.7 ) ) )
		{
			if( thePlayer.IsActionAllowed( EIAB_DismountVehicle ) )
			{	
				boatComp = (CBoatComponent)thePlayer.GetUsedVehicle().GetComponentByClassName( 'CBoatComponent' );
				boatComp.IssueCommandToDismount( DT_normal );
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_DismountVehicle);
			}
		}
	}
	
	///////////////////////////
	// @Replacers
	///////////////////////////
	
	event OnCiriDrawWeapon( action : SInputAction )
	{
		var duringCastSign : bool;
	
		//draw weapon
		if ( IsReleased(action) || ( IsPressed(action) && (thePlayer.GetCurrentMeleeWeaponType() == PW_None || thePlayer.GetCurrentMeleeWeaponType() == PW_Fists) ) )
		{
			if ( thePlayer.GetBIsInputAllowed() && thePlayer.GetBIsCombatActionAllowed()  )
			{
				if (thePlayer.GetCurrentMeleeWeaponType() == PW_Steel && !thePlayer.IsThreatened() )
					thePlayer.OnEquipMeleeWeapon( PW_None, false );
				else
					thePlayer.OnEquipMeleeWeapon( PW_Steel, false );
			}
		}
		else if(IsReleased(action) || ( IsPressed(action) && (thePlayer.GetCurrentMeleeWeaponType() == PW_Steel || thePlayer.GetCurrentMeleeWeaponType() == PW_Silver) ) )
		{
			CiriSheatheWeapon();
		}
	}
	
	event OnCiriHolsterWeapon( action : SInputAction )
	{
		var currWeaponType : EPlayerWeapon;
		
		if(IsPressed( action ))
		{
			currWeaponType = thePlayer.GetCurrentMeleeWeaponType();
			
			if(currWeaponType == PW_Steel || currWeaponType == PW_Silver)
			{
				CiriSheatheWeapon();				
			}			
		}
	}
	
	private final function CiriSheatheWeapon()
	{
		if ( thePlayer.GetBIsInputAllowed() && thePlayer.GetBIsCombatActionAllowed() && !thePlayer.IsThreatened() )
		{
			thePlayer.OnEquipMeleeWeapon( PW_None, false );
		}
	}
	
	///////////////////////////
	// @Replacers
	///////////////////////////
	event OnCommHoldFastMenu( action : SInputAction )
	{
		if(IsPressed(action))
		{
			holdFastMenuInvoked = true;		
			PushInventoryScreen();
		}
	}
	
	event OnFastMenu( action : SInputAction )
	{		
		if( IsReleased(action) )
		{
			if(holdFastMenuInvoked)
			{
				holdFastMenuInvoked = false;
				return false;
			}
			
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			
			if (theGame.GetGuiManager().IsAnyMenu())
			{
				return false;
			}
			
			if( IsActionAllowed( EIAB_OpenFastMenu ) )
			{
				theGame.SetMenuToOpen( '' );
				theGame.RequestMenu('CommonMenu' );
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenFastMenu);
			}
		}
	}

	event OnIngameMenu( action : SInputAction )
	{
		var openedPanel : name;
		openedPanel = theGame.GetMenuToOpen(); 
		// #Y avoid opening menu on release after opening TutorialsMenu on hold
		if( IsReleased(action) && openedPanel != 'GlossaryTutorialsMenu' && !theGame.GetGuiManager().IsAnyMenu() ) // #B very ugly :P
		{
			if ( theGame.IsBlackscreenOrFading() )
			{
				return false;
			}
			theGame.SetMenuToOpen( '' );
			theGame.RequestMenu('CommonIngameMenu' );
		}
	}
	
	event OnToggleHud( action : SInputAction )
	{
		var hud : CR4ScriptedHud;
		if ( IsReleased(action) )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.ToggleHudByUser();
			}
		}
	}
	
	public final function Debug_ClearAllActionLocks(optional action : EInputActionBlock, optional all : bool)
	{
		var i : int;
		
		if(all)
		{
			Dbg_UnlockAllActions();			
		}
		else
		{
			OnActionLockChanged(action, false);
			actionLocks[action].Clear();
		}
	}
}
