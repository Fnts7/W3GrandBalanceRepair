import class CPhantomComponent extends CComponent
{
	// Activate
	import final function Activate();
	// Deactivate
	import final function Deactivate();
	// Get triggering collision group names
	import final function GetTriggeringCollisionGroupNames( out names : array< name > );
	// Get number of objects inside
	import final function GetNumObjectsInside(): int;
}