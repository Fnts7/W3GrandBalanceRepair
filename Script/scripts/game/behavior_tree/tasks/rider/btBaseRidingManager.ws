/////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerVehicleMount
abstract class CBTTaskRidingManagerVehicleMount extends IBehTreeTask
{
	protected var mountType : name;
	var riderData      		: CAIStorageRiderData;
	var attachSlot 			: name;
	
	function OnActivate() : EBTNodeStatus
	{
        var vehicleComponent: CVehicleComponent;
		vehicleComponent = GetVehicleComponent();
		
		if ( !vehicleComponent || vehicleComponent.IsMountingPossible() == false )
        {
			return BTNS_Failed;
        }		
        return BTNS_Active;
	}
	
	function GetVehicleComponent() : CVehicleComponent
	{
		return NULL;
	}
	
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor			: CActor = GetActor();
		var behaviorsToActivate : array< name >;
		var preloadResult		: bool = true;	

		// Must be called before anything is done
		vehicleComponent.OnMountStarted( riderActor, riderData.sharedParams.vehicleSlot );

		// [ Step ] Set vehicle and callback
		riderActor.SetUsedVehicle( (CGameplayEntity)vehicleComponent.GetEntity() );	
		behaviorsToActivate.PushBack( behGraphName );
		// Order to preload behavior - if we're going to play exploration, we will have time to load behavior in the background
		preloadResult = riderActor.PreloadBehaviorsToActivate( behaviorsToActivate );
		LogAssert( preloadResult, "CBTTaskRidingManagerVehicleMount::OnMountStarted - preloading behaviors failed" );	
		// RiderData
		riderData.sharedParams.mountStatus = VMS_mountInProgress;
		
		//riderActor.CreateAttachment( vehicleComponent.GetEntity(), attachSlot );	
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
		var behaviorsToActivate : array< name >;
		var graphResult 		: bool;
		var movementAdjustor	: CMovementAdjustor;
		
		// Rider data
		riderData.sharedParams.mountStatus = VMS_mounted;
		// Rider
		riderActor.RemoveTimer( 'UpdateTraverser' );

		// [ Step ] Change beh graph and stuff - we should have behavior graph loaded already
		behaviorsToActivate.PushBack( behGraphName );
		graphResult = riderActor.ActivateBehaviors( behaviorsToActivate );
		
		riderActor.SetBehaviorVariable('MountType',GetMountTypeVariable());
		
		if ( riderData.ridingManagerInstantMount )
		{
			riderActor.RaiseForceEvent( 'InstantMount' );
		}
		
		
		LogAssert( graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors activation failed" );
		
		if ( riderData.sharedParams.vehicleSlot == EVS_passenger_slot )
		{
			if ( riderActor.SetBehaviorVariable('isPassenger', 1.0f) == false )
			{
				LogAssert( graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors variable init failed" );
			}
		}
		else
		{
			if ( riderActor.SetBehaviorVariable('isPassenger', 0.0f) == false )
			{
				LogAssert( graphResult, "CBTTaskRidingManagerHorseMount::OnMountFinishedSuccessfully - behaviors variable init failed" );
			}
		}
		
		// Collisions must be disabled (physx character represtentation turned off) to properly attach rider to boat
		riderActor.EnableCollisions( false );
		
		// Don't attach to root slot. attach to entity and constraints will make it look proper
		riderActor.CreateAttachment( vehicleComponent.GetEntity(), attachSlot );		
		
		movementAdjustor = riderActor.GetMovingAgentComponent().GetMovementAdjustor();
		if ( movementAdjustor )
		{
			movementAdjustor.CancelAll();
		}
		
		// This must be called at the very end of mount, and only if success
		vehicleComponent.OnMountFinished( riderActor );
	}
	
	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor 	= GetActor();
		riderData.ridingManagerMountError 	= true;
		vehicleComponent.OnDismountStarted( riderActor );
		vehicleComponent.OnDismountFinished( riderActor, riderData.sharedParams.vehicleSlot );
		
		riderData.sharedParams.mountStatus 	= VMS_dismounted;
		
		riderActor.SetUsedVehicle( NULL );
	}	
	// everything common to player and NPC mounting 
	latent function MountActor( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor = GetActor();
		var exploration 		: SExplorationQueryToken;
		var vehicleEntity		: CEntity = vehicleComponent.GetEntity();
		var queryContext		: SExplorationQueryContext;
		var success 			: bool = true;		
		
		// [ Step ] making sure the NPC is in the proper position for mounting
		if ( riderData.ridingManagerInstantMount == false )
		{
			queryContext.inputDirectionInWorldSpace = VecNormalize( vehicleEntity.GetWorldPosition() - riderActor.GetWorldPosition() );
			// Exploration.valid will tell us if we are at the proper distance :
			exploration = theGame.QueryExplorationFromObjectSync( riderActor, vehicleEntity );
			success 	= exploration.valid;
		}
		
		if ( success )
		{
			// Mounting can begin we are in a position to mount
			OnMountStarted( riderData, behGraphName, vehicleComponent );

			// [ Step ] Play mount anim 
			if ( riderData.ridingManagerInstantMount == false )
			{
				riderActor.AddTimer( 'UpdateTraverser', 0.f, true, false, TICK_PrePhysics );
				success = riderActor.ActionExploration( exploration, NULL, riderData.sharedParams.GetHorse() );
			}
		}
		
		if ( success )
		{		
			OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
		}
		else
		{
			OnMountFailed( riderData, vehicleComponent );
		}
	}
	
	function GetMountTypeVariable() : float
	{
		switch ( mountType )
		{
			case 'horse_mount_B_01' 	: return 1.f;
			case 'horse_mount_L' 		: return 2.f;
			case 'horse_mount_LB' 		: return 3.f;
			case 'horse_mount_LF' 		: return 4.f;
			case 'horse_mount_R_01' 	: return 5.f;
			case 'horse_mount_RB_01' 	: return 6.f;
			case 'horse_mount_RF_01' 	: return 7.f;
			default 					: return 0.f;
		}
		return 0.f;
	}
	
    function Initialize()
    {
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
    }
}

// CBTTaskRidingManagerVehicleMountDef
abstract class CBTTaskRidingManagerVehicleMountDef extends IBehTreeTaskDefinition
{

}





////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerVehicleDismount
class CBTTaskRidingManagerVehicleDismount extends IBehTreeTask
{
    var riderData     : CAIStorageRiderData;

    function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var vehicleActor 		: CActor;
		// This need to be the first thing called
		if ( vehicleComponent )
		{
			vehicleComponent.OnDismountStarted( riderActor );
		}

		// This needs to be here in the case we dismount while we are mounting 
		// This happens when we despawn riders
		//riderActor.BreakAttachment();
		riderActor.ActionCancelAll(); // Kill the traverser
		riderActor.RemoveTimer( 'UpdateTraverser' ); // Kill the traverser callback
		riderData.sharedParams.mountStatus = VMS_dismountInProgress;
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		// Rider data
		riderData.sharedParams.mountStatus = VMS_dismounted;
		// Rider
		riderActor.EnableCharacterCollisions(true);
		riderActor.BreakAttachment();
		riderActor.SetUsedVehicle(NULL);
		
		// vehicle
		if ( vehicleComponent )
		{
			// this needs to be called last
			vehicleComponent.OnDismountFinished( riderActor, riderData.sharedParams.vehicleSlot );
		}
    }

    

    // This function exists because we need to be able to call dismount actor from a non-latent function
    // I know this sucks but latent function suck too !
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent  )
    {	
    }

    // This function must be kept non-latent
    function FindDismountDirection( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent, out dismountDirection : float )
	{
		var riderActor						: CActor 	= GetActor();
		var vehicleEntity					: CEntity 	= vehicleComponent.GetEntity();
		var horseComponent					: W3HorseComponent;
		var LeftForwardDismountPosition 	: Vector;
		var LeftForwardDismountPositionTrot : Vector;
		var RightForwardDismountPosition 	: Vector;
		var LeftBackwardDismountPosition 	: Vector;
		var RightBackwardDismountPosition 	: Vector;
		var BackDismountPosition 			: Vector;
		var actorMovingAgentComponent 		: CMovingPhysicalAgentComponent;
		var vehiclePosition					: Vector 	= vehicleEntity.GetWorldPosition();
		var vehicleForward					: Vector 	= vehicleEntity.GetWorldForward();
		var vehicleRight					: Vector 	= vehicleEntity.GetWorldRight();
		var dismountCheckLength				: float		= 1.0;
		var possibleDirections				: array<float>;
		dismountDirection = 1.0;	
		actorMovingAgentComponent =( CMovingPhysicalAgentComponent ) riderActor.GetMovingAgentComponent();
		// [ Step ] calculate dismount positions 
		// dismountDirection : in wich direction to dismount, some sides might be blocked by geometry
		LeftForwardDismountPosition 	= vehiclePosition - vehicleRight * dismountCheckLength;
		LeftForwardDismountPositionTrot = vehiclePosition + (2 * vehicleForward - vehicleRight) * dismountCheckLength;
		RightForwardDismountPosition 	= vehiclePosition + vehicleRight * dismountCheckLength;
		LeftBackwardDismountPosition 	= vehiclePosition + (-vehicleForward - vehicleRight) * dismountCheckLength;
		RightBackwardDismountPosition 	= vehiclePosition + (-vehicleForward + vehicleRight) * dismountCheckLength;
		BackDismountPosition 			= vehiclePosition + (-vehicleForward ) * dismountCheckLength;
		
		horseComponent = (W3HorseComponent)vehicleComponent;
		
		if ( horseComponent && riderActor == thePlayer  )
		{
			if ( horseComponent.GetCurrentPitch() >= 30.0 )
			{
				if( IsPositionValid( vehicleComponent, BackDismountPosition ) )
				{
					thePlayer.SetBehaviorVariable( 'dismountType',0.f );
					dismountDirection = 4.0;
					return;
				}
				else
				{
					riderData.ridingManagerDismountType = DT_instant;
					return;
				}
			}
			else if ( thePlayer.GetBehaviorVariable('dismountType') == 1.f )
			{
				if( IsPositionValid( vehicleComponent, LeftForwardDismountPositionTrot ) )
				{
					return;
				}
				else if( IsPositionValid( vehicleComponent, BackDismountPosition ) )
				{
					thePlayer.SetBehaviorVariable( 'dismountType',0.f );
					dismountDirection = 4.0;
					return;
				}
				else
				{
					thePlayer.SetBehaviorVariable('dismountType',0.f);
				}
			}
		}
		
		// primary directions
		if( IsPositionValid( vehicleComponent, LeftForwardDismountPosition ) )
		{
			possibleDirections.PushBack( 0.0 );
		}
		if( IsPositionValid( vehicleComponent, RightForwardDismountPosition ) )
		{
			possibleDirections.PushBack( 1.0 );
		}
		if( possibleDirections.Size() <= 0 )
		{
			// secondary directions
			if( IsPositionValid( vehicleComponent, LeftBackwardDismountPosition ) )
			{
				possibleDirections.PushBack( 2.0 );
			}
			if( IsPositionValid( vehicleComponent, RightBackwardDismountPosition ) )
			{
				possibleDirections.PushBack( 3.0 );
			}
			
			if( !possibleDirections.Size() )
			{
				if( IsPositionValid( vehicleComponent, BackDismountPosition ) )
				{
					dismountDirection = 4.0;
					return;
				}
				else
				{
					riderData.ridingManagerDismountType = DT_instant;
					return;
				}
			}
			
			dismountDirection = possibleDirections[ RandRange( possibleDirections.Size() ) ];
			
		}
		else
		{
			dismountDirection = possibleDirections[ RandRange( possibleDirections.Size() ) ];
		}
	}
	
	function IsPositionValid( vehicleComponent : CVehicleComponent, _position : Vector ) : bool
	{
		var riderActor						: CActor 	= GetActor();
		var actorMovingAgentComponent 		: CMovingPhysicalAgentComponent;
		var vehicleEntity					: CEntity 	= vehicleComponent.GetEntity();
		var vehiclePosition					: Vector 	= vehicleEntity.GetWorldPosition();
		var pointA, pointB, outPosition, outNormal : Vector;
		var collisionGroupsNames 			: array<name>;
		//var dbgSphereName 					: array<name>; // Hack so that we can have many unique debug spheres
		
		actorMovingAgentComponent = ( CMovingPhysicalAgentComponent ) riderActor.GetMovingAgentComponent();
		
		collisionGroupsNames.PushBack('Static');
		collisionGroupsNames.PushBack('Terrain');
		collisionGroupsNames.PushBack('Destructible');
		collisionGroupsNames.PushBack('Foliage');
		
		pointA = vehiclePosition;
		pointB = _position;
		pointA.Z += 1.0;
		pointB.Z += 1.0;

		if ( theGame.GetWorld().SweepTest( pointA, pointB, 0.4, outPosition, outNormal, collisionGroupsNames ) )
		{
			//thePlayer.GetVisualDebug().AddSphere( dbgSphereName[ 0 ], 0.4, _position, true, Color( 255, 0, 255 ), 10.0 );
			return false;
		}

		//thePlayer.GetVisualDebug().AddSphere( dbgSphereName[ 0 ], 0.4, _position, true, Color( 0, 255, 0 ), 10.0 );
		return true;
	}
	
    latent function DismountActor_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent, dismountDirection : float )
	{
		var riderActor				: CActor 	= GetActor();
		var riderActorTarget		: CActor;
		var angleDistance 			: float;
		var vehicleEntity			: CEntity 	= vehicleComponent.GetEntity();	
		var params					: SCustomEffectParams;
		var numSecWait				: float;
		var r4player				: CR4Player;

		if( (W3HorseComponent)vehicleComponent )
		{
			numSecWait = 2.0f;
		}
		else
		{
			// Avoid long behaviour deactivation
			numSecWait = 0.5f;
		}
		
		switch ( riderData.ridingManagerDismountType )
		{
			case DT_normal:
			{
				riderActor.SetBehaviorVariable('shakeOffRider', 0.f );
				riderActor.SetBehaviorVariable('dismountDirection', dismountDirection );
				
				r4player = (CR4Player)riderActor;
								
				if ( riderActor.RaiseForceEventWithoutTestCheck( 'dismount' ) )
				{
					// re-enabling collision here because geralt needs to adjust to terrain
					riderActor.WaitForBehaviorNodeDeactivation( 'dismountEnd', numSecWait );
				}
				else
				{
					if ( riderActor.RaiseForceEvent( 'dismount' ) )
					{
						// re-enabling collision here because geralt needs to adjust to terrain
						riderActor.WaitForBehaviorNodeDeactivation( 'dismountEnd', numSecWait );
					}
				}
				
				break;
			}
			
			case DT_shakeOff:
			{
				// Setting shakeOffRider var
				riderActor.SetBehaviorVariable('shakeOffRider', 1.f );
				vehicleEntity.SetBehaviorVariable('shakeOffRider', 1.f );				
				
				// Setting dismountDirection var 
				riderActor.SetBehaviorVariable('dismountDirection', dismountDirection );
				vehicleEntity.SetBehaviorVariable('dismountDirection', dismountDirection );				
				
				
				params.effectType = EET_Knockdown;
				params.creator = (CGameplayEntity)vehicleComponent.GetEntity();
				params.sourceName = "shakeOff_dismount";
				params.duration = 5;
				riderActor.AddEffectCustom(params);
				
				PlaySyncAnimWithRider( vehicleEntity, 'dismount', 'dismountEnd');
				
				break;
			}
			case DT_ragdoll:
			{
				riderActorTarget = riderActor.GetTarget();
				if ( riderActorTarget )
				{
					angleDistance = NodeToNodeAngleDistance(riderActorTarget,riderActor);
					if ( AbsF(angleDistance) < 50 )
						dismountDirection = 0.f;
					else if ( angleDistance <= -50 )
						dismountDirection = 1.f;
					else
						dismountDirection = 2.f;
				}
				else
				{
					dismountDirection = 0.f;
				}
				
				riderActor.SetBehaviorVariable('dismountDirection', dismountDirection );
				riderActor.RaiseForceEvent( 'dismountRagdoll' );
				riderActor.WaitForBehaviorNodeDeactivation('dismountRagdollEnd',0.5);
				riderActor.BreakAttachment();
				break;
			}
			case DT_instant:
			{
				break;
			}
		}
	}

	latent function DismountActor( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var dismountDirection : float = 1.0f;
		OnDismountStarted( riderData, vehicleComponent );
		
		FindDismountDirection( riderData, vehicleComponent, dismountDirection );
		DismountActor_Latent( riderData, vehicleComponent, dismountDirection );
		OnDismountFinishedA( riderData, vehicleComponent );
		OnDismountFinishedB_Latent( riderData, vehicleComponent );
	}

	function DismountActor_NonLatent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		OnDismountStarted( riderData, vehicleComponent );
		OnDismountFinishedA( riderData, vehicleComponent );
	}
	// Raises eventName on both vehicle and user, and wait for deactivationEvent on user
	latent function PlaySyncAnimWithRider( vehicleEntity: CEntity, eventName : CName, deactivationEvent : CName )
	{
		var riderActor						: CActor 	= GetActor();
		
		vehicleEntity.RaiseForceEventWithoutTestCheck('ForceIdle');
		Sleep(0.1);
		if( riderActor != thePlayer )
		{
			vehicleEntity.RaiseForceEventWithoutTestCheck( eventName );
			riderActor.RaiseForceEventWithoutTestCheck( eventName );
			riderActor.BreakAttachment();
			Sleep(1.f);
			riderActor.RaiseEvent('SwitchToRagdoll');
		}
		else
		{	
			vehicleEntity.RaiseEventWithoutTestCheck( eventName );
			riderActor.RaiseEventWithoutTestCheck( eventName );
			riderActor.BreakAttachment();
			vehicleEntity.WaitForBehaviorNodeDeactivation(deactivationEvent, 10.0f );
		}
		
	}
    function Initialize()
    {
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
    }
}

// CBTTaskRidingManagerVehicleDismountDef
abstract class CBTTaskRidingManagerVehicleDismountDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRidingManagerVehicleDismount';
}
