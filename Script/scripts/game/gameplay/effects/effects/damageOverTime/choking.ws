/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_Choking extends W3DamageOverTimeEffect
{
	default effectType = EET_Choking;
	default resistStat = CDS_None;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		target.PauseHPRegenEffects('choking');
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		//stop choking if player found some air
		if(target.GetStat(BCS_Air) > 0)
		{
			isActive = false;
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.ResumeHPRegenEffects('choking');
	}
}
