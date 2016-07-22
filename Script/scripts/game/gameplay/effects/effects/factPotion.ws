/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

class W3Potion_Fact_Params extends W3PotionParams
{
	var factName : name;
}

/*
	Adds fact for the duration of potion. This is used in quests where we
	need to keep track of the fact that hero has drunk some special potion.
*/
class W3Potion_Fact extends CBaseGameplayEffect
{
	protected saved var fact : name;				//fact to add to DB

	default isPotionEffect = true;
	default effectType = EET_Fact;
	default isPositive = true;
	default isNegative = false;
	default isNeutral = false;
		
	public function Init(params : SEffectInitInfo)
	{
		super.Init(params);
		
		//this gets overriden by CacheSettings because it's a potion so we need to set it up again
		isPositive = false;
		isNegative = false;
		isNeutral = true;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3Potion_Fact_Params;
	
		super.OnEffectAdded(customParams);
		
		params = (W3Potion_Fact_Params)customParams;
		fact = params.factName;
		effectNameLocalisationKey = "pot_name_" + fact;
		effectDescriptionLocalisationKey = "pot_desc_" + fact;
		FactsAdd(fact);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		FactsRemove(fact);
	}
	
	public function GetFactName() : name
	{
		return fact;
	}
	
	public function GetEffectNameLocalisationKey() : string
	{
		return "effect_" + NameToString(fact);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////  BUFF INTERACTIONS  //////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var factPot : W3Potion_Fact;
		
		factPot = (W3Potion_Fact)e;
		if(factPot)
		{
			//should check if it's the same fact potion here but there's only one in game and fact is set in OnEffectAdded() which
			//was not called by this point for this new effect so as a hack I'm skipping fact name comparison here
			return EI_Cumulate;
		}
		
		return EI_Pass;
	}
}