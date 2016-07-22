// CCameraPivotPositionControllerExplorationInteraction
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 25/04/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CCameraPivotPositionControllerExplorationInteraction extends CCameraPivotPositionControllerJump
{
	private	editable	var	collisionOffsetF		: float;	default	collisionOffsetF	= 1.0f;
	private				var explorationDirection	: Vector;
	private				var collisionOffset			: Vector;
	
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerActivate( currentOffset : float )
	{		
		var camera		: CCustomCamera;
		var player		: CR4Player;
		var exploration : SExplorationQueryToken;
		
		
		player	= ( CR4Player ) thePlayer;
		camera	= theGame.GetGameCamera();
		
		// find the offset we want
		exploration				= player.substateManager.m_SharedDataO.GetLastExploration();
		explorationDirection	= exploration.normal;
		
		collisionOffset			= explorationDirection * collisionOffsetF; 
		collisionOffset.Z		+= zOffset;
		
		//Set it to the camera
		camera.SetCollisionOffset( collisionOffset );
		
		super.ControllerActivate( currentOffset );
	}
	
	/*
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var camera	: CCustomCamera;
		
		
		camera	= theGame.GetGameCamera();
		camera.SetCollisionOffset( collisionOffset );
		
		super.ControllerUpdate( currentPosition , currentVelocity , timeDelta );
	}
	*/
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerDeactivate()
	{
		var camera		: CCustomCamera;
		
		camera.ResetCollisionOffset();
	}
}



//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CCameraRotationControllerInteraction extends ICustomCameraScriptedPivotRotationController
{
	// Forced pitch
	editable					var pitchMaxSpeed		: float;	default	pitchMaxSpeed		= 200.0f;
	
	editable					var blendTodesiredPitch	: bool;		default	blendTodesiredPitch	= false;
	editable					var desiredPitch		: float;	default	desiredPitch		= -20.0f;
	editable					var desiredPitchSpeed	: float;	default	desiredPitchSpeed	= 5.0f;
	
	// Yaw
	editable					var yawMaxSpeed			: float;	default	yawMaxSpeed			= 300.0f;
	
	
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		if( blendTodesiredPitch )
		{
			currentRotation.Pitch	= LerpAngleF( MinF( timeDelta * desiredPitchSpeed, 1.0f ), currentRotation.Pitch, desiredPitch );
		}
		currentRotation.Pitch	+= pitchMaxSpeed * theInput.GetActionValue( 'GI_AxisRightY' ) * timeDelta;
		currentRotation.Pitch	= ClampF( currentRotation.Pitch, minPitch, maxPitch );
		currentRotation.Yaw		-= yawMaxSpeed * theInput.GetActionValue( 'GI_AxisRightX' ) * timeDelta;
	}
	/*
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerSetDesiredYaw( yaw : float, mult : float )
	{
	}
	
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerUpdateInput( out movedHorizontal : bool, out movedVertical : bool )
	{
		movedHorizontal	= true;
		movedVertical	= true;
	}
	*/
	//------------------------------------------------------------------------------------------------------------------
	protected function ControllerActivate( currentRotation : EulerAngles )
	{		
	}
}
