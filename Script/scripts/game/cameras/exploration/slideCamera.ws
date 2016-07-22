// CCameraPivotPositionControllerSlide
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 23/01/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CCameraPivotPositionControllerSlide extends ICustomCameraScriptedPivotPositionController
{
	private		var	originalPosition	: Vector;	
	editable	var	blendSpeed			: float;	default	blendSpeed			= 20.0f;
	private		var	timeCur				: float;
	
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		//var Zoffset				: Vector;
		var	blendXYCoef			: float;
		var blendZSpeed			:float;
		var	blendZCoef			: float;
		var targetPosition		: Vector;
		var preset				: SCustomCameraPreset;
		
		// Original position
		if( timeCur	== 0.0f )
		{
			originalPosition	= currentPosition;
		}
		
		// Get the preset to use some data
		//preset				= theGame.GetGameCamera().GetActivePreset(); 
		
		// Get the target position
		targetPosition		=  thePlayer.GetWorldPosition();// + preset.offset;
		
		// Get the blends
		// Blend the target position on XY
		originalPosition	= Vector( BlendF( originalPosition.X, targetPosition.X, blendSpeed * timeDelta )
									, BlendF( originalPosition.Y, targetPosition.Y, blendSpeed * timeDelta )
									, BlendF( originalPosition.Z, targetPosition.Z, blendSpeed * timeDelta ) );
		
		// Set the final position
		currentPosition = originalPosition;
		
		timeCur			+= timeDelta;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerActivate( currentOffset : float )
	{		
		timeCur	= 0.0f;
	}
}