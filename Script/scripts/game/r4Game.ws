/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2011-2014
/** Author :
/***********************************************************************/

import struct SSavegameInfo
{
	import var filename : string;			// filename is auto-generated, can be custom on PC, if save is done in editor ar renamed manually.
	import var slotType : ESaveGameType;	// valid values are: SGT_AutoSave, SGT_QuickSave, SGT_Manual, SGT_CheckPoint
	import var slotIndex : int;				// -1 means: no slot assigned (PC will always have -1 here). Remember that consoleas share the same slot numbers for quicksaves and manual saves.
											// ATM there are 2 slots for AutoSaves, 2 for checkpoints and 8 for all others, meaning (on consoles) this value have range from 0 to 1 for autosaves and checkpoints and from 0 to 7 otherwise. 
};

//#J should match enum EPlatform in configVarSystem.h
enum Platform
{
	Platform_PC = 0,
	Platform_Xbox1 = 1,
	Platform_PS4 = 2,
	Platform_Unknown = 3
}

struct SPostponedPreAttackEvent
{
	var entity		: CGameplayEntity;
	var	eventName 	: name;
	var eventType 	: EAnimationEventType;
	var data 		: CPreAttackEventData;
	var animInfo	: SAnimationEventAnimInfo;
};

import class CR4Game extends CCommonGame
{
	saved var zoneName : EZoneName;		//cached game area name updated when entering different areas
	private var gamerProfile : W3GamerProfile;
	private var isDialogOrCutscenePlaying : bool;					//is dialogue or cutscene currently playing
	private saved var recentDialogOrCutsceneEndGameTime : GameTime;		//time (as game time) of most recent dialog or cutscene end
	public var isCutscenePlaying : bool;
	public var isDialogDisplayDisabled : bool;
	default isDialogDisplayDisabled = false;
	public var witcherLog : W3GameLog;
	public var deathSaveLockId : int;
	private var currentPresence : name;
	private var restoreUsableItemL : bool;
	
	private saved var savedEnchanterFunds 			: int;
	private saved var gameplayFactsForRemoval 		: array<SGameplayFactRemoval>;
	private saved var gameplayFacts 				: array<SGameplayFact>;
	private saved var tutorialManagerHandle			: EntityHandle;			//to get tutorial manager entity after loading a game
	private saved var diffChangePostponed			: EDifficultyMode;		//postponed difficulty mode change - due to missing thePlayer object	
	private saved var dynamicallySpawnedBoats		: array<EntityHandle>;		//list of dynamically spawned boats that we keep
	private saved var dynamicallySpawnedBoatsToDestroy : array<EntityHandle>;	//list of dynamically spawned boats that we will destroy as not needed anymore
	
	private saved var uberMovement : bool; 	default uberMovement = false;
	
	function EnableUberMovement( flag : bool )
	{
		uberMovement = flag;
	}
	
	public function IsUberMovementEnabled() : bool
	{
		return uberMovement;
	}	
	
		default diffChangePostponed = EDM_NotSet;
	
	// Returns true if opened the Steam controller overlay to configure bindings. Otherwise returns false.
	import final function ShowSteamControllerBindingPanel() : bool;
	
	import final function ActivateHorseCamera( activate : bool, blendTime : float, optional instantMount : bool );
	
	import final function GetFocusModeController() : CFocusModeController;
	
	public var isRespawningInLastCheckpoint : bool;
	default isRespawningInLastCheckpoint = false;
	private var environmentID : int;
	
	public function SetIsRespawningInLastCheckpoint()
	{
		isRespawningInLastCheckpoint = true;
	}
	
	event /* C++ */ OnGameSaveListUpdated()
	{
		var menuBase 	: CR4MenuBase;
		var ingameMenu 	: CR4IngameMenu;
		
		menuBase = (CR4MenuBase)(theGame.GetGuiManager().GetRootMenu());
		
		if (menuBase)
		{
			ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
			
			if (ingameMenu)
			{
				ingameMenu.HandleSaveListUpdate();
			}
		}
	}
	
	event /* C++ */ OnGameLoadInitFinished()
	{
		var requiredContent : array< name >;
		var blockedContentTag : name;
		var i : int;
		var progress : float;
		var loadResult : ELoadGameResult;
		var ingameMenu : CR4IngameMenu;
		var menuBase : CR4MenuBase;
	
		loadResult = GetLoadGameProgress();
		blockedContentTag = 'launch0';
		
		if ( loadResult != LOAD_MissingContent && loadResult != LOAD_Error )
		{
			theSound.SoundEvent("stop_music"); // If theres an error, don't stop the music. Otherwise, stop it!
			theSound.SoundEvent("gui_global_game_start");
			theGame.GetGuiManager().RequestMouseCursor(false);
		}
		
		if ( loadResult == LOAD_NotInitialized || loadResult == LOAD_Initializing || loadResult == LOAD_Loading )
		{
			LogChannel( 'Save', "Event OnGameLoadInitFinished() called, but load not initialized / not ready / already loading. DEBUG THIS!" );
			isRespawningInLastCheckpoint = false;
			return true; // event handled
		}
		
		if ( loadResult == LOAD_MissingContent )
		{
			GetContentRequiredByLastSave( requiredContent );
			
			theSound.SoundEvent("gui_global_denied");
			
			for ( i = ( requiredContent.Size() - 1 ); i >= 0; i -= 1 )
			{
				if ( !IsContentAvailable( requiredContent[ i ] ) )
				{
					blockedContentTag = requiredContent[ i ];
					break;
				}
			}
			
			progress = ProgressToContentAvailable( blockedContentTag );
			GetGuiManager().ShowProgressDialog( UMID_MissingContentOnLoadError, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, blockedContentTag );
			isRespawningInLastCheckpoint = false;
			
			menuBase = (CR4MenuBase)(theGame.GetGuiManager().GetRootMenu());
			if (menuBase)
			{
				ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
				
				if (ingameMenu)
				{
					ingameMenu.HandleLoadGameFailed();
				}
			}
			
			return true; // event handled
		}
		
		if ( loadResult == LOAD_Error )
		{
			menuBase = (CR4MenuBase)(theGame.GetGuiManager().GetRootMenu());
			
			theSound.SoundEvent("gui_global_denied");
			
			if (menuBase)
			{
				ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
				
				if (ingameMenu)
				{
					ingameMenu.HandleLoadGameFailed();
				}
			}
		}

		if ( loadResult != LOAD_MissingContent && loadResult != LOAD_Error && isRespawningInLastCheckpoint )
		{
			ReleaseNoSaveLock( deathSaveLockId );
			theInput.RestoreContext( 'Exploration', true );
			isRespawningInLastCheckpoint = false;
		}
	}
	
	event /* C++ */ OnGameLoadInitFinishedSuccess()
	{
		GetGuiManager().GetRootMenu().CloseMenu();
	}
	
	public function IsFocusModeActive() : bool
	{
		var focusModeController : CFocusModeController;
		focusModeController = GetFocusModeController();
		if ( focusModeController )
		{
			return focusModeController.IsActive();
		}
		return false;
	}
	
	var logEnabled	: bool;
	default logEnabled = true;
	
	public function EnableLog( enable : bool )
	{
		logEnabled = enable;
	}
	
	public function CanLog() : bool
	{
		return logEnabled && !IsFinalBuild();
	}
		
	import final function GetSurfacePostFX() : CGameplayFXSurfacePost;
	
	import final function GetCommonMapManager() : CCommonMapManager;

	import final function GetJournalManager() : CWitcherJournalManager;

	import final function GetLootManager() : CR4LootManager;
	
	import final function GetInteractionsManager() : CInteractionsManager;
	
	import final function GetCityLightManager() : CCityLightManager;	
	
	import final function GetSecondScreenManager() : CR4SecondScreenManagerScriptProxy;
		
	import final function GetGuiManager() : CR4GuiManager;

	import final function GetGlobalEventsScriptsDispatcher() : CR4GlobalEventsScriptsDispatcher;
	
	import final function GetFastForwardSystem() : CGameFastForwardSystem;
	
	import final function NotifyOpeningJournalEntry( jorunalEntry : CJournalBase );
	
	var globalEventsScriptsDispatcherInternal :	CR4GlobalEventsScriptsDispatcher;
	public function GetGlobalEventsManager() : CR4GlobalEventsScriptsDispatcher
	{
		if ( !globalEventsScriptsDispatcherInternal )
		{
			globalEventsScriptsDispatcherInternal = GetGlobalEventsScriptsDispatcher();
		}
		return globalEventsScriptsDispatcherInternal;
	}
		
	// Start sepia effect
	import final function StartSepiaEffect( fadeInTime: float ) : bool;
	
	// Start sepia effect
	import final function StopSepiaEffect( fadeOutTime: float ) : bool;
	
	// Get the calculated wind value for point, accounting global wind and all the wind emitters in range
	import final function GetWindAtPoint( point : Vector ) : Vector;
	// Get the calculated wind value for point for visuals, accounting global wind and all the wind emitters in range
	import final function GetWindAtPointForVisuals( point : Vector ) : Vector;
	
	import final function GetGameCamera() : CCustomCamera;
	
	//temp here
	import final function GetBuffImmunitiesForActor( actor : CActor ) : CBuffImmunity;
	import final function GetMonsterParamsForActor( actor : CActor, out monsterCategory : EMonsterCategory, out soundMonsterName : CName, out isTeleporting : bool, out canBeTargeted : bool, out canBeHitByFists : bool ) : bool;
	import final function GetMonsterParamForActor( actor : CActor, out val : CMonsterParam ) : bool;
	
	// get the volume path manager
	import final function GetVolumePathManager() : CVolumePathManager;
	
	// spawn player horse or teleport if exists, the horse will be tagged with 'PLAYER_horse'
	import final function SummonPlayerHorse( teleportToSafeSpot : bool, createEntityHelper : CR4CreateEntityHelper );

	// toggle vs for menus
	import final function ToggleMenus();
	import final function ToggleInput();
	
	import final function GetResourceAliases( out aliases : array< string > );
	
	//kinect
	import final function GetKinectSpeechRecognizer() : CR4KinectSpeechRecognizerListenerScriptProxy;
	
	// tutorial system access
	import final function GetTutorialSystem() : CR4TutorialSystem;
	
	// User profile
	import final function DisplaySystemHelp();
	import final function DisplayUserProfileSystemDialog();
	import final function SetRichPresence( presence : name );

	// callback to c++ from user ui box
	import final function OnUserDialogCallback( message, action : int );
	
	// Save user settings
	import final function SaveUserSettings();
	
	public final function UpdateRichPresence(presence : name)
	{
		SetRichPresence(presence);
		currentPresence = presence;
	}
	
	public final function ClearRichPresence(presence : name)
	{
		var manager: CCommonMapManager;
	    var currentArea : EAreaName;
	    
		//don't clear if some other area has already changed presence setting
		if(currentPresence == presence)
		{
			manager = theGame.GetCommonMapManager();
			currentArea = manager.GetCurrentJournalArea();
			currentPresence =  manager.GetLocalisationNameFromAreaType( currentArea );
			SetRichPresence(currentPresence);
			/*
			SetRichPresence('location_outside_all');
			currentPresence = 'location_outside_all';
			*/
		}
	}
	
	//game globals
	import var params : W3GameParams;

	private var minimapSettings : C2dArray; //#B
	public var playerStatisticsSettings : C2dArray; //#B
	public var hudSettings : C2dArray; //#B

	// this handles all damage dealing
	public var damageMgr : W3DamageManager;

	// this instance holds cached effects for further use
	public var effectMgr : W3GameEffectManager;
	
	// timescale management
	private var timescaleSources : array<STimescaleSource>;

	// updates environments
	public saved var envMgr : W3EnvironmentManager;
	
	public var runewordMgr : W3RunewordManager;
	
	private var questLevelsFilePaths : array<string>;
	public var questLevelsContainer : array<C2dArray>; 
	public var expGlobalModifiers : C2dArray; 
	public var expGlobalMod_kills : float;
	public var expGlobalMod_quests : float;
	
	//sync anims
	private var syncAnimManager : W3SyncAnimationManager;
	public function GetSyncAnimManager() : W3SyncAnimationManager
	{
		if( !syncAnimManager )
		{
			syncAnimManager = new W3SyncAnimationManager in this;
		}
		
		return syncAnimManager;
	}
	
	//drinking minigame
	/* REMOVED_DRINKING
	public var drinkingMinigameMananger : W3DrinkingManager;	
	public function CreateDrinkingManager()	{ drinkingMinigameMananger = new W3DrinkingManager in this; }
	public function DeleteDrinkingManager()	{ delete drinkingMinigameMananger; }
	*/
	
	public function SetEnvironmentID( id : int )
	{
		environmentID = id;
	}
	
	private function SetTimescaleSources()
	{
		timescaleSources.Clear();
		timescaleSources.Grow( EnumGetMax('ETimescaleSource') + 1 );

		//ETS_PotionBlizzard
		timescaleSources[ ETS_PotionBlizzard ].sourceType = ETS_PotionBlizzard;
		timescaleSources[ ETS_PotionBlizzard ].sourceName = 'PotionBlizzard';
		timescaleSources[ ETS_PotionBlizzard ].sourcePriority = 10;
		
		//ETS_SlowMoTask
		timescaleSources[ ETS_SlowMoTask ].sourceType = ETS_SlowMoTask;
		timescaleSources[ ETS_SlowMoTask ].sourceName = 'SlowMotionTask';
		timescaleSources[ ETS_SlowMoTask ].sourcePriority = 15;
		
		//ETS_HeavyAttack
		timescaleSources[ ETS_HeavyAttack ].sourceType = ETS_HeavyAttack;
		timescaleSources[ ETS_HeavyAttack ].sourceName = 'HeavyAttack';
		timescaleSources[ ETS_HeavyAttack ].sourcePriority = 15;
		
		//ETS_ThrowingAim
		timescaleSources[ ETS_ThrowingAim ].sourceType = ETS_ThrowingAim;
		timescaleSources[ ETS_ThrowingAim ].sourceName = 'ThrowingAim';
		timescaleSources[ ETS_ThrowingAim ].sourcePriority = 15;
		
		//ETS_RaceSlowMo
		timescaleSources[ ETS_RaceSlowMo ].sourceType = ETS_RaceSlowMo;
		timescaleSources[ ETS_RaceSlowMo ].sourceName = 'RaceSlowMo';
		timescaleSources[ ETS_RaceSlowMo ].sourcePriority = 10;
		
		//ETS_RadialMenu
		timescaleSources[ ETS_RadialMenu ].sourceType = ETS_RadialMenu;
		timescaleSources[ ETS_RadialMenu ].sourceName = 'RadialMenu';
		timescaleSources[ ETS_RadialMenu ].sourcePriority = 20;
		
		//ETS_CFM_PlayAnim
		timescaleSources[ ETS_CFM_PlayAnim ].sourceType = ETS_CFM_PlayAnim;
		timescaleSources[ ETS_CFM_PlayAnim ].sourceName = 'CFM_PlayAnim';
		timescaleSources[ ETS_CFM_PlayAnim ].sourcePriority = 25;
		
		//ETS_CFM_On
		timescaleSources[ ETS_CFM_On ].sourceType = ETS_CFM_On;
		timescaleSources[ ETS_CFM_On ].sourceName = 'CFM_On';
		timescaleSources[ ETS_CFM_On ].sourcePriority = 20;
		
		//ETS_DebugInput
		timescaleSources[ ETS_DebugInput ].sourceType = ETS_DebugInput;
		timescaleSources[ ETS_DebugInput ].sourceName = 'debug_input';
		timescaleSources[ ETS_DebugInput ].sourcePriority = 30;
		
		//ETS_SkillFrenzy
		timescaleSources[ ETS_SkillFrenzy ].sourceType = ETS_SkillFrenzy;
		timescaleSources[ ETS_SkillFrenzy ].sourceName = 'skill_frenzy';
		timescaleSources[ ETS_SkillFrenzy ].sourcePriority = 15;
		
		//ETS_HorseMelee
		timescaleSources[ ETS_HorseMelee ].sourceType = ETS_HorseMelee;
		timescaleSources[ ETS_HorseMelee ].sourceName = 'horse_melee';
		timescaleSources[ ETS_HorseMelee ].sourcePriority = 15;
		
		//ETS_FinisherInput
		timescaleSources[ ETS_FinisherInput ].sourceType = ETS_FinisherInput;
		timescaleSources[ ETS_FinisherInput ].sourceName = 'finisher_input';
		timescaleSources[ ETS_FinisherInput ].sourcePriority = 15;
		
		//ETS_TutorialFight
		timescaleSources[ ETS_TutorialFight ].sourceType = ETS_TutorialFight;
		timescaleSources[ ETS_TutorialFight ].sourceName = 'tutorial_fight';
		timescaleSources[ ETS_TutorialFight ].sourcePriority = 25;
		
		//ETS_InstantKill
		timescaleSources[ ETS_InstantKill ].sourceType = ETS_InstantKill;
		timescaleSources[ ETS_InstantKill ].sourceName = 'instant_kill';
		timescaleSources[ ETS_InstantKill ].sourcePriority = 5;
	}
	
	public function GetTimescaleSource(src : ETimescaleSource) : name
	{
		return timescaleSources[src].sourceName;
	}
	
	public function GetTimescalePriority(src : ETimescaleSource) : int
	{
		return timescaleSources[src].sourcePriority;
	}
	
	private function UpdateSecondScreen()
	{
		var areaMapPins 			: array< SAreaMapPinInfo >;
		var areaMapPinsCount		: int;
		var index_areas				: int;
		var worldPath				: string;
		var localMapPins			: array< SCommonMapPinInstance >;
		var globalMapPins		 	: array< SCommonMapPinInstance >;
		var mapPin					: SCommonMapPinInstance;
	
		areaMapPins 		= GetCommonMapManager().GetAreaMapPins();
		areaMapPinsCount 	= areaMapPins.Size();
	    for ( index_areas = 0; index_areas < areaMapPinsCount; index_areas += 1 )
	    {	   
			mapPin.id = areaMapPins[ index_areas ].areaType;
			mapPin.tag = '0';
			mapPin.type = 'WorldMap';
			mapPin.position = areaMapPins[ index_areas ].position;
			mapPin.isDiscovered = true;
			globalMapPins.PushBack( mapPin );
			
			localMapPins	= GetCommonMapManager().GetMapPinInstances( areaMapPins[ index_areas ].worldPath );
			GetSecondScreenManager().SendAreaMapPins( areaMapPins[ index_areas ].areaType, localMapPins );			
		}		
		
		GetSecondScreenManager().SendGlobalMapPins( globalMapPins );	
	}
	
	// #J Values should match enum Platform defined at top of file
	import final function GetPlatform():int;
	
	private var isSignedIn:bool;
	default isSignedIn = false;
	
	public function isUserSignedIn():bool
	{
		if (GetPlatform() == Platform_PC)
		{
			return true;
		}
		else
		{
			return isSignedIn;
		}
	}
	
	event OnUserSignedIn()
	{
		isSignedIn = true;
		
		GetGuiManager().OnSignIn();
	}
	
	event OnUserSignedOut()
	{
		isSignedIn = false;
		
		GetGuiManager().OnSignOut();
	}
	
	event OnSignInStarted()
	{
		GetGuiManager().OnSignInStarted();
	}
	
	event OnSignInCancelled()
	{
		GetGuiManager().OnSignInCancelled();
	}
	
	import final function SetActiveUserPromiscuous();
	
	import final function ChangeActiveUser();
	
	import final function GetActiveUserDisplayName() : string;
	
	// returns if all content up to the specified tag is properly installed
	import final function IsContentAvailable( content : name ) : bool;
	
	// returns the percentage of the install process towards reaching that content tag 10 = 10 percent
	import final function ProgressToContentAvailable( content : name ) : int;
	
	import final function ShouldForceInstallVideo() : bool;
	
	import final function IsDebugQuestMenuEnabled() : bool;
	
	// this is for the quest to mark a point, where we start doing saves with NGP enabled
	import final function EnableNewGamePlus( enable : bool );
	
	/* this is defined on C++ side:
	enum ENewGamePlusStatus
	{
		NGP_Success,				// when everything went fine
		NGP_Invalid,				// when passed SSavegameInfo is not a valid one
		NGP_CantLoad,				// when save data cannot be loaded (like: corrupted save data or missing DLC)
		NGP_TooOld,					// when save data is made on unpatched game version and needs to be resaved
		NGP_RequirementsNotMet,		// when player didn't finish the game or have too low level
		NGP_InternalError,			// shouldn't happen at all, means that we have internal problems with the game
		NGP_ContentRequired,		// when the game is not fully installed
	};
	call StartNewGamePlus() and check the result. Then display appropriate message if needed. */
	import final function StartNewGamePlus( save : SSavegameInfo ) : ENewGamePlusStatus;
	
	public function OnConfigValueChanged( varName : name, value : string ) : void
	{
		var kinect : CR4KinectSpeechRecognizerListenerScriptProxy;
		kinect = GetKinectSpeechRecognizer();
		
		if ( varName == 'Kinect' )
		{
			if ( value == "true" )
				kinect.SetEnabled( true );
			else
				kinect.SetEnabled( false );
		}
	}
	
	public function LoadQuestLevels( filePath: string ) : void
	{	
		var index : int;	
		index = questLevelsFilePaths.FindFirst( filePath );		
		if( index == -1 )
		{		
			questLevelsFilePaths.PushBack( filePath );	
			questLevelsContainer.PushBack( LoadCSV( filePath ) ); 
		}
	}
	
	public function UnloadQuestLevels( filePath: string ) : void
	{	
		var index : int;	
		index = questLevelsFilePaths.FindFirst( filePath );		
		if( index != -1 )
		{
			questLevelsFilePaths.Erase( index );	
			questLevelsContainer.Erase( index );
		}		 
	}
	
	event OnGameStarting(restored : bool )
	{
		var diff : int;
	
		if(!restored)
		{
			//because when you launch the game there is some memory corruption (?). In any case: variables are not reset but instead hold their values from previous session
			gameplayFacts.Clear();
			gameplayFactsForRemoval.Clear();
		}
		
		if (!FactsDoesExist("lowest_difficulty_used") || GetLowestDifficultyUsed() == EDM_NotSet)
		{
			SetLowestDifficultyUsed(GetDifficultyLevel());
		}
			
		SetHoursPerMinute(0.25);	//this is actually set somewhere in C++ but we need to reset it with each new game session as editor fails to do that	
		SetTimescaleSources();
		
		//reset since theGame object does not reset properly on game launch
		isDialogOrCutscenePlaying = false;
	
		// params object is already created in c++
		params.Init();
		
		//combat log
		witcherLog = new W3GameLog in this;
				
		InitGamerProfile();
			
		// initializing damage manager
		damageMgr = new W3DamageManager in this;

		tooltipSettings = LoadCSV("gameplay\globals\tooltip_settings.csv");
		minimapSettings = LoadCSV("gameplay\globals\minimap_settings.csv"); //#B
		LoadHudSettings();
		playerStatisticsSettings = LoadCSV("gameplay\globals\player_statistics_settings.csv"); //#B 
					
		LoadQuestLevels( "gameplay\globals\quest_levels.csv" );		 
		
		expGlobalModifiers = LoadCSV("gameplay\globals\exp_mods.csv"); 
		expGlobalMod_kills = StringToFloat( expGlobalModifiers.GetValueAt(0,0) );
		expGlobalMod_quests = StringToFloat( expGlobalModifiers.GetValueAt(1,0) );
		
		InitializeEffectManager();

		envMgr = new W3EnvironmentManager in this;
		envMgr.Initialize();
		
		runewordMgr = new W3RunewordManager in this;
		runewordMgr.Init();
		
		theGame.RequestPopup( 'OverlayPopup' );
		
		theSound.Initialize();	
		if(IsLoadingScreenVideoPlaying())
		{
			theSound.EnterGameState(ESGS_Movie);
		}
	}
		
	private function InitGamerProfile()
	{
		gamerProfile = new W3GamerProfile in this;
		gamerProfile.Init();
	}
	
	public function GetGamerProfile() : W3GamerProfile
	{
		//because objects are created randomly on game start and might be created before the game is created
		if(!gamerProfile)
			InitGamerProfile();
		
		return gamerProfile;
	}
	
	public function OnTick()
	{
		if(envMgr)
			envMgr.Update();
			
		//if player finally spawned we can update scheduled difficulty change
		if(diffChangePostponed != EDM_NotSet && thePlayer)
		{
			OnDifficultyChanged(diffChangePostponed);
			diffChangePostponed = EDM_NotSet;
		}
		
		FirePostponedPreAttackEvents();
	}	
	
	event OnGameStarted(restored : bool)
	{
		var focusModeController : CFocusModeController;
		
		focusModeController = GetFocusModeController();
		
		if( !restored )
		{
			//call this only once at the start of new game to clear VALUES FROM PREVIOUS GAME SESSIONS BECAUSE ENGINE DOESN'T CLEAR THEM
			if(FactsQuerySum("started_new_game") <= 0)
			{
				thePlayer.displayedQuestsGUID.Clear();

				dynamicallySpawnedBoats.Clear();
				FactsAdd("started_new_game", 1);
			}
		}
		
		if ( focusModeController )
		{
			focusModeController.OnGameStarted();
		}
	
		GetCommonMapManager().OnGameStarted();
		
		//rich presence
		ClearRichPresence(currentPresence);		

		theSound.InitializeAreaMusic( GetCommonMapManager().GetCurrentArea() );
		UpdateSecondScreen();
		
		if( thePlayer && thePlayer.teleportedOnBoatToOtherHUB )
		{
			thePlayer.SetTeleportedOnBoatToOtherHUB( false );
			thePlayer.AddTimer( 'DelayedSpawnAndMountBoat', 0.001f, false );
		}
	}
	
	event OnHandleWorldChange()
	{
		thePlayer.SetTeleportedOnBoatToOtherHUB( true );
	}

	
	event OnBeforeWorldChange( worldName : string )
	{
		// force setting loading screen video
		var manager : CCommonMapManager = theGame.GetCommonMapManager();
		if ( manager )
		{
			manager.CacheMapPins();
			manager.ForceSettingLoadingScreenVideoForWorld( worldName );
		}

		// clear used vehicle handle so it's empty when player is spawned in new world
		thePlayer.SetUsedVehicle( NULL );
	}
	
	event OnAfterLoadingScreenGameStart()
	{
		var tut : STutorialMessage;
		
		// Try to change the game state in case we were in a movie loading screen.
		theSound.LeaveGameState(ESGS_Movie);
		// If we entered constrained mode when in main menu or alt tabbed, we can be now in Menu mixing state.
		// We fire the system_resume in order to get out of it.
		theSound.SoundEvent("system_resume");
		
		//show stash tutorial message if game loaded and it's a pre-stash playthrough
		if(ShouldProcessTutorial('TutorialStash') && FactsQuerySum("tut_stash_fresh_playthrough") <= 0)
		{			
			//fill tutorial object data
			tut.type = ETMT_Message;
			tut.tutorialScriptTag = 'TutorialStash';
			tut.canBeShownInMenus = false;
			tut.glossaryLink = false;
			tut.markAsSeenOnShow = true;
			
			//show tutorial
			theGame.GetTutorialSystem().DisplayTutorial(tut);
		}
	}
	
	event /* C++ */ OnSaveStarted( type : ESaveGameType )
	{
		LogChannel( 'Savegame', "OnSaveStarted " + type );
		//theGame.GetGuiManager().ShowSavingIndicator(); // #Y disable for cert version
	}

	event /* C++ */ OnSaveCompleted( type : ESaveGameType, succeeded : bool )
	{
		var hud : CR4ScriptedHud;
		var text : string;

		LogChannel( 'Savegame', "OnSaveCompleted " + type + " " + succeeded );
		
		if ( succeeded )
		{
			theGame.GetGuiManager().ShowSavingIndicator();
			theGame.GetGuiManager().HideSavingIndicator();
		
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				text = "panel_hud_message_gamesaved_X1";
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				text = "panel_hud_message_gamesaved_PS4";
			}
			else
			{
				text = "panel_hud_message_gamesaved";
			}
			
			if ( type == SGT_AutoSave || type == SGT_CheckPoint || type == SGT_ForcedCheckPoint )
			{
				hud = ( CR4ScriptedHud )GetHud();
				if ( hud )
				{
					hud.HudConsoleMsg( GetLocStringByKeyExt(text) );
				}
			}
			else
			{
				thePlayer.DisplayHudMessage( text );
			}
		}
		else if ( type == SGT_QuickSave || type == SGT_Manual )
		{
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				text = "panel_hud_message_gamesavedfailed_X1";	
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				text = "panel_hud_message_gamesavedfailed_PS4";
			}
			else
			{
				text = "panel_hud_message_gamesavedfailed";
			}
			
			theGame.GetGuiManager().ShowUserDialog(0, "", text, UDB_Ok);
		}
	}

	event OnControllerReconnected()
	{
		if(!theGame.IsBlackscreen() && theGame.IsActive())
		{
			if(theGame.GetGuiManager().IsAnyMenu())
			{//if we are in a menu we resume music only
				theSound.SoundEvent("system_resume_music_only");
			}
			else
			{
				theSound.SoundEvent("system_resume");
			}
		}
		
		GetGuiManager().OnControllerReconnected();
	}
	
	event OnControllerDisconnected()
	{
		if(!theGame.IsBlackscreen() && theGame.IsActive() && !theGame.GetGuiManager().IsAnyMenu())
		{
			//we dont want to pause sounds if game is loading or is inactive or is already paused cos of Menu
			theSound.SoundEvent("system_pause");
		}
		
		GetGuiManager().OnControllerDisconnected();
	}
	
	//called when a quest reward is given
	event OnGiveReward( target : CEntity, rewardName : name, rewrd : SReward )
	{
		var i 						: int;
		var itemCount				: int;
		var gameplayEntity 			: CGameplayEntity;
		var inv		 				: CInventoryComponent;
		var goldMultiplier			: float;
		var itemMultiplier			: float;
		var itemsCount				: int;
		var ids						: array<SItemUniqueId>;
		var itemCategory 			: name;
		var lvlDiff					: int;
		var moneyWon				: int;
		var expModifier				: float;
		var difficultyMode			: EDifficultyMode;
		var rewardNameS				: string;
		var ep1Content				: bool;
		var rewardMultData			: SRewardMultiplier;
		
		if ( target == thePlayer )
		{
			// exp 
			if ( rewrd.experience > 0 && GetWitcherPlayer())
			{
				// check of EP1 content
				rewardNameS = NameToString(rewardName);
				ep1Content = false;
				if ( StrContains(rewardNameS, "q60") )
				{
					ep1Content = true;
				}
				
				{
					if(FactsQuerySum("witcher3_game_finished") > 1 && !ep1Content )
					{
						expModifier = 0.5f;		//after completing the main quest line we get always 50% base exp
					}
					else
					{
						if ( rewrd.level == 0 )
						{
							expModifier = 1.f;   // special quests
						}
						else
						{
							lvlDiff = rewrd.level - thePlayer.GetLevel();
							
							//reward levels are set for base game, we need to increase them in NG+
							if(FactsQuerySum("NewGamePlus") > 0)
								lvlDiff += params.GetNewGamePlusLevel();
								
							if ( lvlDiff <= -theGame.params.LEVEL_DIFF_HIGH )
							{
								expModifier = 0.f; 		//no exp
							}
							else
							{
								difficultyMode = theGame.GetDifficultyMode();
								if ( difficultyMode == EDM_Hardcore )
								{
									expModifier = 0.8;
								}
								else if ( difficultyMode == EDM_Hard )
								{
									expModifier = 0.9;
								}
								else
								{
									expModifier = 1.0;
								}
								
								if ( ep1Content && lvlDiff < theGame.params.LEVEL_DIFF_HIGH )
								{
									expModifier += lvlDiff * theGame.params.LEVEL_DIFF_XP_MOD;
									if ( expModifier > theGame.params.MAX_XP_MOD )
										expModifier = theGame.params.MAX_XP_MOD;
									if ( expModifier < 0.f )
										expModifier = 0.f;
								}
							}
						}
					}
				}
				
				if(expModifier > 0.f)
					GetWitcherPlayer().AddPoints( EExperiencePoint, RoundF( rewrd.experience * expGlobalMod_quests * expModifier), true);
				else if ( expModifier == 0.f && rewrd.experience > 0 )
				{
					expModifier = 0.05f;			
					GetWitcherPlayer().AddPoints( EExperiencePoint, RoundF( rewrd.experience * expGlobalMod_quests * expModifier), true);
				}
			}
			
			if ( rewrd.achievement > 0 )
			{
				theGame.GetGamerProfile().AddAchievement( rewrd.achievement );
			}
		}
		
		gameplayEntity = (CGameplayEntity)target;
		if ( gameplayEntity )
		{
			inv = gameplayEntity.GetInventory();
			if ( inv )
			{
				rewardMultData = thePlayer.GetRewardMultiplierData( rewardName );
				
				if( rewardMultData.isItemMultiplier )
				{
					goldMultiplier = 1.0;
					itemMultiplier = rewardMultData.rewardMultiplier;
				}
				else
				{
					goldMultiplier = rewardMultData.rewardMultiplier;
					itemMultiplier = 1.0;
				}
				
				// gold
				if ( rewrd.gold > 0 )
				{
					inv.AddMoney( (int)(rewrd.gold * goldMultiplier) );
					thePlayer.RemoveRewardMultiplier(rewardName);		
					if( target == thePlayer )
					{
						moneyWon = (int)(rewrd.gold * goldMultiplier);
						
						if ( moneyWon > 0 )
							thePlayer.DisplayItemRewardNotification('Crowns', moneyWon );
					}
				}
				
				// items
				
				for ( i = 0; i < rewrd.items.Size(); i += 1 )
				{
					itemsCount = RoundF( rewrd.items[ i ].amount * itemMultiplier );
					
					if( itemsCount > 0 )
					{
						ids = inv.AddAnItem( rewrd.items[ i ].item, itemsCount );
						
						for ( itemCount = 0; itemCount < ids.Size(); itemCount += 1 )
						{
							// failsafe - when item is spawned in container and there is no player level yet - reset item and regenerate
							if ( inv.ItemHasTag( ids[i], 'Autogen' ) && GetWitcherPlayer().GetLevel() - 1 > 1 )
							{ 
								inv.GenerateItemLevel( ids[i], true );
							}
						}
						
						itemCategory = inv.GetItemCategory( ids[0] );
						if ( itemCategory == 'alchemy_recipe' ||  itemCategory == 'crafting_schematic' )
						{
							inv.ReadSchematicsAndRecipes( ids[0] );
						}						
						
						if(target == thePlayer)
						{
							//Gwint cards should not display info in rewards, notification is handled inside AddAnItem function to display info from all sources
							if( !inv.ItemHasTag( ids[0], 'GwintCard') )
							{
								thePlayer.DisplayItemRewardNotification(rewrd.items[ i ].item, RoundF( rewrd.items[ i ].amount * itemMultiplier ) );
							}
						}
					}
				}
			}
		}
	}

	public function IsEffectManagerInitialized() : bool
	{
		if(!effectMgr)
			return false;
		
		return effectMgr.IsReady();
	}
	
	public function InitializeEffectManager()
	{
		effectMgr = new W3GameEffectManager in this;
		effectMgr.Initialize();
	}
	
	public function GetLowestDifficultyUsed() : EDifficultyMode
	{
		return FactsQuerySum("lowest_difficulty_used");
	}
	
	public function SetLowestDifficultyUsed(d : EDifficultyMode)
	{
		FactsSet("lowest_difficulty_used", (int)d);
	}
	
	// Game ended
	event OnGameEnded()
	{	
		var focusModeController : CFocusModeController;
		
		if ( runewordMgr )
		{
			delete runewordMgr;
			runewordMgr = NULL;
		}
		
		focusModeController = GetFocusModeController();
		if ( focusModeController )
		{
			focusModeController.OnGameEnded();
		}
		
		DeactivateEnvironment( environmentID, 0 );
			
		if(effectMgr)
		{
			delete effectMgr;
			effectMgr = NULL;
		}
		
		if(envMgr)
		{
			delete envMgr;
			envMgr = NULL;
		}
		
		if( syncAnimManager )
		{
			delete syncAnimManager;
			syncAnimManager = NULL;
		}
		
		RemoveTimeScale( GetTimescaleSource(ETS_RadialMenu) );

		//for sound debuging/ambients in editor
		theSound.Finalize();
		//theSound.SoundState( "game_state", ""  );
		
		LogChannel( 'HUD', "GUI Closed" );
	}
		
	public var m_runReactionSceneDialog : bool;
	public function SetRunReactionSceneDialog( val : bool ){ m_runReactionSceneDialog = val; }
	
	public function SetIsDialogOrCutscenePlaying(b : bool)
	{
		var witcher 	 	: W3PlayerWitcher;
		var activePoster 	: W3Poster;
		var hud			 	: CR4ScriptedHud;
		var radialModule 	: CR4HudModuleRadialMenu;
		var lootPopup		: CR4LootPopup;
		var bolts			: SItemUniqueId;
		
		isDialogOrCutscenePlaying = b;
		recentDialogOrCutsceneEndGameTime = GetGameTime();
		
		if ( b)
		{
			hud = (CR4ScriptedHud)GetHud();
	
			if( hud )
			{
				radialModule = (CR4HudModuleRadialMenu)hud.GetHudModule("RadialMenuModule");
				if (radialModule && radialModule.IsRadialMenuOpened())
				{
					radialModule.HideRadialMenu();
				}
			}
			
			lootPopup = (CR4LootPopup)GetGuiManager().GetPopup('LootPopup');
			
			if (lootPopup)
			{
				lootPopup.ClosePopup();
			}
		}
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())
		{
			theGame.GetTutorialSystem().OnCutsceneOrDialogChange(b);
			
			if(b)
			{
				FactsAdd("tut_dialog_started", 1, CeilF(ConvertRealTimeSecondsToGameSeconds(1)));
			}
		}
		
		//disable player quen
		witcher = GetWitcherPlayer();
		if(b && witcher && witcher.IsAnyQuenActive())
		{
			witcher.FinishQuen( true, true );			
		}
		
		activePoster = thePlayer.GetActivePoster ();
		
		if ( activePoster )
		{
			CloseMenu('PosterMenu');
			activePoster.OnEndedObservingPoster();
		}
		
		if ( b && thePlayer.IsHoldingItemInLHand ())
		{
			thePlayer.HideUsableItem( true );
			restoreUsableItemL = true;
		}
		if ( !b && restoreUsableItemL )
		{
			restoreUsableItemL = false;
			
			if ( !thePlayer.IsInCombat() )
			{
				thePlayer.OnUseSelectedItem();
			}
		}
		
		//harpoon equip hack - sometimes scenes can teleport player to water for a short while - in such case 
		//harpoons equip properly but it does not handle getting out of the water properly
		if(!b && witcher)
		{
			//if no bolts equipped or equipped bodkin/harpoon bolts
			if(!witcher.GetItemEquippedOnSlot(EES_Bolt, bolts) || witcher.inv.ItemHasTag(bolts, theGame.params.TAG_INFINITE_AMMO))			
				witcher.AddAndEquipInfiniteBolt();
		}
	}
	
	public final function IsDialogOrCutscenePlaying() : bool
	{
		return isDialogOrCutscenePlaying;
	}
	
	public final function GetRecentDialogOrCutsceneEndGameTime() : GameTime
	{
		return recentDialogOrCutsceneEndGameTime;
	}
	
	public final function GetSavedEnchanterFunds() : int
	{
		return savedEnchanterFunds;
	}

	public final function SetSavedEnchanterFunds( value : int )
	{
		savedEnchanterFunds = value;
	}

	//bullshit as the var is public but cannot be accessed
	public function SetIsCutscenePlaying(b : bool)
	{
		isCutscenePlaying = b;
	}
	
	/////////////////////////////////////////////
	// MAIN MENU
	/////////////////////////////////////////////
	
	/* C++ */ public function PopulateMenuQueueStartupOnce( out menus : array< name > )
	{
		menus.PushBack( 'StartupMoviesMenu' );
	}
	
	/* C++ */ public function PopulateMenuQueueStartupAlways( out menus : array< name > )
	{
		if (GetPlatform() != Platform_PC)
		{
			if ( theGame.GetDLCManager().IsEP2Available() )
			{
				menus.PushBack( 'StartScreenMenuEP2' );
			}
			else if ( theGame.GetDLCManager().IsEP1Available() )
			{
				menus.PushBack( 'StartScreenMenuEP1' );
			}
			else
			{
				menus.PushBack( 'StartScreenMenu' );
			}
		}
	}
	
	/* C++ */ public function PopulateMenuQueueConfig( out menus : array< name > )
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		
		if( GetPlatform() != Platform_PC )
		{
			menus.PushBack( 'RescaleMenu' );
			menus.PushBack( 'MainGammaMenu' );
		}
	}

	/* C++ */ public function PopulateMenuQueueMainOnce( out menus : array< name > )
	{
		if (GetPlatform() != Platform_PC)
		{
			menus.PushBack( 'AutosaveWarningMenu' );
		}
		menus.PushBack( 'RecapMoviesMenu' );
	}
	
	/* C++ */ public function PopulateMenuQueueMainAlways( out menus : array< name > )
	{
		if (theGame.GetDLCManager().IsEP2Available())
		{
			menus.PushBack( 'CommonMainMenuEP2' );
		}
		else if (theGame.GetDLCManager().IsEP1Available())
		{
			menus.PushBack( 'CommonMainMenuEP1' );
		}
		else
		{
			menus.PushBack( 'CommonMainMenu' );
		}
	}

	public function GetNewGameDefinitionFilename() : string
	{
		return "game/witcher3.redgame";
	}
	
	/////////////////////////////////////////////
	// GAME ZONES
	/////////////////////////////////////////////
	
	public function GetCurrentZone() : EZoneName
	{
		return zoneName;
	}
	
	public function SetCurrentZone( tag : name )
	{
		zoneName = ZoneNameToType( tag );
	}
		
	/////////////////////////////////////////////
	// 					UI
	/////////////////////////////////////////////
	
	private var uiHorizontalFrameScale : float;	default uiHorizontalFrameScale 				= 1.0;
	private var uiVerticalFrameScale : float;	default uiVerticalFrameScale 				= 1.0;
	private var uiScale : float;				default uiScale 							= 1.0;	
	private var uiGamepadScaleGain : float;		default uiGamepadScaleGain 					= 0.0;
	private var uiOpacity : float;				default uiOpacity 							= 0.8;
	
	// #Y temp solution to store this value
	protected var isColorBlindMode:bool;
	public function getColorBlindMode():bool
	{
		return isColorBlindMode;
	}
	public function setColorBlindMode(value:bool)
	{
		isColorBlindMode = value;
	}
	
	// menu to be opened by common/background menu
	private var menuToOpen : name;
	public function GetMenuToOpen() : name
	{
		return menuToOpen;
	}
	public function SetMenuToOpen( menu : name )
	{
		menuToOpen = menu;
	}
	
	public function RequestMenuWithBackground( menu : name, backgroundMenu : name, optional initData : IScriptable )
	{
		var commonMenu : CR4CommonMenu;
		var guiManager : CR4GuiManager;
		
		guiManager = GetGuiManager();
		commonMenu = (CR4CommonMenu)guiManager.GetRootMenu();
		if( commonMenu )
		{
			commonMenu.SwitchToSubMenu(menu,"");
		}
		else
		{
			if ( guiManager.IsAnyMenu() )
			{
				guiManager.GetRootMenu().CloseMenu();
			}
			
			SetMenuToOpen( menu );
			theGame.RequestMenu( backgroundMenu, initData );
		}
	}
	
	public function OpenPopup(DataObject : W3PopupData) : void
	{
		theGame.RequestMenu('PopupMenu', DataObject);
	}

	public function SetUIVerticalFrameScale( value : float )
	{
		uiVerticalFrameScale = value;
	}

	public function GetUIVerticalFrameScale() : float
	{
		return uiVerticalFrameScale;
	}

	public function SetUIHorizontalFrameScale( value : float )
	{
		var horizontalPlusFrameScale : float;
		uiHorizontalFrameScale = value;
		horizontalPlusFrameScale = theGame.GetUIHorizontalPlusFrameScale();
		uiHorizontalFrameScale = uiHorizontalFrameScale * horizontalPlusFrameScale;
	}
	
	public function GetUIHorizontalFrameScale() : float
	{
		return uiHorizontalFrameScale;
	}
	
	public function SetUIScale( value : float )
	{
		uiScale = value;
	}

	public function GetUIScale() : float
	{
		return uiScale;
	}

	public function SetUIGamepadScaleGain( value : float )
	{
		uiGamepadScaleGain = value;
	}

	public function GetUIGamepadScaleGain() : float
	{
		return uiGamepadScaleGain;
	}

	public function SetDeathSaveLockId(i : int)
	{
		deathSaveLockId = i;
	}
	
	public function SetUIOpacity( value : float )
	{
		uiOpacity = value;
	}

	public function GetUIOpacity() : float
	{
		return uiOpacity;
	}
	
	public function setDialogDisplayDisabled( value : bool )
	{
		isDialogDisplayDisabled = value;
	}

	public function LoadHudSettings()
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		hudSettings = LoadCSV("gameplay\globals\hud_settings.csv"); //#B
			
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			
		isDialogDisplayDisabled = inGameConfigWrapper.GetVarValue('Localization', 'Subtitles') == "false";
			
		SetUIVerticalFrameScale( StringToFloat(inGameConfigWrapper.GetVarValue('Hidden', 'uiVerticalFrameScale')) );
		SetUIHorizontalFrameScale( StringToFloat(inGameConfigWrapper.GetVarValue('Hidden', 'uiHorizontalFrameScale')) );
			
		uiScale = StringToFloat(theGame.hudSettings.GetValueAt(1,theGame.hudSettings.GetRowIndexAt( 0, "uiScale" )));	
		uiOpacity = StringToFloat(theGame.hudSettings.GetValueAt(1,theGame.hudSettings.GetRowIndexAt( 0, "uiOpacity" )));	
	}
	
	event OnRefreshUIScaling()
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		SetUIVerticalFrameScale( StringToFloat(inGameConfigWrapper.GetVarValue('Hidden', 'uiVerticalFrameScale')) );
		SetUIHorizontalFrameScale( StringToFloat(inGameConfigWrapper.GetVarValue('Hidden', 'uiHorizontalFrameScale')) );
	}
	
	event OnSpawnPlayerHorse( )
	{
		var createEntityHelper				: CR4CreateEntityHelper;
		
		thePlayer.RaiseEvent('HorseSummon');
		
		if( !thePlayer.GetHorseWithInventory()
			||	!thePlayer.GetHorseWithInventory().IsAlive()
			|| 	( !thePlayer.WasVisibleInScaledFrame( thePlayer.GetHorseWithInventory(), 1.5f, 1.5f ) && VecDistanceSquared( thePlayer.GetWorldPosition(), thePlayer.GetHorseWithInventory().GetWorldPosition() ) > 900 )
			||  VecDistanceSquared( thePlayer.GetWorldPosition(), thePlayer.GetHorseWithInventory().GetWorldPosition() ) > 1600 )
		{
			createEntityHelper = new CR4CreateEntityHelper in this;
			createEntityHelper.SetPostAttachedCallback( this, 'OnPlayerHorseSummoned' );
			theGame.SummonPlayerHorse( true, createEntityHelper ); 
		}
		else
		{
			// Just come to me you koń ! 
			thePlayer.GetHorseWithInventory().SignalGameplayEventParamObject( 'HorseSummon', thePlayer );
		}
		
		thePlayer.OnSpawnHorse();
	}

	private function OnPlayerHorseSummoned( horseEntity : CEntity )
	{
		var saddle	 		: SItemUniqueId;
		var horseManager	: W3HorseManager;
		var horse			: CActor;

		//Demonic Saddle
		horseManager = GetWitcherPlayer().GetHorseManager();
		saddle = horseManager.GetItemInSlot(EES_HorseSaddle);
		if ( horseManager.GetInventoryComponent().GetItemName(saddle) == 'Devil Saddle' )
		{
			// proper appearance for 'Devil Saddle' is set inside ApplyHorseUpdateOnSpawn called below
			horse = (CActor)horseEntity;
			horse.AddEffectDefault(EET_WeakeningAura, horse, 'horse saddle', false);
		}
		
		thePlayer.GetHorseWithInventory().SignalGameplayEventParamObject( 'HorseSummon', thePlayer );
		
		GetWitcherPlayer().GetHorseManager().ApplyHorseUpdateOnSpawn();
	}
	
	//See EDialogActionIcon for flag values (EDialogActionIcon)
	event OnTutorialMessageForChoiceLines( flags : int )
	{
		//var dbg_icons : array<EDialogActionIcon>;
		
		//dbg_icons	 = GetDialogActionIcons(flags);
		GameplayFactsSet('dialog_choice_flags', flags);
		GameplayFactsAdd('dialog_choice_is_set', 1, 1);
	}
	
	event OnTutorialMessageForChoiceLineChosen( flags : int )
	{
		GameplayFactsSet('dialog_used_choice_flags', flags);
		GameplayFactsAdd('dialog_used_choice_is_set', 1, 1);
	}	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////   GAMEPLAY FACTS   //////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/*
		Duplicated facts db functionality. The reason is that if game is paused or if gametime is frozen to a fixed hour (e.g. constant 15:30)
		then facts CANNOT be removed from DB until game is unpaused / time is unfrozen. As a consequence this screws up all facts
		being added for some period of time. We're not going to get any fix on this.
	*/

	public function GameplayFactsAdd(factName : string, optional value : int, optional realtimeSecsValidFor : int)
	{
		var idx : int;
		var newFact : SGameplayFact;
		var newFactRemoval : SGameplayFactRemoval;
		
		if(value < 0)
			return;
		else if(value == 0)
			value = 1;
			
		idx = GetGameplayFactIndex(factName);
		if(idx >= 0)
		{
			gameplayFacts[idx].value += value;
		}
		else
		{
			newFact.factName = factName;
			newFact.value = value;
			gameplayFacts.PushBack(newFact);
		}
		
		if(realtimeSecsValidFor > 0)
		{
			newFactRemoval.factName = factName;
			newFactRemoval.value = value;
			newFactRemoval.timerID = thePlayer.AddTimer('GameplayFactRemove', realtimeSecsValidFor, , , , true, false);
			
			gameplayFactsForRemoval.PushBack(newFactRemoval);
		}
	}
	
	public function GameplayFactsSet(factName : string, value : int)
	{
		var idx : int;
		var newFact : SGameplayFact;
		
		idx = GetGameplayFactIndex(factName);
		if(idx >= 0)
		{
			gameplayFacts[idx].value = value;
		}
		else
		{
			newFact.factName = factName;
			newFact.value = value;
			gameplayFacts.PushBack(newFact);
		}
	}
	
	public function GameplayFactsRemove(factName : string)
	{
		var i : int;
		
		for(i=0; i<gameplayFacts.Size(); i+=1)
		{
			if(gameplayFacts[i].factName == factName)
			{
				gameplayFacts.EraseFast(i);
				return;
			}
		}
	}
	
	//Gameplay fact removed by finished timer of given timer ID
	public function GameplayFactRemoveFromTimer(timerID : int)
	{
		var idx, factIdx : int;
		
		idx = GetGameplayFactsForRemovalIndex(timerID);
		if(idx < 0)
		{
			LogAssert(false, "CR4Game.GameplayFactRemoveFromTimer: trying to process non-existant timer <<" + timerID + ">>");
			return;
		}
		
		factIdx = GetGameplayFactIndex(gameplayFactsForRemoval[idx].factName);
		if(factIdx < 0)					
			return;
		
		gameplayFacts[factIdx].value -= gameplayFactsForRemoval[idx].value;
		if(gameplayFacts[factIdx].value <= 0)
			gameplayFacts.EraseFast(factIdx);
			
		gameplayFactsForRemoval.EraseFast(idx);
	}

	public function GameplayFactsQuerySum(factName : string) : int
	{
		var idx : int;
		
		idx = GetGameplayFactIndex(factName);
		if(idx >= 0)		
			return gameplayFacts[idx].value;
			
		return 0;
	}
	
	private function GetGameplayFactIndex(factName : string) : int
	{
		var i : int;
		
		for(i=0; i<gameplayFacts.Size(); i+=1)
		{
			if(gameplayFacts[i].factName == factName)
				return i;			
		}
		
		return -1;
	}
	
	private function GetGameplayFactsForRemovalIndex(timerID : int) : int
	{
		var i : int;
		
		for(i=0; i<gameplayFactsForRemoval.Size(); i+=1)
		{
			if(gameplayFactsForRemoval[i].timerID == timerID)
				return i;			
		}
		
		return -1;
	}
	
	public function GetR4ReactionManager() : CR4ReactionManager
	{
		return ( CR4ReactionManager ) GetBehTreeReactionManager();
	}
		
	public function GetDifficultyMode() : EDifficultyMode
	{
		var diff : EDifficultyMode;
				
		diff = GetDifficultyLevel();
		
		//if diff not set, then use default
		if(diff == EDM_NotSet)
		{
			return EDM_Medium;
		}
		
		return diff;
	}
	
	event OnDifficultyChanged(newDifficulty : int)
	{
		var i : int;
		var lowestDiff : EDifficultyMode;
		
		//we need player to get entities around it to update their stats - if no player then postpone
		if(!thePlayer)
		{
			diffChangePostponed = newDifficulty;
			return false;
		}
		
		theTelemetry.SetCommonStatI32(CS_DIFFICULTY_LVL, newDifficulty);

		//update min used difficulty mode if current mode < previous min mode
		lowestDiff = GetLowestDifficultyUsed();		
		if(lowestDiff != newDifficulty && MinDiffMode(lowestDiff, newDifficulty) == newDifficulty)
			SetLowestDifficultyUsed(newDifficulty);
			
		UpdateStatsForDifficultyLevel( GetSpawnDifficultyMode() );
	}
	
	//called AFTER player entity has changed to a new actor
	public function OnPlayerChanged()
	{
		var i : int;
		var buffs : array<CBaseGameplayEffect>;
		var witcher : W3PlayerWitcher;
		
		//remove buffs added when we were previously playing with this character
		thePlayer.RemoveAllNonAutoBuffs();
		
		//force resume all autobuffs
		buffs = thePlayer.GetBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			buffs[i].ResumeForced();
		}
	
		//we have no destructors so we cannot remove fx when player character is destroyed - hence the hack
		GetGameCamera().StopEffect( 'frost' );
		DisableCatViewFx( 1.0f );
		thePlayer.StopEffect('critical_low_health');
		DisableDrunkFx();
		thePlayer.StopEffect('critical_toxicity');
		
		if(GetWitcherPlayer())
			GetWitcherPlayer().UpdateEncumbrance();
	
		// Update difficulty on all spawned gameplay entities, as
		// playing as Ciri we're limited to medium difficulty.	
		UpdateStatsForDifficultyLevel( GetSpawnDifficultyMode() );
		
		//reset timescale to 1.0f
		RemoveAllTimeScales();
	}
	
	// When the player is using Ciri monsters
	// should be limited to Medium difficulty.
	public function GetSpawnDifficultyMode() : EDifficultyMode
	{
		if( thePlayer && thePlayer.IsCiri() )
		{
			return MinDiffMode( GetDifficultyMode(), EDM_Medium );
		}
		return GetDifficultyMode();
	}
	
	public function UpdateStatsForDifficultyLevel( difficulty : EDifficultyMode )
	{
		var i : int;
		var actor : CActor;
		var npcs : array< CNewNPC >;
		GetAllNPCs( npcs );
		for( i=0; i < npcs.Size(); i+=1 )
		{
			actor = (CActor)npcs[i];
			if( actor )
			{
				actor.UpdateStatsForDifficultyLevel( difficulty );
			}
		}
	}

	public function CanTrackQuest( questEntry : CJournalQuest ) : bool
	{
		var questName : string;
		var baseName : string;
		var i : int;
		var questCount : int;
		var playerLevel : int;
		var questLevel : int;
		var questLevels : C2dArray;
		var questLevelsCount : int;
		var iterQuestLevels : int;
		
		baseName = questEntry.baseName;
		playerLevel = thePlayer.GetLevel();

		if ( questEntry.GetType() == MonsterHunt )
		{
			questLevelsCount = theGame.questLevelsContainer.Size();
			for( iterQuestLevels = 0; iterQuestLevels < questLevelsCount; iterQuestLevels += 1 )
			{
				questLevels = theGame.questLevelsContainer[iterQuestLevels];
			// these questLevels should be in journal
				questCount = questLevels.GetNumRows();
				for( i = 0; i < questCount; i += 1 )
				{
						questName  = questLevels.GetValueAtAsName( 0, i );
					if ( questName == baseName )
					{
							questLevel  = NameToInt( questLevels.GetValueAtAsName( 1, i ) );
						return playerLevel >= questLevel - 5;
					}
				}
			}
		}
		return true;
	}
	
	import final function GetGwintManager() : CR4GwintManager;
	
	public function IsBlackscreenOrFading() : bool
	{
		return IsBlackscreen() || IsFading();
	}
		
	////////////////////////////////////////////////////////////
	// "postponed" CPreAttackEvevets - called in "Main" tick
	////////////////////////////////////////////////////////////

	var postponedPreAttackEvents : array< SPostponedPreAttackEvent >;
	
	event OnPreAttackEvent( entity : CGameplayEntity, animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
		var postponedPreAttackEvent : SPostponedPreAttackEvent;
		
		postponedPreAttackEvent.entity		= entity;
		postponedPreAttackEvent.eventName 	= animEventName;
		postponedPreAttackEvent.eventType 	= animEventType;
		postponedPreAttackEvent.data 		= data;
		postponedPreAttackEvent.animInfo	= animInfo;
		
		postponedPreAttackEvents.PushBack( postponedPreAttackEvent );
	}

	function FirePostponedPreAttackEvents()
	{
		var i, size : int;
		var entity : CGameplayEntity;
		
		size = postponedPreAttackEvents.Size();
		for ( i = 0; i < size; i+=1 )
		{
			entity = postponedPreAttackEvents[i].entity;
			if ( entity )
			{
				entity.OnPreAttackEvent( postponedPreAttackEvents[i].eventName,
										 postponedPreAttackEvents[i].eventType,
										 postponedPreAttackEvents[i].data,
										 postponedPreAttackEvents[i].animInfo );
			}
		}
		postponedPreAttackEvents.Clear();
	}
	
	public final function AddDynamicallySpawnedBoatHandle(handle : EntityHandle)
	{
		var i : int;
		
		if(EntityHandleGet(handle))
		{			
			dynamicallySpawnedBoats.PushBack(handle);
			
			if(dynamicallySpawnedBoats.Size() >= theGame.params.MAX_DYNAMICALLY_SPAWNED_BOATS)
			{
				//check for nulls in array - failsafe (if sth else would destroy boat)
				for(i=dynamicallySpawnedBoatsToDestroy.Size()-1; i>=0; i-=1)
				{
					if(!EntityHandleGet(dynamicallySpawnedBoats[i]))
						dynamicallySpawnedBoats.EraseFast(i);
				}
			
				if(dynamicallySpawnedBoats.Size() >= theGame.params.MAX_DYNAMICALLY_SPAWNED_BOATS)
				{
					dynamicallySpawnedBoatsToDestroy.PushBack( dynamicallySpawnedBoats[0] );
					dynamicallySpawnedBoats.Erase(0);
				}
			}
		}
	}
	
	public final function IsBoatMarkedForDestroy(boat : W3Boat) : bool
	{
		var handle : EntityHandle;
		var i : int;
		
		EntityHandleSet(handle, boat);
		for(i=0; i<dynamicallySpawnedBoatsToDestroy.Size(); i+=1)
		{
			if(handle == dynamicallySpawnedBoatsToDestroy[i])
			{
				dynamicallySpawnedBoatsToDestroy.EraseFast(i);
				return true;
			}
		}
		
		return false;
	}

	public final function VibrateControllerVeryLight(optional duration : float)
	{
		if ( !theInput.LastUsedGamepad() )
			return;
			
		if(duration == 0)
			duration = 0.15f;
			
		if(IsSpecificRumbleActive(0.2, 0))
		{
			OverrideRumbleDuration(0.2, 0, duration);
		}
		else
		{
			VibrateController(0.2, 0, duration);
		}
	}
	
	public final function VibrateControllerLight(optional duration : float)
	{
		if ( !theInput.LastUsedGamepad() )
			return;
			
		if(duration == 0)
			duration = 0.2f;
			
		if(IsSpecificRumbleActive(0.5, 0))
		{
			OverrideRumbleDuration(0.5, 0, duration);
		}
		else
		{
			VibrateController(0.5, 0, duration);
		}
	}
	
	public final function VibrateControllerHard(optional duration : float)
	{
		if ( !theInput.LastUsedGamepad() )
			return;
			
		if(duration == 0)
			duration = 0.2f;
		
		if(IsSpecificRumbleActive(0.75, 0.75))
		{
			OverrideRumbleDuration(0.75, 0.75, duration);
		}
		else
		{
			VibrateController(0.75, 0.75, duration);
		}
	}
	
	public final function VibrateControllerVeryHard(optional duration : float)
	{
		if ( !theInput.LastUsedGamepad() )
			return;
			
		if(duration == 0)
			duration = 0.5f;
		
		if(IsSpecificRumbleActive(1, 1))
		{
			OverrideRumbleDuration(1, 1, duration);
		}
		else
		{
			VibrateController(1, 1, duration);
		}
	}
	import public final function GetWorldDLCExtender() : CR4WorldDLCExtender;
	
	public function GetMiniMapSize( areaType : int ) : float
	{
		var mapSize  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 1, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			mapSize = StringToFloat( valueAsString );
		}
		else
		{
			mapSize = GetWorldDLCExtender().GetMiniMapSize( areaType );
		}
		return mapSize;
	}
	
	public function GetMiniMapTileCount( areaType : int ) : int
	{
		var tileCount  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 2, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			tileCount = StringToInt( valueAsString );
		}
		else
		{
			tileCount = GetWorldDLCExtender().GetMiniMapTileCount( areaType );
		}
		return tileCount;
	}
	
	public function GetMiniMapExteriorTextureSize( areaType : int ) : int
	{
		var exteriorTextureSize  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 3, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			exteriorTextureSize = StringToInt( valueAsString );
		}
		else
		{
			exteriorTextureSize = GetWorldDLCExtender().GetMiniMapExteriorTextureSize( areaType );
		}
		return exteriorTextureSize;
	}
	
		
	public function GetMiniMapInteriorTextureSize( areaType : int ) : int
	{
		var interiorTextureSize  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 4, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			interiorTextureSize = StringToInt( valueAsString );
		}
		else
		{
			interiorTextureSize = GetWorldDLCExtender().GetMiniMapInteriorTextureSize( areaType );
		}
		return interiorTextureSize;
	}
	
	public function GetMiniMapTextureSize( areaType : int ) : int
	{
		var textureSize  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 5, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			textureSize = StringToInt( valueAsString );
		}
		else
		{
			textureSize = GetWorldDLCExtender().GetMiniMapTextureSize( areaType );
		}
		return textureSize;
	}
	
	public function GetMiniMapMinLod( areaType : int ) : int
	{
		var minLod  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 6, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			minLod = StringToInt( valueAsString );
		}
		else
		{
			minLod = GetWorldDLCExtender().GetMiniMapMinLod( areaType );
		}
		return minLod;
	}
	
	public function GetMiniMapMaxLod( areaType : int ) : int
	{
		var maxLod  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 7, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			maxLod = StringToInt( valueAsString );
		}
		else
		{
			maxLod = GetWorldDLCExtender().GetMiniMapMaxLod( areaType );
		}
		return maxLod;
	}

	
	public function GetMiniMapExteriorTextureExtension( areaType : int ) : string
	{
		var exteriorTextureExtension  : string;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 8, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			exteriorTextureExtension = ExtractStringFromCSV( valueAsString );
		}
		else
		{
			exteriorTextureExtension = GetWorldDLCExtender().GetMiniMapExteriorTextureExtension( areaType );
		}
		return exteriorTextureExtension;
	}
	
	public function GetMiniMapInteriorTextureExtension( areaType : int ) : string
	{
		var interiorTextureExtension  : string;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 9, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			interiorTextureExtension = ExtractStringFromCSV( valueAsString );
		}
		else
		{
			interiorTextureExtension = GetWorldDLCExtender().GetMiniMapInteriorTextureExtension( areaType );
		}
		return interiorTextureExtension;
	}
	
	public function GetMiniMapVminX( areaType : int ) : int
	{
		var vminX  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 11, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			vminX = StringToInt( valueAsString );
		}
		else
		{
			vminX = GetWorldDLCExtender().GetMiniMapVminX( areaType );
		}
		return vminX;
	}
	
	public function GetMiniMapVmaxX( areaType : int ) : int
	{
		var vmaxX  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 12, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			vmaxX = StringToInt( valueAsString );
		}
		else
		{
			vmaxX = GetWorldDLCExtender().GetMiniMapVmaxX( areaType );
		}
		return vmaxX;
	}
	
	public function GetMiniMapVminY( areaType : int ) : int
	{
		var vminY  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 13, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			vminY = StringToInt( valueAsString );
		}
		else
		{
			vminY = GetWorldDLCExtender().GetMiniMapVminY( areaType );
		}
		return vminY;
	}
	
	public function GetMiniMapVmaxY( areaType : int ) : int
	{
		var vmaxY  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 14, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			vmaxY = StringToInt( valueAsString );
		}
		else
		{
			vmaxY = GetWorldDLCExtender().GetMiniMapVmaxY( areaType );
		}
		return vmaxY;
	}
	
	public function GetMiniMapSminX( areaType : int ) : int
	{
		var sminX  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 15, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			sminX = StringToInt( valueAsString );
		}
		else
		{
			sminX = GetWorldDLCExtender().GetMiniMapSminX( areaType );
		}
		return sminX;
	}
	
	public function GetMiniMapSmaxX( areaType : int ) : int
	{
		var smaxX  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 16, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			smaxX = StringToInt( valueAsString );
		}
		else
		{
			smaxX = GetWorldDLCExtender().GetMiniMapSmaxX( areaType );
		}
		return smaxX;
	}
	
	public function GetMiniMapSminY( areaType : int ) : int
	{
		var sminY  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 17, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			sminY = StringToInt( valueAsString );
		}
		else
		{
			sminY = GetWorldDLCExtender().GetMiniMapSminY( areaType );
		}
		return sminY;
	}
	
	public function GetMiniMapSmaxY( areaType : int ) : int
	{
		var smaxY  : int;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 18, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			smaxY = StringToInt( valueAsString );
		}
		else
		{
			smaxY = GetWorldDLCExtender().GetMiniMapSmaxY( areaType );
		}
		return smaxY;
	}
	
	public function GetMiniMapMinZoom( areaType : int ) : float
	{
		var minZoom  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 19, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			minZoom = StringToFloat( valueAsString );
		}
		else
		{
			minZoom = GetWorldDLCExtender().GetMiniMapMinZoom( areaType );
		}
		return minZoom;
	}
	
	public function GetMiniMapMaxZoom( areaType : int ) : float
	{
		var maxZoom  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 20, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			maxZoom = StringToFloat( valueAsString );
		}
		else
		{
			maxZoom = GetWorldDLCExtender().GetMiniMapMaxZoom( areaType );
		}
		return maxZoom;
	}
	
	public function GetMiniMapZoom12( areaType : int ) : float
	{
		var zoom12  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 21, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			zoom12 = StringToFloat( valueAsString );
		}
		else
		{
			zoom12 = GetWorldDLCExtender().GetMiniMapZoom12( areaType );
		}
		return zoom12;
	}
	
	public function GetMiniMapZoom23( areaType : int ) : float
	{
		var zoom23  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 22, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			zoom23 = StringToFloat( valueAsString );
		}
		else
		{
			zoom23 = GetWorldDLCExtender().GetMiniMapZoom23( areaType );
		}
		return zoom23;
	}
	
	public function GetMiniMapZoom34( areaType : int ) : float
	{
		var zoom34  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 23, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			zoom34 = StringToFloat( valueAsString );
		}
		else
		{
			zoom34 = GetWorldDLCExtender().GetMiniMapZoom34( areaType );
		}
		return zoom34;
	}
	
	public function GetGradientScale( areaType : int ) : float
	{
		var scale  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 24, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			scale = StringToFloat( valueAsString );
		}
		else
		{
			scale = GetWorldDLCExtender().GetGradientScale( areaType );
		}
		return scale;
	}
	
	public function GetPreviewHeight( areaType : int ) : float
	{
		var height  : float;
		var valueAsString : string;
		
		valueAsString = minimapSettings.GetValueAt( 25, areaType );
		
		if( StrLen( valueAsString ) != 0 )
		{
			height = StringToFloat( valueAsString );
		}
		else
		{
			height = GetWorldDLCExtender().GetPreviewHeight( areaType );
		}
		return height;
	}

	private function UnlockMissedAchievements()
	{
		var manager : CCommonMapManager = theGame.GetCommonMapManager();	
		if ( manager )
		{
			manager.CheckExplorerAchievement();
		}

		GetWitcherPlayer().CheckForFullyArmedAchievement();
		GetGamerProfile().CheckProgressOfAllStats();
		if (FactsDoesExist("witcher3_game_finished"))
		{
			Achievement_FinishedGame();
		}
	}
	
	public final function MutationHUDFeedback( type : EMutationFeedbackType )
	{
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		

		hud = (CR4ScriptedHud)GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.DisplayMutationFeedback( type );
			}
		}
	}
}

function hasSaveDataToLoad():bool
{
	var currentSave	: SSavegameInfo;
	var saveGames	: array< SSavegameInfo >;
	
	theGame.ListSavedGames( saveGames );
	if ( saveGames.Size() > 0 )
	{
		return true;
	}
	
	return false;
}

exec function EnableLog( enable : bool )
{
	theGame.EnableLog( enable );
}
