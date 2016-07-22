//>--------------------------------------------------------------------------
// BTCondIsInTheWay
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if a position B is in the way of going from A to C.
// Used for example to detect if an enemy is between my ally and me
// Returns false if one of the the three target used is missing
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 15-November-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
enum ETargetName
{
	TN_Me,
	TN_CombatTarget,
	TN_ActionTarget,
	TN_CustomTarget,
	TN_NamedTarget
}
class BTCondIsInTheWay extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var origin 					: ETargetName;
	public var obstacle 				: ETargetName;
	public var destination 				: ETargetName;
	public var returnIfInvalid 		: bool;
	
	public var requiredDistanceFromLine	: float;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var l_originPos			: Vector;
		var l_obstaclePos		: Vector;
		var l_destinationPos	: Vector;
		
		var l_tempDebug			: Vector;
		
		var l_distOrOb 			: float;
		var l_distOrDes 		: float;
		var l_distDesOb			: float;
		
		var distanceFromLine 	: float;		
		
		if( origin == TN_NamedTarget 		) l_originPos 		= GetNamedTarget( 'OriginTarget' ).GetWorldPosition();
		else l_originPos = GetTargetPos( origin );
		
		if( obstacle == TN_NamedTarget 		) l_obstaclePos 	= GetNamedTarget( 'ObstacleTarget' ).GetWorldPosition();
		else l_obstaclePos 	= GetTargetPos( obstacle );
		
		if( destination == TN_NamedTarget 	) l_destinationPos 	= GetNamedTarget( 'DestinationTarget' ).GetWorldPosition();
		else l_destinationPos = GetTargetPos( destination );
		
		// If one of the three target is invalid, consider that nothing is in the way
		if( l_originPos == Vector( 0, 0, 0 ) || l_obstaclePos == Vector( 0, 0, 0 ) || l_destinationPos == Vector( 0, 0, 0 ) )
		{
			return returnIfInvalid;
		}
		
		
		l_tempDebug = l_destinationPos - l_originPos + Vector( 0, 0, 1);
		l_tempDebug = l_tempDebug * 0.5f;
		GetNPC().GetVisualDebug().AddText('Destination', "Follow", l_originPos + l_tempDebug, true,,Color( 255, 255, 255 ), true, 0.5f );
		
		GetNPC().GetVisualDebug().AddArrow('toDestination', l_originPos + Vector( 0, 0, 1), l_destinationPos + Vector( 0, 0, 1), 1, 0.5f, 0.8f, true, Color( 255, 56, 89 ),, 0.5f );
		
		
		l_distOrOb 	= VecDistance( l_originPos, l_obstaclePos ); 		// Distance between the two points trying to form a line
		l_distOrDes = VecDistance( l_originPos, l_destinationPos ); 	// Distance between origin and obstacle
		l_distDesOb = VecDistance( l_destinationPos, l_obstaclePos ); 	// Distance between destination and obstacle
		
		// If the obstacle is further away from both origin and dest than the distance between origin to dest
		if( l_distOrOb > l_distOrDes  &&  l_distDesOb > l_distOrDes )
		{
			return false;
		}
		
		// if the obstacle is in the space between origin and dest
		if( l_distOrOb < l_distOrDes && l_distDesOb < l_distOrDes )
		{
			distanceFromLine = VecDistanceToEdge( l_obstaclePos, l_originPos, l_destinationPos  );
			if( distanceFromLine < requiredDistanceFromLine )
			{
				return true;
			}		
		}
		
		return false;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private final function GetTargetPos( _TargetName : ETargetName ) : Vector
	{
		var l_pos 		: Vector;
		var l_heading 	: float;
		
		switch ( _TargetName )
		{
			case TN_Me:
				return GetNPC().GetWorldPosition();
			case TN_CombatTarget:
				return GetCombatTarget().GetWorldPosition();
			case TN_ActionTarget:
				return GetActionTarget().GetWorldPosition();
			case TN_CustomTarget:
				GetCustomTarget( l_pos, l_heading );
				return l_pos;
			default:
				return Vector( 0, 0, 0 );
		}		
		
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondIsInTheWayDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsInTheWay';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	private editable var origin 					: ETargetName;
	private editable var obstacle 					: ETargetName;
	private editable var destination 				: ETargetName;
	private editable var requiredDistanceFromLine	: float;
	private editable var returnIfInvalid			: bool;
	
	hint origin 					= "if named target, use 'OriginTarget'";
	hint obstacle 					= "if named target, use 'ObstacleTarget'";
	hint destination 				= "if named target, use 'DestinationTarget'";
	hint requiredDistanceFromLine 	= "required distance between the obstacle and the line formed by the origin and the destination";
	hint returnIfInvalid 			= "If one of the three targets is invalid, return this value";
	
	default origin 					= TN_Me;
	default obstacle 				= TN_CombatTarget;
	default destination 			= TN_ActionTarget;
}