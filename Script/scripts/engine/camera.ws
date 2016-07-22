/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

enum ECameraState
{
	CS_Exploration,
	CS_Combat,
	CS_FocusModeNC,
	CS_FocusModeCombat,
	CS_AimThrow,
	CS_Horse,
	CS_Boat,
}

enum ECameraShakeState
{
	CSS_Normal,
	CSS_Drunk,
	CSS_Elevator
}

enum ECameraShakeMagnitude
{
	CSM_0	=	0,
	CSM_1	=	1,
	CSM_2	=	2,
	CSM_3	=	3,
	CSM_4	=	4,
	CSM_5	=	5
}

import class CCamera extends CEntity
{
	var cameraState : ECameraState;
	// Activate camera's selected camera component
	import final function SetActive( blendTime : float );

	// Is selected camera component active
	import final function IsActive() : bool;
	
	// Is camera on stack
	import final function IsOnStack() : bool;

	// Get direction
	import final function GetCameraDirection() : Vector;

	// Get position
	import final function GetCameraPosition() : Vector;

	// Get camera position in world space
	import final function GetCameraMatrixWorldSpace() : Matrix;

	// Set fov
	import final function SetFov( fov : float );

	// Get fov
	import final function GetFov() : float;
	
	// Set zoom
	import final function SetZoom( value : float );

	// Get zoom
	import final function GetZoom() : float;

	// Reset camera state and data
	import final function Reset();
	
	// Reset camera rotations. Optionals: smoothly - true, horizontal - true, vertical - true.
	import final function ResetRotation( optional smoothly : bool, optional horizontal : bool, optional vertical : bool, optional duration : float );
	import final function ResetRotationTo( smoothly : bool, horizontalAngle : float, optional verticalAngle : float, optional duration : float );

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Rotate - use behavior for rotating
	import final function Rotate( leftRightDelta, upDownDelta : float );

	// Follow node
	import final function Follow( dest : CEntity );
	
	// Follow node with rotation
	import final function FollowWithRotation( dest : CEntity );

	// Look at target
	import final function LookAt( target : CNode, optional duration : float, optional activatingTime : float );
	
	// Look at static target 
	import final function LookAtStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	// Look at bone in an animated component
	import final function LookAtBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	// Deactivate focus on target
	import final function LookAtDeactivation( optional deactivatingTime : float );
	
	// Has look at target
	import final function HasLookAt() : bool;

	// Get look at target position
	import final function GetLookAtTargetPosition() : Vector;
	
	// Focus on target
	import final function FocusOn( target : CNode, optional duration : float, optional activatingTime : float );
	
	// Focus on static target
	import final function FocusOnStatic( staticTarget : Vector, optional duration : float, optional activatingTime : float );
	
	// Focus on bone in an animated component
	import final function FocusOnBone( target : CAnimatedComponent, boneName : string, optional duration : float, optional activatingTime : float );
	
	// Deactivate focus
	import final function FocusDeactivation( optional deactivatingTime : float );
	
	// Is focused
	import final function IsFocused() : bool;

	// Get focus target position
	import final function GetFocusTargetPosition() : Vector;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// Script functions
	
	final function SetCameraState( newState : ECameraState ) : bool
	{
		var lCamState : int;
		var ret : bool;
		lCamState = (int) newState;

		if ( SetBehaviorVariable( 'cameraState', (float) lCamState ) )
		{
			cameraState = newState;
			return true;
		}
		return false;
	}
	
	final function GetCameraState( ) : ECameraState
	{
		return cameraState;
	}

	final function CameraShakeLooped( strength : float, optional cameraShakeType : ECameraShakeState )
	{
		SetBehaviorVariable( 'cameraShakeState', (int)cameraShakeType );
		SetBehaviorVariable( 'cameraShakeLooped', strength );
	}

	final function GCameraShake( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float )
	{
		var finalStrength : float;
		var distance : float;
		var camera 	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		if( testDistance )
		{
			if( maxDistance <= 0 )
			{
				maxDistance = 20.0f;
			}
			if( shakeEpicenter == Vector(0,0,0) )
			{
				shakeEpicenter = thePlayer.GetWorldPosition();
			}
			
			distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
			
			if( distance > maxDistance )
			{
				distance = maxDistance;
			}
			
			finalStrength = strength * (1 - distance / maxDistance);
		}
		else
		{
			finalStrength = strength;
		}
		SetBehaviorVariable( 'cameraShakeStrength', finalStrength );
		RaiseForceEvent( 'Shake' );
		
		if( camera )
		{
			if( finalStrength > 1 )
			{
				finalStrength = 1.0f;
			}
			
			animation.animation = 'camera_shake_hit_lvl3_1';
			animation.priority = CAP_High;
			animation.blendIn = 0.1f;
			animation.blendOut = 0.1f;
			animation.weight = finalStrength;
			animation.speed	= 1.0f;
			animation.additive = true;
			animation.reset = true;
			
			camera.PlayAnimation( animation );
		}
	}
	
	final function SetCameraShakeState( newState : ECameraShakeState, strength : float) : bool
	{
		var res, res2 : bool;
		
		res = SetBehaviorVariable( 'cameraShakeState', (float) ((int)newState) );
		
		if(newState == CSS_Normal)
			strength = 0;			//because otherwise CSS_Normal does not work!!!!!
		
		res2 = SetBehaviorVariable( 'cameraShakeStrength', strength );
		
		return res && res2;
	}
}

function GCameraShakeLight( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float, optional looping : bool, optional animName : name, optional speed : float )
{
	var finalStrength : float;
	var distance : float;
	var camera 	: CCustomCamera;
	var animation : SCameraAnimationDefinition;
	
	
	camera 	= theGame.GetGameCamera();
	if( camera )
	{
		return;
	}
	
	
	if( testDistance )
	{
		if( maxDistance <= 0 )
		{
			maxDistance = 20.0f;
		}
		if( shakeEpicenter == Vector(0,0,0) )
		{
			shakeEpicenter = thePlayer.GetWorldPosition();
		}
		
		distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
		
		if( distance > maxDistance )
		{
			distance = maxDistance;
		}
		
		finalStrength = strength * (1 - distance / maxDistance);
	}
	else
	{
		finalStrength = strength;
	}
	
	if( speed == 0.0f )
	{
		speed	= 1.0f;
	}
	
	
	if( finalStrength > 1 )
	{
		finalStrength = 1.0f;
	}
	
	if ( animName == '' )
	{
		animName = 'camera_shake_hit_lvl3_1';		
	}

	animation.animation = animName;	
	animation.priority = CAP_Low;
	animation.blendIn = 0.1f;
	animation.blendOut = 0.1f;
	animation.weight = finalStrength;
	animation.speed	= speed;
	animation.additive = true;
	animation.reset = true;
	animation.loop = looping;
	
	camera.PlayAnimation( animation );
}

function GCameraShake( strength : float, optional testDistance : bool, optional shakeEpicenter : Vector, optional maxDistance : float, optional looping : bool, optional animName : name, optional speed : float )
{
	var finalStrength : float;
	var distance : float;
	var camera 	: CCustomCamera;
	var animation : SCameraAnimationDefinition;
	
	
	camera 	= theGame.GetGameCamera();
	if( !camera )
	{
		return;
	}
	
	if( testDistance )
	{
		if( maxDistance <= 0 )
		{
			maxDistance = 20.0f;
		}
		if( shakeEpicenter == Vector(0,0,0) )
		{
			shakeEpicenter = thePlayer.GetWorldPosition();
		}
		
		distance = VecDistance( shakeEpicenter, thePlayer.GetWorldPosition() );
		
		if( distance > maxDistance )
		{
			distance = maxDistance;
		}
		
		finalStrength = strength * (1 - distance / maxDistance);
	}
	else
	{
		finalStrength = strength;
	}
	
	if( speed == 0.0f )
	{
		speed	= 1.0f;
	}
	
	
	if( finalStrength > 1 )
	{
		finalStrength = 1.0f;
	}
	
	if ( animName == '' )
	{
		animName = 'camera_shake_hit_lvl3_1';		
	}

	animation.animation = animName;	
	animation.priority = CAP_High;
	animation.blendIn = 0.1f;
	animation.blendOut = 0.1f;
	animation.weight = finalStrength;
	animation.speed	= speed;
	animation.additive = true;
	animation.reset = true;
	animation.loop = looping;
	
	camera.PlayAnimation( animation );
}