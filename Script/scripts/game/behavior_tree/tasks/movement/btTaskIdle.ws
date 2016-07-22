/////////////////////////////////////////////////////////////////////
// Idle
/////////////////////////////////////////////////////////////////////
class CBTTaskIdle extends IBehTreeTask
{
	var toleranceAngle : float;
	var checkRotation	: bool;
	
	var isMoving : bool;
	
	default isMoving = false;

	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var temp : bool;
		
		return !npc.IsRotatedTowards( target, toleranceAngle );
	}
	
	function Rotate() : bool
	{
		var npc : CNewNPC = GetNPC();
		var npcPos, vec : Vector;
		var curRot, rot : EulerAngles;
		var target : CActor = GetCombatTarget();
		var temp : float;
		
		npcPos = npc.GetWorldPosition();
				
		vec = target.GetWorldPosition() - npcPos;
		rot = VecToRotation( vec );
		
		curRot = npc.GetWorldRotation();
		
		if( AbsF( AngleDistance( curRot.Yaw, rot.Yaw )) > toleranceAngle/2 )
		{
			if ( !isMoving )
			{
				isMoving = true;
				temp = AngleDistance( curRot.Yaw, rot.Yaw );
				if ( temp >= 120 )
				{
					//rotate r 180
					npc.SetBehaviorVariable( 'rotateAngle', 5 );
				}
				else if ( temp >= 60 )
				{
					//rotate r 90
					npc.SetBehaviorVariable( 'rotateAngle', 4 );
				}
				else if ( temp >= 0 )
				{
					//rotate r 45
					npc.SetBehaviorVariable( 'rotateAngle', 3 );
				}
				else if ( temp >= -60 )
				{
					//rotate l 45
					npc.SetBehaviorVariable( 'rotateAngle', 2 );
				}
				else if ( temp >= -120 )
				{
					//rotate l 90
					npc.SetBehaviorVariable( 'rotateAngle', 1 );
				}
				else
				{
					//rotate l 180
					npc.SetBehaviorVariable( 'rotateAngle', 0 );
				}
			}
			
			if( npc.RaiseEvent( 'Rotate' ) )
			{
				return true;
			}
			return false;
		}
		
		isMoving = false;
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var npcPos, vec : Vector;
		var curRot, rot : EulerAngles;
		var target : CActor = GetCombatTarget();
		var temp : float;
		
		while(true)
		{
			if ( !npc.IsRotatedTowards( target, toleranceAngle ) )
			{
				return BTNS_Completed;
			}
			
			Sleep(0.5);
		}
		
		return BTNS_Failed;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		//npc.RaiseEvent('RotateEnd');
		isMoving = false;
	}	
	
}

class CBTTaskIdleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIdle';

	editable var toleranceAngle : float;
	editable var checkRotation	: bool;
	
	default toleranceAngle = 12;
	default checkRotation = true;
}


