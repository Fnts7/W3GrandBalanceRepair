/***********************************************************************/
/** Copyright © 2013
/** Author : Carl Granberg
/***********************************************************************/

// -: IMPORTANT :-
// the "new" door system is work in progress. Don't use until
// after the W2 doors (CDoor, CDoorAttachment etc.) and the scripted temp doors
// (W3Door, W3LockableItem) has been refactored and removed.

import class CDoorComponent extends CInteractionComponent
{	
	import function Open( force : bool, unlock : bool );	
	import function Close( force : bool );

	import function IsOpen() : bool;
	import function IsLocked() : bool;
	
	import function AddForceImpulse( origin : Vector, force : float );	
	import function InstantClose();
	import function InstantOpen( unlock : bool );
	import function AddDoorUser( actor : CActor );
	import function EnebleDoors( enable : bool );
	import function IsInteractive( ) : bool;
	import function IsTrapdoor( ) : bool;	
	import function InvertMatrixForDoor( m : Matrix ) : Matrix;	// Only for doors because this invert function is very expensive and usage should be limited
	import function Unsuppress();
}