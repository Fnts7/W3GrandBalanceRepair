/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CGame
/** Copyright © 2009
/***********************************************************************/

exec function acticon( contentToActivate : name )
{
	theGame.DebugActivateContent( contentToActivate );
}

import class CGame extends CObject
{
	import final function DebugActivateContent( contentToActivate : name );

	// Returns if build is final (no debug stuff present)
	import final function IsFinalBuild() : bool;
	
	// Are we in game ?
	import final function IsActive() : bool;	

	// Is game paused
	import final function IsPaused() : bool;
	
	// Is game paused for a reason
	import final function IsPausedForReason( reason : string ) : bool;

	// Are we in game ?
	import final function IsStopped() : bool;	
	
	// Are we loading game with video playing ?
	import final function IsLoadingScreenVideoPlaying() : bool;	
	
	// Pause game
	import final function Pause( reason : string );

	// Unpause game
	import final function Unpause( reason : string );
	
	// Pause active cutscenes
	import final function PauseCutscenes();
	
	// Unpause active cutscenes
	import final function UnpauseCutscenes();
	
	// Exit game
	import final function ExitGame();
	
	// Is game actively paused
	import final function IsActivelyPaused() : bool;
	
	// Set active pause
	import final function SetActivePause( flag : bool );

	// Get engine time (real time counted when game is not paused); NOTE: Don't store it under saved vars unless converted to Float !!!
	import final function GetEngineTime() : EngineTime;
	// Get engine time in seconds (real time counted when game is not paused)
	import final function GetEngineTimeAsSeconds() : Float;
	
	// Get engine time scale
	import final function GetTimeScale( optional forCamera : Bool ) : float;
	
	// Set engine time scale, higher priority value is more important
	import final function SetTimeScale( timeScale : float, sourceName : name, priority : Int32, optional affectCamera : Bool, optional dontSave : Bool );
	
	// Remove engine time scale
	import final function RemoveTimeScale( sourceName : name );

	// Remove all engine time scales
	import final function RemoveAllTimeScales();

	// Set or remove engine time scale depending on argument
	import final function SetOrRemoveTimeScale( timeScale : float, sourceName : name, priority : Int32, optional affectCamera : Bool );

	// Print current time scales
    import final function LogTimeScales();

	// Get game time (not counted when game paused, used for the gameplay not for micro timing)
	import final function GetGameTime() : GameTime;
	
	// Sets new game time
	import final function SetGameTime( time : GameTime, callEvents : bool );

	// Sets world time speed
	import final function SetHoursPerMinute( f : float );
	
	// Gets world time speed
	import final function GetHoursPerMinute() : float;
	
	//get difficulty level from savefile / options
	import final function GetDifficultyLevel() : int;	
	
	//set difficulty level visible in options menu
	import final function SetDifficultyLevel( amount : int );
	
	//called when difficulty is changed in options menu
	event OnDifficultyChanged(newDifficulty : int);
	
	///////////////////////////////////////
	
	// Check if the vibration option is set in the game menu
	import final function IsVibrationEnabled() : bool;
	// Enable/disable vibrations
	import final function SetVibrationEnabled( enabled : bool );
	// Set low frequency and high frequency motors speed [0,1]
	import final function VibrateController( lowFreq, highFreq, duration : float );
	import final function StopVibrateController();
	import final function GetCurrentVibrationFreq( out lowFreq : float, out highFreq : float );
	import final function RemoveSpecificRumble( lowFreq : float, highFreq : float );
	import final function IsSpecificRumbleActive( lowFreq : float, highFreq : float ) : bool;
	
	import final function OverrideRumbleDuration( lowFreq : float, highFreq : float, newDuration : float );
	
	// Is pad connected
	import final function IsPadConnected() : bool;

	// Create entity. There are a few persistance options one might use:
	// PM_DontPersist 	- 	creates an entity that will not be taken into consideration
	//						when the game state is saved
	// PM_SaveStateOnly - 	state of the entity will be saved when the entity gets streamed out,
	//						however when a game save is made and then loaded, the entity will not be
	//						automatically created - one has to recreate it manually!
	// PM_Persist		-	entity will be automatically recreated when a saved game is restored,
	//						and its state will be saved as well when the entity gets streamed out
	import final function CreateEntity( entityTemplate : CEntityTemplate, pos : Vector, optional rot : EulerAngles,
										optional useAppearancesFromIncludes : bool /* = true */, optional forceBehaviorPose : bool /* = false */, 
										optional doNotAdjustPlacement : bool /* = false */, optional persistanceMode : EPersistanceMode /* = PM_DontPersist */, optional tagList : array< name > ) : CEntity;
	
	// Get node by tag
	import final function GetNodeByTag( tag : name ) : CNode;
	
	// Get entity by tag
	import final function GetEntityByTag( tag : name ) : CEntity;
	
	// Get entities by tag
	import final function GetEntitiesByTag( tag : name, out entities : array<CEntity> );
	
	// Get nodes by tag
	import final function GetNodesByTag( tag : name, out nodes : array<CNode> );

	// Get nodes by tag
	import final function GetNodesByTags( tagsList : array<name>, out nodes : array<CNode>, optional matchAll : bool );

	// Get default animation time multiplier used by animated components
	//import final function GetDefaultAnimationTimeMultiplier() : float;
	
	// Set animation time multiplier for all animated components (also newly created)
	//import final function SetDefaultAnimationTimeMultiplier( mult : float );
	
	// Returns the active world
	import final function GetWorld() : CWorld;
	
	// Is debug free enabled
	import final function IsFreeCameraEnabled() : bool;
	
	// Enable debug free camera
	import final function EnableFreeCamera( flag : bool );
	
	// Get free camera position
	import final function GetFreeCameraPosition() : Vector;
	
	// Is given showFlag enabled
	import final function IsShowFlagEnabled( showFlag : EShowFlags ) : bool;
	
	// Set or clear given showFlag
	import final function SetShowFlag( showFlag : EShowFlags, enabled : bool );
	
	// Play cutscene. If return false see log for warnings.
	import final function PlayCutsceneAsync( csName : string, actorNames : array<string>, actorEntities : array<CEntity>, csPos : Vector, csRot : EulerAngles, optional cameraNum : int ) : bool;

	// Is currently playing a non-gameplay scene
	import final function IsCurrentlyPlayingNonGameplayScene() : bool;
		
	// Are we during streaming
	import final function IsStreaming() : bool;
	
	// Latent functions
	
	// Play cutscene. If return false see log for warnings.
	import final latent function PlayCutscene( csName : string, actorNames : array<string>, actorEntities : array<CEntity>, csPos : Vector, csRot : EulerAngles, optional cameraNum : int ) : bool;
		
	// Fade out screen to given color
	import final latent function FadeOut( optional fadeTime : float /*=1.0*/, optional fadeColor : Color /*=Color::BLACK*/ );
	
	// Fade in screen
	import final latent function FadeIn( optional fadeTime : float /*=1.0*/ );
	
	// Fade out screen to given color
	import final function FadeOutAsync( optional fadeTime : float /*=1.0*/, optional fadeColor : Color /*=Color::BLACK*/ );
	
	// Fade in screen
	import final function FadeInAsync( optional fadeTime : float /*=1.0*/ );
	
	// Is screen fade in progress? (fade out or fade in)
	import final function IsFading() : bool;
	
	// Is blackscreen set?
	import final function IsBlackscreen() : bool;
	
	// Is blackscreen or fading out
	import final function HasBlackscreenRequested() : bool;
	
	import final function SetFadeLock( lockName : string );
	import final function ResetFadeLock( lockName : string );
	
	///////////////////////////////////////////////////////////////////
	// Achievement system
	import final function UnlockAchievement( achName : name ) : bool;
	
	import final function LockAchievement( achName : name ) : bool;
	
	import final function GetUnlockedAchievements( out unlockedAchievments : array< name > );
	
	import final function GetAllAchievements( out unlockedAchievments : array< name > );
	
	import final function IsAchievementUnlocked( achievement : name ) : bool;
	
	///////////////////////////////////////////////////////////////////
	// User Profile
	import final function ToggleUserProfileManagerInputProcessing( enabled : bool );
	
	///////////////////////////////////////////////////////////////////
	// Difficulty level 
	
	import final function IsCheatEnabled( cheatFeature : ECheats ) : bool;
	
	import final function ReloadGameplayConfig();
	
	import final function GetGameplayChoice() : bool;
	
	import final function GetGameplayConfigFloatValue( propName : name ) : float;
	
	import final function GetGameplayConfigBoolValue( propName : name ) : bool;
	
	import final function GetGameplayConfigIntValue( propName : name ) : int;
	
	import final function GetGameplayConfigEnumValue( propName : name ) : int;
	
	// Set AI objects loose time (time after which NPCs "forget" their targets)
	import final function SetAIObjectsLooseTime( time : float );
	
	import final function AddInitialFact( factName : string );
	
	import final function RemoveInitialFact( faceName : string );
	
	import final function ClearInitialFacts();
	
	// Current viewport resolution
	import final function GetCurrentViewportResolution( out width : int, out height : int ) : void;

	///////////////////////////////////////////////////////////////////
	// Loading screen. Use with care!
	import final function SetSingleShotLoadingScreen( contextName : name, optional initString : string, optional videoToPlay : string );
};

// Setup radial blur
import function RadialBlurSetup( blurSourcePos : Vector, blurAmount, sineWaveAmount, sineWaveSpeed, sineWaveFreq : float );

// Disable radius blur
import function RadialBlurDisable();

// Setup fullscreen blur
import function FullscreenBlurSetup( intensity : float );

// This class enables you to create entities async with the the of Game::CreateEntityAsync
import class CCreateEntityHelper
{
	import function SetPostAttachedCallback( caller : IScriptable, funcName : name );
	import function IsCreating() : bool;
	import function Reset();
	import function GetCreatedEntity() : CEntity;
}

import class CR4CreateEntityHelper extends CCreateEntityHelper
{
}
