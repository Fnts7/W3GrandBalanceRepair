/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera, Andrzej Kwiatkowski
/***********************************************************************/

class W3InteractionSwitch extends W3PhysicalSwitch
{
	protected var isActivatedByPlayer		: bool;			
	editable var focusModeHighlight			: EFocusModeVisibility;
	
	default isActivatedByPlayer				= false;
	default focusModeHighlight 				= FMV_None;
	
	editable var interactionActiveInState 	: ESwitchState;
	default interactionActiveInState		= SS_Undefined;	
	hint interactionActiveInState = "State for which interaction is possible. If set to SS_Undefined, there's no restriction.";
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		UpdateInteractionComponent( GetComponent( "Unlocked" ) );
		UpdateFocusModeHighlight();
		
		AddAnimEventCallback('SwitchOnEvent',	'OnAnimEvent_SwitchOnEvent');
		AddAnimEventCallback('SwitchOffEvent',	'OnAnimEvent_SwitchOffEvent');
	}

	public function Enable( enable : bool )
	{
		super.Enable( enable );
		
		UpdateInteractionComponent( GetComponent( "Unlocked" ) );
		UpdateFocusModeHighlight();		
	}
	
	public function Lock( lock : bool )
	{
		var hud : CR4ScriptedHud;
		
		super.Lock( lock );
		
		if ( isActivatedByPlayer )
		{
			// when interaction is active during locking/unlocking switch, we need to change interaction icon
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.ForceInteractionUpdate();
			}
		}
	}
	
	public function InteractWith( on : bool, switchType : PhysicalSwitchAnimationType )
	{
		var inteactionState				: W3PlayerWitcherStateApproachInteractionState;
		var vecToObject 				: Vector;
		var heading						: float;
		
		//thePlayer.GotoState( 'ApproachInteractionState' );
		
		vecToObject = this.GetWorldPosition() - thePlayer.GetWorldPosition();
		heading = VecHeading( vecToObject );
		inteactionState = ( W3PlayerWitcherStateApproachInteractionState )thePlayer.GetState( 'ApproachInteractionState' );
		inteactionState.SetObjectPointHeading( heading, this );
		inteactionState.SetSyncInteractionAnimation( on, switchType );
		
			//hide usable item
		if (thePlayer.IsHoldingItemInLHand())
		{
			thePlayer.HideUsableItem(true);
			restoreUsableItemL = true;
		}
		
		thePlayer.GotoState( 'ApproachInteractionState' );// true );
	}
	
	function UpdateInteractionComponent( optional component : CComponent )
	{
		if ( !component )
		{
			component = GetComponent( 'CInteractionComponent' );
		}
		if ( component )
		{
			component.SetEnabled( enabled );
		}
	}
	
	event OnInteractionAttached( interaction : CInteractionComponent )
	{
		UpdateInteractionComponent( interaction );
	}
	
	function UpdateFocusModeHighlight()
	{
		if ( enabled )
		{
			SetFocusModeVisibility( focusModeHighlight );
		}
		else
		{
			SetFocusModeVisibility( FMV_None );
		}	
	}

	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			isActivatedByPlayer = true;
		}
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			isActivatedByPlayer = false;
		}
	}
	
	event OnInteraction( interactionComponentName : string, activator : CEntity )
	{
		var switchEntity : CEntity;
		var toSwitchEntity : Vector;
		
		if ( IsLocked() )
		{
			GetWitcherPlayer().DisplayHudMessage("panel_hud_message_just_locked");
		}
		else 
		{
			if ( IsOn() )
			{
				if ( switchOffAnimationType == PSAT_Undefined )
				{
					Toggle( (CActor)activator, false, false );
				}
				else
				{
					InteractWith( true, switchOffAnimationType );
					//AK: moved to syncManager, since we don't know if player changed switch state until sync anim is started
					//ProcessPostTurnActions( false, false );
					EntityHandleSet( lastActivatorHandle, thePlayer );
				}
			}
			else if ( IsOff() )
			{
				if ( switchOffAnimationType == PSAT_Undefined )
				{
					Toggle( (CActor)activator, false, false );
				}
				else
				{
					InteractWith( false, switchOffAnimationType );
					//AK: moved to syncManager, since we don't know if player changed switch state until sync anim is started
					//ProcessPostTurnActions( false, false );
					EntityHandleSet( lastActivatorHandle, thePlayer );
				}
			}
		}
		
		/*
		if ( IsOn() )
		{
			if ( switchOffAnimationType == PSAT_Lever )
			{
				InteractWith( true, PSAT_Lever );
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOff', thePlayer, this );
				//ProcessPostTurnActions( false, false );
				EntityHandleSet( lastActivatorHandle, thePlayer );
			}
			else if ( switchOffAnimationType == PSAT_Button )
			{
				InteractWith( true, PSAT_Button );
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOff', thePlayer, this );
				//ProcessPostTurnActions( false, false );
				EntityHandleSet( lastActivatorHandle, thePlayer );
			}
			else
			{
				Toggle( (CActor)activator, false, false );
			}
		}
		else if ( IsOff() )
		{
			if ( switchOnAnimationType == PSAT_Lever )
			{
				InteractWith( false, PSAT_Lever );
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchLeverOn', thePlayer, this );
				//ProcessPostTurnActions( false, false );
				EntityHandleSet( lastActivatorHandle, thePlayer );
			}
			else if ( switchOnAnimationType == PSAT_Button )
			{
				InteractWith( false, PSAT_Button );
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'SwitchButtonOn', thePlayer, this );
				//ProcessPostTurnActions( false, false );
				EntityHandleSet( lastActivatorHandle, thePlayer );
			}
			else
			{
				Toggle( (CActor)activator, false, false );
			}
		}
		*/
		/*
		if ( IsOn() || IsOff() )
		{
			Toggle( (CActor)activator, false, false );
		}
		*/	
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( interactionActiveInState != SS_Undefined && interactionActiveInState != currentState )
		{
			return false;
		}
		
		if( activator == thePlayer )
		{
			if( IsEnabled() )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}
	
	event OnAnimEvent_SwitchOnEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'SwitchState', BEH_ON_FROM_OFF );
	}
	event OnAnimEvent_SwitchOffEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetBehaviorVariable( 'SwitchState', BEH_OFF_FROM_ON );
	}
};
