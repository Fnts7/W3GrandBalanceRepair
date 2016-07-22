/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

//decreases duration of control impairing effects to bare minimum
class W3Mutagen13_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen13;
	
	//one test is done on mutagen add, another in effect manager on buff added
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var buffs : array<CBaseGameplayEffect>;
		var i : int;
		
		super.OnEffectAdded(customParams);
		
		buffs = target.GetBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			if(IsEffectTypeAffected(buffs[i].GetEffectType()))
				buffs[i].SetTimeLeft(GetForcedDuration());
		}
	}
	
	//duration which is being forced on affected effects
	public function GetForcedDuration() : float
	{
		//if the value is too low effects might block because they get removed before animation request is processed
		//the fastest fix is to set a higher value. If this won't work then we'll have to add timers that wait for critical
		//anim started and then apply forced duration
		return 0.5;
	}
	
	//checks if given effect type is affected by this mutagen
	public function IsEffectTypeAffected(effectType : EEffectType) : bool
	{
		switch(effectType)
		{
			case EET_Blindness:
			case EET_WraithBlindness:
			case EET_Confusion:
			case EET_CounterStrikeHit:
			case EET_HeavyKnockdown:
			case EET_Hypnotized:
			case EET_Immobilized:
			case EET_Knockdown:
			case EET_LongStagger:
			case EET_Paralyzed:
			case EET_Stagger:
			case EET_Slowdown:				
				return true;
			default :
				return false;
		}
	}
}