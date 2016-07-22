/****************************************/
/** Copyright © 2016
/** Author : Andrzej Zawadzki
/****************************************/

//buff that heals player
class W3Effect_Mutation11Buff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Buff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var min, max			: SAbilityAttributeValue;		
		
		super.OnEffectAdded( customParams );
		
		//initial heal
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );		
		target.ForceSetStat( BCS_Vitality, target.GetMaxHealth() * min.valueAdditive );
	}

	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		//animation and fireworks
		GetWitcherPlayer().Mutation11StartAnimation();
		
		//unpause health regen
		target.ResumeHPRegenEffects( '', true );
		
		//start regen
		target.StartVitalityRegen();
		
		//immortal
		target.AddEffectDefault( EET_Mutation11Immortal, target, "Mutation 11", false );
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	event OnEffectRemoved()
	{
		//remove immortality buff
		target.RemoveBuff( EET_Mutation11Immortal );
		
		//add delay
		target.AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		
		super.OnEffectRemoved();
	}
}	