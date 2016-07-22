/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

/*
	Increases damage & resistances vs specters
*/
class W3Mutagen28_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen28;
	default dontAddAbilityOnTarget = true;
	
	public function GetMonsterDamageBonus(mc : EMonsterCategory) : SAbilityAttributeValue
	{
		var min, max : SAbilityAttributeValue;
		var attName : name;
		
		attName = MonsterCategoryToAttackPowerBonus(mc);
		
		if(!IsNameValid(attName))
			return min;
			
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, attName, min, max);
		return GetAttributeRandomizedValue(min, max);
	}
	
	public function GetProtection(mc : EMonsterCategory, dmgType : name, isDoT : bool, out bonusResist : float, out bonusReduct : float)
	{
		var res : ECharacterDefenseStats;
		var atts : array<name>;
		var min, max : SAbilityAttributeValue;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var pointRes, percRes : name;
		
		bonusResist = 0;
		bonusReduct = 0;
	
		//only against specters!
		if(mc != MC_Specter)
			return;
			
		//get resistance attribute names (for points and for percents)
		res = GetResistForDamage(dmgType, isDoT);
		pointRes = ResistStatEnumToName(res, true);
		percRes = ResistStatEnumToName(res, false);
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, atts);
		
		//get attribute values and check if they are resist bonus
		for(i=0; i<atts.Size(); i+=1)
		{
			if(pointRes == atts[i])
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], min, max);
				bonusReduct = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			}
			else if(percRes == atts[i])
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], min, max);
				bonusResist = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			}
		}
	}
}