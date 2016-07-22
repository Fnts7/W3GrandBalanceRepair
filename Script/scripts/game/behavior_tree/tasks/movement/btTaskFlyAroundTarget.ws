// CBTTaskFlyAroundTarget

class CBTTaskFlyAroundTarget extends CBTTaskVolumetricMove
{
	var distance					: float;
	var frontalHeadingOffset		: int;
	var randomFactor				: int;
	var height						: float;
	var randomHeightAmplitude		: float;
	
	
	private var collisionGroupsNames : array<name>;
	
	latent function Main() : EBTNodeStatus
	{
		var npc 						: CNewNPC;
		var npcPos						: Vector;	
		var anchorPointPos				: Vector;
		
		var anchorPointToDestDist		: float;
		var anchorPointToNpcVector		: Vector;
		var crossZ						: float;
		
		var random : float;
		var traceStartPos, traceEndPos, traceEffect, normal, heading : Vector;
		var world					: CWorld;
		var waterLevel 				: float;
		var groundLevel				: float;
		var groundLevelFound		: bool;
		var dest					: Vector;
		var threshold 				: float;
		
		var fallingBack				: bool;		
		var toDestVector			: Vector;
		var toDestHeading			: float;
		var myHeading				: float;
		
		npc = GetNPC();
		
		world = theGame.GetWorld();
		
		threshold = 0;
		
		while( true )
		{
			anchorPointPos = GetCombatTarget().GetWorldPosition();
			npcPos = npc.GetWorldPosition();
			waterLevel = world.GetWaterLevel(npcPos);
			
			anchorPointToNpcVector = npcPos - anchorPointPos;
			anchorPointToNpcVector.Z = 0;
			anchorPointToNpcVector = VecNormalize( anchorPointToNpcVector );
			heading = npc.GetHeadingVector();
			dest = anchorPointPos + anchorPointToNpcVector * distance;// + VecNormalize( npc.GetHeadingVector() ) * frontalHeadingOffset;
			// determine at which side we are steering now (to continue doing so)
			crossZ = ( anchorPointToNpcVector.X * heading.Y ) - (anchorPointToNpcVector.Y * heading.X );
			if ( ( crossZ >= 0.0 && !fallingBack ) || ( crossZ < 0.0 && fallingBack ) )
			{
				// steer left
				dest.X = dest.X - anchorPointToNpcVector.Y * frontalHeadingOffset;
				dest.Y = dest.Y + anchorPointToNpcVector.X * frontalHeadingOffset;
			}
			else
			{
				// steer right
				dest.X = dest.X + anchorPointToNpcVector.Y * frontalHeadingOffset;
				dest.Y = dest.Y - anchorPointToNpcVector.X * frontalHeadingOffset;
			}
			
			if( fallingBack )
			{
				// I am done changing heading when facing the current dest.
				toDestVector 	= dest - npcPos;				
				toDestHeading 	= VecHeading( toDestVector );
				
				if( AbsF( AngleDistance( toDestHeading, myHeading ) ) < 90 )
				{
					fallingBack = false;
				}
			}	
			
			// randomizing
			random = RandRange( randomFactor ) - ( randomFactor / 2 );
			
			dest.X = dest.X + random;
			dest.Y = dest.Y + random;
			
			random = RandF()*randomHeightAmplitude - ( randomHeightAmplitude / 2 );
			
			dest.Z = dest.Z + height + random;
			
			// if new dest is too close
			anchorPointToDestDist = VecDistance( anchorPointPos, dest );
			if( anchorPointToDestDist < distance )
			{
				dest = dest + VecNormalize( dest - anchorPointPos ) * (distance - anchorPointToDestDist); 
			}
			
			//traceStartPos = npcPos;
			traceStartPos = dest;
			traceEndPos = traceStartPos;
			
			traceEndPos.Z -= 20;
			
			if( world.StaticTrace( traceStartPos, traceEndPos, traceEffect, normal, collisionGroupsNames ) )
			{
				groundLevel = traceEffect.Z;
				groundLevelFound = true;
			}
			
			if ( groundLevel < waterLevel )
			{
				groundLevel = waterLevel;
				groundLevelFound = true;
			}
			
			if ( groundLevelFound  )
			{
				if( groundLevel > anchorPointPos.Z )
				{
					dest.Z += groundLevel - anchorPointPos.Z;
				}
				
				if ( dest.Z < groundLevel + threshold)
				{
					dest.Z = groundLevel + threshold;
				}
			}
				
			//npc.GetVisualDebug().AddLine( 'flyAround', npcPos, dest, true, Color( 255, 255, 0 ), 1.0f );
			
			// Fall back if pathfinding cannot be done			
			if( !UsePathfinding( npcPos, dest, 2.0 ) && !fallingBack )
			{
				fallingBack = true;
			}
			CalculateBehaviorVariables( dest );
			
			Sleep( 0.1f );
		}
		
		return BTNS_Active;
	}
	
	function Initialize()
	{
		collisionGroupsNames.PushBack('Terrain');
		collisionGroupsNames.PushBack('Foliage');
		collisionGroupsNames.PushBack('Static');
	}
	
}

class CBTTaskFlyAroundTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlyAroundTarget';

	editable var distance				: CBehTreeValFloat;
	editable var frontalHeadingOffset	: CBehTreeValInt;
	editable var randomFactor			: CBehTreeValInt;
	editable var height					: CBehTreeValFloat;
	editable var randomHeightAmplitude	: CBehTreeValFloat;
};