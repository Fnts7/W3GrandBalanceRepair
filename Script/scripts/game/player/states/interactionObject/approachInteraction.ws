/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

state ApproachInteractionState in W3PlayerWitcher extends ExtendedMovable
{
	private var objectPointHeading 		: float;		//heading towards object point - Geralt will turn in that direction
	private var objectHeadingSet 		: bool;			//set to indicate that heading has been set by external source
	private var stopRequested 			: bool;			//set to true when something is requesting state stop	
	private var objectEntity			: CEntity;
	private var switchOn				: bool;
	private var switchAnimationType		: PhysicalSwitchAnimationType;
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		//holster weapons
		//thePlayer.OnMeleeForceHolster( true );
		thePlayer.OnRangedForceHolster( true );
		parent.BlockAction( EIAB_DrawWeapon, 'Interaction', false );
		
		
		//interaction handled in syncManager
		//this.SetInteractionComponent( false );
		
		// Intall movement timer
		parent.AddTimer( 'InputCheckDelay', 0.5f, true, false, TICK_PrePhysics );
		parent.AddTimer( 'ApproachTimeout', 4.0f );
		
		InitStateApproachInteraction(prevStateName);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		// Remove movement timer
		parent.RemoveTimer( 'InputCheck', TICK_PrePhysics );
		
		//this.SetInteractionComponent( true );
		parent.UnblockAction( EIAB_DrawWeapon, 'Interaction' );
		super.OnLeaveState(nextStateName);
	}
	
	entry function InitStateApproachInteraction( prevStateName : name )
	{
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var toObjectEntity		: Vector;
		var moveToPosition		: Vector;
		var moveToRotation		: EulerAngles;
		var parentPosition		: Vector;
		var parentRadius		: float;
		
		
		parent.LockEntryFunction( true );
		
		//move to intreaction entity
		if(objectEntity)
		{
			parentPosition 	= parent.GetWorldPosition();
			parentRadius 	= parent.GetRadius();
			toObjectEntity 	= parentPosition - objectEntity.GetWorldPosition();
			
			if ( VecLength2D( toObjectEntity ) > 0.8341f )
			{
				moveToRotation = objectEntity.GetWorldRotation();
				moveToPosition = objectEntity.GetWorldPosition() - 0.8341 * VecNormalize( VecFromHeading( moveToRotation.Yaw +180 )) - 0.13 * VecNormalize( VecFromHeading( moveToRotation.Yaw + 90 ));
				
				parent.GetVisualDebug().AddSphere( 'approachInteractionPos', parentRadius, moveToPosition, true, Color( 255, 0, 0 ), 3.f );
				
				if ( theGame.GetWorld().NavigationLineTest( parentPosition, moveToPosition, parentRadius ) && 
					 theGame.GetWorld().NavigationCircleTest( moveToPosition, parentRadius ))
				{
					//we should go to object point with ~1 meter of tolerance radius
					//movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
					//ticket = movementAdjustor.CreateNewRequest( 'ApproachInterraction' );
					//movementAdjustor.RotateTo( ticket, VecHeading( moveToPosition - parentPosition ));
					parent.ActionMoveTo( moveToPosition, MT_Walk, 0.001, 0.3 );
				}
			}
		}
		
		//after approach ends, play sync animation
		PlaySyncInteractionAnimation();
		
		parent.LockEntryFunction( false );
		StopApproach();
	}
	
	public function SetObjectPointHeading(head : float, obj : CEntity )
	{
		objectPointHeading 	= head;
		objectEntity 		= obj;
	}
	
	public function SetSyncInteractionAnimation( on : bool, switchType : PhysicalSwitchAnimationType )
	{
		switchOn 			= on;
		switchAnimationType = switchType;
	}
	
	public function PlaySyncInteractionAnimation()
	{
		switch( switchAnimationType )
		{
			case PSAT_Lever:
			
			if ( switchOn )
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOff', thePlayer, objectEntity );
			else
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOn', thePlayer, objectEntity );
			break;
				
			case PSAT_Button:	
			
			if ( switchOn )
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOff', thePlayer, objectEntity );
			else
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOn', thePlayer, objectEntity );
			break;
		}
	}
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		
		ret = virtual_parent.OnReactToBeingHit( damageAction );
		parent.LockEntryFunction( false );
		StopApproach();
		return ret;
	}
	
	private function SetInteractionComponent( b : bool )
	{
		var component : CComponent;
		
		if ( objectEntity )
			component = objectEntity.GetComponentByClassName( 'CInteractionComponent' );
			
		if ( component )
			component.SetEnabled( b );
	}
	
	/////////////////////////////////////////  DEINIT  /////////////////////////////////////////////////////
	private function StopApproach()
	{
		parent.PopState(true);		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Movement
	
	
	// allows approach interruption on input from axis
	timer function InputCheckDelay( timeDelta : float, id : int )
	{
		parent.AddTimer( 'InputCheck', 0.001, true, false, TICK_PrePhysics );
	}
	
	// allows approach interruption on input from axis
	timer function InputCheck( timeDelta : float, id : int )
	{
		var action : EActorActionType;
		
		// Calculate player speed and rotation angle
		if ( parent.GetIsMovable() )
		{
			action = parent.GetCurrentActionType();
			
			if ( action != ActorAction_None )
			{
				if( theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY') != 0 )
				{
					//thePlayer.SignalGameplayEvent( 'StopPlayerActionOnInput' );
					parent.LockEntryFunction( false );
					StopApproach();
				}
			}
		}
	}
	// failsafe for cases when ActionMoveTo fails makes player stuck
	timer function ApproachTimeout( timeDelta : float, id : int )
	{
		// play sync anim after timeout
		PlaySyncInteractionAnimation();
		parent.LockEntryFunction( false );
		StopApproach();
	}
};
