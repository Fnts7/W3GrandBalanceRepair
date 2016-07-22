/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Over The Shoulder camera for throwing items for player
	
	Since offsetZ is broken (gets overriden somehow) we don't use it and use a custom offset here.
*/
class ThrowingCamera extends ICustomCameraScriptedPivotPositionController
{
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var playerPos, OTSoffset, Zoffset, XYoffset : Vector;
	
		playerPos = thePlayer.GetWorldPosition();
		OTSoffset = VecCross( Vector(0,0,-1), VecNormalize(theCamera.GetCameraDirection()) );		//shift to the right to get OTS
		Zoffset = Vector(0, 0, 1.5);																	//move up since player's Z is on the ground
		
		//move the camera in front of the player in XY - to hide the feet sliding :)
		XYoffset = VecNormalize(theCamera.GetCameraDirection());
		XYoffset.X = XYoffset.X * 0.2;
		XYoffset.Y = XYoffset.Y * 0.2;
		XYoffset.Z = 0;		
		
		currentPosition = playerPos + OTSoffset + Zoffset + XYoffset;
	}
}