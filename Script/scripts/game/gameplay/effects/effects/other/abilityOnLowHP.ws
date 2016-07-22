/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

//gives ability when HP is low (below or equal to effectValue.additive)
class W3Effect_AbilityOnLowHP extends CBaseGameplayEffect
{
	private var lowHPAbilityName : name;				//name of the ability to give when HP is low

	default effectType = EET_AbilityOnLowHealth;
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;

	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		var attributes : array<name>;
	
		super.CacheSettings();
		
		attributeName = 'healthPercents';
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, attributes);
		for(i=0; i<attributes.Size(); i+=1)
		{
			if(dm.IsAbilityDefined(attributes[i]))
			{
				lowHPAbilityName = attributes[i];
				break;
			}
		}
	}

	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate(deltaTime);
		
		if(target.GetHealthPercents() * 100 <= effectValue.valueAdditive)
			target.AddAbility(lowHPAbilityName, false);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility(lowHPAbilityName);		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////  BUFF INTERACTIONS  //////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		//different ability
		if(lowHPAbilityName != ((W3Effect_AbilityOnLowHP)e).lowHPAbilityName)
			return EI_Pass;
			
		//same ability
		return super.GetSelfInteraction(e);
	}
}