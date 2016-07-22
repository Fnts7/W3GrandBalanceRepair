﻿/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

//health regen
class W3Effect_WellFed extends W3RegenEffect
{
	default effectType = EET_WellFed;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
	}
	
	event OnPerk15Unequipped()
	{
		SetTimeLeft( initialDuration );
		duration = initialDuration;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		if( isOnPlayer && GetWitcherPlayer() )
		{	
			// Perk 15 - increases food buff time to X minutes. 
			if( GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
			{
				min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration', false, false );
				duration = min.valueAdditive;
			}
			if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
				duration *= 1 + min.valueMultiplicative;
			}
		}
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		var dm : CDefinitionsManagerAccessor;
		var thisLevel, otherLevel : int;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		eff = (W3Effect_WellFed)e;
		dm.GetAbilityAttributeValue(abilityName, 'level', min, max);
		thisLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		dm.GetAbilityAttributeValue(eff.abilityName, 'level', min, max);
		otherLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		
		if(otherLevel >= thisLevel)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
}
