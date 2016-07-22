/////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerHorseMount
abstract class CBTTaskRidingManagerHorseMount extends CBTTaskRidingManagerVehicleMount
{
	default attachSlot = '';
	
	function GetVehicleComponent() : CVehicleComponent
	{
		return (CVehicleComponent)riderData.sharedParams.GetHorse().GetComponentByClassName('CVehicleComponent');
	}
	
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;

		super.OnMountStarted( riderData, behGraphName, vehicleComponent );

		vehicleActor      	= (CActor)vehicleComponent.GetEntity();
		vehicleActor.SignalGameplayEvent( 'HorseMountStart' );
		riderActor.SignalGameplayEvent( 'HorseMountStart' );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;
		var player				: CR4Player;
		var behaviorsToActivate : array< name >;
		var graphResult			: bool;

		vehicleActor      	= (CActor)vehicleComponent.GetEntity();
		player				= (CR4Player)riderActor;
		// This one second offset will make sure the actor doesn't teleport on its attachement
		// Do not apply when instant mount
		if ( riderData.ridingManagerInstantMount == false )
		{
			riderActor.GetMovingAgentComponent().SetAdditionalOffsetWhenAttachingToEntity( vehicleActor, 1.0f );
		}

		if ( player )
		{
			riderActor.EnableCollisions( false ); // needed because rider disapears after finish mounting
		}

		riderActor.SetBehaviorVariable( 'rider', 1.0f );
		vehicleActor.SignalGameplayEvent( 'HorseMountEnd' );
		riderActor.SignalGameplayEvent( 'HorseMountEnd' );
		
		// do that only if mounting succeeds
		if ( riderActor.CanStealOtherActor( vehicleActor ) )
		{
			theGame.ConvertToStrayActor( vehicleActor );
			if ( player )
			{
				player.SaveLastMountedHorse( vehicleActor );
			}
		}
		
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();

		super.OnMountFailed( riderData, vehicleComponent );
	} 

	function OnGameplayEvent( eventName : CName ) : bool
	{
		var riderActor			: CActor 	= GetActor();
		var riderData       	: CAIStorageRiderData;
		var vehicleEntity 		: CEntity;
		var vehicleComponent  	: W3HorseComponent;

		//super.OnListenedGameplayEvent( eventName );
		
		if( eventName == 'OnPoolRequest' || eventName == 'RequestInstantDismount' )
		{
			Complete(false);
		}
		if( eventName == 'MountHorseType' )
		{
			mountType = GetEventParamCName('');
			if ( riderActor == thePlayer )
			{
				((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnMountAnimStarted();
			}
		}
		if( eventName == 'HorseRidingOn' )
		{
			if( riderActor == thePlayer )
			{
				((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnHorseRidingOn();
			}
		}
		return false;
	}   
}

// CBTTaskRidingManagerHorseMountDef
abstract class CBTTaskRidingManagerHorseMountDef extends CBTTaskRidingManagerVehicleMountDef
{
}



////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerNPCHorseMount
class CBTTaskRidingManagerNPCHorseMount extends CBTTaskRidingManagerHorseMount
{    
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor             : CActor = GetActor();
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );

		// [ Step ] Flags
		riderActor.EnableCharacterCollisions( false );
		riderActor.EnablePhysicalMovement( false );
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( true );
	}	

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();
		// [ Step ] Flags
		riderActor.GetRootAnimatedComponent().SetUseExtractedMotion( true);
        riderActor.EnableCollisions( false ); // needed because rider disapears after finish mounting
		
        // [ Step ] InitBehGraph
		riderActor.GetMovingAgentComponent().ResetMoveRequests();
        riderActor.SetBehaviorVariable( 'direction', 0.0f );
        riderData.sharedParams.GetHorse().GetMovingAgentComponent().ResetMoveRequests();
        riderData.sharedParams.GetHorse().SetBehaviorVariable( 'direction', 0.0f );
        
        // [ Step ] setting voiceovers for npc on the horse
        riderActor.SoundSwitch( "vo_3d", 'vo_3d_long_on_horse', 'head' );
        
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();

		riderActor.EnableCharacterCollisions( true );
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( false );

		super.OnMountFailed( riderData, vehicleComponent );
	}

    latent function Main() : EBTNodeStatus
    {
        var npc             	: CNewNPC = GetNPC();
        var stupidArray 		: array< name >;
        var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;

        riderData.ridingManagerMountError   = false;

        // [ HACK ] We are in a branch that asks for mounting so a horse will appear sooner or later
        // instant mount without horse and so we must wait for the streaming to load it 
        while ( !riderData.sharedParams.GetHorse() )
        {
			SleepOneFrame();
        }      

		// [Hack] Makeing sure the NPC is in exploration ( not in combat )
        stupidArray.PushBack( 'Exploration' );
		GetActor().ActivateBehaviors( stupidArray ); 
		
		vehicleEntity      = riderData.sharedParams.GetHorse();
        vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent();  

        // [ Step ] Play anim and wait for it to finish
		MountActor( riderData, 'VehicleHorse', vehicleComponent );

        return BTNS_Completed;
    }
}

// CBTTaskRidingManagerNPCHorseMounttDef
class CBTTaskRidingManagerNPCHorseMountDef extends CBTTaskRidingManagerHorseMountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCHorseMount';
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerPlayerHorseMount
class CBTTaskRidingManagerPlayerHorseMount extends CBTTaskRidingManagerHorseMount
{
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor          : CActor = GetActor();	

		riderActor.EnableCharacterCollisions( false ); 
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var horseComponent		: W3HorseComponent;
		var vehicleEntity 		: CEntity = vehicleComponent.GetEntity();     
        horseComponent = (W3HorseComponent)vehicleComponent;
        
		horseComponent.canDismount = true;
		
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();
		theGame.ActivateHorseCamera( false, 0.f );
		riderActor.ActionCancelAll();
		riderActor.EnableCharacterCollisions( true );
		riderActor.RegisterCollisionEventsListener();		

		theInput.SetContext( thePlayer.GetExplorationInputContext() );
		super.OnMountFailed( riderData, vehicleComponent );
	}

    latent function Main() : EBTNodeStatus
    {
        var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;
    
        riderData.ridingManagerMountError   = false; 

        vehicleEntity      = riderData.sharedParams.GetHorse();
        vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent(); 

        // [ Step ] Play anim and wait for it to finish
		MountActor( riderData, 'VehicleHorse', vehicleComponent );
        return BTNS_Completed;
    }
}

// CBTTaskRidingManagerPlayerHorseMountDef
class CBTTaskRidingManagerPlayerHorseMountDef extends CBTTaskRidingManagerHorseMountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerHorseMount';
}
////////////////////////////////////////////////////////////////////
// DISMOUNT !
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerHorseDismount
abstract class CBTTaskRidingManagerHorseDismount extends CBTTaskRidingManagerVehicleDismount
{
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var vehicleActor 		: CActor;
		
		super.OnDismountStarted( riderData, vehicleComponent );
		vehicleActor      = (CActor)vehicleComponent.GetEntity();
		if ( vehicleActor )
		{
			vehicleActor.SignalGameplayEvent( 'HorseDismountStart' );
		}
		riderActor.SignalGameplayEvent( 'HorseDismountStart' );	
    }
    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var vehicleActor 		: CActor;
		// Rider
		riderActor.SignalGameplayEvent( 'HorseDismountEnd' );

		// Vehicle
		vehicleActor      = (CActor)vehicleComponent.GetEntity();
		if ( vehicleActor )
		{
			vehicleActor.SignalGameplayEvent( 'HorseDismountEnd' );
		}
		if ( (CR4Player)riderActor )
		{
			riderActor.EnableCollisions( true );
		}
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }

    latent function Main() : EBTNodeStatus
    {
		var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;    
		vehicleEntity      	= riderData.sharedParams.GetHorse();
        vehicleComponent   	= ((CNewNPC)vehicleEntity).GetHorseComponent(); 
		DismountActor( riderData, vehicleComponent );		

        return BTNS_Completed;
    }
    function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity;
		var vehicleComponent  	: W3HorseComponent;
		
		if ( eventName == 'OnPoolRequest' || eventName == 'RequestInstantDismount' )
		{
			vehicleEntity      	= riderData.sharedParams.GetHorse();
			if ( vehicleEntity )
			{
				vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent();
			}
			if( riderData.sharedParams.mountStatus != VMS_dismounted )
			{	
				
				DismountActor_NonLatent( riderData, vehicleComponent );
				// Hack to force behaviour graph
				// RiderActor needs to passed here because riderData.sharedParams.RiderActor is not garantied to be valid
				riderData.OnInstantDismount( riderActor );
			}
		}
		return false;
	}
}

// CBTTaskRidingManagerHorseDismountDef
abstract class CBTTaskRidingManagerHorseDismountDef extends CBTTaskRidingManagerVehicleDismountDef
{
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnPoolRequest' );
		listenToGameplayEvents.PushBack( 'RequestInstantDismount' );
	}
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerNPCHorseDismount
class CBTTaskRidingManagerNPCHorseDismount extends CBTTaskRidingManagerHorseDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();	
		super.OnDismountStarted( riderData, vehicleComponent );	
		riderActor.GetRootAnimatedComponent().SetUseExtractedMotion( true ); 
		riderActor.EnablePhysicalMovement(false);
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( false );
		
		riderActor.AddBuffImmunity( EET_Frozen, 'HorseDismount', true );
    }   

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var params : SCustomEffectParams;
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();	
		
		if ( riderData.ridingManagerDismountType == DT_ragdoll || riderData.ridingManagerDismountType == DT_shakeOff )
		{
			riderData.sharedParams.hasFallenFromHorse = true;
			riderActor.SetKinematic(false);
			params.effectType = EET_Ragdoll;
			params.creator = riderActor;
			params.sourceName = "ragdoll_dismount";
			params.duration = 2;
			riderActor.AddEffectCustom( params );
			riderActor.SignalGameplayEvent( 'RagdollFromHorse' );
			riderActor.EnableCollisions( true );
			if ( riderData.ridingManagerDismountType == DT_ragdoll )
				riderActor.EnableCharacterCollisions( false );
			
		}
		else
		{
			riderActor.EnableCollisions( true );	
		}
		
		// [ Step ] setting voiceovers for npc on foot again
        riderActor.SoundSwitch( "vo_3d", 'vo_3d_long', 'head' );
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var stupidArray     	: array< name >;
		var params				: SCustomEffectParams;
		var inv					: CInventoryComponent;
		var item				: SItemUniqueId;
		
		inv = riderActor.GetInventory();
		item = inv.GetItemFromSlot('r_weapon');
		
		if ( riderActor.IsInCombat() && inv.IsIdValid(item) && inv.ItemHasTag(item,'sword1h') )
			stupidArray.PushBack( 'sword_1handed' );
		else
			stupidArray.PushBack( 'Exploration' );
			
		riderActor.ActivateBehaviors( stupidArray );
		
		if ( riderData.ridingManagerDismountType == DT_ragdoll || riderData.ridingManagerDismountType == DT_shakeOff )
		{
			GetNPC().SetIsFallingFromHorse( true ); // this needs to be called before applying ragdoll - adding HeavyKnockdown immunity inside so only ragdoll is applied
			
			params.effectType = EET_Ragdoll;
			params.creator = (CGameplayEntity)vehicleComponent.GetEntity();
			params.sourceName = "ragdoll_dismount";
			params.duration = 2;
			riderActor.AddEffectCustom(params);
		}
		
		riderActor.RemoveBuffImmunity( EET_Frozen, 'HorseDismount' );
		
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}

// CBTTaskRidingManagerNPCHorseDismountDef
class CBTTaskRidingManagerNPCHorseDismountDef extends CBTTaskRidingManagerHorseDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCHorseDismount';
}


////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerPlayerHorseDismount
class CBTTaskRidingManagerPlayerHorseDismount extends CBTTaskRidingManagerHorseDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var newRiderPosition	: Vector;
		var pointA, pointB, outPosition, outNormal : Vector;
		var collisionGroupsNames : array<name>;
		
		super.OnDismountStarted( riderData, vehicleComponent );
		
		riderActor.SetBehaviorVariable( 'swordAdditiveBlendWeight', 0.f );
		
		if ( riderData.ridingManagerDismountType == DT_instant )
		{
			if ( !theGame.GetWorld().NavigationFindSafeSpot(riderActor.GetWorldPosition(),0.4, 2, newRiderPosition) )
			{
				newRiderPosition = riderActor.GetWorldPosition();
				newRiderPosition.Z += 1.5;
			}
			else
			{
				collisionGroupsNames.PushBack('Static');
				collisionGroupsNames.PushBack('Terrain');
				collisionGroupsNames.PushBack('Destructible');
				
				// we need to make sure new point has Line of Sight with Previous Point
				pointA = riderActor.GetWorldPosition();
				pointB = newRiderPosition;
				pointA.Z += 1.f;
				pointB.Z += 1.f;
				if ( !theGame.GetWorld().StaticTrace(pointA,pointB,outPosition,outNormal,collisionGroupsNames) )
				{
					newRiderPosition = riderActor.GetWorldPosition();
					newRiderPosition.Z += 1.5;
				}
			}
			riderActor.Teleport(newRiderPosition);
		}
    }
    
    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();		

		// freeing the horse for other NPC's to use
		// unless this the main horse in this case we need to be able to wistle him
		if ( vehicleComponent.GetEntity() != thePlayer.GetHorseWithInventory() )
		{
			((W3HorseComponent)vehicleComponent).Unpair(); 
		}
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }	
}

// CBTTaskRidingManagerPlayerHorseDismountDef
class CBTTaskRidingManagerPlayerHorseDismountDef extends CBTTaskRidingManagerHorseDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerHorseDismount';
}
