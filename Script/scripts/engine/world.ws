/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CWorld
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

import class CWorld extends CResource
{
	// Show layer group
	import final function ShowLayerGroup( layerGroupName : string );

	// Hide layer group
	import final function HideLayerGroup( layerGroupName : string );
	
	// Trace
	import final function PointProjectionTest( point : Vector, normal : EulerAngles, range : float ) : bool; 
	
	// Trejs
	import final function StaticTrace( pointA, pointB : Vector, out position : Vector, out normal : Vector, optional collisionGroupsNames : array<name> ) : bool;
	
	import final function StaticTraceWithAdditionalInfo( pointA, pointB : Vector, out position : Vector, out normal : Vector, out material : name, out component : CComponent, optional collisionGroupsNames : array<name> ) : bool;

	
	// Sweep ( Raycast with radius )
	import final function SweepTest( pointA, pointB : Vector, radius : float, out position, normal : Vector, optional collisionGroupsNames : array<name> ) : bool;

	// Sphere overlap for given radius. Returns the number of hits and array of hit CEntities.
	import final function SphereOverlapTest( out entities : array< CEntity > ,position : Vector, radius : float, optional collisionGroupsNames : array< name > ) : int;	
	
	// get water level at point
	import final function GetWaterLevel( point : Vector, optional dontUseApproximation : bool ) : float;
	
	// get water depth at point
	import final function GetWaterDepth( point : Vector, optional dontUseApproximation : bool ) : float;
	
	// get water tangent at point with direction
	import final function GetWaterTangent( point : Vector, direction : Vector, optional resolution : float /*= 0.25f*/ ) : Vector;

	// Spatial navigation data test that checks if (possibly) wide line from pos1 to pos2 fits navigation data.
	// ignoreObstacles allow us to filter out obstacles
	// noEndpointZ ignores pos2 Z value (and ignore test if this value is in navmesh vicinity)
	import final function NavigationLineTest( pos1 : Vector, pos2 : Vector, radius : float, optional ignoreObstacles : bool /*= false */, optional noEndpointZ : bool /*= false */ ) : bool;
	
	// Spatial navigation data test that checks if circle with a radius fits navigation data.
	// ignoreObstacles allow us to filter out obstacles
	import final function NavigationCircleTest( position : Vector, radius : float, optional ignoreObstacles : bool /*= false */ ) : bool;
	
	// Spatial navigation data test that checks if wide line hits edge of navigation data and returns contact points.
	// closestPointOnLine: closest point on line to geometry
	// closestPointOnGeometry: closest point on navigation data edge
	// ignoreObstacles allow us to filter out obstacles
	// return value: function returns 2d distance between closestPointOnLine and closestPointOnGeometry.
	// To check if function has hit anything at all just check if returned value is smaller then radius parameter
	import final function NavigationClosestObstacleToLine( pos1 : Vector, pos2 : Vector, radius : float, out closestPointOnLine : Vector, out closestPointOnGeometry : Vector, optional ignoreObstacles : bool /*=false */ ) : float;
	
	// Spatial navigation data test that checks if circle with radius hits edge of navigation data and returns contact point.
	// closestPointOnGeometry: closest point on navigation data edge
	// ignoreObstacles allow us to filter out obstacles
	// return value: function returns 2d distance between position and closestPointOnGeometry.
	// To check if function has hit anything at all just check if returned value is smaller then radius parameter
	import final function NavigationClosestObstacleToCircle( position : Vector, radius : float, out closestPointOnGeometry : Vector, optional ignoreObstacles : bool /*= false */ ) : float;
	
	// Spacial navigation test that returns the furthest point from pos1 in direction to pos2 that is accessible from pos1 in clear line.
	// Returns false, if such point doesn't exist ( == pos1 is not accessible ).
	import final function NavigationClearLineInDirection(  pos1 : Vector, pos2 : Vector, radius : float, out closestPointOnLine : Vector ) : bool;
	
	// Search for safe spot ('outSafeSpot') of given radius ('personalSpace') in vicinity of 'position', where search distance limit is 'searchRadius'.
	// Function give very good result (often the closest possible) for locations that are indeed on navigation but too close to its boundings.
	import final function NavigationFindSafeSpot( position : Vector, personalSpace : float, searchRadius : float, out outSafeSpot : Vector ) : bool;
	
	// Compute Z of given location based on navigation data.
	// Returns true and sets Z if there is navigable area between zMin and zMax height at given 2d position.
	import final function NavigationComputeZ( position : Vector, zMin : float, zMax : float, out z : float ) : bool;
	
	// Function does physics raycast to correct position Z, that is usually returned from navigation.
	// Returns 'true' if physical raycast actually had hit anything.
	import final function PhysicsCorrectZ( position : Vector, out z : float ) : bool;

	import final function GetDepotPath() : string;
	
	// force graphical lod level for testing purposes
	import final function ForceGraphicalLOD( lodLevel : int );	
	
	// Get terrain size and number of tiles for minimap & worldmap
	import final function GetTerrainParameters( out terrainSize : float, out tilesCount : int ) : bool;
	
	// Get the trace manager for high performance trace batching
	import final function GetTraceManager() : CScriptBatchQueryAccessor;	
	
	
	event OnWeatherChange()
	{
		if(thePlayer)
			thePlayer.OnWeatherChanged();
	}	
	
};
