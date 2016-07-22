///////////////////////////////
//  Copyright © 2016		 //
//	Author: Andrzej Zawadzki //
///////////////////////////////

statemachine class W3WitcherBed extends W3AnimationInteractionEntity
{
	private var m_wasUsed				: bool;
	private var m_wereItemsRefilled		: bool;
	public var m_bedSaveLock			: int;
	
	editable var m_bedLevel	: int; 			// represents level of a bed
	
		hint m_bedLevel = "Represent level of bed";
		
	editable var m_handsIkActive : bool;	// enables IK for hands
	
		hint m_handsIkActive = "Enables IK for hands";
		
	default	interactionAnim = PEA_GoToSleep;
	default focusModeVisibility = FMV_Interactive;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();

		if( activator.GetEntity() == GetWitcherPlayer() )
		{
			mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var l_movingAgentComponent		: CMovingPhysicalAgentComponent;
		
		l_movingAgentComponent = (CMovingPhysicalAgentComponent)((CActor)activator).GetMovingAgentComponent();
		
		if( l_movingAgentComponent.IsOnGround() )
		{
			m_wasUsed = true;
			GotoState( 'Sleep' );
		}
	}
	
	public function GetWasUsed() : bool
	{
		return m_wasUsed;
	}
	
	public function SetWasUsed( b : bool )
	{
		m_wasUsed = b;
	}
	
	public function GetBedLevel() : int
	{
		return m_bedLevel;
	}
	
	public function GetWereItemsRefilled() : bool
	{
		return m_wereItemsRefilled;
	}
	
	public function SetWereItemsRefilled( b : bool )
	{
		m_wereItemsRefilled = b;
	}
	
	public function IsHandsIkActive() : bool
	{
		return m_handsIkActive;
	}
	
	public function EnableHandsIk()
	{
		var l_leftHandSlotValid		: bool;
		var l_leftHandSlotMatrix	: Matrix;
		var l_rightHandSlotValid	: bool;
		var l_rightHandSlotMatrix	: Matrix; 
	
		if ( IsHandsIkActive() )
		{
			l_leftHandSlotValid = CalcEntitySlotMatrix( 'bedLeftHandLocation', l_leftHandSlotMatrix );
			if ( l_leftHandSlotValid )
			{
				thePlayer.SetBehaviorVectorVariable( 'bedLeftHandLocation', MatrixGetTranslation( l_leftHandSlotMatrix ) );
			}
			
			l_rightHandSlotValid = CalcEntitySlotMatrix( 'bedRightHandLocation', l_rightHandSlotMatrix );
			if ( l_rightHandSlotValid )
			{
				thePlayer.SetBehaviorVectorVariable( 'bedRightHandLocation', MatrixGetTranslation( l_rightHandSlotMatrix ) );
			}
			
			thePlayer.SetBehaviorVariable( 'bedIkActive', 1.f );
		}
	}
	
	public function DisableHandsIk()
	{
		if ( IsHandsIkActive() )
		{
			thePlayer.SetBehaviorVariable( 'bedIkActive', 0.f );
		}
	}
}

state Sleep in W3WitcherBed
{
	event OnEnterState( prevStateName : name )
	{		
		theGame.CreateNoSaveLock( "Approaching Bed", parent.m_bedSaveLock, true );
		MovePlayerToBed();
		
		// Enabling hands IK
		parent.EnableHandsIk();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		// Disabling hands IK
		parent.DisableHandsIk();
	}
	
	entry function MovePlayerToBed()
	{
		var l_movAdj 				: CMovementAdjustor; 
		var l_ticket 				: SMovementAdjustmentRequestTicket;
		var l_node					: CNode;
		var l_component				: CComponent;
		var l_HACKmovementCorrector	: CExplorationMovementCorrector;
		var l_buffsHud				: CR4HudModuleBuffs;
		
		// Locking player's ability to rotate while playing animation IF the ubermovement is ON
		l_HACKmovementCorrector = thePlayer.substateManager.m_MovementCorrectorO;
		l_HACKmovementCorrector.disallowRotWhenGoingToSleep = true;		
		
		l_buffsHud = (CR4HudModuleBuffs)theGame.GetHud().GetHudModule( 'BuffsModule' );
		l_buffsHud.SetDisplayBuffs( false );
		
		l_node = parent.GetComponent( "witcherBed_WP_1" );
		
		// Turning interaction off
		l_component = parent.GetComponentByClassName( 'CInteractionComponent' );
		l_component.SetEnabled( false );
		
		thePlayer.OnMeleeForceHolster( false );
		
		if( thePlayer.IsCurrentlyUsingItemL() )
		{
			thePlayer.OnUseSelectedItem();
		}
		
		thePlayer.AddBuffImmunity_AllCritical( 'Bed', true );
		thePlayer.AddBuffImmunity_AllNegative( 'Bed', true );
		
		// Moving player to bed
		thePlayer.BlockAllActions( 'WitcherBed', true,,,,,false );
		thePlayer.ActionMoveToNodeWithHeading( l_node, MT_Walk, 1.f, 0.4f );
		
		// Turning off the collision on bed
		parent.ApplyAppearance( "no_collision" );
		
		thePlayer.RaiseEvent( 'ForceIdle' );
		
		// Adjusting player's position
		l_movAdj = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
		l_ticket = l_movAdj.CreateNewRequest( 'InteractionEntity' );
	
		l_movAdj.AdjustmentDuration( l_ticket, 0.75f );
		l_movAdj.SlideTowards( l_ticket, l_node );	
		l_movAdj.RotateTowards( l_ticket, parent, 40 );

		// Starting 'Going ot Bed' animation
		thePlayer.PlayerStartAction( PEA_GoToSleep );
	}
}

state WakeUp in W3WitcherBed
{	
	event OnEnterState( prevStateName : name )
	{
		var l_component			: CComponent;
		var l_buffsHud			: CR4HudModuleBuffs;
		
		l_buffsHud = (CR4HudModuleBuffs)theGame.GetHud().GetHudModule( 'BuffsModule' );
		l_component = parent.GetComponentByClassName( 'CInteractionComponent' );
		
		l_buffsHud.SetDisplayBuffs( true );
		
		l_component.SetEnabled( true );		
	}
}