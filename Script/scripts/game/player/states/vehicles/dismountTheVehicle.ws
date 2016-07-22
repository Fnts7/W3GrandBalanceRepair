// Please keep this as empty as possible
// use RidingManager instead
state DismountTheVehicle in CPlayer extends PostUseVehicle
{
	public var vehicle 			: CVehicleComponent;
	public var dismountType 	: EDismountType;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	event OnEnterState( prevStateName : name )
	{
		parent.AddAnimEventCallback('enable_physics',	'OnAnimEvent_enable_physics');
		parent.AddAnimEventCallback('disableFeetIK',	'OnAnimEvent_disableFeetIK');
		parent.AddAnimEventCallback('enableFeetIK',		'OnAnimEvent_enableFeetIK');
		parent.BlockAllActions( 'DismountVehicle', true,, true );
		
		HACK_DeactivatePhysicsRepresentation();
		
		thePlayer.substateManager.m_SharedDataO.ResetHeightFallen();
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		//parent.RemoveAnimEventCallback('enable_physics');
		//parent.RemoveAnimEventCallback('disableFeetIK');
		//parent.RemoveAnimEventCallback('enableFeetIK');
		
		LogAssert( !vehicle, "DismountTheVehicle::OnLeaveState, 'vehicle' is still set" );
		
		vehicle = NULL;
		
		super.OnLeaveState( nextStateName );
		
		parent.RegisterCollisionEventsListener();
		
		thePlayer.ResetRawPlayerHeading();
				
		parent.BlockAllActions( 'DismountVehicle', false );
		parent.UnblockAction( EIAB_Crossbow, 'DismountVehicle2' );
		
		parent.SetUsedVehicle(NULL);
		parent.SetBehaviorVariable( 'keepSpineUpright', 0.f );	
		
		HACK_ActivatePhysicsRepresentation();
		//parent.BreakAttachment();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	final function SetupState( v : CVehicleComponent, inDismountType : EDismountType )
	{
		LogAssert( !vehicle, "DismountTheVehicle::SetupState, 'vehicle' is already set" );
		
		vehicle 		= v;
		dismountType 	= inDismountType;
	}
	
	// This is called when the state was interupted ( ie the dismount didn't have time to finish )
	cleanup function DismountCleanup() 
	{
		vehicle = NULL;
		HACK_ActivatePhysicsRepresentation();
	}
	
	function ContinuedState()
	{	
		parent.PopState( true );
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		moveData.pivotRotationController.SetDesiredHeading( VecHeading(theCamera.GetCameraDirection()) );
	}
	
	event OnAnimEvent_enable_physics( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		HACK_ActivatePhysicsRepresentation();
		parent.BreakAttachment();
		//parent.SetUsedVehicle(NULL);
	}
	
	event OnAnimEvent_disableFeetIK( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//parent.SetBehaviorVariable( 'disableFeetIK', 1.f );
	}
	
	event OnAnimEvent_enableFeetIK( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//parent.SetBehaviorVariable( 'disableFeetIK', 0.f );
	}
}
