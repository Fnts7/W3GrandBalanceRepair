import class CCommonGame extends CGame
{
	import final function EnableSubtitles( enable : bool );
	import final function AreSubtitlesEnabled() : bool;

	// Fetch the community system
	import final function GetCommunitySystem() : CCommunitySystem;
	
	// CAIAttackRange interface
	import final function GetAttackRangeForEntity( sourceEntity : CEntity, optional attackName : name ) : CAIAttackRange;
	
	// Get Reactions Manager
	import final function GetReactionsMgr() : CReactionsManager;
	
	import final function GetBehTreeReactionManager() : CBehTreeReactionManager;
	
	// Get GetIngredientCathegoryElements
	import final function GetIngredientCategoryElements(catName : name , out names : array<name>, out priorities : array<int>);
	
	// Is Ingredient Category Specified
	import final function IsIngredientCategorySpecified(catName : name):bool;
	
	// Get All Ingredients Categories
	import final function GetIngredientCathegories() : array<name>;

	// Get a list of item names belonging to this set
	import final function GetSetItems( setName : name) : array<name>;
	
	// Get a list of ability names for the item set
	import final function GetItemSetAbilities( itemName : name) : array<name>;
	
	// Get Definition Manager
	import final function GetDefinitionsManager() : CDefinitionsManagerAccessor;
	
	import final function QueryExplorationSync( entity : CEntity, optional queryContext : SExplorationQueryContext ) : SExplorationQueryToken;
	import final function QueryExplorationFromObjectSync( entity : CEntity, object : CEntity, optional queryContext : SExplorationQueryContext ) : SExplorationQueryToken;
	//import final function SetDynamicExplorationAndGetToken( entity : CEntity, explorer : CEntity, position : Vector, direction : Vector, optional queryContext : SExplorationQueryContext ) : SExplorationQueryToken;

	// Get global attitude
	import final function GetGlobalAttitude( srcGroup : name, dstGroup : name ) : EAIAttitude;

	// Set global attitude
	import final function SetGlobalAttitude( srcGroup : name, dstGroup : name, attitude : EAIAttitude ) : bool;
		
	// Get reward by name
	import final function GetReward( rewardName : name, out rewrd : SReward ) : bool;
	
	// Give reward to entity
	import final function GiveReward( rewardName : name, targetEntity : CEntity );
	
	// Adds the actor to the stray actor list if he is not there already
	// If the actor is part of an encounter it will be detached from it
	// If the actor implement a guard area behaviour it will be removed
	import final function ConvertToStrayActor( actor : CActor ) : bool;
	
	// CreateEntityASync. There are a few persistance options one might use:
	// PM_DontPersist 	- 	creates an entity that will not be taken into consideration
	//						when the game state is saved
	// PM_SaveStateOnly - 	state of the entity will be saved when the entity gets streamed out,
	//						however when a game save is made and then loaded, the entity will not be
	//						automatically created - one has to recreate it manually!
	// PM_Persist		-	entity will be automatically recreated when a saved game is restored,
	//						and its state will be saved as well when the entity gets streamed out
	import final function CreateEntityAsync( createEntityHelper : CCreateEntityHelper, entityTemplate : CEntityTemplate, pos : Vector, optional rot : EulerAngles,
										optional useAppearancesFromIncludes : bool /* = true */, optional forceBehaviorPose : bool /* = false */, 
										optional doNotAdjustPlacement : bool /* = false */, optional persistanceMode : EPersistanceMode /* = PM_DontPersist */, optional tagList : array< name > ) : int;
	
	
	// important! loading game is partially an async operation now (on consoles)
	// to make this possible i had to split easy-to-use LoadGame() function into 3 steps. 
	// so now, basic procedure is:
	// 1) call InitLoadLastGame() or InitLoadGame()
	// 2) wait for OnGameLoadInitFinished() event
	// 3) call GetLoadGameProgress() to get the result	
	import final function LoadLastGameInit( optional suppressVideo : bool /*=false*/ );
	import final function LoadGameInit( info : SSavegameInfo );

	import final function CanStartStandaloneDLC( dlc : name ) : bool;
	import final function InitStandaloneDLCLoading( dlc : name, difficulty : int ) : ELoadGameResult;
	
	// value returned:
	// LOAD_NotInitialized,		// returned when no loading operation was initialized
	// LOAD_Initializing,		// returned when initializing, until everything gets initialized (mounted on orbis/synced on durango/etc...)
	// LOAD_ReadyToLoad,		// returned when you can actually create loader and start reading save data
	// LOAD_Loading,			// returned when the game is actually being loaded (loader was created, but not finalized)
	// LOAD_Error,				// returned when initialization failed for some reason
	// LOAD_MissingContent		// returned when initialization succeeded, but content requirements are not met
	import final function GetLoadGameProgress() : ELoadGameResult;

	import final function ListSavedGames( out fileNames : array< SSavegameInfo > ) : bool; 
	
	import final function GetDisplayNameForSavedGame( savegame : SSavegameInfo ) : string;
	
	// Saves the game
	// SGT_None
	// SGT_AutoSave,
	// SGT_QuickSave,
	// SGT_Manual,
	// SGT_ForcedCheckPoint, 
	// SGT_CheckPoint,
	// "slot" is the slot number <0-numSlots>, use GetNumSaveSlots() to get numSlots, or use -1 to auto-assign
	import final function SaveGame( type : ESaveGameType, slot : int );
	
	// Gets the number of save slots of each type for current platform, returns -1 if number of slots is not limited
	import final function GetNumSaveSlots( type : ESaveGameType ) : int;
	
	import final function DeleteSavedGame( savegame : SSavegameInfo ) : void;
	
	import final function GetContentRequiredByLastSave( out content : array< name > ) : void;
	
	// Gets the savegame info structure of a savegame in given slot.
	// Works only for platforms that support save slots. Use GetNumSaveSlots() to find out.
	// returns true if slot is occupied, false if slot is free.
	// Also returns false if slot index is out of range or the platform doesn't support slots.
	import final function GetSaveInSlot( type : ESaveGameType, slot : int, out info : SSavegameInfo ) : bool;
	
	import final function ShouldShowSaveCompatibilityWarning() : bool;
	
	import final function RequestNewGame( gameResourceFilename : string ) : bool;
	import final function RequestEndGame();
	import final function RequestExit();
	import final function GetGameResourceList() : array< string >;
	
	import final function GetGameRelease() : string;
	
	// Gets current language in two letters format (e.g. "EN")
	import final function GetCurrentLocale() : string;
	
	// Get all known NPCs
	import final function GetAllNPCs( out npcs : array<CNewNPC> );
	
	// Get Action Point Manager
	import final function GetAPManager() : CActionPointManager;

	// Get Story Scene System
	import final function GetStorySceneSystem() : CStorySceneSystem;
	
	// Get node by tag
	import final function GetActorByTag( tag : name ) : CActor;
	import final function GetNPCByTag( tag : name ) : CNewNPC;
	
	// Get nodes by tag
	import final function GetActorsByTag( tag : name, out actors : array<CActor> );
	import final function GetNPCsByTag( tag : name, out npcs : array<CNewNPC> );
	
	// Gets game languages in form of string database language ids
	import final function GetGameLanguageId( out audioLang : int, out subtitleLang : int );
	
	// Gets game languages in form of language names
	import final function GetGameLanguageName( out audioLang : string, out subtitleLang : string );
	
	// Gets game languages in form of indices on available languages list
	import final function GetGameLanguageIndex( out audioLang : int, out subtitleLang : int );
	
	// Gets a list of languages available for user
	import final function GetAllAvailableLanguages( out textLanguages : array< string >, out speechLanguages : array< string > );
	
	// Sets game languages using indices from available languages lists
	import final function SwitchGameLanguageByIndex( audioLang : int, subtitleLang : int );
	
	import final function ReloadLanguage();
	
	// Checks if game time manager is paused
	import final function IsGameTimePaused() : bool;
	
	//////////////////////
	// Entity state modifiers
	import final function AddStateChangeRequest( entityTag : name, modifier : IEntityStateChangeRequest );
	
	//////////////////////
	// Save locks
	// Creates a new save lock
	// default value for allowCheckpoints parameter is true
	import final function CreateNoSaveLock( reason : string, out lock : int, optional unique : bool, optional allowCheckpoints : bool );
	
	// Releases an existing save lock
	import final function ReleaseNoSaveLock( lock : int );
	
	// Releases an existing save lock. Only works on "unique" locks. You have to explicitly say your lock is "unique" to be able to remove it 
	//regardless of the lock count. This is for safety reasons.
	import final function ReleaseNoSaveLockByName( lockName : string );
	
	// Checks if saves are locked
	import final function AreSavesLocked() : bool;
	
	// Checks if this is a fresh game (started by "new game" option)
	// returns false after a world change or "load game"
	// returns true for freshly started "standalone DLC" mode
	import final function IsNewGame() : bool;
	
	// Checks if this is a fresh game in standalone DLC mode (started by "new game / only EP1 / EP2" option)
	// returns true only in this scenario
	import final function IsNewGameInStandaloneDLCMode() : bool;
	
	// returns true is user have unlocked "new game plus" functionality by completing the game and fulfilling other conditions
	import final function IsNewGamePlusEnabled() : bool;
	
	// Saves changes that user made to the config
	import final function ConfigSave();
	
	// Checks whether saves info is already collected
	import final function AreSavesInitialized() : bool;
	
	// Camera invert handling	
	import final function IsInvertCameraX() : bool;
	import final function IsInvertCameraY() : bool;
	import final function SetInvertCameraX( invert : bool );
	import final function SetInvertCameraY( invert : bool );
	import final function SetInvertCameraXOnMouse( invert : bool );
	import final function SetInvertCameraYOnMouse( invert : bool );
	
	import final function IsCameraAutoRotX() : bool;
	import final function IsCameraAutoRotY() : bool;
	import final function SetCameraAutoRotX( flag : bool );
	import final function SetCameraAutoRotY( flag : bool );
	
	import final function ChangePlayer( playerTemplate : String, optional appearance : name );
	
	import final function ScheduleWorldChangeToMapPin( worldPath : string, mapPinName : name );
	import final function ScheduleWorldChangeToPosition( worldPath : string, position : Vector, rotation : EulerAngles );
	
	import final function ForceUIAnalog( value : bool );
	import final function RequestMenu( menuName: name, optional initData : IScriptable );
	import final function CloseMenu( menuName: name );
	import final function RequestPopup( popupName: name, optional initData : IScriptable );
	import final function ClosePopup( popupName: name );
	import final function GetHud() : CHud;
	import final function GetInGameConfigWrapper() : CInGameConfigWrapper;
	
	// import facts from Witcher 2 saved game file
	import final function ImportSave( savegameInfo : SSavegameInfo ) : bool;
	
	// list all available Witcher2 saved game files
	import final function ListW2SavedGames( out savedGames : array< SSavegameInfo > ) : bool;
	
	// Test if given location is NOT occupied by any creature
	import final function TestNoCreaturesOnLocation( pos : Vector, radius : float, optional ignoreActor : CActor ) : bool;
	
	// Test if given line is NOT occupied by any creature
	import final function TestNoCreaturesOnLine( pos0 : Vector, pos1 : Vector, lineWidth : float, optional ignoreActor0 : CActor /* NULL */, optional ignoreActor1 : CActor /* NULL */, optional ignoreGhostCharacters : bool /* false */ ) : bool;
	
	// "reason" is just a debug string here
	// "force" is to avoid cancelling the request by some other logic
	import final function RequestAutoSave( reason : string, force : bool );
	
	import final function CalculateTimePlayed() : GameTime;
	
	// use this to request async reading of a screenshot for the savedata specified
	import final function RequestScreenshotData( save : SSavegameInfo );

	// use this to wait until the screenshot data is ready. Once this thing returns true, you can use the screenshot with scaleform (the regular way).
	// In case if an error, this will also return true, but the image will be the default "wolf" icon.
	import final function IsScreenshotDataReady() : bool;

	// use this to either cancel the async reading process, or just to free the image... just use it once you're done with the screenshot and don't want the data anymore
	import final function FreeScreenshotData();
	
	// use this to center the mouse in flash
	import final function CenterMouse();
	
	// use this to set a custom position for the mouse cursor
	import final function MoveMouseTo(xpos : float, ypos : float);

	event OnBeforeWorldChange( worldName : string );

	//for displaying item tooltips
	public var tooltipSettings : C2dArray;
	
	import final function GetUIHorizontalPlusFrameScale() : float;
	
	import final function GetDLCManager() : CDLCManager;
	
	import final function AreConfigResetInThisSession() : bool;
	
	import final function HasShownConfigChangedMessage() : bool;
	
	import final function SetHasShownConfigChangedMessage( value : bool ) : void;

	import final function GetApplicationVersion() : string;
	
	import final function IsSoftwareCursor() : bool;
	
	import final function ShowHardwareCursor() : void;
	
	import final function HideHardwareCursor() : void;
	
	import final function GetAchievementsDisabled() : bool;
}
