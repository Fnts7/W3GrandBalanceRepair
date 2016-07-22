/***********************************************************************/
/** Copyright © 2012
/** Author : Rafal Jarczewski, Tomasz Kozera
/***********************************************************************/

class W3Effect_Toxicity extends CBaseGameplayEffect
{
	//toxicity decay
	default effectType = EET_Toxicity;
	default attributeName = 'toxicityRegen';
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;	
		
	//damage dealing
	private saved var dmgTypeName 			: name;							//damage type	
	private saved var toxThresholdEffect	: int;
	private var delayToNextVFXUpdate		: float;
		
	// Globals need to be set only once
	public function CacheSettings()
	{
		dmgTypeName = theGame.params.DAMAGE_NAME_DIRECT;
		
		super.CacheSettings();
	}
	
	// Customly check if the camera effect should be added - not active always
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		var witcher : W3PlayerWitcher;
	
		if( !((W3PlayerWitcher)target) )
		{
			LogAssert(false, "W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		witcher = GetWitcherPlayer();
	
		//SPECIAL CASE - first check if the camera should be on or off - APPARENTLY FULLSCREEN EFFECTS ARE REMOVED?
		if( witcher.GetStatPercents(BCS_Toxicity) >= witcher.GetToxicityDamageThreshold())
			switchCameraEffect = true;
		else
			switchCameraEffect = false;
			
		//init all stuff and the camera
		super.OnEffectAdded(customParams);	
	}
	
	// check if threshold level is high enough and if so start dealing damage
	// also update info if the camera effect should be played or not
	event OnUpdate(deltaTime : float)
	{
		var dmg, maxStat, toxicity, threshold, drainVal : float;
		var dmgValue, min, max : SAbilityAttributeValue;
		var currentStateName 	: name;
		var currentThreshold	: int;
	
		super.OnUpdate(deltaTime);
		
		//set damage percents
		toxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false) / GetWitcherPlayer().GetStatMax(BCS_Toxicity);
		threshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		
		//check if the camera effect should be switched on/off
		if( toxicity >= 0.5f && !isPlayingCameraEffect)
			switchCameraEffect = true;
		else if(toxicity < 0.5f && isPlayingCameraEffect)
			switchCameraEffect = true;

		//veins on face
		if( delayToNextVFXUpdate <= 0 )
		{		
			// There are 4 toxicity thresholds
			// 0%-25% | 25%-50% | 50%-75% | 75%-100%
			if(toxicity < 0.25f)		currentThreshold = 0;
			else if(toxicity < 0.5f)	currentThreshold = 1;
			else if(toxicity < 0.75f)	currentThreshold = 2;
			else						currentThreshold = 3;
			
			if( toxThresholdEffect != currentThreshold && !target.IsEffectActive('invisible' ) )
			{
				toxThresholdEffect = currentThreshold;
				
				switch ( toxThresholdEffect )
				{
					case 0: PlayHeadEffect('toxic_000_025'); break;
					case 1: PlayHeadEffect('toxic_025_050'); break;
					case 2: PlayHeadEffect('toxic_050_075'); break;
					case 3: PlayHeadEffect('toxic_075_100'); break;
				}
				
				// Give time to the effect to finish playing before playing another one
				delayToNextVFXUpdate = 2;
			}			
		}
		else
		{
			delayToNextVFXUpdate -= deltaTime;
		}
				
		//hit health if needed	
		if(toxicity >= threshold)
		{
			currentStateName = thePlayer.GetCurrentStateName();
			if(currentStateName != 'Meditation' && currentStateName != 'MeditationWaiting')
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, dmgTypeName, min, max);	//seems like we can cache dmgTypeName?? Should investiagate why it's not cached! 
			
				if(DamageHitsVitality(dmgTypeName))
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
				
				dmgValue = GetAttributeRandomizedValue(min, max);
				dmg = MaxF(0, deltaTime * ( dmgValue.valueAdditive + (dmgValue.valueMultiplicative * (maxStat + dmgValue.valueBase) ) ));
				
				//skill damping tox damage
				//if(thePlayer.CanUseSkill(S_Sword_s17) && target.GetStat(BCS_Focus) >= 1)
				//{
				//	dmg *= CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Sword_s17, 'tox_dmg_mult', false, true));
				//}
			
				if(dmg > 0)
					effectManager.CacheDamage(dmgTypeName,dmg,NULL,this,deltaTime,true,CPS_Undefined,false);
				else
					LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
			}
			
			//ignore pain bonus
			if(thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain))
				target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');
		}
		else
		{
			//ignore pain bonus
			target.RemoveBuff(EET_IgnorePain);
		}
			
		//first we needed to check if the camera should be on or not	
		drainVal = deltaTime * (effectValue.valueAdditive + (effectValue.valueMultiplicative * (effectValue.valueBase + target.GetStatMax(BCS_Toxicity)) ) );
		
		//regen *2 out of combat
		if(!target.IsInCombat())
			drainVal *= 2;
			
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
	}
	
	function PlayHeadEffect( effect : name, optional stop : bool )
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i : int;
		
		inv = target.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				continue;
			}
			
			headId = headIds[i];
					
			if(!inv.IsIdValid( headId ))
			{
				LogAssert(false, "W3Effect_Toxicity : Can't find head item");
				return;
			}
			
			head = inv.GetItemEntityUnsafe( headId );
			
			if( !head )
			{
				LogAssert(false, "W3Effect_Toxicity : head item is null");
				return;
			}

			if ( stop )
			{
				head.StopEffect( effect );
			}
			else
			{
				head.PlayEffectSingle( effect );
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		toxThresholdEffect = -1;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		//ignore pain bonus
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && target.HasBuff(EET_IgnorePain))
			target.RemoveBuff(EET_IgnorePain);
			
		//veins on face
		//target.StopEffect('toxicity_face');
		
		// Stop whichever effect is currently playing
		PlayHeadEffect( 'toxic_000_025', true );
		PlayHeadEffect( 'toxic_025_050', true );
		PlayHeadEffect( 'toxic_050_075', true );
		PlayHeadEffect( 'toxic_075_100', true );
		
		PlayHeadEffect( 'toxic_025_000', true );
		PlayHeadEffect( 'toxic_050_025', true );
		PlayHeadEffect( 'toxic_075_050', true );
		PlayHeadEffect( 'toxic_100_075', true );
		
		toxThresholdEffect = 0;
	}
	
	protected function SetEffectValue()
	{
		RecalcEffectValue();
	}
	
	public function RecalcEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		//effect val
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
		
		//skill val
		if(thePlayer.CanUseSkill(S_Alchemy_s15))
			effectValue += thePlayer.GetSkillAttributeValue(S_Alchemy_s15, attributeName, false, true) * thePlayer.GetSkillLevel(S_Alchemy_s15);
			
		if(thePlayer.HasAbility('Runeword 8 Regen'))
			effectValue += thePlayer.GetAbilityAttributeValue('Runeword 8 Regen', 'toxicityRegen');
	}
}
