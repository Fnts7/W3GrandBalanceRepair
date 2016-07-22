/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

// increases focus generation
class W3Potion_MariborForest extends CBaseGameplayEffect
{
	default effectType = EET_MariborForest;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var min, max : SAbilityAttributeValue;
		var adrenalineBonus : float;
		
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() == 3)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'focus_on_drink', min, max);
			adrenalineBonus = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			target.GainStat(BCS_Focus, adrenalineBonus);
		}
	}
}