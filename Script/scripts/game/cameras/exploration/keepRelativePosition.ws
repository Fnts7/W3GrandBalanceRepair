// CCameraPivotPositionControllerKeepRelative
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 15/04/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CCameraPivotPositionControllerKeepRelative extends ICustomCameraScriptedPivotPositionController
{
	private	var	offset	: Vector;
	private	var	isSet	: bool;		default	isSet	= false;
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{	
		// First frame
		if( !isSet )
		{
			offset	= currentPosition - thePlayer.GetWorldPosition();
			isSet	= true;
		}
		
		// Set the final position
		currentPosition = thePlayer.GetWorldPosition() + offset;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerActivate( currentOffset : float )
	{	
		isSet	= false;	
	}
}