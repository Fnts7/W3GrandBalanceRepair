/***********************************************************************/
/** Copyright © 2014
/** Author : Patryk Fiutowski
/***********************************************************************/

//used for swimming stamin drain
class W3Effect_StaminaDrainSwimming extends CBaseGameplayEffect
{
	private var effectValueMovement 			: SAbilityAttributeValue;			//drain when in idle pose
	private var effectValueSprinting 			: SAbilityAttributeValue;			//drain when sprinting
	private var effectValueColdWater 			: SAbilityAttributeValue;			//drain when in cold water ( skellige )

	default effectType = EET_StaminaDrainSwimming;
	default attributeName = '';
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnUpdate(deltaTime : float)
	{
		var drain					: float;
		var drainAdd 				: float;
		var drainMult 				: float = 0.f;
		var statee 					: CR4PlayerStateSwimming;
		var currStat  				: float;
		var rangeA, rangeB, rangeC 	: float;
		var currentWaterDepth		: float;	
		
		super.OnUpdate(deltaTime);
	
		
		//get swimming state object
		statee = (CR4PlayerStateSwimming)thePlayer.GetCurrentState();
		
		if(!statee)
		{
			return true;
		}
		
		//if ( !statee.ShouldDrainStamina() )
		//	return true;
		
		
		currStat = target.GetStat(BCS_SwimmingStamina);
		if ( currStat <= 0 )
		{
			statee.OnEmptyStamina();
		}
		else //AK: on request removing stamina drain
		{
			/*
			if ( !statee.CheckIdle() )
			{
				drainAdd += effectValueMovement.valueAdditive;
				drainMult += effectValueMovement.valueMultiplicative;
				
				if ( thePlayer.GetIsSprinting() )
				{
					drainAdd += effectValueSprinting.valueAdditive;
					drainMult += effectValueSprinting.valueMultiplicative;
				}
			}
			
			if ( statee.IsInColdWater() )
			{
				drainAdd += effectValueColdWater.valueAdditive;
				
				drainMult += effectValueColdWater.valueMultiplicative;
			}
			
			if ( statee.IsInTroubledWater() && !statee.IsDiving() )
			{
				rangeA 	= statee.GetWindPower(); // ranges from 0.5 to 1.4
				rangeB = rangeA - 0.5f; 		 // [ 0, 0.9 ]
				rangeC = rangeB * 1.11f * 0.03;	 // 1 / 0.9f
			}
			
			currentWaterDepth = statee.GetWaterDepth();
			currentWaterDepth = ClampF( currentWaterDepth, 0, 10 );
			currentWaterDepth *= 0.1f;
			
			drain = MaxF(0.f, drainAdd );
			
			//drain += MaxF(0.f, target.GetStatMax(BCS_SwimmingStamina) * ( drainMult + rangeC ) * currentWaterDepth );
			drain += MaxF(0.f, target.GetStatMax(BCS_SwimmingStamina) * drainMult );
			
			drain *= deltaTime;
			
			if ( drain > 0 )
				effectManager.CacheStatUpdate(BCS_SwimmingStamina, -drain);
			*/
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			isActive = false;
			return true;
		}
		
		ReadXMLValues();
		
		//target.PauseEffects(EET_AutoStaminaRegen, 'SwimmingStaminaDrain', true );
		//target.PauseEffects(EET_AutoSwimmingStaminaRegen, 'SwimmingStaminaDrain', true);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		ReadXMLValues();
	}
	
	private function ReadXMLValues()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainMovement', min, max);
		effectValueMovement = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainSprinting', min, max);
		effectValueSprinting = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaDrainColdWater', min, max);
		effectValueColdWater = GetAttributeRandomizedValue(min, max);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.ResumeStaminaRegen( 'SwimmingStaminaDrain' );
	}
}
