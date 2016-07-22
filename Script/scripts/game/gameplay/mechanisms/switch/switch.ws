/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

enum ESwitchState
{
	SS_Undefined,
	SS_Off,
	SS_SwitchingOn,
	SS_On,
	SS_SwitchingOff,
}

enum EResetSwitchMode
{
	RSM_Default,
	RSM_Current,	
	RSM_True,
	RSM_False
}

abstract class W3Switch extends CGameplayEntity
{
	editable  			var isInitiallyEnabled		: bool;				default isInitiallyEnabled		= true;	
	editable  			var isInitiallyLocked		: bool;
	editable  			var isInitiallyOn			: bool;
	//editable 			var canBeActivatedByPlayer	: bool;				default canBeActivatedByPlayer	= true;
	//editable 			var canBeActivatedByNPC		: bool;
	//editable			var canBeOnlyTurnedOn		: bool;				default canBeOnlyTurnedOn = false;
	editable		 	var maxUseCount				: int;				default maxUseCount = -1;
	editable saved 		var skipEventsAtBeginning	: bool;				default skipEventsAtBeginning = true;
	editable inlined 	var whenOnEvents			: array< W3SwitchEvent >;
	editable inlined 	var whenOffEvents			: array< W3SwitchEvent >;
	editable inlined 	var whenSwitchedEvents		: array< W3SwitchEvent >;
	
	protected saved		var currentState			: ESwitchState;		default currentState			= SS_Undefined;
	protected saved		var enabled					: bool;				default enabled					= true;
	protected saved		var locked					: bool;
	protected saved 	var totalUseCount			: int;
	protected saved		var skipEvents				: bool;
	//protected saved		var virtualSwitchesLinked	: array< W3VirtualSwitch >;
	protected saved		var virtualSwitchesLinkedHandle	: array< EntityHandle >;
	protected saved 	var lastActivatorHandle 	: EntityHandle;	
	protected			var restoreUsableItemL		: bool;
	
	const				var BEH_ON					: float;			default BEH_ON					= 10;			//to prevent the behavior from reading 0/1 when the value is not yet initialized
	const				var BEH_OFF					: float;			default BEH_OFF					= 11;			//to prevent the behavior from reading 0/1 when the value is not yet initialized
	const				var BEH_ON_FROM_OFF			: float;			default BEH_ON_FROM_OFF			= 20;			//to prevent the behavior from reading 0/1 when the value is not yet initialized
	const				var BEH_OFF_FROM_ON			: float;			default BEH_OFF_FROM_ON			= 21;			//to prevent the behavior from reading 0/1 when the value is not yet initialized
	
	function __PrintState( optional prefix : bool )
	{
		if ( prefix )
		{
			LogChannel( 'NewSwitch', "  " + GetName() + " new state: " + currentState );
		}
		else
		{
			LogChannel( 'NewSwitch', GetName() + " new state: " + currentState );
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		__PrintState();
		
		if( !spawnData.restored )
		{
			// since default value seem to not always work, set undefined state manually
			currentState = SS_Undefined;
			Reset( RSM_Default, RSM_Default, RSM_Default, true, skipEventsAtBeginning );
		}
		else
		{
			RestoreAfterSave();
		}
	}

	event OnAnimSwitchedOff()
	{
		currentState = SS_Off;
		__PrintState( true );

		if ( skipEvents )
		{
			skipEvents = false;
		}
		else
		{
			ActivateEvents( whenOffEvents );
			ActivateEvents( whenSwitchedEvents );
			NotifyVirtualSwitches();
		}
		EntityHandleSet( lastActivatorHandle, NULL );
		
		if ( restoreUsableItemL )
		{
			thePlayer.OnUseSelectedItem();
		}
	}

	event OnAnimSwitchingOn()
	{
		currentState = SS_SwitchingOn;
		__PrintState( true );
	}

	event OnAnimSwitchedOn()
	{
		currentState = SS_On;
		__PrintState( true );

		if ( skipEvents )
		{
			skipEvents = false;
		}
		else
		{
			ActivateEvents( whenOnEvents );
			ActivateEvents( whenSwitchedEvents );
			NotifyVirtualSwitches();
		}
		EntityHandleSet( lastActivatorHandle, NULL );
		if ( restoreUsableItemL )
		{
			thePlayer.OnUseSelectedItem();
		}
	}

	event OnAnimSwitchingOff()
	{
		currentState = SS_SwitchingOff;
		__PrintState( true );
	}
	
	event OnManageSwitch( operations : array< ESwitchOperation >, force : bool, skipEvents : bool )
	{
		var i, size : int;
		size = operations.Size();
		for ( i = 0; i < size; i += 1 )
		{
			switch ( operations[ i ] )
			{
			case SO_TurnOn:
				Turn( true, thePlayer, force, skipEvents );
				break;
			case SO_TurnOff:
				Turn( false, thePlayer, force, skipEvents );
				break;
			case SO_Toggle:
				Toggle( thePlayer, force, skipEvents );
				break;
			case SO_Reset:
				Reset( RSM_Default, RSM_Default, RSM_Default, force, skipEvents );
				break;
			case SO_Enable:
				Enable( true );
				break;
			case SO_Disable:
				Enable( false );
				break;
			case SO_Lock:
				Lock( true );
				break;
			case SO_Unlock:
				Lock( false );
				break;
			}
		}
	}

	public function Reset( optional enable : EResetSwitchMode, optional lock : EResetSwitchMode, optional on : EResetSwitchMode, optional force : bool, optional skipEvents : bool )
	{
		totalUseCount = 0;
	
		// enable
		if ( enable == RSM_Default )
		{
			enabled = isInitiallyEnabled;
		}
		else if ( enable == RSM_True )
		{
			enabled = true;
		}
		else if ( enable == RSM_False )
		{
			enabled = false;
		}
		
		// lock
		if ( lock == RSM_Default )
		{
			Lock(isInitiallyLocked);
		}
		else if ( lock == RSM_True )
		{
			Lock(true);
		}
		else if ( lock == RSM_False )
		{
			Lock(false);
		}
		
		if ( on == RSM_Default )
		{
			if ( isInitiallyOn )
			{
				Turn( true, NULL, force, skipEvents );
			}
			else
			{
				Turn( false, NULL, force, skipEvents );
			}
		}
		else if ( on == RSM_True )
		{
			Turn( true, NULL, force, skipEvents );
		}
		else if ( on == RSM_False )
		{
			Turn( false, NULL, force, skipEvents );
		}
	}
	
	public function RestoreAfterSave()
	{
		var prevState : ESwitchState;
		
		LogChannel('NewSwitch', "RestoreAfterSave " + currentState + " " + enabled + " " + locked );
		
		prevState = currentState;
	
		// need to clear state to run right functions in Turn()
		switch( currentState )
		{
		case SS_Undefined:
			LogAssert( false, "Switch shouldn't have undefined state after loading" );
			// fallback for broken saves -> SS_Off
			Turn( false, NULL, true, true );
			break;
		case SS_Off:
			currentState = SS_Undefined; 
			Turn( false, NULL, true, true );
			break;
		case SS_SwitchingOff:
			currentState = SS_Undefined;
			Turn( false, NULL, true, skipEvents ); // savegame during switch being turned on/off, this could be tested
			break;
		case SS_On:
			currentState = SS_Undefined;
			Turn( true, NULL, true, true );
			break;
		case SS_SwitchingOn:
			currentState = SS_Undefined;
			Turn( true, NULL, true, skipEvents ); // savegame during switch being turned on/off, this could be tested
			break;
		}
		
		if( ( currentState == SS_Undefined ) && ( prevState != SS_Undefined ) )
		{
			currentState = prevState;
			if( currentState == SS_SwitchingOff )
			{
				currentState = SS_Off;
			}
			else if( currentState == SS_SwitchingOn )
			{
				currentState = SS_On;
			}
		}
	}

	// in case of changing this function, make sure to apply changes to overridden Turn in virtualSwitch.ws
	public function Turn( on : bool, actor : CActor, force : bool, skipEvents : bool )
	{
		var wasTurned : bool;
		
		wasTurned = false;

		if ( IsAvailable() || force )
		{
			if ( on && ( IsOff() || IsUndefined() ) )
			{
				SetBehaviorVariable( 'SwitchState', BEH_ON );
				wasTurned = true;
			}
			else if ( !on && ( IsOn() || IsUndefined() ) )
			{
				SetBehaviorVariable( 'SwitchState', BEH_OFF );
				wasTurned = true;
			}
		}
		
		if ( wasTurned )
		{
			ProcessPostTurnActions( force, skipEvents );
			EntityHandleSet( lastActivatorHandle, actor );
		}
	}

	public function ProcessPostTurnActions( force : bool, skip : bool )
	{
		skipEvents = skip;
		if ( !force )
		{
			totalUseCount += 1;
			if ( IsUseCountReached() )
			{
				Enable( false );
			}
		}
	}

	public function Toggle( actor : CActor, force : bool, skip : bool )
	{
		if ( IsOn() )
		{
			Turn( false, actor, force, skip );
		}
		else if ( IsOff() )
		{
			Turn( true, actor, force, skip );
		}
		else
		{
			// switching, add action to queue?
		}
	}

	public function Enable( enable : bool )
	{
		enabled = enable;
	}

	public function Lock( lock : bool )
	{
		locked = lock;
		
		GetComponent("Locked").SetEnabled(lock);
		GetComponent("Unlocked").SetEnabled(!lock);		
	}
	
	public function IsEnabled() : bool
	{
		return enabled;
	}
	
	public function IsLocked() : bool
	{
		return locked;
	}
	
	public function IsOn() : bool
	{
		return currentState == SS_On;
	}
	
	public function IsOff() : bool
	{
		return currentState == SS_Off;
	}

	public function IsSwitchingOn() : bool
	{
		return currentState == SS_SwitchingOn;
	}
	
	public function IsSwitchingOff() : bool
	{
		return currentState == SS_SwitchingOff;
	}

	public function IsUndefined() : bool
	{
		return currentState == SS_Undefined;
	}
	
	public function IsUseCountReached() : bool
	{
		if ( maxUseCount < 0 )
		{
			return false;
		}
		return totalUseCount >= maxUseCount;
	}

	public function IsAvailable() : bool
	{
		return IsEnabled() && !IsLocked() && !IsUseCountReached();
	}

	public function AddLinkToVirtualSwitch( virtual : W3VirtualSwitch )
	{
		var localHandle : EntityHandle;
		
		if ( virtual )
		{
			EntityHandleSet( localHandle, virtual );
			virtualSwitchesLinkedHandle.PushBack( localHandle );
		}
	}

	public function NotifyVirtualSwitches()
	{
		var i, size : int;
		var virtualSwitchLinked : W3VirtualSwitch;
		
		size = virtualSwitchesLinkedHandle.Size();
		for( i = 0; i < size; i += 1 )
		{
			virtualSwitchLinked = (W3VirtualSwitch)EntityHandleGet( virtualSwitchesLinkedHandle[i] );
			virtualSwitchLinked.Notify( this );
		}
	}
	
	protected function ActivateEvents( events : array< W3SwitchEvent > )
	{
	
		var i, size : int;
		var lastActivator : CActor;
		
		
		size = events.Size();
		for( i = 0; i < size; i += 1 )
		{
			if ( events[ i ] )
			{
				lastActivator = (CActor)EntityHandleGet( lastActivatorHandle );
				events[ i ].TriggerArgNode( this, lastActivator );
			}
		}
	}
}

function GetSwitchByTag( tag : name ) : W3Switch
{
	var entity			: CEntity;
	var switchEntity	: W3Switch;

	entity = theGame.GetEntityByTag( tag );
	if ( !entity )
	{
		LogAssert(false, "No entity found with tag <" + tag + ">" );
		return NULL;
	}
	switchEntity = (W3Switch)entity;
	if ( !switchEntity )
	{
		LogAssert(false, "Entity with tag <" + tag + "> is not a W3Switch" );
		return NULL;
	}
	return switchEntity;
}
