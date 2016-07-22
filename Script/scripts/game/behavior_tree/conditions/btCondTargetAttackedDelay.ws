//>--------------------------------------------------------------------------
// BTCondTargetAttackedDelay
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check how long since the last time the target was attacked - no matter if the attacked failed of succeeded
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 22-January-2014
//---------------------------------------------------------------------------
class BTCondTargetAttackedDelay extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var delay 	: float;
	var wasHit 	: bool;
	
	function IsAvailable() : bool
	{
		var l_target 		: CActor = GetCombatTarget();
		var l_currentDelay 	: float;
		
		if( l_target )
		{
			if( !wasHit )
			{			
				l_currentDelay = l_target.GetDelaySinceLastAttacked();
			}
			else
			{
				l_currentDelay = l_target.GetDelaySinceLastHit();
			}
			
			return l_currentDelay >= delay;
		}
		
		return false;
	}
}

class BTCondTargetAttackedDelayDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondTargetAttackedDelay';

	editable var delay 	: float;
	editable var wasHit	: bool;
	
	hint delay 	= "Delay without being attacked";
	hint wasHit = "should only consider the delay since the last attack that hit";
}
