/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Applies knockdown type of effect. Generally use this class always when you want to apply
	knockdown/stagger etc. It checks the 'hit severity reduction' of the target and decides
	which of the buffs to apply.
*/
class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		//custom value for the effect to apply
	private saved var customDuration : float;							//custom duration for the final applied effect
	private saved var customAbilityName : name;							//custom ability name for the effect to apply

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	
	// picks the right knockdown type effect to apply and disables itself
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var aardPower	: float;
		var tags : array<name>;
		var i : int;
		var appliedType : EEffectType;
		var null : SAbilityAttributeValue;
		var npc : CNewNPC;
		var params : SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
		}
		
		//first determine the type of effect to apply - let's calculate
		if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)		//if effect value set
			aardPower = effectValue.valueMultiplicative * ( 1 - resistance ) / (1 + effectValue.valueAdditive/100);
		else
			aardPower = creatorPowerStat.valueMultiplicative * ( 1 - resistance ) / (1 + creatorPowerStat.valueAdditive/100);
		
		//for shielded enemy
		npc = (CNewNPC)target;
		if(npc && npc.HasShieldedAbility() )
		{
			if ( npc.IsShielded(GetCreator()) )
			{
				if ( aardPower >= 1.2 )//when aard is most powerfull
					appliedType = EET_LongStagger;
				else
					appliedType = EET_Stagger;
			}
			else
			{
				if ( aardPower >= 1.2 )//when aard is most powerfull
					appliedType = EET_Knockdown;
				if ( aardPower >= 1.0 )
					appliedType = EET_LongStagger;
				else
					appliedType = EET_Stagger;
			}
		}
		else if ( target.HasAbility( 'mon_type_huge' ) )
		{
			if ( aardPower >= 1.2 )
				appliedType = EET_LongStagger;
			else
				appliedType = EET_Stagger;
		}
		else if ( target.HasAbility( 'WeakToAard' ) )
		{
			appliedType = EET_Knockdown;
		}
		else if( aardPower >= 1.2 )
		{
			appliedType = EET_HeavyKnockdown;
		}
		else if( aardPower >= 0.95 )
		{
			appliedType = EET_Knockdown;
		}
		else if( aardPower >= 0.75 )
		{
			appliedType = EET_LongStagger;
		}
		else
		{
			appliedType = EET_Stagger;
		}
		
		//now let's modify it by hit severity reduction
		appliedType = ModifyHitSeverityBuff(target, appliedType);
		
		//now set the right buff with custom params if any
		params.effectType = appliedType;
		params.creator = GetCreator();
		params.sourceName = sourceName;
		params.isSignEffect = isSignEffect;
		params.customPowerStatValue = creatorPowerStat;
		params.customAbilityName = customAbilityName;
		params.duration = customDuration;
		params.effectValue = customEffectValue;	
		
		target.AddEffectCustom(params);
		
		//HACK
		//disable by changing duration, otherwise it's reported as if the buff would not apply properly (it gets disabled on adding)
		isActive = true;
		duration = 0;
	}
			
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}