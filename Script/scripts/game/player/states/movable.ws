/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Movable state
/////////////////////////////////////////////
enum EDir
{
	Dir_L180,
	Dir_L135,
	Dir_L90,
	Dir_L45,
	Dir_F,
	Dir_R45,
	Dir_R90,
	Dir_R135,
	Dir_R180
}

enum EPlayerStopPose
{
	EPS_LeftForward,
	EPS_LeftUp,
	EPS_RightForward,
	EPS_RightUp
}


import state Movable in CPlayer extends Base
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter/Leave events

	/**
	
	*/
	event OnEnterState( prevStateName : name )
	{
		// Pass to base class
		super.OnEnterState(prevStateName);
				
		// Intall movement timer
		parent.AddTimer( 'ProcessMovement', 0.001, true, false, TICK_PrePhysics );
		
		// Enable player movement
		//parent.isMovable = true;
	}
	
	/**
	
	*/
	event OnLeaveState( nextStateName : name )
	{ 
		var currRotation : EulerAngles;
		var agent : CMovingAgentComponent = parent.GetMovingAgentComponent();
		
		// Pass to base class
		super.OnLeaveState(nextStateName);
		
		// Remove movement timer
		parent.RemoveTimer( 'ProcessMovement', TICK_PrePhysics );		
		
		// reset additional movement flags
		if(agent)
			agent.SetBehaviorVariable( 'headingChange', 0 );
		
		// Prevent CMoveTRGPlayerManualMovement from being updated from this point
		//if ( nextStateName == 'Exploration' )
		//	thePlayer.ActionCancelAll();
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Animation events
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Movement
	
	timer function ProcessMovement( timeDelta : float , id : int)
	{
		var action : EActorActionType;
		var r4player : CR4Player;
		r4player = (CR4Player) parent;
		
		// Calculate player speed and rotation angle	
		if ( parent.GetIsMovable() )
		{
			action = parent.GetCurrentActionType();
			
			if ( action == ActorAction_None )
			{				
				if ( r4player )
				{
					r4player.SetDefaultLocomotionController();
				}
			}
			else //if ( action == ActorAction_Moving )
			{
				MonitorInput();
			}
		}
		else
		{
			ResetMovementFlags();
		}
	}
	
	private function ResetMovementFlags()
	{
		var currRotation : EulerAngles;
		currRotation = parent.GetWorldRotation();
		
		parent.rawPlayerSpeed = 0.f;
		parent.rawPlayerAngle = 0.f;
		parent.rawPlayerHeading = currRotation.Yaw;
	}
	
	private function MonitorInput()
	{
		if( theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY') != 0 )
		{
			thePlayer.SignalGameplayEvent( 'StopPlayerActionOnInput' );
		}
	}
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct SHeadingHistory
{
	var time 		: 	EngineTime;
	var headValue 	: 	float;
	var speedValue  :   float;
}

class CMoveTRGPlayerManualMovement extends CMoveTRGScript
{	
	private var currVelocity : float;
	default currVelocity = 0.0f;
	
	private var m_heading					: float;
	private var m_orientationWODump			: float;
	
	private var m_headingChangeVal			: float;
	private var m_headingHistoryTime		: float;
	private var m_headingHistory			: array<SHeadingHistory>;
	
	private var lastKnownPlayerHeading : float;
	default lastKnownPlayerHeading = 0.0f;
	
	default		m_headingChangeVal			= 0.0f;
	default		m_headingHistoryTime		= 0.2f;

	function DampOrientation(value : float,inputValue : float) : float
	{
		var diffValue : float;
		var dampFactor : float;
		var speed : float;
		var absDist : float;
		
		var dist : float;
		var deltaValue : float;
		
		dampFactor = 0.95f;
		speed  = 45.0f;
		
		dist = AngleDistance(inputValue, value);
		absDist = AbsF(dist);

		//LogChannel( 'Combat Damp ', "currV " +value + " destV : " + inputValue + " dist : " + dist);
		
		deltaValue = (dampFactor * timeDelta * speed);

		if( value == inputValue || AbsF(dist) < deltaValue - 0.00001f)
		{
			value = inputValue;
			return value ;
		}

		if( dist < 0 )
		{
			value  = value  - deltaValue;
		}
		else
		{
			value  = value  + deltaValue;
		}

		if(value < -180.0f) 
		{
			value  += 360.0f;
		}
		else if( value  > 180.0f)
		{
			value  -= 360.0f;
		}
		
		//LogChannel( 'Combat Damp ', "currV " +value);
		
		return value ;
	}
	
	function DampOrientationDiff(value : float,inputValue : float, optional dampValue : float) : float
	{
		var diffValue : float;
		var dampFactor : float;
		var absDist : float;
		
		var dist : float;
		var deltaValue : float;
		
		//TEMP
		var entities : array<CGameplayEntity>;
		var player : CPlayer;
		var size : int;
		
		/*
		player = (CPlayer)agent.GetEntity();
		entities = ... get something in range from player
		size =  entities.Size();
		if ( size <= 1 )
		{
			dampFactor = player.dampValue;
		}
		else
		{
			dampFactor = player.dampValue;
		}
		*/
		
		if ( dampValue )
		{
			dampFactor = dampValue;
		}
		else
		{
			dampFactor = 2.0f;
		}
		
		dist = AngleDistance(inputValue, value);
		absDist = AbsF(dist);

		//LogChannel( 'Combat Damp ', "currV " +value + " destV : " + inputValue + " dist : " + dist);
		
		deltaValue = (dampFactor *timeDelta * absDist);

		if( value == inputValue || absDist < deltaValue - 0.00001f)
		{
			value = inputValue;
			return value ;
		}

		if( dist < 0 )
		{
			value  = value  - deltaValue;
		}
		else
		{
			value  = value  + deltaValue;
		}

		if(value < -180.0f) 
		{
			value  += 360.0f;
		}
		else if( value  > 180.0f)
		{
			value  -= 360.0f;
		}
		
		//LogChannel( 'Combat Damp ', "currV " +value);
		
		return value ;
	}
	
	
	function DampOrientationSpring(value : float,inputValue : float) : float
	{
		var diffValue : float;
		var dampFactor : float;
		var absDist : float;
		
		var dist : float;
		var deltaValue : float;
		
		var springAccel : float;
		
		dampFactor = 10.0f;
		
		dist = AngleDistance(inputValue, value);
		absDist = AbsF(dist);

        springAccel = -(  absDist * dampFactor ) - currVelocity * 2.f * SqrtF( dampFactor );
        currVelocity += springAccel * timeDelta;
        
		deltaValue = (currVelocity * timeDelta);

		if( value == inputValue || absDist < deltaValue - 0.00001f)
		{
			value = inputValue;
			return value;
		}

		if( dist < 0 )
		{
			value  = value  - deltaValue;
		}
		else
		{
			value  = value  + deltaValue;
		}

		if(value < -180.0f) 
		{
			value  += 360.0f;
		}
		else if( value  > 180.0f)
		{
			value  -= 360.0f;
		}
		
		LogChannel( 'Combat Damp ', "currV " +value);
		
		return value ;
	}
	
	private function GetMaxHeadingDiff( currHeading : float ) : float	
	{
		var maxDiff : float;
		var diff : float;
		var i : int;
		
		maxDiff = -1.f;
		
		for ( i = 0; i < m_headingHistory.Size(); i += 1 )
		{
			diff = AbsF( AngleDistance( m_headingHistory[i].headValue, currHeading ) );
			if ( diff > maxDiff )
			{
				maxDiff = diff;
			}
		}
		return maxDiff;
	}	
	
	private final function SetTorsoOrientationGoal( angleWS : float )
	{
		var angleDiff : float;
		var entity : CEntity;
		
		entity = agent.GetEntity();
		
		angleDiff = AngleDistance( angleWS, entity.GetHeading() ) / 180.f;
		
		//player.GetVisualDebug().AddArrow( 'orientation', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( player.tomsinTest + player.GetHeading() ), 1.f, 0.2f, 0.2f, true, Color(255,128,128), true );
		
		entity.SetBehaviorVariable( 'torsoOrientation', angleDiff );
	}
	/*
	private function SetHandAim()
	{
		var pitch : float;
		var player : CPlayer = thePlayer;
		var m : Matrix;
		var ea : EulerAngles;
		m = theCamera.GetCameraMatrixWorldSpace();
		ea = MatrixGetRotation( m );//camera.GetWorldRotation();
		
		pitch = ea.Pitch;
		
		if ( pitch < -15.0 )
		{
			pitch += 15.0;
			player.handAimPitch = (pitch/(-40.0));
			player.SetBehaviorVariable( 'handAimPitch',player.handAimPitch);
		}
		else
		{
			player.handAimPitch = 0;
			player.SetBehaviorVariable( 'handAimPitch',player.handAimPitch);
		}
		//LogChannel('handAimDebug', "pitch = " + pitch);
	}
	*/
	
	private function SetHandAim()
	{
		var fHandPitch : float;
		var pitch : float;
		var player : CPlayer = thePlayer;
		var target : CActor;
		var playerPos : Vector;
		var targetPos : Vector;
		var pos, posZ : Vector;
		var firstVec, secondVec, crossVec : Vector;
		var playerRot : EulerAngles;
		var targetRot : EulerAngles;
		var m : Matrix;
		var i : float;
		
		target = player.GetTarget();
		
		if ( !target )
			return;
		
		playerPos = player.GetWorldPosition();
		targetPos = target.GetWorldPosition();
		targetPos.Z += 2;
		
		//pos = playerPos + 2*player.GetHeadingVector();
		pos = targetPos;
		pos.Z = playerPos.Z;
		
		posZ = playerPos;
		posZ.Z += 4;
		firstVec = pos - playerPos;
		secondVec = targetPos - playerPos;
		
		//secondVec = VecProjectPointToPlane(playerPos,pos,posZ,secondVec);
		
		crossVec = VecCross(VecNormalize(firstVec),VecNormalize(secondVec));
		
		pitch = VecGetAngleDegAroundAxis(firstVec,secondVec,crossVec);
		
		fHandPitch = pitch/90;
		
		if ( targetPos.Z < playerPos.Z )
		{
			fHandPitch *= -1;
		}
		
		i = 0;
		
		player.SetBehaviorVariable( 'handPitch',fHandPitch);
	}
}

exec function hpitch( pitch : float )
{
	var player : CPlayer = thePlayer;
	player.SetBehaviorVariable( 'handPitch',pitch);
}
