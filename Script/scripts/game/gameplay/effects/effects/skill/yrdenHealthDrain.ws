/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0.9 + RandF() / 5;	
		
		
		SetEffectValue();
	}
	
	
	protected function SetEffectValue()
	{
		var witcher : W3PlayerWitcher;
		var sp : SAbilityAttributeValue;
		
		witcher = (W3PlayerWitcher)GetCreator();
		
		effectValue = thePlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s11);
		
		if (witcher)
		{
			sp = witcher.GetTotalSignSpellPower(S_Magic_3);
			effectValue.valueAdditive = witcher.GetSkillLevel(S_Magic_s11) * witcher.GetLevel() * sp.valueMultiplicative / 2.5f;
		}
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	
			target.PlayEffect('yrden_shock');
		}
	}
}