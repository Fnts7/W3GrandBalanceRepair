//>--------------------------------------------------------------------------
// BTCondCheckTargetRotationToActor
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check combat Target's Rotation to me
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 27-February-2014
//---------------------------------------------------------------------------
class BTCondCheckTargetRotationToActor extends IBehTreeTask
{
	var toleranceAngle : float;
	
	function IsAvailable() : bool
	{
		var l_npc 		: CNewNPC = GetNPC();
		var l_target 	: CActor = GetCombatTarget();
		var l_res 		: bool;
		
		l_res = l_target.IsRotatedTowards( l_npc, toleranceAngle );
		
		return l_res;
	}
}

class BTCondCheckTargetRotationToActorDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondCheckTargetRotationToActor';

	editable var toleranceAngle : float;
	
	default toleranceAngle = 20;
}