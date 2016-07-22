//>--------------------------------------------------------------------------
// BTCondAerialSpaceIsFree
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if there is free aerial space at a position
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 24-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondAerialSpaceIsFree extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var localOffset 			: Vector;	
	var checkLineOfSight		: bool;
	var cylinderRadiusToCheck	: float;
	var cylinderHeightToCheck	: float;
	var checkedNode 			: ETargetName;
	var namedTarget				: name;
	
	private var m_CollisionGroupNames 	: array<name>;
	private var m_LastTestTime			: float;
	private var m_LastTestResult		: bool;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function Initialize()
	{
		m_CollisionGroupNames.PushBack('Terrain');
		m_CollisionGroupNames.PushBack('Foliage');
		m_CollisionGroupNames.PushBack('Static');
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_npc 			: CNewNPC = GetNPC();
		var l_matrix		: Matrix;
		var l_pos			: Vector;
		var l_posToTest 	: Vector;
		var l_worldOffset	: Vector;
		var l_ground 		: Vector;
		var l_normal 		: Vector;
		var l_npcRadius		: float;
		var l_rotation		: EulerAngles;
		var l_temp			: Vector;
		var l_toPosVect		: Vector;
		var l_heading		: float;
		
		if( theGame.GetEngineTimeAsSeconds() - m_LastTestTime > 1.0f )
		{		
			switch ( checkedNode )
			{
				case TN_Me:
					l_pos 		= l_npc.GetWorldPosition();
					l_matrix 	= l_npc.GetLocalToWorld();
					break;
				case TN_CombatTarget:
					l_pos 		= GetCombatTarget().GetWorldPosition();
					l_matrix 	= GetCombatTarget().GetLocalToWorld();
					break;
				case TN_ActionTarget:
					l_pos 		= GetActionTarget().GetWorldPosition();
					l_matrix 	= GetActionTarget().GetLocalToWorld();
					break;
				case TN_CustomTarget:
					GetCustomTarget( l_pos, l_heading );
					l_matrix 	= l_npc.GetLocalToWorld();
					break;
				case TN_NamedTarget:
					l_pos 		= GetNamedTarget( namedTarget ).GetWorldPosition();					
					l_matrix 	= GetNamedTarget( namedTarget ).GetLocalToWorld();
					break;
			}
			
			l_worldOffset 	= VecTransform( l_matrix, localOffset);
			l_posToTest 	= l_worldOffset;
			
			l_npcRadius 	= l_npc.GetRadius();
			
			m_LastTestResult = true;
			
			// If the space is not free
			if( theGame.GetWorld().SweepTest( l_posToTest , l_posToTest + Vector(0,0, cylinderHeightToCheck), cylinderRadiusToCheck, l_temp, l_temp ) )
			{	
				// Debug
				//l_npc.GetVisualDebug().AddBox( 'TakeOffArea', Vector( cylinderRadiusToCheck, cylinderRadiusToCheck, cylinderHeightToCheck), l_posToTest, l_rotation, true, Color(255,0,0), 10 );
				m_LastTestResult =  false;
			}		
			
			// If I cannot reach the position
			if ( m_LastTestResult == true && checkLineOfSight && theGame.GetWorld().SweepTest( l_pos , l_posToTest, l_npcRadius, l_temp, l_temp, m_CollisionGroupNames ) )
			{
				// Debug
				l_toPosVect = l_posToTest - l_pos ;
				l_rotation = VecToRotation( l_toPosVect );
				//l_npc.GetVisualDebug().AddBox( 'TakeOffSight', Vector( cylinderRadiusToCheck, cylinderRadiusToCheck, cylinderHeightToCheck), l_posToTest, l_rotation, true, Color(255,0,0), 10 );
				m_LastTestResult =  false;
			}
			
			//l_npc.GetVisualDebug().AddBox( 'TakeOffArea', Vector( cylinderRadiusToCheck, cylinderRadiusToCheck, cylinderHeightToCheck), l_posToTest, l_rotation, true, Color(255,255,0), 10 );		
		}
		
		return m_LastTestResult;
		
	}
	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondAerialSpaceIsFreeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondAerialSpaceIsFree';

	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var localOffset 			: Vector;
	editable var checkLineOfSight		: bool;
	editable var cylinderRadiusToCheck	: float;
	editable var cylinderHeightToCheck	: float;
	editable var checkedNode 			: ETargetName;
	editable var namedTarget			: name;
	
	default checkLineOfSight 		= true;
	default checkedNode				= TN_Me;
	
	hint localOffset 				= "Offset from me (in local). x is right, y is forward, the z value is not taken into consideration";
	hint cylinderRadiusToCheck 		= "World Up oriented cylinder to test for free space";
	hint cylinderHeightToCheck 		= "World Up oriented cylinder to test for free space";
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
}
