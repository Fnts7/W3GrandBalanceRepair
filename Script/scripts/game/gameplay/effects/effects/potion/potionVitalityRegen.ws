/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Potion_VitalityRegen extends W3RegenEffect
{
	protected var combatRegen, nonCombatRegen : SAbilityAttributeValue;			//effectValues for combat and non-combat
	protected var playerTarget : CR4Player;

	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		var min, max : SAbilityAttributeValue;
							
		super.CacheSettings();
		
		//find which stat we're regenerating - regenstat set in child classes but let's make sure
		if(regenStat == CRS_Vitality)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			
			for(i=0; i<att.Size(); i+=1)
			{
				if(att[i] == 'vitalityCombatRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					combatRegen = GetAttributeRandomizedValue(min, max);
				}
				else if(att[i] == 'vitalityRegen')
				{
					dm.GetAbilityAttributeValue(abilityName, att[i], min, max);
					nonCombatRegen = GetAttributeRandomizedValue(min, max);
					attributeName = att[i];
				}
			}
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		playerTarget = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		playerTarget = (CR4Player)target;
	}
	
	event OnUpdate(deltaTime : float)
	{
		if(playerTarget.IsInCombat())
			effectValue = combatRegen;
		else
			effectValue = nonCombatRegen;
			
		super.OnUpdate(deltaTime);
	}
}