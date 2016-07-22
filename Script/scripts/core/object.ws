/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Base scriptable class, minimal base class for native classes exposed to scripts
// Contains old CStateMachine functionalty although state machines are not automatic
// To enable state machine functionality for a class use the "statemachine" keyword next to "class"

import class IScriptable extends ISerializable
{
	/////////////////////////////////////////////////////////////
	// State machine related functions

	// Pushes new state on the stack and enters it
	import function PushState( stateName : name );

	// Pops current state from the stack and enters state from the top of the stack
	import function PopState( optional popAll : bool );

	// Changes to given state; optionally pops all other states from stack
	import function GotoState( optional newState : name, optional keepStack : bool, optional forceEvents : bool );

	// Goes to auto/default state i.e. the one specified via autoState variable
	import final function GotoStateAuto();
	
	// Get state by name, low level, use with care
	import final function GetState( stateName : name ) : CScriptableState;

	// Get state this state machine is in
	import final function GetCurrentState() : CScriptableState;

	// Get the name of the state this state machine is in
	import final function GetCurrentStateName() : name;

	// Checks if we're in given state
	import final function IsInState( stateName : name ) : bool;

	// Prevents activation of new entry function or new state
	import final function LockEntryFunction( lock : bool );
	
	// Set cleanup function
	import final function SetCleanupFunction( functionName : name );

	// Clear cleanup function
	import final function ClearCleanupFunction();
	
	// Enables entry function logging
	import final function DebugDumpEntryFunctionCalls( enabled : bool );
	
	// Logs full state stack
	import final function LogStates();

	// Get human readable string description of object
	import function ToString() : string;
}

/////////////////////////////////////////////////////////////
// Legacy CObject - all scripted stuff is still CObject

import class CObject extends IScriptable 
{	
	// Make clone of this object. Warning! Clone position is set to 0,0,0 instead of being cloned!
	import function Clone( newParent : CObject ) : CObject;
	
	// Get parent
	import function GetParent() : CObject;
}