class W3Effect_Mutation11Immortal extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Immortal;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded( customParams );
		
		//set immortality
		target.SetImmortalityMode( AIM_Immortal, AIC_Mutation11 );
	}
	
	event OnEffectRemoved()
	{
		//reset immortality
		target.SetImmortalityMode( AIM_None, AIC_Mutation11 );
		
		super.OnEffectRemoved();
	}
}