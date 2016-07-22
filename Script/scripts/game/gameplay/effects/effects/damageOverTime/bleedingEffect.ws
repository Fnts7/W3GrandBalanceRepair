/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

class W3Effect_Bleeding extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding;
	default resistStat = CDS_BleedingRes;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if( target == thePlayer)
		 Log("");
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		//if target received no damage then we shut off the particle effect
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}