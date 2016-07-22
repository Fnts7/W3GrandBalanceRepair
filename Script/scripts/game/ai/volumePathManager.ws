/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for Community System
/** Copyright © 2012-2013
/***********************************************************************/

import class CVolumePathManager extends IGameSystem
{
	import function GetPath( start : Vector, end : Vector, out resultPath : array<Vector>, optional maxHeight : float ) : bool;
	import function GetPointAlongPath( start : Vector, end : Vector, distAlongPath : float, optional maxHeight : float ) : Vector;
	import function IsPathfindingNeeded( start : Vector, end : Vector ) : bool;
};