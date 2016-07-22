﻿/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

// Ability manager to be used with actors other than player
class W3NonPlayerAbilityManager extends W3AbilityManager
{
	private var weatherBonuses : array<SWeatherBonus>;			//list of weather bonus data used by this npc

	public function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
	{
		var ret : bool;
		var i : int;
		var npc : CNewNPC;
		
		if(!ownr)
		{
			LogAssert(false, "W3NonPlayerAbilityManager.Init: owner is NULL!!!!");
			return false;
		}
		
		npc = (CNewNPC)ownr;
		if(!npc)
		{
			LogAssert(false, "W3NonPlayerAbilityManager.Init: owner is not an NPC!!!!");
			return false;
		}
		
		//add default non-player character ability - this needs to be done before we get abilities so we need to call it before super.Init
		ownr.AddAbility(theGame.params.GLOBAL_ENEMY_ABILITY);
		
		weatherBonuses.Clear();
		
		//also add character level bonuses for each level above 1		
		if ( ! isFromLoad )
		{
			npc.AddTimer('AddLevelBonuses', 0.1, true, false, , true);
		}
		
		ret = super.Init(ownr,cStats, isFromLoad, diff);
		if(!ret)
			return false;
		
		InitSkills();
		InitWeatherBonuses();
		isInitialized = true;
		return true;
	}
	
	public function PostInit(){}
	protected function OnVitalityChanged()
	{
		( (CNewNPC)owner ).SetNpcHealthBar();
	}
	protected function OnEssenceChanged()
	{
		( (CNewNPC)owner ).SetNpcHealthBar();
	}
	protected function OnToxicityChanged(){}
	protected function OnFocusChanged(){}
	protected function OnAirChanged(){}
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////  @WEATHER BONUSES  /////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//loads weather bonuses used by this NPC and sets the initial weather check timer
	private function InitWeatherBonuses()
	{
		var dm : CDefinitionsManagerAccessor;
		var abs, atts : array<name>;
		var i,j : int;
		var abilityTags : array<name>;
		var bonus : SWeatherBonus;
	
		abs = owner.GetAbilities(false);
		dm = theGame.GetDefinitionsManager();
		dm.GetUniqueContainedAbilities( abs, atts );
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if (StrBeginsWith(NameToString(atts[i]),("WeatherBonusEffect")))
			{			
				dm.GetAbilityTags( atts[i], abilityTags );
				
				for (j = 0; j < abilityTags.Size(); j+=1)
				{
					switch (abilityTags[j])
					{
						case 'Dawn':
							bonus.dayPart = EDP_Dawn;
							break;
						case 'Noon':
							bonus.dayPart = EDP_Noon;
							break;
						case 'Dusk':
							bonus.dayPart = EDP_Dusk;
							break;
						case 'Midnight':
							bonus.dayPart = EDP_Midnight;
							break;
						case 'Clear':
							bonus.weather = EWE_Clear;
							break;	
						case 'Rain':
							bonus.weather = EWE_Rain;
							break;	
						case 'Snow':
							bonus.weather = EWE_Snow;
							break;
						case 'AnyWeather':
							bonus.weather = EWE_Any;
							break;
						case 'FullMoon':
							bonus.moonState = EMS_Full;
							break;
						case 'RedMoon':
							bonus.moonState = EMS_Red;
							break;
						case 'NoMoon':
							bonus.moonState = EMS_NotFull;
							break;
						case 'AnyMoon':
							bonus.moonState = EMS_Any;
							break;
							
						default:
							break;
					}
				}
				bonus.ability = atts[i];
				weatherBonuses.PushBack(bonus);
			}
		}
		
		if(weatherBonuses.Size() > 0)
		{
			owner.AddTimer('WeatherBonusCheck', 5, true);
		}
	}
	
	public function GetWeatherBonus(dayPart : EDayPart, weather : EWeatherEffect, moonState : EMoonState) : name
	{
		var i : int;
		var bonus : SWeatherBonus;
		
		for (i = 0; i < weatherBonuses.Size(); i+=1)
		{
			bonus = weatherBonuses[i];
			if (bonus.dayPart == dayPart && ( bonus.weather == weather || bonus.weather == EWE_Any) && ( bonus.moonState == moonState || bonus.moonState == EMS_Any ))
			{
				return bonus.ability;
			}
		}
		return '';
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Initializes NPC skills - adds proper abilities
	private function InitSkills()
	{
		var atts : array<name>;
		var i,size : int;
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		charStats.GetAllContainedAbilities(atts);
		size = atts.Size();
		for(i=0; i<size; i+=1)
		{
			if(!IsBasicAttack(atts[i]) && !dm.AbilityHasTag(atts[i], theGame.params.DIFFICULTY_TAG_DIFF_ABILITY) && !dm.AbilityHasTag(atts[i], theGame.params.NOT_A_SKILL_ABILITY_TAG) )
			{
				//if it's an ability name and it's not a basic attack (those are already added) and not a difficulty-based ability
				charStats.AddAbility(atts[i]);
			}
		}
	}
	
	protected function GetAttributeValueInternal(attributeName : name, optional tags : array<name>) : SAbilityAttributeValue	
	{
		var ret : SAbilityAttributeValue;
		var i : int;
	
		ret = super.GetAttributeValueInternal(attributeName, tags);
	
		//we need to remove bonuses from blocked abilities already added to the character
		for(i=0; i<blockedAbilities.Size(); i+=1)
		{
			if(charStats.HasAbility(blockedAbilities[i].abilityName))
			{
				ret -= charStats.GetAbilityAttributeValue(attributeName, blockedAbilities[i].abilityName);
			}
		}
		
		return ret;
	}
}