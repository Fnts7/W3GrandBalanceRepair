/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskWander extends IBehTreeTask
{
	var minDistance, maxDistance, minSpeed, maxSpeed, absSpeed, headingChange, heading : float;
	var initialPosCheck, isMoving : bool;
	var moveType : EMoveType;
	var initialPos, newHeading, checkPos : Vector;
	
	default isMoving = false;
	default initialPosCheck = false;
	default heading = 0.f;

	function IsAvailable() : bool
	{
		return true;
	}

	latent function Main() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		var res : bool;
		var whereTo, randVec : Vector;
		var heading : float;
		var moveType : EMoveType;
		var actorToTargetAngle, distToTarget : float;
		
		isMoving = true;
		if( initialPosCheck == false )
		{
			initialPosCheck = true;
			initialPos = actor.GetWorldPosition();
		}
		
		randVec = VecRingRand(minDistance,maxDistance);
		whereTo = initialPos + randVec;
		//heading = VecHeading(initialPos - whereTo);
		absSpeed = RandRangeF( maxSpeed, minSpeed );
		
		//actorToTargetAngle = AbsF( AngleDistance( VecHeading( whereTo - actor.GetWorldPosition() ), VecHeading( actor.GetHeadingVector() )));
		//actorToTargetAngle = AbsF( VecGetAngleBetween( whereTo - actor.GetWorldPosition() ), VecHeading( actor.GetHeadingVector() )));
		distToTarget = VecDistance( actor.GetWorldPosition(), whereTo );
		
		res = actor.ActionMoveTo( whereTo, moveType, absSpeed );
		isMoving = false;
		if( res || distToTarget < 4 )
		{
			return BTNS_Completed;
		}
		
		return BTNS_Active;
		
		/*
		headingChange = RandRangeF( 20.0, 10.0 );
		if ( RandRangeF( 1.0, -1.0 ) < 0 )
		{
			headingChange *= -1;
		}
		heading = heading + headingChange;
		newHeading = VecFromHeading( heading );
		
		checkPos = actor.GetWorldPosition() + newHeading * randVec;
		
		res = actor.ActionMoveToWithHeading( whereTo, newHeading, moveType, absSpeed );

		isMoving = false;
		if( res )
		{
			return BTNS_Completed;
		}
		return BTNS_Failed;
		*/
	}
	
	function OnDeactivate() : void
	{
		if ( isMoving )
		{
			GetActor().ActionCancelAll();
			isMoving = false;
		}
	}
}

class CBTTaskWanderDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWander';

	editable var maxDistance : float;
	editable var minDistance : float;
	editable var moveType : EMoveType;
	editable var minSpeed : float;
	editable var maxSpeed : float;
	
	default maxDistance = 12.0;
	default minDistance = 4.0;
	default minSpeed = 0.2;
	default maxSpeed = 2.0;
	default moveType = MT_Run;
}