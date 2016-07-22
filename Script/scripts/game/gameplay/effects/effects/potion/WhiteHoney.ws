/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

//Removes all potion effects and clears toxicity
class W3Potion_WhiteHoney extends CBaseGameplayEffect
{
	default effectType = EET_WhiteHoney;
	
	/**
		Highly custom - overrides parent without calling super.
	*/
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var exceptions : array<CBaseGameplayEffect>;
		var wolf : CBaseGameplayEffect;
		
		super.OnEffectAdded(customParams);
		
		//cannot cache as we can drink it from inventory now and afterwards drink more pots before leaving IU (game is paused, no update calls)
		target.ForceSetStat(BCS_Toxicity, 0);
		
		//remove potion buffs
		exceptions.PushBack(this);
		wolf = thePlayer.GetBuff(EET_WolfHour);
		if(wolf)
			exceptions.PushBack(wolf);
			
		thePlayer.RemoveAllPotionEffects(exceptions);
	}
}