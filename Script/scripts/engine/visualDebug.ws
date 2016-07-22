/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for visual debug
/** Copyright © 2009
/***********************************************************************/

// Retained debug visualization
import class CVisualDebug extends CObject
{
	// Add debug text
	import final function AddText
	(
		dbgName : name,
		text : string,
		optional position : Vector,		// ZEROS
		optional absolutePos : bool,	// false
		optional line : byte,			// 0
		optional color : Color,			// WHITE
		optional background : bool,		// false
		optional timeout : float		// -1.0
	);
	
	// Add debug sphere
	import final function AddSphere
	(
		dbgName : name,
		radius : float,
		optional position : Vector,		// ZEROS
		optional absolutePos : bool,	// false
		optional color : Color,			// WHITE
		optional timeout : float		// -1.0
	);
	
	// Add debug box
	import final function AddBox
	(
		dbgName : name,
		size : Vector,
		optional position : Vector,		// ZEROS
		optional rotation : EulerAngles,// ZEROS
		optional absolutePos : bool,	// false
		optional color : Color,			// WHITE
		optional timeout : float		// -1.0
	);
	
	// Add debug axis
	import final function AddAxis
	(
		dbgName : name,
		optional scale : float,			// 1.0
		optional position : Vector,		// ZEROS
		optional rotation : EulerAngles,// ZEROS
		optional absolutePos : bool,	// false
		optional timeout : float		// -1.0
	);
	
	// Add debug line
	import final function AddLine
	(
		dbgName : name,
		optional startPosition, endPosition : Vector,		// ZEROS
		optional absolutePos : bool,						// false
		optional color : Color,								// WHITE
		optional timeout : float							// -1.0
	);
	
	import final function AddArrow
	( 
		dbgName : name, 
		optional start : Vector, optional end : Vector, 
		optional arrowPostionOnLine01 : float, optional arrowSizeX : float, optional arrowSizeY : float,
		optional absolutePos : bool, 
		optional color : Color, 
		optional overlay : bool, 
		optional timeout : float 
	);
	
	// Add debug bar
	import final function AddBar( dbgName : name, x : int, y : int, width : int, height : int, progress : float, color : Color, optional text : string, optional timeout : float );
	import final function AddBarColorSmooth( dbgName : name, x : int, y : int, width : int, height : int, progress : float, color : Color, optional text : string, optional timeout : float );
	import final function AddBarColorAreas( dbgName : name, x : int, y : int, width : int, height : int, progress : float, optional text : string, optional timeout : float );
	
	// Remove debug text
	import final function RemoveText( dbgName : name );
	
	// Remove debug sphere
	import final function RemoveSphere( dbgName : name );
	
	// Remove debug box
	import final function RemoveBox( dbgName : name );
	
	// Remove debug axis
	import final function RemoveAxis( dbgName : name );
	
	// Remove debug line
	import final function RemoveLine( dbgName : name );
	
	// Remove debug arrow
	import final function RemoveArrow( dbgName : name );
	
	// Remove debug bar
	import final function RemoveBar( dbgName : name );
};

// Script interface for CRenderFrame class used in CGameplayEntity.OnVisualDebug evemt
import class CScriptedRenderFrame extends CObject
{
	// Draw debug text
	import function DrawText( text : String, position : Vector, color : Color );
	
	// Draw debug sphere
	import function DrawSphere( position : Vector, radius : float, color : Color );
	
	// Draw debug line
	import function DrawLine( start : Vector, end : Vector, color : Color );

}