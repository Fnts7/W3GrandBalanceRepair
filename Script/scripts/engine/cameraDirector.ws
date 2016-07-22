/***********************************************************************/
/** Camera Director
/***********************************************************************/

import class CCameraDirector
{
	// Converts screen coordinates to vector in world coordinates
	import final function ViewCoordsToWorldVector( x, y : int, out rayStart : Vector, out rayDirection : Vector );
	
	// Converts screen coordinates to vector in world coordinates
	import final function WorldVectorToViewCoords( worldPos : Vector, out x : int, out y : int );
	
	// Returns screen space ratio from -1 to 1. Returns false if object is behind the camera.
	import final function WorldVectorToViewRatio( worldPos : Vector, out x : float, out y : float ) : bool;
	
	import final function GetCameraPosition() : Vector;
	import final function GetCameraRotation() : EulerAngles;
	import final function GetCameraForward() : Vector;
	import final function GetCameraRight() : Vector;
	import final function GetCameraUp() : Vector;
	import final function GetCameraHeading() : float;
	import final function GetCameraDirection() : Vector;
	
	import final function GetFov() : float;
	
	import final function GetTopmostCameraObject() : IScriptable;
	
	
	//>-----------------------------------------------------------------------------------------------------------------
	public function GetCameraForwardOnHorizontalPlane() : Vector
	{
		var l_ForwardV	: Vector;
		
		l_ForwardV		= GetCameraForward();
		l_ForwardV.Z	= 0.0f;		
		
		return VecNormalize( l_ForwardV );
	}
}