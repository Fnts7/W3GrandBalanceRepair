/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Movement Adjustor
/** Copyright © 2013 
/***********************************************************************/

// ----------------------------------------------------------------------
// Movement adjustment notifies (a list)
// ----------------------------------------------------------------------

/*
enum EMovementAdjustmentNotify
{
	MAN_None, // always have default value!
	MAN_LocationAdjustmentReachedDestination,
	MAN_RotationAdjustmentReachedDestination,
	MAN_AdjustmentEnded,
	MAN_AdjustmentCancelled,
	// ask programmer for more if you need them! :)
};
*/

// ----------------------------------------------------------------------
// Movement adjustment request ticket
// ----------------------------------------------------------------------

import struct SMovementAdjustmentRequestTicket {};

// ----------------------------------------------------------------------
// Movement adjustor
//
//		Movement adjustor is used to adjust location/rotation
//		of moving character to match requested result.
//
//		When animation contains movement and adjustment should be
//		short and leave character to animate properly afterwards,
//		synchronization point should be used.
//		It is "AdjustmentSyncPoint" simple event placed on timeline.
// ----------------------------------------------------------------------
import class CMovementAdjustor extends CObject
{
	// check if request is still active
	import final function IsRequestActive( ticket : SMovementAdjustmentRequestTicket ) : bool;

	// check if there are any active adjustment requests
	import final function HasAnyActiveRequest() : bool;
	import final function HasAnyActiveRotationRequests() : bool;
	import final function HasAnyActiveTranslationRequests() : bool;
	
	// cancel specific request
	import final function Cancel( ticket : SMovementAdjustmentRequestTicket );
	// cancel request(s) by name
	import final function CancelByName( requestName : name );
	// cancel all requests
	import final function CancelAll();
	
	// create new resuest. returns ticket that is used to identify request and manipulate it
	import final function CreateNewRequest( optional requestName : name ) : SMovementAdjustmentRequestTicket;
	// find request using given name
	import final function GetRequest( requestName : name ) : SMovementAdjustmentRequestTicket;

	// one frame translation/rotation
	import final function AddOneFrameTranslationVelocity( translationVelocity : Vector );
	import final function AddOneFrameRotationVelocity( rotationVelocity : EulerAngles );
	
	// helper functions that set parameters of adjustment (with ticket)
	
	// define blending in time
	import final function BlendIn( ticket : SMovementAdjustmentRequestTicket, blendInTime : float );

	// keep adjustment active for given time
	import final function KeepActiveFor( ticket : SMovementAdjustmentRequestTicket, duration : float );
	// adjustment should take exactly given amount of time (it will try to reach target value right at end of that time)
	import final function AdjustmentDuration( ticket : SMovementAdjustmentRequestTicket, duration : float );
	// adjustment will be continuous and will use top possible speed
	import final function Continuous( ticket : SMovementAdjustmentRequestTicket );
	// adjustment won't end automatically - it will require manual cancelling
	import final function DontEnd( ticket : SMovementAdjustmentRequestTicket );

	// actor or target is baded on node and it should be taken into account (use for adjusting against other entity)
	import final function BaseOnNode( ticket : SMovementAdjustmentRequestTicket, onNode : CNode );
	
	// binds adjustment to event, helps if ticking order issues and doesn't require updating source animation each frame
	import final function BindToEvent( ticket : SMovementAdjustmentRequestTicket, eventName : name, optional adjustDurationOnNextEvent : bool );
	// as above, plus sets up adjustment duration (if bindOnly is not requested)
	import final function BindToEventAnimInfo( ticket : SMovementAdjustmentRequestTicket, animInfo : SAnimationEventAnimInfo, optional bindOnly : bool );

	// instead of doing plain slide or plain rotation, try to scale movement/rotation from animation
	import final function ScaleAnimation( ticket : SMovementAdjustmentRequestTicket, optional scaleAnimation : bool, optional scaleLocation : bool, optional scaleRotation : bool );
	// as above, but seperately for vertical adjustment
	import final function ScaleAnimationLocationVertically( ticket : SMovementAdjustmentRequestTicket, optional scaleAnimationLocationVertically : bool );

	// dont use source animation (delta seconds from event, delta location/rotation)
	import final function DontUseSourceAnimation( ticket : SMovementAdjustmentRequestTicket, optional dontUseSourceAnimation : bool );
	// give information about current state of source animation (deltas will be read from there, as well as "AdjustmentSyncPoint")
	import final function UpdateSourceAnimation( ticket : SMovementAdjustmentRequestTicket, animInfo : SAnimationEventAnimInfo );
	// if no source animation update comes next frame, cancel request
	import final function CancelIfSourceAnimationUpdateIsNotUpdated( ticket : SMovementAdjustmentRequestTicket, optional cancelIfSourceAnimationUpdateIsNotUpdated : bool );
	// use different sync point time in animation than event's end time (will overwrite "AdjustmentSyncPoint")
	import final function SyncPointInAnimation( ticket : SMovementAdjustmentRequestTicket, optional syncPointTime : float );
	
	// use bone as operator for adjustment at sync point or continuously (by default only for location adjustment)
	// unless you are really sure about what you are doing, continuously update should be the same as if whole adjustment is continuous or not
	// useBoneToMatchTargetHeadingWeight = 0.0 means that when facing node (or heading) bone location will be used to point at node (or heading) (use it to face object from current location - eg. attacker)
	// useBoneToMatchTargetHeadingWeight = 1.0 means that bone's rotation will match node's heading (or requested heading) (use it to be in sync with other object - eg. victim)
	// values between can, but should not be used
	import final function UseBoneForAdjustment( ticket : SMovementAdjustmentRequestTicket, optional boneName : name, optional useContinuously : bool, optional useBoneForLocationAdjustmentWeight : float, optional useBoneForRotationAdjustmentWeight : float, optional useBoneToMatchTargetHeadingWeight : float );

	// match entity's slot's location and rotation
	import final function MatchEntitySlot( ticket : SMovementAdjustmentRequestTicket, entity : CEntity, slotName : name );
	
	// pretend that location adjustment is still active (for example to override any translation)
	import final function KeepLocationAdjustmentActive( ticket : SMovementAdjustmentRequestTicket );
	// replace translation data from behavior graph with adjustment
	import final function ReplaceTranslation( ticket : SMovementAdjustmentRequestTicket, optional replaceTranslation : bool );
	// at the beginning of adjustment it should be at given location
	import final function ShouldStartAt( ticket : SMovementAdjustmentRequestTicket, atLocation : Vector );
	// slide to given location
	import final function SlideTo( ticket : SMovementAdjustmentRequestTicket, targetLocation : Vector );
	// slide by vector
	import final function SlideBy( ticket : SMovementAdjustmentRequestTicket, byVector : Vector );
	// slide towards node (keep distance)
	import final function SlideTowards( ticket : SMovementAdjustmentRequestTicket, node : CNode, optional minDistance : float, optional maxDistance : float );
	// slide to entity's bone
	import final function SlideToEntity( ticket : SMovementAdjustmentRequestTicket, entity : CEntity, optional boneName : name, optional minDistance : float, optional maxDistance : float );
	// setup max speed for location adjustment
	import final function MaxLocationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, maxSpeed : float, optional maxSpeedZ : float );
	// setup max distance for for location adjustment (and to allow limiting it through speed)
	import final function MaxLocationAdjustmentDistance( ticket : SMovementAdjustmentRequestTicket, optional throughSpeed : bool, optional locationAdjustmentMaxDistanceXY : float, optional locationAdjustmentMaxDistanceZ : float );
	// allow vertical adjustment
	import final function AdjustLocationVertically( ticket : SMovementAdjustmentRequestTicket, optional adjustLocationVertically : bool );
	
	// pretend that rotation adjustment is still active (for example to override any rotation)
	import final function KeepRotationAdjustmentActive( ticket : SMovementAdjustmentRequestTicket );
	// replace rotation data from behavior graph with adjustment
	import final function ReplaceRotation( ticket : SMovementAdjustmentRequestTicket, optional replaceRotation : bool );
	// at the beginning of adjustment it should be facing heading
	import final function ShouldStartFacing( ticket : SMovementAdjustmentRequestTicket, targetHeading : Float );
	// rotate to heading
	import final function RotateTo( ticket : SMovementAdjustmentRequestTicket, targetHeading : Float );
	// rotate by angle
	import final function RotateBy( ticket : SMovementAdjustmentRequestTicket, byHeading : Float );
	// rotate towards node with offset (eg. to allow rotating away)
	import final function RotateTowards( ticket : SMovementAdjustmentRequestTicket, node : CNode, optional offsetHeading : Float );
	// match move rotation requested by steering/locomotion
	import final function MatchMoveRotation( ticket : SMovementAdjustmentRequestTicket );
	// setup max speed for rotation adjustment
	import final function MaxRotationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, rotationAdjustmentMaxSpeed : Float );
	// max speed rotation adjustment may be overriden by steering (if requested by steering)
	import final function SteeringMayOverrideMaxRotationAdjustmentSpeed( ticket : SMovementAdjustmentRequestTicket, optional steeringMayOverrideMaxRotationAdjustmentSpeed : Bool );
	
	// character should move in specified direction only (delta location will be forced to point in that direction)
	import final function LockMovementInDirection( ticket : SMovementAdjustmentRequestTicket, heading : Float );
	// rotate existing delta location to fulfill desired rotation (not limited)
	import final function RotateExistingDeltaLocation( ticket : SMovementAdjustmentRequestTicket, optional rotateExistingDeltaLocation : Bool );
	
	// notify script object's event when something particular (defined with EMovementAdjustmentNotify) happens event method should have parameters: event OnSomething( requestName : name, notify : EMovementAdjustmentNotify );
	import final function NotifyScript( ticket : SMovementAdjustmentRequestTicket, notifyObject : IScriptable, eventName : name, notify : EMovementAdjustmentNotify );
	// clear notification of script object's event when something particular (defined with EMovementAdjustmentNotify) happens
	import final function DontNotifyScript( ticket : SMovementAdjustmentRequestTicket, notifyObject : IScriptable, eventName : name, notify : EMovementAdjustmentNotify );

	/** Example, how to use it:
	
		function SlidePlayerByOneMeterInOneSecond()
		{
			var ticket : SMovementAdjustmentRequestTicket;
			var movementAdjustor : CMovementAdjustor;
			var oneMeterDist : Vector;

			oneMeterDist.X = 1.0f;

			movementAdjustor = player.GetMovingAgentComponent().GetMovementAdjustor();
			if (! movementAdjustor.HasAnyActiveRequest())
			{
				ticket = movementAdjustor.CreateNewRequest( 'Example' );
				movementAdjustor.AdjustmentDuration( ticket, 1.0f );
				movementAdjustor.SlideBy( ticket, oneMeterDist );
			}
		}

	 */
};