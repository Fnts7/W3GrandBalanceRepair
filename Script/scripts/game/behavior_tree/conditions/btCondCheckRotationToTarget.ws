class BTCondCheckRotationToTarget extends IBehTreeTask
{
	var ifNot : bool;
	var toleranceAngle : float;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var res : bool;
		
		res = npc.IsRotatedTowardsPoint( target.GetWorldPosition(), toleranceAngle );
		
		if (ifNot)
			return !res;
		else
			return res;
	}
}

class BTCondCheckRotationToTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondCheckRotationToTarget';

	editable var ifNot : bool;
	editable var toleranceAngle : float;
	
	default ifNot = true;
	default toleranceAngle = 20;	
}