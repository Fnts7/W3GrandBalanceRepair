/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Mutagen25_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen25;
	default dontAddAbilityOnTarget = true;
	
	private var attackPowerBonus : SAbilityAttributeValue;
	
	public function GetAttackPowerBonus() : SAbilityAttributeValue
	{
		return attackPowerBonus;
	}
	
	public function CacheSettings()
	{
		var min, max : SAbilityAttributeValue;
		
		super.CacheSettings();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, PowerStatEnumToName(CPS_AttackPower), min, max);
		attackPowerBonus = GetAttributeRandomizedValue(min, max);
	}
}