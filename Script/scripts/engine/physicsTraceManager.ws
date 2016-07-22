

/*
enum EBatchQueryQueryFlag
{
	EQQF_IMPACT				// Compute the position of impact
	EQQF_NORMAL				// Compute the impact normal
	EQQF_DISTANCE			// Compute the distance of impact from origin
	EQQF_TOUCHING_HIT		// Specified the hit object as a touching hit. Will pass through every object and may return multiple results.
	EQQF_BLOCKING_HIT		// Specified the hit object as a blocking hit. Will stop on the first hit and return at most one result.
	EQQF_NO_INITIAL_OVERLAP	// Disable initial overlap tests in sweeps.
	EQQF_PRECISE_SWEEP		// Use more accurate sweep function, but slower.
	EQQF_MESH_BOTH_SIDES	// Report hits with back faces of triangles.
};

enum EBatchQueryState
{
	BQS_NotFound,		// not found or timed out
	BQS_NotReady,
	BQS_Processed
};
*/

import struct SScriptRaycastId {}

import struct SScriptSweepId {}

import struct SRaycastHitResult
{
	import var position		: Vector;
	import var normal		: Vector;
	import var distance		: float;
	import var component	: CComponent;
}

import struct SSweepHitResult
{
	import var position		: Vector;
	import var normal		: Vector;
	import var distance		: float;
	import var component	: CComponent;
}

import class CScriptBatchQueryAccessor
{
	/*
	Default collisionGroupsNames	= { Static, Terrain }
	Default queryFlags				= EQQF_IMPACT + EQQF_NORMAL + EQQF_DISTANCE + EQQF_BLOCKING_HIT
	*/
	
	// Combine EBatchQueryQueryFlag as queryFlags.
	import final latent function RayCast( start : Vector, end : Vector, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	import final latent function RayCastDir( start : Vector, direction : Vector, distance : float, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	
	import final function RayCastSync( start : Vector, end : Vector, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name> ) : bool;
	import final function RayCastDirSync( start : Vector, direction : Vector, distance : float, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name> ) : bool;
	
	import final function RayCastAsync( start : Vector, end : Vector, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptRaycastId;
	import final function RayCastDirAsync( start : Vector, direction : Vector, distance : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptRaycastId;
	
	import final function GetRayCastState( queryId : SScriptRaycastId, out result : array<SRaycastHitResult> ) : EBatchQueryState;
	
	import final latent function Sweep( start, end : Vector, radius : float, out result : array<SSweepHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	import final latent function SweepDir( start, direction : Vector, radius, distance : float, out result : array<SSweepHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	
	import final function SweepAsync( start, end : Vector, radius : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptSweepId;
	import final function SweepDirAsync( start, direction : Vector, radius, distance : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptSweepId;
	
	import final function GetSweepState( queryId : SScriptSweepId, out result : array<SSweepHitResult> ) : EBatchQueryState;
}