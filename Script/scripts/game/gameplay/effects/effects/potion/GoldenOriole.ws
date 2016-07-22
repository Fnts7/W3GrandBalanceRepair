/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

class W3Potion_GoldenOriole extends CBaseGameplayEffect
{
	default effectType = EET_GoldenOriole;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() < 3)
		{
			target.RemoveAllBuffsOfType(EET_Poison);
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if(GetBuffLevel() < 3)
		{
			target.RemoveAllBuffsOfType(EET_Poison);
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////  BUFF INTERACTIONS  //////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	protected function GetEffectStrength() : float
	{		
		var i : int;
		var val, tmp : SAbilityAttributeValue;
		var ret : float;
		var isPoint : bool;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		
		dm.GetAbilityAttributes(abilityName, atts);
		
		//get this effect value
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsNonPhysicalResistStat(ResistStatNameToEnum(atts[i], isPoint)))
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], val, tmp);
				
				if(isPoint)
					ret += CalculateAttributeValue(val);
				else
					ret += 100 * CalculateAttributeValue(val);
			}
		}

		return ret;
	}
}