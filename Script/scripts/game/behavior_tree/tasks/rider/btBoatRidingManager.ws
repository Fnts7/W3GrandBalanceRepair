/////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerBoatMount
abstract class CBTTaskRidingManagerBoatMount extends CBTTaskRidingManagerVehicleMount
{
	var behGraphAlias : name;
	default attachSlot = 'seat';
	
	function GetVehicleComponent() : CVehicleComponent
	{
		var boat			: CEntity;
        boat = EntityHandleGet( riderData.sharedParams.boat );
		return (CVehicleComponent)boat.GetComponentByClassName('CVehicleComponent');
	}
	
	function OnActivate() : EBTNodeStatus
	{
        var vehicleComponent: CVehicleComponent;
        
        if ( super.OnActivate() != BTNS_Active )
        {   
			return BTNS_Failed;
		}
		
		if ( riderData.sharedParams.vehicleSlot == EVS_driver_slot )
        {
			attachSlot 							= 'seat';
        }
        else
		{
			attachSlot 							= 'seat_passenger';
		}		
		
		return BTNS_Active;
	}
	
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor		: CActor = GetActor();
		var vehicleActor 	: CActor;
		// must be called first
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );	
		// Don't attach to root slot. attach to entity and constraints will make it look proper
		//riderActor.CreateAttachment( vehicleComponent.GetEntity(), attachSlot );	
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;
		
		// Must be called last
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}
	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();
		super.OnMountFailed( riderData, vehicleComponent );
	}
	latent function Main() : EBTNodeStatus
    {
        var vehicleComponent: CVehicleComponent;
        var vehicle			: CEntity;
        var boatComp		: CBoatComponent;
        
        if( riderData.sharedParams.rider != thePlayer )
        {
			riderData.ridingManagerInstantMount = true;
		}
		
        vehicle = EntityHandleGet( riderData.sharedParams.boat );
		vehicleComponent = (CVehicleComponent)vehicle.GetComponentByClassName('CVehicleComponent');
		
		// If actor is already mounted to vehicle to the same slot as shown in rider data
		if( riderData.sharedParams.vehicleSlot == EVS_driver_slot && vehicleComponent.GetUser() )
		{
			return BTNS_Failed;
		}
		
		boatComp = (CBoatComponent)vehicle.GetComponentByClassName('CBoatComponent');
		if( boatComp )
		{
			if( riderData.sharedParams.vehicleSlot == EVS_passenger_slot && boatComp.GetPassenger() )
			{
				return BTNS_Failed;
			}
		}
		
        // [ Step ] Play anim and wait for it to finish
		MountActor( riderData, behGraphAlias, vehicleComponent );
        return BTNS_Completed;
    }
}

// CBTTaskRidingManagerBoatMountDef
abstract class CBTTaskRidingManagerBoatMountDef extends CBTTaskRidingManagerVehicleMountDef
{
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerPlayerBoatMount
class CBTTaskRidingManagerPlayerBoatMount extends CBTTaskRidingManagerBoatMount
{
	default behGraphAlias  = 'PlayerSailing';

	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{        
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		super.OnMountFailed( riderData, vehicleComponent );
	}
	
}



// CBTTaskRidingManagerPlayerBoatMountDef
class CBTTaskRidingManagerPlayerBoatMountDef extends CBTTaskRidingManagerBoatMountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerBoatMount';
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerNPCBoatMount
class CBTTaskRidingManagerNPCBoatMount extends CBTTaskRidingManagerBoatMount
{
	default behGraphAlias  = 'VehicleBoat';
	
	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
	
		riderActor.EnableCollisions( false ); // needed because rider disapears after finish mounting
		// Must be called last
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}
}

// CBTTaskRidingManagerNPCBoatMountDef
class CBTTaskRidingManagerNPCBoatMountDef extends CBTTaskRidingManagerBoatMountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCBoatMount';
}

////////////////////////////////////////////////////////////////////
// DISMOUNT !

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerBoatDismount
abstract class CBTTaskRidingManagerBoatDismount extends CBTTaskRidingManagerVehicleDismount
{
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }

    // This function exists because we need to be able to call dismount actor from a non-latent function
    // I know this sucks but latent function suck too !
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
    latent function Main() : EBTNodeStatus
    {
        var vehicleComponent: CVehicleComponent;
        var boat			: CEntity;

        boat = EntityHandleGet( riderData.sharedParams.boat );
		vehicleComponent = (CVehicleComponent)boat.GetComponentByClassName('CVehicleComponent');
		DismountActor( riderData, vehicleComponent );			
        return BTNS_Completed;
    }
}

// CBTTaskRidingManagerBoatDismountDef
abstract class CBTTaskRidingManagerBoatDismountDef extends CBTTaskRidingManagerVehicleDismountDef
{  
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerPlayerBoatDismount
class CBTTaskRidingManagerPlayerBoatDismount extends CBTTaskRidingManagerBoatDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		/*var riderActor : CActor = GetActor();
		var riderPos : Vector;
		var riderRot : EulerAngles;
		var pitchDiff, rollDiff : float;
		
		// when player is dismounting while the boat is not leveled, he will keep his rotation in next state, so he will not for example stand straight
		riderPos = riderActor.GetWorldPosition();
		riderRot = riderActor.GetWorldRotation();
		
		pitchDiff = 0.0 - riderRot.Pitch;
		rollDiff = 0.0 - riderRot.Roll;
		
		riderActor.TeleportWithRotation( riderPos, EulerAngles( 0.0, riderRot.Yaw, 0.0 ) );
		//riderActor.GetMovingAgentComponent().SetAdditionalOffsetToConsumeMS( Vector(0,0,0), EulerAngles( pitchDiff, 0.0, rollDiff ), 2.0 );*/
		
		vehicleComponent.ToggleVehicleCamera( false );
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    // This function exists because we need to be able to call dismount actor from a non-latent function
    // I know this sucks but latent function suck too !
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}
// CBTTaskRidingManagerPlayerBoatDismountDef
class CBTTaskRidingManagerPlayerBoatDismountDef extends CBTTaskRidingManagerBoatDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerBoatDismount';
}

////////////////////////////////////////////////////////////////////
// CBTTaskRidingManagerNPCBoatDismount
class CBTTaskRidingManagerNPCBoatDismount extends CBTTaskRidingManagerBoatDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor = GetActor();
		vehicleComponent.ToggleVehicleCamera( false );
		riderActor.EnableCollisions( true ); // needed because rider disapears after finish mounting
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    // This function exists because we need to be able to call dismount actor from a non-latent function
    // I know this sucks but latent function suck too !
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}

// CBTTaskRidingManagerNPCBoatDismountDef
class CBTTaskRidingManagerNPCBoatDismountDef extends CBTTaskRidingManagerBoatDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCBoatDismount';
}