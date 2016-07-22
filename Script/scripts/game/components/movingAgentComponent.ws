/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CMovingAgentComponent
/** Copyright © 2010
/***********************************************************************/

//import struct SPathEngineEmptySpaceQuery
//{
//	import var width : float;						//< Area width
//	import var height : float;						//< Area height
//	import var yaw : float;							//< Yaw (-1.0 means agent yaw for first (zero) test, and random for further tests)
//	import var searchRadius : float;				//< Search radius
//	import var localSearchRadius : float;			//< Local search radius for away path
//	import var maxPathLen : float;					//< Max length of path to center of area
//	import var maxCenterLevelDifference : float;	//< Max level difference to current position
//	import var maxAreaLevelDifference : float;		//< Max difference inside area
//	import var numTests : int;						//< Number of tests (+1 for agent position)
//	import var checkObstaclesLevel : EPathEngineEmptySpaceCollision;	//< Check obstacles level in area test
//	import var useAwayMethod : bool;				//< Path away method of center search
//	import var debug : bool;						//< Debug draw
//};

/*
enum ECharacterPhysicsState
{
	CPS_Simulated,
	CPS_Animated,
	CPS_Falling,
	CPS_Swimming,
	CPS_Ragdoll,
	CPS_Count
};

enum ECollisionSides
{
	CS_FRONT,
	CS_RIGHT,
	CS_BACK,
	CS_LEFT,
	CS_FRONT_LEFT,
	CS_FRONT_RIGHT,
	CS_BACK_RIGHT,
	CS_BACK_LEFT,
	CS_CENTER,
};
*/

import class CMovingAgentComponent extends CAnimatedComponent
{
	//holds up to 8 recent relative speed to amount for speed spikes in GetRelativeSpeedType
	private var relativeSpeedBuffer : array<float>;

	// Sets maximum move rotation speed [deg/s]
	import final function SetMaxMoveRotationPerSec( rotSpeed : float );
	
	// Sets maximum move type
	import final function SetMoveType( moveType : EMoveType );
	
	// Find empty space ( returns -1.0 on error or width of found area )
	// NOT CURRENTLY (RE)IMPLEMNETED
	// ASK PROGRAMMERS (AI TEAM) TO REIMPLEMENT THIS STUFF
	//import final latent function FindEmptySpace( params : SPathEngineEmptySpaceQuery, out outNavMeshPos : Vector, out outYaw : float ) : float;

	// Get effective move speed returned from behavior
	import final function GetCurrentMoveSpeedAbs() : float;
	
	// Teleport actor behind the camera and optionaly continue movement
	import final function TeleportBehindCamera( continueMovement : bool ) : bool;
	
	// Enable combat movement mode
	import final function EnableCombatMode( combat : bool ) : bool;
	
	// Enable/disable virtual controller
	import final function EnableVirtualController( virtualControllerName : CName, enabled : bool );
	
	// Set Virtual Radius with blend
	import final function SetVirtualRadius( radiusName : CName, optional virtualControllerName : CName );
	
	// Set Virtual Radius instantly
	import final function SetVirtualRadiusImmediately( radiusName : CName );	
	
	// Reset Virtual Radius
	import final function ResetVirtualRadius( optional virtualControllerName : CName );
	
	// Set Height
	import final function SetHeight( height : float );
	
	// Reset Height
	import final function ResetHeight();
	
	// Test if agent may move straight to given destination
	import final function CanGoStraightToDestination( destination : Vector ) : bool;
	
	// Test if the specified position is valid in terms of being located on a navmesh
	// and not being obstructed
	import final function IsPositionValid( position : Vector ) : bool;
	
	// Returns the line end point's navmesh position.
	import final function GetEndOfLineNavMeshPosition( pos : Vector, out outPos : Vector ) : bool;
	
	// Checks if one can reach the specified position in a straight line without
	// bumping into anything
	import final function IsEndOfLinePositionValid( position : Vector ) : bool;
	
	// Finds location on path at given distance. Returns false if there is no path or path is shorter than given distance.
	import final function GetPathPointInDistance( distance : float, out position : Vector ) : bool;
	
	// Toggle enabled, restore agent to stored position
	final function SetEnabledRestorePosition( enabled : bool ) : bool
	{
		SetEnabled( enabled );
		if( enabled )
		{
			return IsEnabled();
		}
		else
		{
			return false;
		}
	}
	
	// Returns the current absolute speed (scalar) of the agent in m.s-1
	import final function GetSpeed() : float;
	
	// Returns the current absolute speed (scalar) of the agent ( 1:walk, 2:run etc. )
	import final function GetRelativeMoveSpeed() : float;
	
	// Get the relative speed that matches the given move type
	import final function GetMoveTypeRelativeMoveSpeed( moveType : EMoveType ) : float;
	
	// Set the relative move speed independently of max acceleration 
	import final function ForceSetRelativeMoveSpeed( relativeMoveSpeed : float );
	
	// Set the relative move speed independently of max acceleration 
	import final function SetGameplayRelativeMoveSpeed( relativeMoveSpeed : float );
	
	// Set the direction of the actor 
	import final function SetGameplayMoveDirection( actorDirection : float );
	
	// Only call this when no steering graph is active
	import final function SetDirectionChangeRate( directionChangeRate : float );
		
	// Returns the maximum speed of the agent
	import final function GetMaxSpeed() : float;
	
	// Returns agent's current velocity
	import final function GetVelocity() : Vector;
	
	// Returns agent's velocity based on requested movement (from animation)
	import final function GetVelocityBasedOnRequestedMovement() : Vector;

	import final function AdjustRequestedMovementDirectionPhysics( out directionWS : Vector, out shouldStop : bool, speed : Float, angleToDeflect : Float, freeSideDistanceRequired : Float, out cornerDetected : bool, out portal : bool) : bool;
	import final function AdjustRequestedMovementDirectionNavMesh( out directionWS : Vector, speed : float, maxAngle : float, maxIteration : int, maxIterationStartSide : int, preferedDirection : Vector, optional checkExploration : bool ) : bool;
	import final function StartRoadFollowing( speed : float, maxAngle : float, maxDistance : float, out correctedDirection : Vector ) : bool;
	import final function ResetRoadFollowing();
	
	// Returns agent's position with respect to its active representation
	import final function GetAgentPosition() : Vector;
	
	import final function SnapToNavigableSpace( snap : bool );
	
	import final function IsOnNavigableSpace() : bool;
	
	import final function IsEntityRepresentationForced() : int;
		
	import final function GetLastNavigablePosition() : Vector;
	
	import final function GetMovementAdjustor() : CMovementAdjustor;

	// Predict location of agent basing on currently used animations
	import final function PredictWorldPosition( inTime : float ) : Vector;
	
	// Change the radius of the trigger activator
	import final function SetTriggerActivatorRadius( radius : float );
	
	// Change the height of the trigger activator
	import final function SetTriggerActivatorHeight( height : float );
	
	// Add activator to given trigger channel (activator will start interacting with triggers on this channel)
	import final function AddTriggerActivatorChannel( channel : ETriggerChannels );
	
	// Remove activator from given trigger channel
	import final function RemoveTriggerActivatorChannel( channel : ETriggerChannels );

	// IK for feet (default blendtime is 0.2)
	import final function SetEnabledFeetIK( enable : bool, optional blendTime : float );
	import final function GetEnabledFeetIK() : bool;
	
	// IK for hands
	import final function SetEnabledHandsIK( enable : bool );
	import final function SetHandsIKOffsets( left : float, right : float );
	

	// IK for slope sliding
	import final function SetEnabledSlidingOnSlopeIK( enable : bool );
	import final function GetEnabledSlidingOnSlopeIK() : bool;

	// Entity for pelvis offset - to match other's entity pelvis offset or accommodate it in some other manner
	import final function SetUseEntityForPelvisOffset( optional entity : CEntity );
	import final function GetUseEntityForPelvisOffset() : CEntity;

	// Offset when attaching to entity or just to consume on "teleport"
	import final function SetAdditionalOffsetWhenAttachingToEntity( optional entity : CEntity, optional time : float );
	import final function SetAdditionalOffsetToConsumePointWS( transformWS: Matrix, optional time : float );
	import final function SetAdditionalOffsetToConsumeMS( pos : Vector, rot : EulerAngles, time : float );
	
	// Call this when you want the agent to stop moving
	public function ResetMoveRequests()
	{
		ForceSetRelativeMoveSpeed( 0.0f );
		SetGameplayRelativeMoveSpeed( 0.0f );
	}
}

import struct SCollisionData
{
	import var entity : CEntity;	// null entity means collision with terrain
	import var point : Vector;
	import var normal : Vector;
};

import class CMovingPhysicalAgentComponent extends CMovingAgentComponent
{
	// Is physical movement enabled
	import final function IsPhysicalMovementEnabled() : bool;
	
	// Gets the current state of the physcal controller
	import final function GetPhysicalState() : ECharacterPhysicsState;
	
	// set animated (true)/simulated (false) movement
	import final function IsAnimatedMovement() : bool;
	import final function SetAnimatedMovement( enable : bool );
	
	// enable/disable character controller gravity - simulated state only
	import final function SetGravity( flag : bool );
	
	// enable/disable character controller gravity
	import final function SetBehaviorCallbackNeed( flag : bool );
	
	// enable/disable character controller swimming mode - simulated state only
	import final function SetSwimming( flag : bool );
	
	// get waterlevel at character controller pos
	import final function GetWaterLevel() : float;
	
	// get submerge depth of character controller - NOT TRUE!!! RETURNS HEIGHT ABOVE WATER LEVEL!!!
	import final function GetSubmergeDepth() : float;
	
	// set diving - simulated state only
	import final function SetDiving( diving : Bool );

	// check diving - simulated state only
	import final function IsDiving() : bool;

	// emerge speed
	import final function SetEmergeSpeed( value : float );
	import final function GetEmergeSpeed() : float;
	
	// ragdoll pushing
	import final function SetRagdollPushingMul( value : float );
	import final function GetRagdollPushingMul() : float;	
	
	// Applies velocity to physical character
	import final function ApplyVelocity( vel : Vector );
	
	// Registers object as listener for physical events
	import final function RegisterEventListener( listener : IScriptable );
	
	// Unregisters listener
	import final function UnregisterEventListener( listener : IScriptable );
	
	// Set pushable (GI_2013_DEMO_HACK)
	import final function SetPushable( pushable : bool );
	
	// Check if character is on ground, is collides with ceiling or there is side collision. Notice its getting data directly from physical capsule
	import final function IsOnGround() : bool;
	import final function IsCollidesWithCeiling() : bool;
	import final function IsCollidesOnSide() : bool;
	
	// check if we are falling
	import final function IsFalling() : bool;
	
	// sliding
	import final function IsSliding() : bool;
	import final function GetSlideCoef() : float;
	import final function GetSlideDir() : Vector;
	import final function SetSliding( enable : bool );
	import final function SetSlidingSpeed( speed : float );
	import final function SetSlidingLimits( min : float, max : float );
	import final function EnableAdditionalVerticalSlidingIteration( enable : bool );
	import final function IsAdditionalVerticalSlidingIterationEnabled() : bool;
	
	// capsule data
	import final function GetCapsuleHeight() : float;
	import final function GetCapsuleRadius() : float;
	
	// terrain
	import final function SetTerrainLimits( min : float, max : float );
	import final function SetTerrainInfluence( mul : float );
	import final function GetSlopePitch() : float;
	import final function GetTerrainNormal( damped : bool ) : Vector;
	import final function GetTerrainNormalWide( out normalAverage : Vector, out normalGlobal : Vector, directionToCheck : Vector, separationH : float, separationF : float, separationB : float );
	
	// collision data
	import final function GetCollisionData( index : int ) : SCollisionData;
	import final function GetCollisionDataCount() : int;
	import final function GetCollisionCharacterData( index : int ) : SCollisionData;
	import final function GetCollisionCharacterDataCount() : int;
	import final function GetGroundGridCollisionOn( side : ECollisionSides ) : bool;
	import final function GetMaterialName() : CName;
	
	// collision prediction/response
	import final function EnableCollisionPrediction( enable : bool );
	
	// virtual controllers
	import final function SetVirtualControllersPitch( pitch : Float );
	import final function EnableVirtualControllerCollisionResponse( virtualControllerName : CName, enable : bool );
}

import class CActionAreaComponent extends CTriggerAreaComponent
{
}
