/****************************************/
/** Copyright © 2016
/** Author : Andrzej Zawadzki
/****************************************/

class W3Effect_Mutation11Debuff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Debuff;
	default isNeutral = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration( setInitialDuration );

		//FOR DEBUG ONLY
		if( FactsQuerySum( "debug_mut11_no_cooldown" ) )
		{
			duration = 0.00001f;
			initialDuration = duration;
		}
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		
		super.OnEffectRemoved();
	}
}	