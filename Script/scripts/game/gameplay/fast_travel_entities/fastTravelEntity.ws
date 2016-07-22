import class CR4MapPinEntity extends CGameplayEntity
{
	import var entityName			: name;
	import var radius				: float;
	import var ignoreWhenExportingMapPins : bool;
}

import class CR4FastTravelEntity extends CR4MapPinEntity
{
	import var groupName			: name;
	import var teleportWayPointTag	: name;
	import var canBeReachedByBoat	: bool;
	import var isHubExit			: bool;
}

class W3FastTravelEntity extends CR4FastTravelEntity
{
	editable var onAreaExit	   : bool; 		default onAreaExit = false;
	
	//Options to override messages and oneliners for the land border
	editable var warningTextStringKeyOverride : string;
	editable var onelinerSceneOverride : CStoryScene;
	editable var overrideSceneInput : name;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		
		super.OnSpawned( spawnData );
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		theGame.GetSecondScreenManager().SendFastTravelEnable();
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		theGame.GetSecondScreenManager().SendFastTravelDisable();
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var initData : W3MapInitData;

		if ( !thePlayer.IsActionAllowed( EIAB_OpenMap ))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenMap);
		}
		else if(!thePlayer.IsActionAllowed( EIAB_FastTravel ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_FastTravel);			
		}
		else if ( mapManager.IsEntityMapPinDisabled( entityName ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, , , true);
		}
		else
		{
			if ( !theGame.IsBlackscreenOrFading() )
			{
				initData = new W3MapInitData in this;
				initData.SetUsedFastTravelEntity( this );
				initData.ignoreSaveSystem = true;
				initData.setDefaultState('FastTravel');
		
				theGame.RequestMenuWithBackground( 'MapMenu', 'CommonMenu', initData );
			}
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		//var initData : W3MapInitData;
		
		if ( activator.GetEntity() == thePlayer && GetWitcherPlayer() )
		{
			SetFocusModeVisibility( FMV_Interactive );
			if ( isHubExit )
			{
				if ( !onAreaExit )
				{						
					if ( area == GetComponent( "BorderTrigger" ) )
					{
						OnPlayerEnteredBorder();
					}
				}
				else
				{
					if ( area == GetComponent( "BorderTrigger" ) )
					{
						OnPlayerExitedBorder();
					}
				}
			}
			else
			{
				if ( area == GetComponent( "FirstDiscoveryTrigger" ) )
				{
					GetComponent( "FirstDiscoveryTrigger" ).SetEnabled( false );
					mapManager.SetEntityMapPinDiscoveredScript(true, entityName, true );
				}
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		//var initData : W3MapInitData;
		
		if ( activator.GetEntity() == thePlayer )
		{
			SetFocusModeVisibility( FMV_None );
			if ( isHubExit )
			{
				if ( onAreaExit )
				{
					if ( area == GetComponent( "BorderTrigger" ) )
					{
						OnPlayerEnteredBorder();
					}
				}
				else
				{
					if ( area == GetComponent( "BorderTrigger" ) )
					{
						OnPlayerExitedBorder();
					}
				}
			}
		}
	}
	
	private function OnPlayerEnteredBorder()
	{
		var text : string;
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var position : Vector;
		var rotation : EulerAngles;
		var shift : Vector;
		var finalPosition : Vector;
		var normal : Vector;
		var mac : CMovingAgentComponent;
		var bc : CBoatComponent;
		var vehicle : CGameplayEntity;
		var gear : int;
		var useStaticTrace : bool;
		
		var SHIFT_DISTANCE : float = 5;
		var TELEPORT_TIMER : float = 5;
		var POSITION_DIFF : Vector;
		POSITION_DIFF.Z = 10000;
		
		position = thePlayer.GetWorldPosition();
		rotation = thePlayer.GetWorldRotation();
		useStaticTrace = true;
		
		vehicle = thePlayer.GetUsedVehicle();
		if ( vehicle )
		{
			mac = (CMovingAgentComponent)vehicle.GetComponentByClassName( 'CMovingAgentComponent' );
			if ( mac )
			{
				// it's a horse!
				shift = mac.GetVelocityBasedOnRequestedMovement();
				shift.Z = 0;
				shift *= -1;
				
				rotation.Yaw += 180;
			}
			else
			{
				bc = (CBoatComponent)vehicle.GetComponentByClassName( 'CBoatComponent' );
				if ( bc )
				{
					// it's a boat!

					if ( thePlayer.GetCurrentStateName() == 'DismountBoat' )
					{
						// special case
						// player dismounts a motionless boat and crosses world border during animation
						// we can't use boat speed to calculate vector since we're gonna get [0,0,0]
						shift = VecFromHeading( rotation.Yaw );
						shift.Z = 0;
						shift *= -1;
						rotation.Yaw += 180;
					}
					else
					{
						shift = bc.GetCurrentSpeed();
						shift.Z = 0;
						shift *= -1;
						rotation.Yaw += 90; // doesn't seem to work for boats
						useStaticTrace = false;
					
						SHIFT_DISTANCE *= 2;
					}
				}
			}
		}
		else
		{
			mac = ( CMovingAgentComponent )thePlayer.GetMovingAgentComponent();
			if ( mac )
			{
				// player on foot
				shift = mac.GetVelocityBasedOnRequestedMovement();
				shift.Z = 0;
				shift *= -1;
				rotation.Yaw += 180;
			}
			else	
			{
				shift = VecFromHeading( rotation.Yaw );
				rotation.Yaw += 180;
			}
		}	

		shift = VecNormalize( shift );
		shift *= SHIFT_DISTANCE;

		if ( useStaticTrace )
		{
			if ( !theGame.GetWorld().StaticTrace( position + shift + POSITION_DIFF, position + shift - POSITION_DIFF, finalPosition, normal ) )
			{
				finalPosition = position + shift;
			}
		}
		else
		{
			finalPosition = position + shift;
		}

		if ( mapManager.NotifyPlayerEnteredBorder( TELEPORT_TIMER, finalPosition, rotation ) == 1 )
		{
			mapManager.AllowSaving( false );
			
			if( warningTextStringKeyOverride != "" )
			{
				text = text = GetLocStringByKeyExt( warningTextStringKeyOverride );
			}
			else
			{
				text = GetLocStringByKeyExt( "panel_common_end_of_the_world" );
			}
			
			thePlayer.DisplayHudMessage( text );
			thePlayer.BlockAction(EIAB_MeditationWaiting,	'EndOfTheWorld', false, false, true );
			thePlayer.BlockAction(EIAB_MountVehicle,		'EndOfTheWorld', false, false, true );
			thePlayer.BlockAction(EIAB_DismountVehicle,		'EndOfTheWorld', false, false, true );
			thePlayer.BlockAction(EIAB_Explorations,		'EndOfTheWorld', false, false, true );
			
			if( GetWitcherPlayer() )
			{
				//If override scene is assign try to use it instead of the voiceset line
				if( onelinerSceneOverride )
				{
					theGame.GetStorySceneSystem().PlayScene( onelinerSceneOverride, overrideSceneInput );
				}
				else
				{
					thePlayer.PlayVoiceset(100, "Input");	//great name btw...
				}
			}
		}
	}
	
	private function OnPlayerExitedBorder()
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( mapManager.NotifyPlayerExitedBorder() == 0 )
		{
			mapManager.AllowSaving( true );
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'EndOfTheWorld' );
			thePlayer.UnblockAction(EIAB_MountVehicle,		'EndOfTheWorld' );
			thePlayer.UnblockAction(EIAB_DismountVehicle,	'EndOfTheWorld' );
			thePlayer.UnblockAction(EIAB_Explorations,		'EndOfTheWorld' );
		}
	}
}
