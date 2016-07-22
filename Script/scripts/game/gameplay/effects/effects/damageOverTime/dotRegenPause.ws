/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_DoTHPRegenReduce extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_DoTHPRegenReduce;
	default attributeName = '';
	
	public function GetEffectValue() : SAbilityAttributeValue
	{
		return effectValue;
	}
}