/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

// increases max vitality
class W3Potion_FullMoon extends W3ChangeMaxStatEffect
{
	default effectType = EET_FullMoon;
	default stat = BCS_Vitality;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() == 3)
		{
			thePlayer.GainStat(BCS_Vitality, thePlayer.GetStat(BCS_Toxicity));
		}
	}
}