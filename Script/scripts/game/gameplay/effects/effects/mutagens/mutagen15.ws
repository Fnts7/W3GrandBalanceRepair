/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen15_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen15;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var witcher : W3PlayerWitcher;
	
		super.OnEffectAdded(customParams);
		
		if(target.IsInCombat() && !target.HasAbility(abilityName))
		{
			witcher = (W3PlayerWitcher)target;
			if (witcher)
				witcher.Mutagen15Init(abilityName);
		}
	}
	
	event OnEffectRemoved()
	{
		var witcher : W3PlayerWitcher;
	
		super.OnEffectRemoved();
		
		witcher = (W3PlayerWitcher)target;
		if (witcher)
			witcher.Mutagen15Drop(true, abilityName);
	}
}