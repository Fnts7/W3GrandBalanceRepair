/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CDebugAttributesManager
/** Copyright © 2012
/***********************************************************************/

// In order to get access to this class just call 'theDebug'
import class CDebugAttributesManager extends CObject
{
	// Add an attribute that you can modify in runtime through 'Dynamic Attributes' debug page.
	// 'debugName' is the name that you will see in the debug page
	// 'propertyName' is the exact name of the attribute you want to access
	// 'context' is the instance of a class who's member is the accessed property
	// NOTE: 'debugName' MUST be unique for all attributes in the same group
	// return values:
	//	- false if the property is not a member of context or if context is NULL or if 'debugName' is already used within group
	//	- true if succesfully added to pool
	
	// KNOWN ISSUES:
	// If you pass 'this' keyword as the 'context' you will get an assertion telling you
	// that the 'context' is NULL. Its really minor so i'll leave it that way for now.
	// The easiest workaround for this:
	//		var someVar : CClassName = this; and pass the 'someVar' instead of 'this'
	import final function AddAttribute( debugName : name, propertyName : name, context : IScriptable, optional groupName : name ) : bool;
}

//Example usage
exec function AT()
{
	// unfortunately you cannot use tokens such as 'thePlayer', 'theGame' yet.
	var player : CPlayer;
	player = thePlayer;
	
	theDebug.AddAttribute( 'bUseRunLSHold', 'bUseRunLSHold', player );
	theDebug.AddAttribute( 'bUseRunLSToggle', 'bUseRunLSToggle', player );
	theDebug.AddAttribute( 'bForcedCombat', 'bForcedCombat', player );
	// Same name different group
	theDebug.AddAttribute( 'PlayerHealth', 'initialHealth', player, 'InitialValues' );
	// Easy as this :)
}