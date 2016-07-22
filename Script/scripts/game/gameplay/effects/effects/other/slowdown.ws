/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

//Slowdown will start to decay after some delay time (can be 0, -1 means never to decay).
//When this happens slowdown will gradually lose its strength and once it reaches 0 buff will remove itself.
//Regardless of that duration can be used in a normal manner.
class W3Effect_Slowdown extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;
	private saved var decayPerSec : float;			//slowdown decay per sec once delay finished
	private saved var decayDelay : float;			//delay after which slowdown decay starts
	private saved var delayTimer : float;			//delay timer
	private saved var slowdown : float;				//base slowdown

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_Slowdown;
	default attributeName = 'slowdown';
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var prc, pts : float;
		
		super.OnEffectAdded(customParams);
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_per_sec', min, max);
		decayPerSec = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_delay', min, max);
		decayDelay = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		//calc final slowdown, YRDEN resist hack
		slowdown = CalculateAttributeValue(effectValue);
		target.GetResistValue(CDS_ShockRes, pts, prc);
		slowdown = slowdown * (1 - ClampF(prc, 0, 1) );
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
		delayTimer = 0;
	}
	
	//after delay time effect will slowly decay - once it does slowdown is removed
	event OnUpdate(dt : float)
	{
		if(decayDelay >= 0 && decayPerSec > 0)
		{
			if(delayTimer >= decayDelay)
			{
				target.ResetAnimationSpeedMultiplier(slowdownCauserId);
				slowdown -= decayPerSec * dt;
				
				if(slowdown > 0)
					slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
				else
					isActive = false;
			}
			else
			{
				delayTimer += dt;
			}
		}
		
		super.OnUpdate(dt);
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		delayTimer = 0;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();		
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
}