/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		
	private saved var customDuration : float;							
	private saved var customAbilityName : name;							

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	
	
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
		
		
		if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)		
			aardPower = effectValue.valueMultiplicative * ( 1 - resistance ) / (1 + effectValue.valueAdditive/100);
		else
			aardPower = creatorPowerStat.valueMultiplicative * ( 1 - resistance ) / (1 + creatorPowerStat.valueAdditive/100);
		
		npc = (CNewNPC)target;
		
		if (IsSignEffect() && npc)
		{
			appliedType = WitcherSignApplicatorLogic(aardPower, npc);
		}
		else
		{
			if(npc && npc.HasShieldedAbility() )
			{
				if ( npc.IsShielded(GetCreator()) )
				{
					if ( aardPower >= 1.2 )
						appliedType = EET_LongStagger;
					else
						appliedType = EET_Stagger;
				}
				else
				{
					if ( aardPower >= 1.2 )
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
		}
		
		appliedType = ModifyHitSeverityBuff(target, appliedType);
		
		
		params.effectType = appliedType;
		params.creator = GetCreator();
		params.sourceName = sourceName;
		params.isSignEffect = isSignEffect;
		params.customPowerStatValue = creatorPowerStat;
		if (IsSignEffect() && npc && params.customPowerStatValue.valueMultiplicative > 2.0f)
			params.customPowerStatValue.valueMultiplicative = 2.0f + LogF( (params.customPowerStatValue.valueMultiplicative - 2.0f) + 1);			
		params.customAbilityName = customAbilityName;
		params.duration = customDuration;
		params.effectValue = customEffectValue;	
		
		target.AddEffectCustom(params);
		
		
		
		isActive = true;
		duration = 0;
	}
	
	protected function WitcherSignApplicatorLogic(power : float, npc : CNewNPC) : EEffectType
	{
		var applyStrongest, applySecondStrong : bool;

		applyStrongest = RandF() < 0.2f;
		applySecondStrong = RandF() < 0.1f;

		if (power > 2.0f)
		{
			power = 2.0f + LogF ((power - 2.0f) + 1);
		}

		power *= RandF();

		if(npc && npc.HasShieldedAbility() )
		{
			if ( npc.IsShielded(GetCreator()) )
			{
				if (applyStrongest || applySecondStrong || power >= 1.35f )
					return EET_LongStagger;
				else
					return EET_Stagger;
			}
			else
			{
				if (applyStrongest || power >= 1.35f )
					return EET_Knockdown;
				if (applySecondStrong || power >= 0.85f )
					return EET_LongStagger;
				else
					return EET_Stagger;
			}
		}
		else if ( target.HasAbility( 'mon_type_huge' ) )
		{
			if (applyStrongest || applySecondStrong || power >= 1.35f )
				return EET_LongStagger;
			else
				return EET_Stagger;
		}
		else if ( target.HasAbility( 'WeakToAard' ) )
		{
			if (applyStrongest || applySecondStrong || power >= 1.35f)
				return EET_HeavyKnockdown;
			else
				return EET_Knockdown;
		}
		else if(applyStrongest || power >= 1.6f )
		{
			return EET_HeavyKnockdown;
		}
		else if(applySecondStrong || power >= 1.1f )
		{
			return EET_Knockdown;
		}
		else if( power >= 0.6f )
		{
			return EET_LongStagger;
		}
		else
		{
			return EET_Stagger;
		}
	}
			
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}