/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// State in a state machine - not a CObject!
/////////////////////////////////////////////

import class CScriptableState extends IScriptable
{
	// Is this state the active one in the state machine
	import function IsActive() : bool;
	// Get the name of this state
	import function GetStateName() : name;

	// Called when we are entering this state
	event OnEnterState( prevStateName : name ) {}
	// Called when we are leaving this state
	event OnLeaveState( nextStateName : name ) {}
	
	// Called to check if this state can be entered
	import function CanEnterState( prevStateName : name ) : bool;
	// Called to check if this tate can be leaved
	import function CanLeaveState( nextStateName : name ) : bool;

	// ---- State change callbacks ---

	// Invoked before state begins
	import function BeginState( prevStateName : name );
	// Invoked before state ends
	import function EndState( nextStateName : name );
	// Invoked on return to state (after other state was popped from the stack)
	import function ContinuedState();
	// Invoked when other state gets pushed on the stack (thus current state gets paused)
	import function PausedState();
}