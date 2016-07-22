//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		btTaskNPCNotInFronOfPlayer - script checks if NPC is in front of player (inside cone) and if not - returns TRUE				//
//																																	//
//		written by Wojciech Żerek, w.zerek@gmail.com																				//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CBTTaskNPCNotInFrontOfPLayer extends IBehTreeTask
{
	var coneAngle		: float;
	var angleOffset		: float;
	var coneRange		: float;
	
	var playerHeading : float;
	var npc : CNewNPC;
	var distance : float;
	var testedAngle : float;
	
	function IsAvailable() : bool
	{
		// calculating cone parameters
		playerHeading = thePlayer.GetHeading() + angleOffset;
		
		//var angleMin, angleMax : float;
		//angleMin = AngleNormalize180( playerHeading - ( coneAngle/2 ) );
		//angleMax = AngleNormalize180( playerHeading + ( coneAngle/2 ) );
		
		// checking if enemy is inside cone
		npc = GetNPC();
		distance = VecDistance2D( npc.GetWorldPosition(), thePlayer.GetWorldPosition() );
		testedAngle = NodeToNodeAngleDistance( npc, thePlayer );
		
		if ( distance < coneRange )
		{
			return false;
		}
		
		if ( testedAngle < ( coneAngle/2 ) )
		{
			return false;
		}

		return true;
	}
}


class CBTTaskNPCNotInFrontOfPLayerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskNPCNotInFrontOfPLayer';

	editable var coneAngle		: float;
	editable var angleOffset	: float;
	editable var coneRange		: float;
	
	default coneAngle = 90;
	default angleOffset = 0;
	default coneRange = 5;
}
