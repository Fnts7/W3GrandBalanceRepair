// CBTTaskFlyAround

class CBTTaskFlyAround extends CBTTaskVolumetricMove
{
	var distance					: float;
	var altitude					: float;
	var tolerance					: float;
	var frontalHeadingOffset		: int;
	var landingGroundOffset			: float;
	var randomHeight				: int;
	
	var anchorPoint					: CEncounter;
	var anchorPointAC				: CAreaComponent;
	
	var anchorPointPos				: Vector;
	
	var anchorPointToNpcVector		: Vector;
	var anchorPointToNpcHeight		: float;
	var anchorPointToNpcDistance2D 	: float;

	var npcToDestVector				: Vector;
	var npcToDestVector2			: Vector;
	var npcToDestDistance			: float;
	var npcToDestAngle				: float;
	
	var flightMaxDuration			: float;
	var flightStartTime				: float;
	var flightDuration				: float;
	
	
	latent function Main() : EBTNodeStatus
	{
		var random : int;
		var shouldLand : bool;
		var traceStartPos, traceEndPos, traceEffect, normal, groundLevel : Vector;
		var groundLevelFound : bool;
		var landingPointSet : bool;
		
		npc = GetNPC();
		anchorPointPos = anchorPoint.GetWorldPosition();
		
		// Z of anchorPoint can be under terrain so it must be checked
		traceStartPos = anchorPointPos;
		traceEndPos = anchorPointPos;
		traceStartPos.Z += 200;
		
		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			anchorPointPos = traceEffect;
		}
		
		flightStartTime = this.GetLocalTime();
		shouldLand = false;
		groundLevelFound = false;
		landingPointSet = false;
		
		// initial dest
		npcPos = npc.GetWorldPosition();
		anchorPointToNpcVector = npcPos - anchorPointPos;
		anchorPointToNpcVector.Z = 0;
		dest = anchorPointPos + VecNormalize( anchorPointToNpcVector ) * distance + VecNormalize( npc.GetHeadingVector() ) * frontalHeadingOffset;
		dest.Z = dest.Z + altitude;
		
		while( true )
		{
			npcPos = npc.GetWorldPosition();
			npcToDestVector = dest - npcPos;		
			npcToDestVector2 = npcToDestVector;
			npcToDestVector2.Z = 0;
			npcToDestDistance = VecDistance( npcPos, dest );
			
			// local ground level
			groundLevelFound = false;
			traceStartPos = npcPos;
			traceEndPos = npcPos;
			traceEndPos.Z -= 20;
			
			if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
			{
				groundLevel = traceEffect;
				groundLevelFound = true;
			}
			
			if( !shouldLand )
			{
				// if close to dest - pick new dest
				if( npcToDestDistance < 8.0 )
				{
					((CMovingAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( false );
					
					anchorPointToNpcVector = npcPos - anchorPointPos;
					anchorPointToNpcVector.Z = 0;
					dest = anchorPointPos + VecNormalize( anchorPointToNpcVector ) * distance + VecNormalize( npc.GetHeadingVector() ) * frontalHeadingOffset;
					
					// randomizing
					random = RandRange( randomHeight ) - ( randomHeight / 2 );
					dest.Z = dest.Z + altitude + random;
					
					// if new dest is too close
					npcToDestDistance = VecDistance( npcPos, dest );
					if( npcToDestDistance < 15.0 )
					{
						dest = dest + VecNormalize( npc.GetHeadingVector() ) * frontalHeadingOffset; 
					}
					
					// if new dest is outside encounter
					if( !anchorPointAC.TestPointOverlap( dest ) )
					{
						dest = anchorPointPos;
					}

					// if new dest is too low
					if( dest.Z - anchorPointPos.Z < 5 )
					{
						dest.Z = dest.Z + 10;
					}
					
					// fly up "cliff" 
					if ( ( anchorPointPos.Z - npcPos.Z ) >= 5.f )
					{
						dest = npcPos;
						dest.Z = dest.Z + 15.f;
					}
					
					npcToDestVector = dest - npcPos;		
					npcToDestVector2 = npcToDestVector;
					npcToDestVector2.Z = 0;
					npcToDestDistance = VecDistance( npcPos, dest );	
				}
			}
			else // shouldLand = true
			{
				((CMovingAgentComponent)npc.GetMovingAgentComponent()).SnapToNavigableSpace( false );
				
				// pick dest inside encounter and set it
				if( !landingPointSet )
				{
					random = RandRange( 10 ) - 5;
					dest = anchorPointPos;
					dest.X += random;
					dest.Y += random;
					
					landingPointSet = true;
				}
				
				if( groundLevelFound )
				{
					dest.Z = groundLevel.Z;
				}
				else
				{
					dest.Z = 0;
				}

				npcToDestVector = dest - npcPos;		
				npcToDestVector2 = npcToDestVector;
				npcToDestVector2.Z = 0;
				npcToDestDistance = VecDistance( npcPos, dest );
				
				if( npcPos.Z - dest.Z < landingGroundOffset )
				{
					return BTNS_Completed;
				}
			}
			
			UsePathfinding( npcPos, dest, 2.0 );
			CalculateBehaviorVariables( dest );
			
			Sleep( 0.1f );
			
			// finish flight after specified time
			flightDuration = this.GetLocalTime();
			
			if( flightDuration > flightStartTime + flightMaxDuration && flightMaxDuration != -1.0 )
			{
				shouldLand = true;
			}
		}
		
		return BTNS_Active;
	}

	function DoTrace( out dest : Vector )
	{
		var groundPosition, offsetGroundPosition, ceilingPosition, ceilingTrace, normal : Vector;
		var npc : CNewNPC = GetNPC();
		var vecDiff : Vector;
		
		((CMovingAgentComponent)npc.GetMovingAgentComponent()).GetPathPointInDistance( 10.f, groundPosition );
		
		offsetGroundPosition = groundPosition;
		offsetGroundPosition.Z += 1.5f;
		
		ceilingTrace = offsetGroundPosition;
		ceilingTrace.Z += 20.f;
		
		if( !theGame.GetWorld().StaticTrace( ceilingTrace, offsetGroundPosition, ceilingPosition, normal ) )
		{
			dest = groundPosition;
			dest.Z += altitude;
		}
		else
		{
			dest = groundPosition;
			vecDiff = ceilingPosition - groundPosition;
			if ( vecDiff.Z < ( altitude + 3 ) )
			{
				dest.Z += vecDiff.Z / 2.f;
			}
			else
			{
				dest.Z += altitude;
			}			
		}
		
		npc.GetVisualDebug().AddSphere( 'ground', 1.f, offsetGroundPosition, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddLine( 'line', offsetGroundPosition, ceilingTrace, true, Color( 255, 0, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'ceiling', 1.f, ceilingPosition, true, Color( 0, 255, 0 ), 0.2f );
		npc.GetVisualDebug().AddSphere( 'destination', 1.f, dest, true, Color( 0, 0, 255 ), 0.2f );
	}
	
	
}

class CBTTaskFlyAroundDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlyAround';

	editable var distance				: CBehTreeValFloat;
	editable var altitude				: CBehTreeValFloat;
	editable var tolerance				: CBehTreeValFloat;
	editable var frontalHeadingOffset	: CBehTreeValInt;
	editable var landingGroundOffset	: CBehTreeValFloat;
	editable var randomHeight			: CBehTreeValInt;
	editable var flightMaxDuration		: CBehTreeValFloat;
	
	var anchorPoint	: CEncounter;
	var anchorPointAC : CComponent;
	
	default landingGroundOffset = 10.0;
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskFlyAround;
		task = (CBTTaskFlyAround) taskGen;
		
		anchorPoint = (CEncounter)GetObjectByVar( 'encounter' );
		anchorPointAC = anchorPoint.GetComponentByClassName('CTriggerAreaComponent');
		
		task.anchorPoint = anchorPoint;
		task.anchorPointAC = (CAreaComponent)anchorPointAC;
	}
};