/***********************************************************************/
/** Copyright © 2014
/** Author : Ryan Pergent
/***********************************************************************/

class W3Effect_VitalityDrain extends W3DamageOverTimeEffect
{
	//Vitality draining
	default effectType 		= EET_VitalityDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		//if target received no damage then we shut off the particle effect
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			PlayTargetFX();
		}
	}
}