

import struct SPredictionInfo
{
	import var distanceToCollision	: float;
	import var normalYaw			: float;
	import var turnAngle			: float;
	import var leftGroundLevel		: float;
	import var frontGroundLevel		: float;
	import var rightGroundLevel		: float;
}

import class CHorsePrediction
{
	import final function CollectPredictionInfo( entity : CNode, testDistance : float, direction : float, checkWater : bool ) : SPredictionInfo;
}