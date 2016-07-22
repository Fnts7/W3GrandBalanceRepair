/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CPhysicsWorld
/** Copyright © 2009 CD Projekt RED
/***********************************************************************/

import function PhysxDebugger( host : string ) : bool;

/*
	triggerObject will receive collision events. If receiverObject is set instead it will receive events. onEventName - ?	
	Sent event is:
	event OnCollision(collidedWith : CObject, actorIndex : int, shapeIndex : int);
		collidedWith - NULL when colliding with terrain.
*/
import function SetPhysicalEventOnCollision( triggerObject : CComponent, optional receiverObject : CObject, optional onEventName : name ) : bool;
import function SetPhysicalEventOnTriggerFocusFound( triggerObject : CComponent, optional receiverObject : CObject, optional onEventName : name ) : bool;
import function SetPhysicalEventOnTriggerFocusLost( triggerObject : CComponent, optional receiverObject : CObject, optional onEventName : name ) : bool;


exec function Pvd( host : string ) : bool
{
	return PhysxDebugger( host );
}