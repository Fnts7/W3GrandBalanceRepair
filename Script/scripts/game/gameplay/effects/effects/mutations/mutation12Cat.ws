class W3Effect_Mutation12Cat extends W3Potion_Cat
{
	default effectType = EET_Mutation12Cat;
	default isPositive = true;
	default isPotionEffect = false;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
}