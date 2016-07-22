class W3Effect_ToxicityVenom extends CBaseGameplayEffect
{
	default effectType = EET_ToxicityVenom;
	default isNegative = true;
	default dontAddAbilityOnTarget = false;
	
	event OnUpdate( dt : float )
	{
		var maxTox, toxToAdd : float;
		
		super.OnUpdate( dt );
		
		maxTox = target.GetStatMax( BCS_Toxicity );
		toxToAdd = effectValue.valueAdditive + effectValue.valueMultiplicative * maxTox;
		toxToAdd *= dt;
		target.GainStat( BCS_Toxicity, toxToAdd );
	}
}