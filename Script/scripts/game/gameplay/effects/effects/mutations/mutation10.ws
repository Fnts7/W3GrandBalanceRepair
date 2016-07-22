class W3Effect_Mutation10 extends CBaseGameplayEffect
{
	private var bonusPerPoint : float;

	default effectType = EET_Mutation10;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_stat_boost', min, max );
		bonusPerPoint = min.valueMultiplicative;
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
	
	public function GetStacks() : int
	{
		return RoundMath( 100 * bonusPerPoint * target.GetStat( BCS_Toxicity ) );
	}
}