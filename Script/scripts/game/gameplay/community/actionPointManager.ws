/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Action Point Manager
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Action Point Manager
/////////////////////////////////////////////
import struct SActionPointId {};

import class CActionPointManager extends CObject
{
	// Returns true if action point has preferred next action points
	import final function HasPreferredNextAPs( currApID : SActionPointId ) : bool;

	// Gets the next action point in sequence
	import final function GetSeqNextActionPoint( currApID : SActionPointId ) : SActionPointId;

	// Gets job tree related to the action point
	import final function GetJobTree( apID : SActionPointId ) : CJobTree;

	// Resets items in the action point
	import final function ResetItems( apID : SActionPointId );
	
	// Gets position, path engine position and rotation of the action point.
	import final function GetGoToPosition( apID : SActionPointId, out placePos : Vector, out placeRot : float ) : bool;

	// Gets position at which the job should be executed
	import final function GetActionExecutionPosition( apID : SActionPointId, out placePos : Vector, out placeRot : float ) : bool;
	
	// Gets friendly name for action point (for debug purposes only)
	import final function GetFriendlyAPName( apID : SActionPointId ) : string;
	
	// Returns true if work in action point with ID 'id' can be interrupted
	import final function IsBreakable( apID : SActionPointId ) : bool;
	
	// Returns true if work in action point with ID 'id' can be interrupted
	import final function GetPlacementImportance( apID : SActionPointId ) : EWorkPlacementImportance;
	
	// Returns true is fireSourceDependent is set to true in the actionPointComponent of an AP entity template
	import final function IsFireSourceDependent( apID : SActionPointId ) : bool;
}

// Assigns an invalid AP ID to the AP ID
import function ClearAPID( out apID : SActionPointId );

// Checks if the specified ap ID is valid
import function IsAPValid( apID : SActionPointId ) : bool;