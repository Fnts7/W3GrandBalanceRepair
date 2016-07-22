/***********************************************************************/
/** Copyright © 2014
/** Author : Tomasz Kozera
/***********************************************************************/

//Buff added from skill. Increases max vitality when toxicity health drain is present. Adds ability each time per skill level.
class W3Effect_IgnorePain extends W3ChangeMaxStatEffect
{
	default effectType = EET_IgnorePain;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		var witcher : W3PlayerWitcher;
		var level : int;
		
		witcher = (W3PlayerWitcher)target;
	
		if(!witcher)
		{
			LogEffects("W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			target.RemoveBuff(EET_IgnorePain, true);
			return false;
		}
		
		level = witcher.GetSkillLevel(S_Alchemy_s20);
		
		//add additional ability stacks so that we get 1 per skill level
		if(level > 1)
			witcher.AddAbilityMultiple(abilityName, level - 1);
		
		super.OnEffectAdded(customParams);
	}
	
	public final function OnSkillLevelChanged(delta : int)
	{
		var i : int;
		
		for(i=0; i<Abs(delta); i+=1)
		{
			if(delta > 0)
			{
				thePlayer.AddAbilityMultiple(abilityName, delta);
			}
			else
			{
				thePlayer.RemoveAbilityMultiple(abilityName, -delta);
			}
		}
	}
		
	event OnEffectRemoved()
	{
		var percents : float;
		var level : int;
	
		percents = target.GetStatPercents(BCS_Vitality);
		
		super.OnEffectRemoved();
		
		level = GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20);
		
		//remove additional ability stacks so that we get 1 per skill level
		if(level > 1)
			target.RemoveAbilityMultiple(abilityName, level);
		
		//update health & health percents		
		target.UpdateStatMax(BCS_Vitality);
		target.ForceSetStat(BCS_Vitality, percents * target.GetStatMax(BCS_Vitality));
	}
}