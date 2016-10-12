/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen21_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen21;
	
	
	public final function Heal()
	{
		var vitality, staminaRegen : float;
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'healingRatio', min, max);
		vitality = target.GetStatMax(BCS_Vitality);
		vitality *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		staminaRegen = GetWitcherPlayer().CorrectStaminaRegen(target.GetAttributeValue('staminaRegen'));

		if (target.HasBuff(EET_GryphonSetBonus))
			staminaRegen *= 1.4f;
		
		vitality *= 18 / staminaRegen;
		
		target.GainStat(BCS_Vitality, vitality);
	}
}