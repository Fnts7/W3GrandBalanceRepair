/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, 
/**			 Tomasz Czarny, 
/**			 Tomek Kozera
/***********************************************************************/

/*
  Class deals with damage dealing. Damage manager is given a DamageAction object
  based on which it delivers damage to the victim. DM takes under consideration all
  possible damage modifiers (bonuses, spells, skills, protection, dodging, immortality etc.).
  DM also displays hit particles and sends info regarding which hit animation to use.
*/
class W3DamageManagerProcessor extends CObject /* CObject extension is required because of Clone function that is used */
{
	//helper cached variables
	private var playerAttacker				: CR4Player;				//attacker entity cast to player class
	private var playerVictim				: CR4Player;				//victim entity cast to player class
	private var action						: W3DamageAction;
	private var attackAction				: W3Action_Attack;			//W3DamageAction cast to AttackAction
	private var weaponId					: SItemUniqueId;			//weapon id (used if AttackAction)
	private var actorVictim 				: CActor;					//victim cast to CActor
	private var actorAttacker				: CActor;					//attacker cast to CActor
	private var dm 							: CDefinitionsManagerAccessor;
	private var attackerMonsterCategory		: EMonsterCategory;
	private var victimMonsterCategory		: EMonsterCategory;
	private var victimCanBeHitByFists		: bool;
	
	// processes damage action
	public function ProcessAction(act : W3DamageAction)
	{
		var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
		var focusDrain : float;
		var npc : CNewNPC;
		var buffs : array<EEffectType>;
		var arrStr : array<string>;
		var aerondight	: W3Effect_Aerondight;
		var trailFxName : name;
			
		wasAlive = act.victim.IsAlive();		
		npc = (CNewNPC)act.victim;
		
		//cache global vars
 		InitializeActionVars(act);
 		
 		//Special case: if attack cannot be parried but player did parry and attack does not apply knockdown:
		//				apply stagger, deal reduced damage, apply buffs
 		if(playerVictim && attackAction && attackAction.IsActionMelee() && !attackAction.CanBeParried() && attackAction.IsParried())
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				//set flag - later in actor's ReduceDamage() we will reduce incoming damage properly
				action.SetParryStagger();
				
				//force to apply buffs 
				action.SetProcessBuffsIfNoDamage(true);
				
				//add stagger buff
				action.AddEffectInfo(EET_LongStagger);
				
				//no hit anim & fx, since we will stagger
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetCanPlayHitParticle(false);
				
				//no bleeding
				action.RemoveBuffsByType(EET_Bleeding);
			}
 		}
 		
 		//store info if player was victim and had quen turned on at the time of attack
 		if(actorAttacker && playerVictim && ((W3PlayerWitcher)playerVictim) && GetWitcherPlayer().IsAnyQuenActive())
			FactsAdd("player_had_quen");
		
		// custom stuff
		ProcessPreHitModifications();

		//quest stuff
		ProcessActionQuest(act);
		
		//check if victim was frozen before attack
		isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));
		
		//deal damage
		validDamage = ProcessActionDamage();
		
		//ingame combat log when victim dies / becomes unconscious
		if(wasAlive && !action.victim.IsAlive())
		{
			arrStr.PushBack(action.victim.GetDisplayName());
			if(npc && npc.WillBeUnconscious())
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
			}
			else if(action.attacker && action.attacker.GetDisplayName() != "")
			{
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
			}
			else
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
			}
		}
		
		if( wasAlive && action.DealsAnyDamage() )
		{
			((CActor) action.attacker).SignalGameplayEventParamFloat(  'CausesDamage', MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage ) );
		}
		
		//process victim reaction to what just happened
		ProcessActionReaction(isFrozen, wasAlive);
		
		//process buffs if damage was dealt or if buff processing is forced regardless of damage
		if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
			ProcessActionBuffs();
		
		//error check - action that did nothing
		if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
			if ( theGame.CanLog() )
			{
				LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
			}
		}
		
		//post process code
		if(actorAttacker)
			actorAttacker.OnProcessActionPost(action);

		//focus points drain on player being hit (amount depends on hit type: light, heavy, super heavy)
		if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			if(actorAttacker && attackAction)
			{
				if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
				else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
				else //light or undefined
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			else
			{
				//no attack action so use light attack cost
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			
			//skill: reduces focus loss when hit
			if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
				focusDrain *= 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16));
				
			thePlayer.DrainFocus(focusDrain);
		}
		
		//runewords 10 & 12 effect on player sword kill - needs to be postponed if finisher will fire, hence it's here rather than in OnDeath()
		if(actorAttacker == GetWitcherPlayer() && actorVictim && !actorVictim.IsAlive() && (action.IsActionMelee() || action.GetBuffSourceName() == "Kill"))
		{
			autoFinishersEnabled = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
			
			//If automatic finishers are disabled we show the fx on death.
			//If they are enabled and we will not perform a finisher we also show it now.
			//If they are enabled and we will perform a finisher the call is postponed (not called here) and called later during the finisher animation.
			if(!autoFinishersEnabled || !thePlayer.GetFinisherVictim())
			{
				if(thePlayer.HasAbility('Runeword 10 _Stats', true))
					GetWitcherPlayer().Runeword10Triggerred();
				if(thePlayer.HasAbility('Runeword 12 _Stats', true))
					GetWitcherPlayer().Runeword12Triggerred();
			}
		}
		
		//breaking quen
		if(action.EndsQuen() && actorVictim)
		{
			actorVictim.FinishQuen(false);			
		}

		//parry, counter, dodge tutorials
		if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
		{
			if(attackAction.IsCountered())
			{
				theGame.GetTutorialSystem().IncreaseCounters();
			}
			else if(attackAction.IsParried())
			{
				theGame.GetTutorialSystem().IncreaseParries();
			}
			
			if(attackAction.CanBeDodged() && !attackAction.WasDodged())
			{
				GameplayFactsAdd("tut_failed_dodge", 1, 1);
				GameplayFactsAdd("tut_failed_roll", 1, 1);
			}
		}
		
		if( playerAttacker && npc && action.IsActionMelee() && action.DealtDamage() && IsRequiredAttitudeBetween( playerAttacker, npc, true ) && !npc.HasTag( 'AerondightIgnore' ) )// && !action.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered() )
		{			
			if( playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
			{
				//increase charges
				aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
				aerondight.IncreaseAerondightCharges( attackAction.GetAttackName() );
				
				//special blood trail fx
				if( aerondight.GetCurrentCount() == aerondight.GetMaxCount() )
				{
					switch( npc.GetBloodType() )
					{
						case BT_Red : 
							trailFxName = 'aerondight_blood_red';
							break;
							
						case BT_Yellow :
							trailFxName = 'aerondight_blood_yellow';
							break;
						
						case BT_Black : 
							trailFxName = 'aerondight_blood_black';
							break;
						
						case BT_Green :
							trailFxName = 'aerondight_blood_green';
							break;
					}
					
					playerAttacker.inv.GetItemEntityUnsafe( attackAction.GetWeaponId() ).PlayEffect( trailFxName );
				}
			}
		}
	}
	
	//cached for easy access and to avoid multiple class casting
	private final function InitializeActionVars(act : W3DamageAction)
	{
		var tmpName : name;
		var tmpBool	: bool;
	
		action 				= act;
		playerAttacker 		= (CR4Player)action.attacker;
		playerVictim		= (CR4Player)action.victim;
		attackAction 		= (W3Action_Attack)action;		
		actorVictim 		= (CActor)action.victim;
		actorAttacker		= (CActor)action.attacker;
		dm 					= theGame.GetDefinitionsManager();
		
		if(attackAction)
			weaponId 		= attackAction.GetWeaponId();
			
		theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
		
		if(actorAttacker)
			theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////   @QUESTS   //////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/*
		Processes action quest stuff - fact setting. Although it's called hit_by_weapon 
		is true for *all attacks* (hand combat and signs) - don't ask me why...
	*/
	private function ProcessActionQuest(act : W3DamageAction)
	{
		var victimTags, attackerTags : array<name>;
		
		victimTags = action.victim.GetTags();
		
		if(action.attacker)
			attackerTags = action.attacker.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_weapon_hit" );
		
		//DZ used to activate monster clues when hit.
		if ((CGameplayEntity) action.victim) action.victim.OnWeaponHit(act);
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////   @DAMAGE   //////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Processes action's damage, returns true if any damage was processed
	private function ProcessActionDamage() : bool
	{
		var directDmgIndex, size, i : int;
		var dmgInfos : array< SRawDamage >;
		var immortalityMode : EActorImmortalityMode;
		var dmgValue : float;
		var anyDamageProcessed, fallingRaffard : bool;
		var victimHealthPercBeforeHit, frozenAdditionalDamage : float;		
		var powerMod : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var canLog : bool;
		var immortalityChannels : array<EActorImmortalityChanel>;
		
		canLog = theGame.CanLog();
		
		//clear processed dmg
		action.SetAllProcessedDamageAs(0);
		size = action.GetDTs( dmgInfos );
		action.SetDealtFireDamage(false);		
		
		//if victim has no stats at all
		if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()) )
		{
			//skip damage dealing, only call OnFireHit event if action deals fire damage
			for(i=0; i<size; i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE && dmgInfos[i].dmgVal > 0)
				{
					action.victim.OnFireHit( (CGameplayEntity)action.causer );
					break;
				}
			}
			
			if ( !actorVictim.abilityManager )
				actorVictim.OnDeath(action);
			
			return false;
		}
		
		//store initial health before hit
		if(actorVictim.UsesVitality())
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);
				
		//special cases that increase incoming damage
		ProcessDamageIncrease( dmgInfos );
					
		//log
		if ( canLog )
		{
			LogBeginning();
		}
			
		//critical hit check
		ProcessCriticalHitCheck();
		
		//some effects can trigger on hit, before we process hit
		ProcessOnBeforeHitChecks();
		
		//attacker's power damage modification
		powerMod = GetAttackersPowerMod();

		//calculate damages
		anyDamageProcessed = false;
		directDmgIndex = -1;
		witcher = GetWitcherPlayer();
		size = dmgInfos.Size();			//size can change as additional damages might be added e.g. in ProcessDamageIncrease
		for( i = 0; i < size; i += 1 )
		{
			//ignore if no damage or direct damage
			if(dmgInfos[i].dmgVal == 0)
				continue;
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDmgIndex = i;
				continue;
			}
			
			//poison damage absorbing from Golden Oriole potion
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim && witcher.HasBuff(EET_GoldenOriole) && witcher.GetPotionBuffLevel(EET_GoldenOriole) == 3)
			{
				//heal
				witcher.GainStat(BCS_Vitality, dmgInfos[i].dmgVal);
				
				//log
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from level 3 Golden Oriole potion: " + dmgInfos[i].dmgVal, action);
				}
				
				//clear damage
				dmgInfos[i].dmgVal = 0;
				
				continue;
			}
			
			//logging
			if ( canLog )
			{
				LogDMHits("", action);
				LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
				if(action.IsDoTDamage())
					LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
			}
			
			//set that we have at least one valid damage to be dealt
			anyDamageProcessed = true;
				
			//calculate final damage to deal
			dmgValue = MaxF(0, CalculateDamage(dmgInfos[i], powerMod));
		
			//add to total damage to be dealt
			if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
			if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
			if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
			if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
		}
		
		if(size == 0 && canLog)
		{
			LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
		}
		
		if ( canLog )
		{
			LogDMHits("", action);
			LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
		}
		
		//global damage reductions of actor not related to specific damage types
		if(actorVictim)
			actorVictim.ReduceDamage(action);
				
		//add direct damage - this is dealt always unless immortal (it will ignore armor, parry, etc.)
		if(directDmgIndex != -1)
		{
			anyDamageProcessed = true;
			
			//ignore invulnerability if it's from White Raffards Potion and you are falling
			immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
			fallingRaffard = immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage";
			
			if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
			{
				action.processedDmg.vitalityDamage += dmgInfos[directDmgIndex].dmgVal;
				action.processedDmg.essenceDamage  += dmgInfos[directDmgIndex].dmgVal;
			}
			else if( actorVictim.IsInvulnerable() )
			{
				//don't add any damage
			}
			else if( actorVictim.IsImmortal() )
			{
				//deal damage but leave victim at 1 hp if it would kill it
				action.processedDmg.vitalityDamage += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Vitality)-1 );
				action.processedDmg.essenceDamage  += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Essence)-1 );
			}
		}
		
		// check for immunity to being one-shotted
		if( actorVictim.HasAbility( 'OneShotImmune' ) )
		{
			if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
			{
				action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
			}
			else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
			{
				action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
			}
		}
		
		//inform victim if fire damage was dealt (e.g. will trigger exploding barrels or toxic gas or lighten up efreet)
		if(action.HasDealtFireDamage())
			action.victim.OnFireHit( (CGameplayEntity)action.causer );
			
		// Check for Intant Kill
		ProcessInstantKill();
			
		//deal total calculated damage to victim
		ProcessActionDamage_DealDamage();
		
		
		if(playerAttacker && witcher)
			witcher.SetRecentlyCountered(false);
		
		//Achievement: chained uninterrupted counters break
		if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
			theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
		
		//reduce item durability
		ProcessActionDamage_ReduceDurability();
		
		//per-hit item temporary bonuses
		if(playerAttacker && actorVictim)
		{
			//reduce applied oil ammo
			if(playerAttacker.inv.ItemHasAnyActiveOilApplied(weaponId) && (!playerAttacker.CanUseSkill(S_Alchemy_s06) || (playerAttacker.GetSkillLevel(S_Alchemy_s06) < 3)) )
			{			
				playerAttacker.ReduceAllOilsAmmo( weaponId );
				
				if(ShouldProcessTutorial('TutorialOilAmmo'))
				{
					FactsAdd("tut_used_oil_in_combat");
				}
			}
			
			//repair object (whetstone & armor table) bonus
			playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
		}
		
		//returning damage aka thorns
		if(actorVictim && actorAttacker && !action.GetCannotReturnDamage() )
			ProcessActionReturnedDamage();	
		
		return anyDamageProcessed;
	}
	
	//makes a test and if successfull, deals instant kill
	private function ProcessInstantKill()
	{
		var instantKill, focus : float;

		if( !actorVictim || !actorAttacker || actorVictim.IsImmuneToInstantKill() )
		{
			return;
		}
		
		//disallow instant kills if action was dodged, countered or parried
		if( action.WasDodged() || ( attackAction && ( attackAction.IsParried() || attackAction.IsCountered() ) ) )
		{
			return;
		}
		
		if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer )
		{
			action.SetInstantKill();
		}
		
		//player has internal cooldown on instant kills
		if( actorAttacker == thePlayer && !action.GetIgnoreInstantKillCooldown() )
		{
			if( !GameTimeDTAtLeastRealSecs( thePlayer.lastInstantKillTime, theGame.GetGameTime(), theGame.params.INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN ) )
			{
				return;
			}
		}
	
		//calc chance if not forced
		if( !action.GetInstantKill() )
		{
			//get base chance
			instantKill = CalculateAttributeValue( actorAttacker.GetInventory().GetItemAttributeValue( weaponId, 'instant_kill_chance' ) );
			
			//skill increase
			if( ( action.IsActionMelee() || action.IsActionRanged() ) && playerAttacker && action.DealsAnyDamage() && thePlayer.CanUseSkill( S_Sword_s03 ) && !playerAttacker.inv.IsItemFists( weaponId ) )
			{
				focus = thePlayer.GetStat( BCS_Focus );
				
				if( focus >= 1 )
				{
					instantKill += focus * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s03, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s03 );
				}
			}
		}
		
		//test
		if( action.GetInstantKill() || ( RandF() < instantKill ) )
		{
			if( theGame.CanLog() )
			{
				if( action.GetInstantKill() )
				{
					instantKill = 1.f;
				}
				LogDMHits( "Instant kill!! (" + NoTrailZeros( instantKill * 100 ) + "% chance", action );
			}
		
			action.processedDmg.vitalityDamage += actorVictim.GetStat( BCS_Vitality );
			action.processedDmg.essenceDamage += actorVictim.GetStat( BCS_Essence );
			action.SetCriticalHit();	//we make instant kills critical hits to make player feel the impact more
			action.SetInstantKillFloater();			
			
			//slomo and sound if instigated by player
			if( playerAttacker )
			{
				thePlayer.SetLastInstantKillTime( theGame.GetGameTime() );
				theSound.SoundEvent( 'cmb_play_deadly_hit' );
				theGame.SetTimeScale( 0.2, theGame.GetTimescaleSource( ETS_InstantKill ), theGame.GetTimescalePriority( ETS_InstantKill ), true, true );
				thePlayer.AddTimer( 'RemoveInstantKillSloMo', 0.2 );
			}			
		}
	}
	
	//checks done before hit is processed
	private function ProcessOnBeforeHitChecks()
	{
		var effectAbilityName, monsterBonusType : name;
		var effectType : EEffectType;
		var null, monsterBonusVal : SAbilityAttributeValue;
		var oilLevel, skillLevel, i : int;
		var baseChance, perOilLevelChance, chance : float;
		var buffs : array<name>;
	
		//test for skill having chance to poison victim if we use proper oil on enemy
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12) && playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
		{
			//check if oil type matches monster type
			monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
			monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
		
			if(monsterBonusVal != null)
			{
				//calculate chance
				oilLevel = (int)CalculateAttributeValue(playerAttacker.inv.GetItemAttributeValue(weaponId, 'level')) - 1;				
				skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s12);
				baseChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, true));
				perOilLevelChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, true));						
				chance = baseChance * skillLevel + perOilLevelChance * oilLevel;
				
				//percentage test
				if(RandF() < chance)
				{
					//get & apply effects
					dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
					for(i=0; i<buffs.Size(); i+=1)
					{
						EffectNameToType(buffs[i], effectType, effectAbilityName);
						action.AddEffectInfo(effectType, , , effectAbilityName);
					}
				}
			}
		}
	}
	
	//makes a test for critical hit and if so sets proper flag on action
	private function ProcessCriticalHitCheck()
	{
		var critChance, critDamageBonus : float;
		var	canLog, meleeOrRanged, redWolfSet, isLightAttack, isHeavyAttack, mutation2 : bool;
		var arrStr : array<string>;
		var samum : CBaseGameplayEffect;
		var signPower, min, max : SAbilityAttributeValue;
		var aerondight : W3Effect_Aerondight;
		
		meleeOrRanged = playerAttacker && attackAction && ( attackAction.IsActionMelee() || attackAction.IsActionRanged() );
		redWolfSet = ( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 );
		mutation2 = ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && action.IsActionWitcherSign();
		
		if( meleeOrRanged || redWolfSet || mutation2 )
		{
			canLog = theGame.CanLog();
		
			//Mutation 2 crit chance depends only on sign intensity
			if( mutation2 )
			{
				if( FactsQuerySum('debug_fact_critical_boy') > 0 )
				{
					critChance = 1.f;
				}
				else
				{
					signPower = action.GetPowerStatValue();
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_chance_factor', min, max);
					critChance = min.valueAdditive + signPower.valueMultiplicative * min.valueMultiplicative;
				}
			} 			
			else
			{
				if( attackAction )
				{
					//Rend skill has bonus crit chance
					if( SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
					{				
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s02, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * playerAttacker.GetSkillLevel(S_Sword_s02);
					}
					
					// Counter attack crit bonus
					if(GetWitcherPlayer() && GetWitcherPlayer().HasRecentlyCountered() && playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker.GetSkillLevel(S_Sword_s11) > 2)
					{
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s11, theGame.params.CRITICAL_HIT_CHANCE, false, true));
					}
					
					//calculate base chance
					isLightAttack = playerAttacker.IsLightAttack( attackAction.GetAttackName() );
					isHeavyAttack = playerAttacker.IsHeavyAttack( attackAction.GetAttackName() );
					critChance += playerAttacker.GetCriticalHitChance(isLightAttack, isHeavyAttack, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
					
					//headshot bonus
					if(action.GetIsHeadShot())
					{
						critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
						actorVictim.SignalGameplayEvent( 'Headshot' );
					}
					
					//backstab bonus
					if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
					{
						critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
					}
						
					// Aerondight
					if( action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
					{
						aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
						
						if( aerondight && aerondight.IsFullyCharged() )
						{
							// Aerondight gives 100% crit chance while fully loaded
							min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'crit_chance_bonus' );
							critChance += min.valueAdditive;
						}
					}
				}
				else
				{
					//calculate base chance
					critChance += playerAttacker.GetCriticalHitChance(false, false, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
				}
				
				//level 3 samum bonus
				samum = actorVictim.GetBuff(EET_Blindness, 'petard');
				if(samum && samum.GetBuffLevel() == 3)
				{
					critChance += 1.0f;
				}
			}
			
			//extensive logging
			if ( canLog )
			{
				//damage bonus from critical
				critDamageBonus = 1 + CalculateAttributeValue(actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker)));
				critDamageBonus += CalculateAttributeValue(actorAttacker.GetAttributeValue('critical_hit_chance_fast_style'));
				critDamageBonus = 100 * critDamageBonus;
				
				//log				
				LogDMHits("", action);				
				LogDMHits("Trying critical hit (" + NoTrailZeros(critChance*100) + "% chance, dealing " + NoTrailZeros(critDamageBonus) + "% damage)...", action);
			}
			
			//test
			if(RandF() < critChance)
			{
				//mark that action has critical hit - we'll use it when calculating damage
				action.SetCriticalHit();
								
				if ( canLog )
				{
					LogDMHits("********************", action);
					LogDMHits("*** CRITICAL HIT ***", action);
					LogDMHits("********************", action);				
				}
				
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,arrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);
			}
			else if ( canLog )
			{
				LogDMHits("... nope", action);
			}
		}	
	}
	
	//logs info at the beginning of hit processing
	private function LogBeginning()
	{
		var logStr : string;
		
		if ( !theGame.CanLog() )
		{
			return;
		}
		
		LogDMHits("-----------------------------------------------------------------------------------", action);		
		logStr = "Beginning hit processing from <<" + action.attacker + ">> to <<" + action.victim + ">> via <<" + action.causer + ">>";
		if(attackAction)
		{
			logStr += " using AttackType <<" + attackAction.GetAttackTypeName() + ">>";		
		}
		logStr += ":";
		LogDMHits(logStr, action);
		LogDMHits("", action);
		LogDMHits("Target stats before damage dealt are:", action);
		if(actorVictim)
		{
			if( actorVictim.UsesVitality() )
				LogDMHits("Vitality = " + NoTrailZeros(actorVictim.GetStat(BCS_Vitality)), action);
			if( actorVictim.UsesEssence() )
				LogDMHits("Essence = " + NoTrailZeros(actorVictim.GetStat(BCS_Essence)), action);
			if( actorVictim.GetStatMax(BCS_Stamina) > 0)
				LogDMHits("Stamina = " + NoTrailZeros(actorVictim.GetStat(BCS_Stamina, true)), action);
			if( actorVictim.GetStatMax(BCS_Morale) > 0)
				LogDMHits("Morale = " + NoTrailZeros(actorVictim.GetStat(BCS_Morale)), action);
		}
		else
		{
			LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
		}
	}
	
	//Apply all effects that increase damage
	private function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
	{
		var difficultyDamageMultiplier, rendLoad, rendBonus, overheal, rendRatio, focusCost : float;
		var i, bonusCount : int;
		var frozenBuff : W3Effect_Frozen;
		var frozenDmgInfo : SRawDamage;
		var hadFrostDamage : bool;
		var mpac : CMovingPhysicalAgentComponent;
		var rendBonusPerPoint, staminaRendBonus, perk20Bonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var damageVal, damageBonus, min, max			: SAbilityAttributeValue;		
		var npcVictim : CNewNPC;
		var sword : SItemUniqueId;
		var actionFreeze : W3DamageAction;
		var aerondight	: W3Effect_Aerondight;
		
		//update damage values due to difficulty mode.
		//TK: disabling damage multiplication on DoTs due to difficulty (#113563 + Quen balance)
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * difficultyDamageMultiplier;
			}
		}
			
		//When victim is frozen and gets hit we deal additional damage (shattering)
		//add frozen buff damage if frozen and not DoT and hit by Aard or physical or silver
		//this damage is not modified by difficulty modes
		if(actorVictim && playerAttacker && !action.IsDoTDamage() && actorVictim.HasBuff(EET_Frozen) && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()) )
		{
			//needed for Achievement - Hasta La Vista
			action.SetWasFrozen();
			
			//calculate additional damage if not hit by White Frost while frozen
			if( !( ( W3WhiteFrost )action.causer ) )
			{				
				frozenBuff = (W3Effect_Frozen)actorVictim.GetBuff(EET_Frozen);			
				frozenDmgInfo.dmgVal = frozenBuff.GetAdditionalDamagePercents() * actorVictim.GetHealth();
			}
			
			//break frozen state and add knockdown
			actorVictim.RemoveAllBuffsOfType(EET_Frozen);
			action.AddEffectInfo(EET_KnockdownTypeApplicator);
			
			//deal additional damage
			if( !( ( W3WhiteFrost )action.causer ) )
			{
				actionFreeze = new W3DamageAction in theGame;
				actionFreeze.Initialize( actorAttacker, actorVictim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
				actionFreeze.SetCannotReturnDamage( true );
				actionFreeze.SetCanPlayHitParticle( false );
				actionFreeze.SetHitAnimationPlayType( EAHA_ForceNo );
				actionFreeze.SetWasFrozen();		//Achievement - Hasta La Vista
				actionFreeze.AddDamage( theGame.params.DAMAGE_NAME_FROST, frozenDmgInfo.dmgVal );
				theGame.damageMgr.ProcessAction( actionFreeze );
				delete actionFreeze;
			}
		}
		
		//underwater bolt damage increase (if attacker and victim are underwater)
		if(actorVictim)
		{
			mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
						
			if(mpac && mpac.IsDiving())
			{
				mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
				
				if(mpac && mpac.IsDiving())
				{
					action.SetUnderwaterDisplayDamageHack();
				
					if(playerAttacker && attackAction && attackAction.IsActionRanged())
					{
						for(i=0; i<dmgInfos.Size(); i+=1)
						{
							if(FactsQuerySum("NewGamePlus"))
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
							}
							else
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
							}
						}
					}
				}
			}
		}
		
		//Rend increased damage on top, per adrenaline point and stamina used
		if(playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			
			//check how much of the 'gauge' player channeled
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			
			//used focus points are lesser of: current focus and (rend time held * max focus)
			rendLoad = MinF(rendRatio * playerAttacker.GetStatMax(BCS_Focus), playerAttacker.GetStat(BCS_Focus));
			
			//used points are rounded as INTs
			if(rendLoad >= 1)
			{
				rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true);
				rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative;
				
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= (1 + rendBonus);
				}
			}
			
			//bonus for stamina usage
			staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
			}
		}	
 
		//NPC arrows in NG+ need to deal more damage
		if ( actorAttacker != thePlayer && action.IsActionRanged() && (int)CalculateAttributeValue(actorAttacker.GetAttributeValue('level',,true)) > 31)
		{
			damageVal = actorAttacker.GetAttributeValue('light_attack_damage_vitality',,true);
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal + CalculateAttributeValue(damageVal) / 2;
			}
		}
		
		//Runeword 4 overheal damage increase
		if ( actorVictim && playerAttacker && attackAction && action.IsActionMelee() && thePlayer.HasAbility('Runeword 4 _Stats', true) && !attackAction.WasDodged() )
		{
			overheal = thePlayer.abilityManager.GetOverhealBonus() / thePlayer.GetStatMax(BCS_Vitality);
		
			if(overheal > 0.005f)
			{
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= 1.0f + overheal;
				}
			
				thePlayer.abilityManager.ResetOverhealBonus();
				
				//hit FX
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );				
			}
		}
		
		// Lynx Set Bonus damage boost
		if( playerAttacker && playerAttacker.IsLightAttack( attackAction.GetAttackName() ) && playerAttacker.HasBuff( EET_LynxSetBonus ) && !attackAction.WasDodged() ) 
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() )
			{
				//Multiplying damage boost by amount of items from Lynx Set
				damageBonus = playerAttacker.GetAttributeValue( 'lynx_dmg_boost' );
				
				damageBonus.valueAdditive *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Lynx );
				
				for( i=0 ; i<dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + damageBonus.valueAdditive;
				}
			}
		}

		//Lynx Set Bonus 2 - hit in the back have increased dmg and stun enemy
		if( playerAttacker && attackAction.IsActionMelee() && actorVictim.IsAttackerAtBack( playerAttacker ) && !actorVictim.HasAbility( 'CannotBeAttackedFromBehind' ) && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive( EISB_Lynx_2 ) && !attackAction.WasDodged() && ( playerAttacker.inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || playerAttacker.inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() && playerAttacker.GetStat(BCS_Focus) >= 1.0f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
				for( i=0; i<dmgInfos.Size() ; i+=1 )
				{
					dmgInfos[i].dmgVal *= 1 + min.valueAdditive;
				}
				
				if ( !( thePlayer.IsInCombatAction() && ( thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Heavy ) ) )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
					focusCost = min.valueAdditive;
					if( GetWitcherPlayer().GetStat( BCS_Focus ) >= focusCost )
					{				
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_stun_duration', min, max );
						attackAction.AddEffectInfo( EET_Confusion, min.valueAdditive );
						playerAttacker.SoundEvent( "ep2_setskill_lynx_activate" );
						playerAttacker.DrainFocus( focusCost );
					}
				}
			}
		}

		// Perk 20 - increases damage done by bombs
		if ( playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
			}
		}
		
		//Mutation 1 adds active sword damage to sign damage
		if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			sword = playerAttacker.inv.GetCurrentlyHeldSword();
			
			damageVal.valueBase = 0;
			damageVal.valueMultiplicative = 0;
			damageVal.valueAdditive = 0;
		
			if( playerAttacker.inv.GetItemCategory(sword) == 'steelsword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
			}
			else if( playerAttacker.inv.GetItemCategory(sword) == 'silversword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
			}
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);				
			
			damageVal.valueBase *= CalculateAttributeValue(min);
			
			if( action.IsDoTDamage() )
			{
				damageVal.valueBase *= action.GetDoTdt();
			}
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal += damageVal.valueBase;
			}
		}
		
		//mutation 8 damage increase for all monsters and bosses
		npcVictim = (CNewNPC) actorVictim;
		if( playerAttacker && npcVictim && attackAction && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && ( victimMonsterCategory != MC_Human || npcVictim.IsImmuneToMutation8Finisher() ) && attackAction.GetWeaponId() == GetWitcherPlayer().GetHeldSword() )
		{
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
			}
		}
		
		// Aerondight bonus
		if( playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );	
			
			if( aerondight )
			{
				min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'dmg_bonus' );
				bonusCount = aerondight.GetCurrentCount();
			
				if( bonusCount > 0 )
				{
					min.valueMultiplicative *= bonusCount;
					
					for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
					{
						dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
					}
				}				
			}
		}	
	}
	
	//handles any "damage returned" at the attacker
	private function ProcessActionReturnedDamage()
	{
		var witcher 			: W3PlayerWitcher;
		var quen 				: W3QuenEntity;
		var params 				: SCustomEffectParams;
		var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged, returned : bool;
		var g5Chance			: SAbilityAttributeValue;
		var dist, checkDist		: float;
		
		//Black Blood potion
		if((W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && (attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
		{
			returned = ProcessActionBlackBloodReturnedDamage();		
		}
		
		//Thorns monster skill
		if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
		{
			returned = ProcessActionThornDamage() || returned;
		}
		
		if(actorVictim.HasAbility( 'Glyphword 5 _Stats', true))
		{			
			if( GetAttitudeBetween(actorAttacker, actorVictim) == AIA_Hostile)
			{
				if( !action.IsDoTDamage() )
				{
					g5Chance = actorVictim.GetAttributeValue('glyphword5_chance');
					
					if(RandF() < g5Chance.valueAdditive)
					{
						canBeParried = attackAction.CanBeParried();
						canBeDodged = attackAction.CanBeDodged();
						wasParried = attackAction.IsParried() || attackAction.IsCountered();
						wasDodged = attackAction.WasDodged();
				
						if(!action.IsActionMelee() || (!canBeParried && canBeDodged && !wasDodged) || (canBeParried && !wasParried && !canBeDodged) || (canBeParried && canBeDodged && !wasDodged && !wasParried))
						{
							returned = ProcessActionReflectDamage() || returned;
						}
					}	
				}
			}			
			
		}
		
		//Leshen Mutagen effect
		if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff(EET_Mutagen26))
		{
			returned = ProcessActionLeshenMutagenDamage() || returned;
		}
		
		//FireShield monster skill
		if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
		{
			witcher = GetWitcherPlayer();			
			processFireShield = true;			
			if(playerAttacker == witcher)
			{
				quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
				if(quen && quen.IsAnyQuenActive())
				{
					processFireShield = false;
				}
			}
			
			if(processFireShield)
			{
				params.effectType = EET_Burning;
				params.creator = actorVictim;
				params.sourceName = actorVictim.GetName();
				//symbolic damage
				params.effectValue.valueMultiplicative = 0.01;
				actorAttacker.AddEffectCustom(params);
				returned = true;
			}
		}
		
		//SilverStuds item ability (returns silver damage to monsers)
		if(actorAttacker.UsesEssence())
		{
			returned = ProcessSilverStudsReturnedDamage() || returned;
		}
			
		//Mutation 4 - Toxic Blood
		if( (W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !playerAttacker.IsInFistFightMiniGame() && !action.IsDoTDamage() && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation4 ) )
		{
			//sometimes ranged attack are setup as melee so we need to hack around it
			dist = VecDistance( actorAttacker.GetWorldPosition(), actorVictim.GetWorldPosition() );
			checkDist = 3.f;
			if( actorAttacker.IsHuge() )
			{
				checkDist += 3.f;
			}
 
			if( dist <= checkDist )
			{
				returned = GetWitcherPlayer().ProcessActionMutation4ReturnedDamage( action.processedDmg.vitalityDamage, actorAttacker, EAHA_ForceYes, action ) || returned;
			}
		}
		
		action.SetWasDamageReturnedToAttacker( returned );
	}
	
	//returns damage to attacker due to mutagen
	private function ProcessActionLeshenMutagenDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage, pts, perc : float;
		var mutagen : W3Mutagen26_Effect;
		
		mutagen = (W3Mutagen26_Effect)playerVictim.GetBuff(EET_Mutagen26);
		mutagen.GetReturnedDamage(pts, perc);
		
		if(pts <= 0 && perc <= 0)
			return false;
			
		returnedDamage = pts + perc * action.GetDamageValueTotal();
		
		//create action that will deal returned damage
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Mutagen26", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		//prevent infinite loop	(returned damage to returned damage...)	
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );				
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	//returns silver damage to attacker
	private function ProcessSilverStudsReturnedDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage : float;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
		
		if(returnedDamage <= 0)
			return false;
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		//prevent infinite loop		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	// Processes return damage (EET_BlackBlood only) functionality of the action (enemy gets hit for X% of the damage it deals to you)
	private function ProcessActionBlackBloodReturnedDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal : SAbilityAttributeValue;
		var bb : W3Potion_BlackBlood;
		var potionLevel : int;
		var returnedDamage : float;
	
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
		potionLevel = bb.GetBuffLevel();
		
		//create action which will be used to return the damage to attacker
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_AttackPower, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );		//prevent infinite loop
		
		returnVal = bb.GetReturnDamageValue();
		
		if(potionLevel == 1)
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
			returnedAction.SetHitReactionType(EHRT_Reflect);
		}
		
		returnedDamage = (returnVal.valueBase + action.processedDmg.vitalityDamage) * returnVal.valueMultiplicative + returnVal.valueAdditive;
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		return true;
	}
	
	// Processes return damage (runeword on armor only) functionality of the action
	private function ProcessActionReflectDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal, min, max : SAbilityAttributeValue;
		var potionLevel : int;
		var returnedDamage : float;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var boneIndex: int;
		var b : bool;
		var component : CComponent;
		//var attack_power : SAbilityAttributeValue;
		
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetTotalArmor());
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'damage_mult', min, max);
		//attack_power = actorVictim.GetAttributeValue('attack_power');
		//returnedDamage *= attack_power.valueBase;
		
		//create action which will be used to return the damage to attacker
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, NULL, "Glyphword5", EHRT_None, CPS_AttackPower, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );		//prevent infinite loop
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Heavy);
		
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage * min.valueMultiplicative);
		
		//damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		//damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		/*
		boneIndex = action.attacker.GetBoneIndex( 'pelvis' );
		if( boneIndex == -1 )
		{
			boneIndex = action.attacker.GetBoneIndex( 'k_pelvis_g' );
		}
		
		fxEnt = theGame.CreateEntity(template, action.attacker.GetBoneWorldPositionByIndex( boneIndex ), action.attacker.GetWorldRotation(), , , true);
		b = fxEnt.CreateAttachment(action.attacker, 'pelvis');	//k_pelvis_g
		if(!b)
			fxEnt.CreateAttachment(action.attacker, 'k_pelvis_g');
		*/
		
		//theGame.CreateEntity(template, action.attacker.GetWorldPosition(), action.attacker.GetWorldRotation(), , , true);
		//fxEnt.CreateAttachment(action.attacker);
		
		component = action.attacker.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', action.attacker);
		action.attacker.PlayEffect('yrden_shock');
		
		return true;
	}
	
	// Process Thorn damage (get damage from victim)
	private function ProcessActionThornDamage() : bool
	{
		var damageAction 		: W3DamageAction;
		var damageVal 			: SAbilityAttributeValue;
		var damage				: float;
		var inv					: CInventoryComponent;
		var damageNames			: array < CName >;
		
		damageAction	= new W3DamageAction in this;
		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
		
		damageAction.SetCannotReturnDamage( true );		//prevent infinite loop
		
		damageVal 				=  actorVictim.GetAttributeValue( 'light_attack_damage_vitality' );
		
		//This is one big lol. We take random damage type from weapon (e.g. silver / fire damage from steel sword).
		//Then we take 10% of that and add to vitality damage done by current action. So if this is called when someone is 
		//attacking a monster it's always 0. Anyway, then we add and multiply that by weapon's damage mods which can by anything from 0 to whatever high value.
		
		inv = actorAttacker.GetInventory();		
		inv.GetWeaponDTNames(weaponId, damageNames );
		damageVal.valueBase  = actorAttacker.GetTotalWeaponDamage(weaponId, damageNames[0], GetInvalidUniqueId() );
		// Take 10% of random damage type
		damageVal.valueBase *= 0.10f;
		
		if( damageVal.valueBase == 0 )
		{
			damageVal.valueBase = 10;
		}
				
		damage = (damageVal.valueBase + action.processedDmg.vitalityDamage) * damageVal.valueMultiplicative + damageVal.valueAdditive;
		damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PIERCING, damage );
		
		damageAction.SetHitAnimationPlayType( EAHA_ForceYes );
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
		
	// Calculates final power stat bonus of attacker (attack power or spell power respectfully)
	private function GetAttackersPowerMod() : SAbilityAttributeValue
	{		
		var powerMod, criticalDamageBonus, min, max, critReduction, sp : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var totalBonus : float;
			
		//base value
		powerMod = action.GetPowerStatValue();
		if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
			LogDMHits("Attacker has power stat of 0!", action);
		
		// M.J. - Adjust damage for player's strong attack
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			powerMod.valueMultiplicative -= 0.833;
		
		// M.J. - Igni has extra damage bonus from spell power
		if ( playerAttacker && (W3IgniProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.IGNI_SPELL_POWER_MILT;
		
		// M.J. Aard damage do noet get damage increase from spell power
		if ( playerAttacker && (W3AardProjectile)action.causer )
			powerMod.valueMultiplicative = 1;
		
		//critical hits
		if(action.IsCriticalHit())
		{
			//Mutation 2 calculates 
			if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) )
			{
				sp = action.GetPowerStatValue();
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_damage_factor', min, max);				
				criticalDamageBonus.valueAdditive = sp.valueMultiplicative * min.valueMultiplicative;
			}
			else 
			{
				criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
				//if ( actorAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
				criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
				
				if(attackAction && playerAttacker)
				{
					if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
						criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
					else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
						criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s17);
				}
			}
			
			//crit damage reduction
			totalBonus = CalculateAttributeValue(criticalDamageBonus);
			critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
			totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);
			
			//final mod
			powerMod.valueMultiplicative += totalBonus;
		}
		
		// Mutagen 5 - incease damage if at max HP
		if (actorVictim && playerAttacker)
		{
			if ( playerAttacker.HasBuff(EET_Mutagen05) && (playerAttacker.GetStat(BCS_Vitality) == playerAttacker.GetStatMax(BCS_Vitality)) )
			{
				mutagen = playerAttacker.GetBuff(EET_Mutagen05);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
				powerMod += GetAttributeRandomizedValue(min, max);
			}
		}
			
		return powerMod;
	}
	
	// Calculates final damage resistances
	private function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
	{
		var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
		var bonusReduct, bonusResist : float;
		var mutagenBuff : W3Mutagen28_Effect;
		var appliedOilName, vsMonsterResistReduction : name;
		var oils : array< W3Effect_Oil >;
		var i : int;
		
		//fists ignore armor (all res is equal to 0)
		if(attackAction && attackAction.IsActionMelee() && actorAttacker.GetInventory().IsItemFists(weaponId) && !actorVictim.UsesEssence())
			return;
			
		//reductions from victim
		if(actorVictim)
		{
			//get base resists
			actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
			
			//oil damage reduction if player has skill which makes oil reduce player's received damage when fighting proper monster type			
			if(playerVictim && actorAttacker && playerVictim.CanUseSkill(S_Alchemy_s05))
			{
				GetOilProtectionAgainstMonster(dmgType, bonusResist, bonusReduct);
				//resistPts += bonusReduct * playerVictim.GetSkillLevel(S_Alchemy_s05);
				resistPerc += bonusResist * playerVictim.GetSkillLevel(S_Alchemy_s05);
			}
			
			//mutagen 28 damage protection against monsters
			if(playerVictim && actorAttacker && playerVictim.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerVictim.GetBuff(EET_Mutagen28);
				mutagenBuff.GetProtection(attackerMonsterCategory, dmgType, action.IsDoTDamage(), bonusResist, bonusReduct);
				resistPts += bonusReduct;
				resistPerc += bonusResist;
			}
			
			//from attacker
			if(actorAttacker)
			{
				//base armor reduction
				armorReduction = actorAttacker.GetAttributeValue('armor_reduction');
				armorReductionPerc = actorAttacker.GetAttributeValue('armor_reduction_perc');
				
				//lvl3 oil resistance reduction
				if(playerAttacker)
				{
					vsMonsterResistReduction = MonsterCategoryToResistReduction(victimMonsterCategory);
					oils = playerAttacker.inv.GetOilsAppliedOnItem( weaponId );
					
					if( oils.Size() > 0 )
					{
						for( i=0; i<oils.Size(); i+=1 )
						{
							appliedOilName = oils[ i ].GetOilItemName();
							
							//if proper oil for this monster type
							if( oils[ i ].GetAmmoCurrentCount() > 0 && dm.ItemHasAttribute( appliedOilName, true, vsMonsterResistReduction ) )
							{
								armorReductionPerc.valueMultiplicative += oils[ i ].GetAmmoPercentage();
							}
						}
					}
				}
				
				//basic heavy attack armor piercing
				if(playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_2))
					armorReduction += playerAttacker.GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, true);
				
				//skill damage reduction
				if ( playerAttacker && 
					 action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && 
					 ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
					   dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
				       dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
					   dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
					   dmgType == theGame.params.DAMAGE_NAME_RENDING || 
					   dmgType == theGame.params.DAMAGE_NAME_SILVER
					 ) && 
					 playerAttacker.CanUseSkill(S_Sword_s06)
				   ) 
				{
					//percentage skill reduction
					skillArmorReduction = playerAttacker.GetSkillAttributeValue(S_Sword_s06, 'armor_reduction_perc', false, true);
					armorReductionPerc += skillArmorReduction * playerAttacker.GetSkillLevel(S_Sword_s06);				
				}
			}
		}
		
		//add ARMOR if can
		if(!action.GetIgnoreArmor())
			resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
		
		//reduce resistance points by armor reduction
		resistPts = MaxF(0, resistPts - CalculateAttributeValue(armorReduction) );		
		resistPerc -= CalculateAttributeValue(armorReductionPerc);		
		//resistPerc *= (1 - MinF(1, armorReductionPerc.valueMultiplicative));		//bug or design change?		
		
		//percents resistance cap
		resistPerc = MaxF(0, resistPerc);
	}
		
	// Calculates final damage for a single damage type
	private function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage, finalIncomingDamage : float;
		var resistPoints, resistPercents : float;
		var ptsString, percString : string;
		var mutagen : CBaseGameplayEffect;
		var min, max : SAbilityAttributeValue;
		var encumbranceBonus : float;
		var temp : bool;
		var fistfightDamageMult : float;
		var burning : W3Effect_Burning;
	
		//get total reductions for this damage type
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
	
		//damage bonus from attacker
		if( thePlayer.IsFistFightMinigameEnabled() && actorAttacker == thePlayer )
		{
			finalDamage = MaxF(0, (dmgInfo.dmgVal));
		}
		else
		{
			// M.J. Spell power impact on Burning caused by Igni need to have diminished returns if spell power is greater than 2.5
			burning = (W3Effect_Burning)action.causer;
			if( burning && burning.IsSignEffect() )
			{
				if ( powerMod.valueMultiplicative > 2.5f )
				{
					powerMod.valueMultiplicative = 2.5f + LogF( (powerMod.valueMultiplicative - 2.5f) + 1 );
				}
			}
			
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
		}
			
		finalIncomingDamage = finalDamage;
			
		if(finalDamage > 0.f)
		{
			//damage reduction, point reduction might be skipped (e.g. Igni channeling)
			if(!action.IsPointResistIgnored() && !(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST ))
			{
				finalDamage = MaxF(0, finalDamage - resistPoints);
				
				if(finalDamage == 0.f)
					action.SetArmorReducedDamageToZero();
			}
		}
		
		if(finalDamage > 0.f)
		{
			// Mutagen 2 - increase resistPercents based on the encumbrance
			if (playerVictim == GetWitcherPlayer() && playerVictim.HasBuff(EET_Mutagen02))
			{
				encumbranceBonus = 1 - (GetWitcherPlayer().GetEncumbrance() / GetWitcherPlayer().GetMaxRunEncumbrance(temp));
				if (encumbranceBonus < 0)
					encumbranceBonus = 0;
				mutagen = playerVictim.GetBuff(EET_Mutagen02);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'resistGainRate', min, max);
				encumbranceBonus *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				resistPercents += encumbranceBonus;
			}
			finalDamage *= 1 - resistPercents;
		}		
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if( playerAttacker && thePlayer.IsWeaponHeld('fist') && !thePlayer.IsInFistFightMiniGame() && action.IsActionMelee() )
		{
			if(FactsQuerySum("NewGamePlus") > 0)
			{fistfightDamageMult = thePlayer.GetLevel()* 0.1;}
			else
			{fistfightDamageMult = thePlayer.GetLevel()* 0.05;}
			
			finalDamage *= ( 1+fistfightDamageMult );
		}
		// M.J. - Adjust damage for player's strong attack
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			finalDamage *= 1.833;
			
		//EP1 hack for boosting Igni damage against bosses
		burning = (W3Effect_Burning)action.causer;
		if(actorVictim && (((W3IgniEntity)action.causer) || ((W3IgniProjectile)action.causer) || ( burning && burning.IsSignEffect())) )
		{
			min = actorVictim.GetAttributeValue('igni_damage_amplifier');
			finalDamage = finalDamage * (1 + min.valueMultiplicative) + min.valueAdditive;
		}
		
		
		
		//extensive logging
		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
			
		return finalDamage;
	}
	
	//deal total damage
	private function ProcessActionDamage_DealDamage()
	{
		var logStr : string;
		var hpPerc : float;
		var npcVictim : CNewNPC;
	
		//extensive logging
		if ( theGame.CanLog() )
		{
			logStr = "";
			if(action.processedDmg.vitalityDamage > 0)			logStr += NoTrailZeros(action.processedDmg.vitalityDamage) + " vitality, ";
			if(action.processedDmg.essenceDamage > 0)			logStr += NoTrailZeros(action.processedDmg.essenceDamage) + " essence, ";
			if(action.processedDmg.staminaDamage > 0)			logStr += NoTrailZeros(action.processedDmg.staminaDamage) + " stamina, ";
			if(action.processedDmg.moraleDamage > 0)			logStr += NoTrailZeros(action.processedDmg.moraleDamage) + " morale";
				
			if(logStr == "")
				logStr = "NONE";
			LogDMHits("Final damage to sustain is: " + logStr, action);
		}
				
		//deal final damage 
		if(actorVictim)
		{
			hpPerc = actorVictim.GetHealthPercents();
			
			//don't deal damage if already dead
			if(actorVictim.IsAlive())
			{
				npcVictim = (CNewNPC)actorVictim;
				if(npcVictim && npcVictim.IsHorse())
				{
					npcVictim.GetHorseComponent().OnTakeDamage(action);
				}
				else
				{
					actorVictim.OnTakeDamage(action);
				}
			}
			
			if(!actorVictim.IsAlive() && hpPerc == 1)
				action.SetWasKilledBySingleHit();
		}
			
		if ( theGame.CanLog() )
		{
			LogDMHits("", action);
			LogDMHits("Target stats after damage dealt are:", action);
			if(actorVictim)
			{
				if( actorVictim.UsesVitality())						LogDMHits("Vitality = " + NoTrailZeros( actorVictim.GetStat(BCS_Vitality)), action);
				if( actorVictim.UsesEssence())						LogDMHits("Essence = "  + NoTrailZeros( actorVictim.GetStat(BCS_Essence)), action);
				if( actorVictim.GetStatMax(BCS_Stamina) > 0)		LogDMHits("Stamina = "  + NoTrailZeros( actorVictim.GetStat(BCS_Stamina, true)), action);
				if( actorVictim.GetStatMax(BCS_Morale) > 0)			LogDMHits("Morale = "   + NoTrailZeros( actorVictim.GetStat(BCS_Morale)), action);
			}
			else
			{
				LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
			}
		}
	}
	
	//Damage dealing - reduce durability of player items
	private function ProcessActionDamage_ReduceDurability()
	{		
		var witcherPlayer : W3PlayerWitcher;
		var dbg_currDur, dbg_prevDur1, dbg_prevDur2, dbg_prevDur3, dbg_prevDur4, dbg_prevDur : float;
		var dbg_armor, dbg_pants, dbg_boots, dbg_gloves, reducedItemId, weapon : SItemUniqueId;
		var slot : EEquipmentSlots;
		var weapons : array<SItemUniqueId>;
		var armorStringName : string;
		var canLog, playerHasSword : bool;
		var i : int;
		
		canLog = theGame.CanLog();

		witcherPlayer = GetWitcherPlayer();
	
		//weapon if attacker
		if ( playerAttacker && playerAttacker.inv.IsIdValid( weaponId ) && playerAttacker.inv.HasItemDurability( weaponId ) )
		{		
			dbg_prevDur = playerAttacker.inv.GetItemDurability(weaponId);
						
			if ( playerAttacker.inv.ReduceItemDurability(weaponId) && canLog )
			{
				LogDMHits("", action);
				LogDMHits("Player's weapon durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(action.attacker.GetInventory().GetItemDurability(weaponId)), action );
			}
		}
		//weapon if parry/counter
		else if(playerVictim && attackAction && attackAction.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			weapons = playerVictim.inv.GetHeldWeapons();
			playerHasSword = false;
			for(i=0; i<weapons.Size(); i+=1)
			{
				weapon = weapons[i];
				if(playerVictim.inv.IsIdValid(weapon) && (playerVictim.inv.IsItemSteelSwordUsableByPlayer(weapon) || playerVictim.inv.IsItemSilverSwordUsableByPlayer(weapon)) )
				{
					playerHasSword = true;
					break;
				}
			}
			
			if(playerHasSword)
			{
				playerVictim.inv.ReduceItemDurability(weapon);
			}
		}
		//armor if player is the victim and if action deals any damage
		else if(action.victim == witcherPlayer && (action.IsActionMelee() || action.IsActionRanged()) && action.DealsAnyDamage())
		{
			//extensive logging
			if ( canLog )
			{
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Armor, dbg_armor) )
					dbg_prevDur1 = action.victim.GetInventory().GetItemDurability(dbg_armor);
				else
					dbg_prevDur1 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Pants, dbg_pants) )
					dbg_prevDur2 = action.victim.GetInventory().GetItemDurability(dbg_pants);
				else
					dbg_prevDur2 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Boots, dbg_boots) )
					dbg_prevDur3 = action.victim.GetInventory().GetItemDurability(dbg_boots);
				else
					dbg_prevDur3 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Gloves, dbg_gloves) )
					dbg_prevDur4 = action.victim.GetInventory().GetItemDurability(dbg_gloves);
				else
					dbg_prevDur4 = 0;
			}
			
			slot = GetWitcherPlayer().ReduceArmorDurability();
			
			//extensive logging
			if( canLog )
			{
				LogDMHits("", action);
				if(slot != EES_InvalidSlot)
				{		
					switch(slot)
					{
						case EES_Armor : 
							armorStringName = "chest armor";
							reducedItemId = dbg_armor;
							dbg_prevDur = dbg_prevDur1;
							break;
						case EES_Pants : 
							armorStringName = "pants";
							reducedItemId = dbg_pants;
							dbg_prevDur = dbg_prevDur2;
							break;
						case EES_Boots :
							armorStringName = "boots";
							reducedItemId = dbg_boots;
							dbg_prevDur = dbg_prevDur3;
							break;
						case EES_Gloves :
							armorStringName = "gloves";
							reducedItemId = dbg_gloves;
							dbg_prevDur = dbg_prevDur4;
							break;
					}
					
					dbg_currDur = action.victim.GetInventory().GetItemDurability(reducedItemId);
					LogDMHits("", action);
					LogDMHits("Player's <<" + armorStringName + ">> durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(dbg_currDur), action );
				}
				else
				{
					LogDMHits("Tried to reduce player's armor durability but failed", action);
				}
			}
				
			//repair object bonus (use the same item that was chosed for durability reduction)
			if(slot != EES_InvalidSlot)
				thePlayer.inv.ReduceItemRepairObjectBonusCharge(reducedItemId);
		}
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////   @REACTION   ////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// processes action reaction - hit anims and particles
	private function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
	{
		var dismemberExplosion 			: bool;
		var damageName 					: name;
		var damage 						: array<SRawDamage>;
		var points, percents, hp, dmg 	: float;
		var counterAction 				: W3DamageAction;		
		var moveTargets					: array<CActor>;
		var i 							: int;
		var canPerformFinisher			: bool;
		var weaponName					: name;
		var npcVictim					: CNewNPC;
		var toxicCloud					: W3ToxicCloud;
		var playsNonAdditiveAnim		: bool;
		var bleedCustomEffect 			: SCustomEffectParams;
		
		if(!actorVictim)
			return;
		
		npcVictim = (CNewNPC)actorVictim;
		
		canPerformFinisher = CanPerformFinisher(actorVictim);
		
		if( actorVictim.IsAlive() && !canPerformFinisher )
		{
			//regular damage
			if(!action.IsDoTDamage() && action.DealtDamage())
			{
				if ( actorAttacker && npcVictim)
				{
					npcVictim.NoticeActorInGuardArea( actorAttacker );
				}

				//if hit when confused (Samum) remove the confusion
				if ( !playerVictim )
					actorVictim.RemoveAllBuffsOfType(EET_Confusion);
				
				//crippling strikes skill - add bleeding
				if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
				{
					bleedCustomEffect.effectType = EET_Bleeding;
					bleedCustomEffect.creator = playerAttacker;
					bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
					bleedCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'duration', false, true));
					bleedCustomEffect.effectValue.valueAdditive = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
					actorVictim.AddEffectCustom(bleedCustomEffect);
				}
			}
			
			//reaction on victim side
			if(actorVictim && wasAlive)
			{
				playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
			}				
		}
		else
		{
			//dismemberment
			if( !canPerformFinisher && CanDismember( wasFrozen, dismemberExplosion, weaponName ) )
			{
				ProcessDismemberment(wasFrozen, dismemberExplosion);
				toxicCloud = (W3ToxicCloud)action.causer;
				
				if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
					ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());
					
				//if dismembered victim is hostile to player drain morale
				if(IsRequiredAttitudeBetween(thePlayer, action.victim, true))
				{
					moveTargets = thePlayer.GetMoveTargets();
					for ( i = 0; i < moveTargets.Size(); i += 1 )
					{
						if ( moveTargets[i].IsHuman() )
							moveTargets[i].DrainMorale(20.f);
					}
				}
			}
			//Finisher
			else if ( canPerformFinisher )
			{
				if ( actorVictim.IsAlive() )
					actorVictim.Kill( 'Finisher', false, thePlayer );
					
				thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
				thePlayer.SetFinisherVictim( actorVictim );
				thePlayer.CleanCombatActionBuffer();
				thePlayer.OnBlockAllCombatTickets( true );
				
				if( actorVictim.WillBeUnconscious() )
				{
					actorVictim.SetBehaviorVariable( 'prepareForUnconsciousFinisher', 1.0f );
					actorVictim.ActionRotateToAsync( thePlayer.GetWorldPosition() );
				}
				
				moveTargets = thePlayer.GetMoveTargets();
				
				for ( i = 0; i < moveTargets.Size(); i += 1 )
				{
					if ( actorVictim != moveTargets[i] )
						moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
				}	
				
				if 	( 	theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" 
					|| ( (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation3 ) ) 
					||	actorVictim.WillBeUnconscious()
					)
				{
					actorVictim.AddAbility( 'ForceFinisher', false );
				}
				
				if ( actorVictim.HasTag( 'ForceFinisher' ) )
					actorVictim.AddAbility( 'ForceFinisher', false );
				
				actorVictim.SignalGameplayEvent( 'ForceFinisher' );
			} 
			else if ( weaponName == 'fists' && npcVictim )
			{
				npcVictim.DisableAgony();	
			}
			
			thePlayer.FindMoveTarget();
		}
		
		if( attackAction.IsActionMelee() )
		{
			actorAttacker.SignalGameplayEventParamObject( 'HitActionReaction', actorVictim );
			actorVictim.OnHitActionReaction( actorAttacker, weaponName );
		}
		
		//process hit sound
		actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
		
		//cam shake when critical hit and playing some hit animation or dead
		//if((playsNonAdditiveAnim || action.additiveHitReactionAnimRequested || !actorVictim.IsAlive()) && attackAction && attackAction.IsCriticalHit() && action.DealtDamage())
		if(action.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive() && actorAttacker == thePlayer )
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10 );
		
		// shield destruction
		if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) && attackAction.IsParried() && attackAction.GetAttackName() == 'attack_heavy' &&  npcVictim.GetStaminaPercents() <= 0.1 )
		{
			npcVictim.ProcessShieldDestruction();
		}
		
		//play hit fx
		if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
			actorVictim.PlayHitEffect(action);
			

		if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
		{
			// R.P: Hack requested by Konrad. Nekker should always have a blood effect, even if we deal no damage
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
		}
			
		//attacker's reflection animation - when player attacks monster with fists and ( (monster has high resistance to damage) or (cannot be hit by fists) )
		if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
		{
			actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
				
			if(MonsterCategoryIsMonster(victimMonsterCategory))
			{
				if(!victimCanBeHitByFists)
				{
					playerAttacker.ReactToReflectedAttack(actorVictim);
				}
				else
				{			
					actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
				
					if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
						playerAttacker.ReactToReflectedAttack(actorVictim);
				}
			}			
		}
		
		//sparks - if armored opponent blocked all damage
		ProcessSparksFromNoDamage();
		
		//check for countered attack
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.IsCountered() && playerVictim == GetWitcherPlayer())
		{
			GetWitcherPlayer().SetRecentlyCountered(true);
		}
		
		/*
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && attackAction.IsCountered()
		{
			//------------ damage from counterstrike			
			counterAction = new W3DamageAction in this;
			counterAction.Initialize(action.victim,action.attacker,NULL,'',EHRT_None,CPS_AttackPower,true,false,false,false);
			counterAction.SetHitAnimationPlayType(EAHA_ForceNo);
			counterAction.SetCanPlayHitParticle(false);
			
			//deal some damage but don't get below 1 hp left
			if(actorAttacker.UsesVitality())
			{
				hp = actorAttacker.GetStat(BCS_Vitality);
				damageName = theGame.params.DAMAGE_NAME_PHYSICAL;
			}
			else
			{
				hp = actorAttacker.GetStat(BCS_Essence);
				damageName = theGame.params.DAMAGE_NAME_SILVER;
			}
				
			if(hp <= 1)
				dmg = 0.0000001;
			else if(hp <= 5)
				dmg = hp - 1;
			else
				dmg = 5;
				
			counterAction.AddDamage(damageName,dmg);
			
			theGame.damageMgr.ProcessAction( counterAction );				
			delete counterAction;
		}
		*/
		
		//vibrate pad - any attack parried or countered
		if(attackAction && !action.IsDoTDamage() && (playerAttacker || playerVictim) && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			theGame.VibrateControllerLight();
		}
	}
	
	private function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
	{
		var dismember			: bool;
		var dismemberChance 	: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;

		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		arrow = (W3ArrowProjectile)action.causer;
		toxicCloud = (W3ToxicCloud)action.causer;
		
		dismemberExplosion = false;
		
		if(playerAttacker)
		{
			secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
		}
		
		if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if( actorVictim.HasTag( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if (actorVictim.WillBeUnconscious())
		{
			dismember = false;		
		}
		else if (playerAttacker && secondaryWeapon )
		{
			dismember = false;
		}
		else if( arrow && !wasFrozen )
		{
			dismember = false;
		}		
		else if( actorAttacker.HasAbility( 'ForceDismemberment' ) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if(wasFrozen)
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}						
		else if( (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if( (W3Effect_YrdenHealthDrain)action.causer )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else
		{
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName( weaponId );
			
			if( attackAction 
				&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
				&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
				&& weaponName != 'polearm'
				&& weaponName != 'fists_lightning' 
				&& weaponName != 'fists_fire' )
			{
				dismember = false;
			}			
			else if ( action.IsCriticalHit() )
			{
				dismember = true;
				dismemberExplosion = action.HasForceExplosionDismemberment();
			}
			else if ( action.HasForceExplosionDismemberment() )
			{
				dismember = true;
				dismemberExplosion = true;
			}
			else
			{
				//base
				dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
				
				//debug
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				//chance on weapon
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
					
				//perk
				witcher = (W3PlayerWitcher)actorAttacker;
				if(witcher && witcher.CanUseSkill(S_Perk_03))
					dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
				
				//Mutation 3 - sword kills always dismember
				if( ( W3PlayerWitcher )playerAttacker && attackAction.IsActionMelee() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) )	
				{
					if( thePlayer.inv.IsItemSteelSwordUsableByPlayer( weaponId ) || thePlayer.inv.IsItemSilverSwordUsableByPlayer( weaponId ) )
					{
						dismemberChance = 100;
					}
				}
				
				dismemberChance = Clamp(dismemberChance, 0, 100);
				
				if (RandRange(100) < dismemberChance)
					dismember = true;
				else
					dismember = false;
			}
		}		

		return dismember;
	}	
	
	private function CanPerformFinisher( actorVictim : CActor ) : bool
	{
		var finisherChance 			: int;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var b						: bool;
		var size					: int;
		var npc						: CNewNPC;
		
		if ( (W3ReplacerCiri)thePlayer || playerVictim || thePlayer.isInFinisher )
			return false;
		
		if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
			return false;
		
		// unconscious finisher only for EP2
		if ( actorVictim.WillBeUnconscious() && !theGame.GetDLCManager().IsEP2Available() )
			return false;
		
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		playerPos = thePlayer.GetWorldPosition();
	
		if ( size > 0 )
		{
			areEnemiesAttacking = false;			
			for(i=0; i<size; i+=1)
			{
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
				{
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		if ( actorVictim.IsHuman() )
		{
			npc = (CNewNPC)actorVictim;
			if ( ( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0 ) || ( actorVictim.HasAbility('ForceFinisher') ) || ( GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) ) )
			{
				finisherChance = 100;
			}
			else if ( ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) ) )
			{
				finisherChance = 75 + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else if ( npc.currentLevel - thePlayer.GetLevel() < -5 )
			{
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
				
			finisherChance = Clamp(finisherChance, 0, 100);
		}
		else 
			finisherChance = 0;	
			
		if ( actorVictim.HasTag('ForceFinisher') )
		{
			finisherChance = 100;
			areEnemiesAttacking = false;
		}
			
		item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );	
		
		if ( thePlayer.forceFinisher )
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
		}
		else
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && RandRange(100) < finisherChance;
			b =	b && !areEnemiesAttacking;
			b =	b && AbsF( victimToPlayerVector.Z ) < 0.4f;
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile;
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
			b =	b && ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) ;
			//&& playerAttacker.HasPerk( FINISHER_PERK) )
		}

		if ( b  )
		{
			if ( !actorVictim.IsAlive() && !actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'DisableFinishers', false );
				
			return true;
		}
		
		return false;
	}
	
	private function CanPerformFinisherOnAliveTarget( actorVictim : CActor ) : bool
	{
		return actorVictim.IsHuman() 
		&& ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) )
		&& actorVictim.IsVulnerable()
		&& !actorVictim.HasAbility('DisableFinisher')
		&& !actorVictim.HasAbility('InstantKillImmune');
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////   @BUFFS   ///////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// processes action buffs, returns true if at least one buff got processed
	private function ProcessActionBuffs() : bool
	{
		var inv : CInventoryComponent;
		var ret : bool;
	
		//no buffs if (attack was dodged) or (target is dead) or (melee attack and parried)
		if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.CanBeParried() && attackAction.IsParried()) )
			return true;
			
		//no buffs if quen prevented all damage. Unless the buff is a knockdown/stagger etc.
		ApplyQuenBuffChanges();
	
		//Mutation 2 valid explosion
		if( actorAttacker == thePlayer && action.IsActionWitcherSign() && action.IsCriticalHit() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation2 ) && action.HasBuff( EET_Burning ) )
		{
			action.SetBuffSourceName( 'Mutation2ExplosionValid' );
		}
	
		//apply buffs if any
		if(actorVictim && action.GetEffectsCount() > 0)
			ret = actorVictim.ApplyActionEffects(action);
		else
			ret = false;
			
		//if attacker is an actor apply also OnHit Applicator Buffs
		if(actorAttacker && actorVictim)
		{
			inv = actorAttacker.GetInventory();
			actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
		}
		
		return ret;
	}
	
	//Quen prevents some buffs from being applied - we filter it here
	private function ApplyQuenBuffChanges()
	{
		var npc : CNewNPC;
		var protection : bool;
		var witcher : W3PlayerWitcher;
		var quenEntity : W3QuenEntity;
		var i : int;
		var buffs : array<EEffectType>;
	
		if(!actorVictim || !actorVictim.HasAlternateQuen())
			return;
		
		npc = (CNewNPC)actorVictim;
		if(npc)
		{
			if(!action.DealsAnyDamage())
				protection = true;
		}
		else
		{
			witcher = (W3PlayerWitcher)actorVictim;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					protection = true;
				}
			}
		}
		
		if(!protection)
			return;
			
		action.GetEffectTypes(buffs);
		for(i=buffs.Size()-1; i>=0; i -=1)
		{
			if(buffs[i] == EET_KnockdownTypeApplicator || IsKnockdownEffectType(buffs[i]))
				continue;
				
			action.RemoveBuff(i);
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////   @DISMEMBERMENT  ////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function ProcessDismemberment(wasFrozen : bool, dismemberExplosion : bool )
	{
		var hitDirection		: Vector;
		var usedWound			: name;
		var npcVictim			: CNewNPC;
		var wounds				: array< name >;
		var i					: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;		
		var forcedRagdoll		: bool;
		var isExplosion			: bool;
		var dismembermentComp 	: CDismembermentComponent;
		var specialWounds		: array< name >;
		var useHitDirection		: bool;
		var fxMask				: EDismembermentEffectTypeFlags;
		var template			: CEntityTemplate;
		var ent					: CEntity;
		var signType			: ESignType;
		
		if(!actorVictim)
			return;
			
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
			
		if(wasFrozen)
		{
			ProcessFrostDismemberment();
			return;
		}
		
		forcedRagdoll = false;
		
		//explosion or normal?
		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		
		if( dismemberExplosion || (attackAction && ( attackAction.GetAttackName() == 'attack_explosion' || attackAction.HasForceExplosionDismemberment() ))
			|| (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			isExplosion = true;
		}
		else
		{
			isExplosion = false;
		}
		
		//forced wound?
		if(playerAttacker && thePlayer.forceDismember && IsNameValid(thePlayer.forceDismemberName))
		{
			usedWound = thePlayer.forceDismemberName;
		}
		else
		{	
			//find proper wound
			if(isExplosion)
			{
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );	

				//fx Mask for Mutation 2
				if( action.IsMutation2PotentialKill() )
				{
					//disable non-mutation 2 wounds
					for( i=wounds.Size()-1; i>=0; i-=1 )
					{
						if( !StrContains( wounds[ i ], "_ep2" ) )
						{
							wounds.EraseFast( i );
						}
					}
					
					signType = action.GetSignType();
					if( signType == ST_Aard )
					{
						fxMask = DETF_Aaard;
					}
					else if( signType == ST_Igni )
					{
						fxMask = DETF_Igni;
					}
					else if( signType == ST_Yrden )
					{
						fxMask = DETF_Yrden;
					}
					else if( signType == ST_Quen )
					{
						fxMask = DETF_Quen;
					}
				}
				else
				{
					fxMask = 0;
				}
				
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
				if ( usedWound )
					StopVO( actorVictim ); 
			}
			else if(attackAction || action.GetBuffSourceName() == "riderHit")
			{
				if  ( attackAction.GetAttackTypeName() == 'sword_s2' || thePlayer.isInFinisher )
					useHitDirection = true;
				
				if ( useHitDirection ) 
				{
					hitDirection = actorAttacker.GetSwordTipMovementFromAnimation( attackAction.GetAttackAnimName(), attackAction.GetHitTime(), 0.1, attackAction.GetWeaponEntity() );
					usedWound = actorVictim.GetNearestWoundForBone( attackAction.GetHitBoneIndex(), hitDirection, WTF_Cut );
				}
				else
				{			
					// Get all wounds
					dismembermentComp.GetWoundsNames( wounds );
					
					// remove explosion wounds
					if(wounds.Size() > 0)
					{
						dismembermentComp.GetWoundsNames( specialWounds, WTF_Explosion );
						for ( i = 0; i < specialWounds.Size(); i += 1 )
						{
							wounds.Remove( specialWounds[i] );
						}
						
						if(wounds.Size() > 0)
						{
							//remove frost wounds
							dismembermentComp.GetWoundsNames( specialWounds, WTF_Frost );
							for ( i = 0; i < specialWounds.Size(); i += 1 )
							{
								wounds.Remove( specialWounds[i] );
							}
							
							//select wound to use
							if ( wounds.Size() > 0 )
								usedWound = wounds[ RandRange( wounds.Size() ) ];
						}
					}
				}
			}
		}
		
		if ( usedWound )
		{
			npcVictim = (CNewNPC)action.victim;
			if(npcVictim)
				npcVictim.DisableAgony();			
			
			actorVictim.SetDismembermentInfo( usedWound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), forcedRagdoll, fxMask );
			actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
			actorVictim.SetBehaviorVariable( 'dismemberAnim', 1.0 );
			
			//MS: hack for bug 112289
			if ( usedWound == 'explode_02' || usedWound == 'explode2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2')
			{
				ProcessDismembermentDeathAnim( usedWound, true, EFDT_LegLeft );
				actorVictim.SetKinematic( false );
				//ApplyForce();				
			}
			else
			{
				ProcessDismembermentDeathAnim( usedWound, false );
			}
			
			//force for EP2 wounds (not in wound)
			if( usedWound == 'explode_01_ep2' || usedWound == 'explode1_ep2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2' )
			{
				template = (CEntityTemplate) LoadResource( "explosion_dismember_force" );
				ent = theGame.CreateEntity( template, npcVictim.GetWorldPosition(), , , , true );
				ent.DestroyAfter( 5.f );
			}
			
			DropEquipmentFromDismember( usedWound, true, true );
			
			if( attackAction && actorAttacker == thePlayer )			
				GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
				
			if(playerAttacker)
				theGame.VibrateControllerHard();	//dismemberment
				
			//add delayed and repositioned dismemberment force fx (because aard impulse is applied before dismemberment processes)
			if( dismemberExplosion && (W3AardProjectile)action.causer )
			{
				npcVictim.AddTimer( 'AardDismemberForce', 0.00001f );
			}
		}
		else
		{
			LogChannel( 'Dismemberment', "ERROR: No wound found to dismember on entity but entity supports dismemberment!!!" );
		}
	}
	
	function ApplyForce()
	{
		var size, i : int;
		var victim : CNewNPC;
		var fromPos, toPos : Vector;
		var comps : array<CComponent>;
		var impulse : Vector;
		
		victim = (CNewNPC)action.victim;
		toPos = victim.GetWorldPosition();
		toPos.Z += 1.0f;
		fromPos = toPos;
		fromPos.Z -= 2.0f;
		impulse = VecNormalize( toPos - fromPos.Z ) * 10;
		
		comps = victim.GetComponentsByClassName('CComponent');
		victim.GetVisualDebug().AddArrow( 'applyForce', fromPos, toPos, 1, 0.2f, 0.2f, true, Color( 0,0,255 ), true, 5.0f );
		size = comps.Size();
		for( i = 0; i < size; i += 1 )
		{
			comps[i].ApplyLocalImpulseToPhysicalObject( impulse );
		}
	}
	
	private function ProcessFrostDismemberment()
	{
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var wound				: name;
		var i, fxMask			: int;
		var npcVictim			: CNewNPC;
		
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
		
		dismembermentComp.GetWoundsNames( wounds, WTF_Frost );
		
		//set mask for optional frozen FX and remove old wounds that don't support it
		//note: intially this was for mutation 6 only but now it's for all frost dismemberment in EP2
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			fxMask = DETF_Mutation6;
			
			//disable old wounds so they won't randomize
			for( i=wounds.Size()-1; i>=0; i-=1 )
			{
				if( !StrContains( wounds[ i ], "_ep2" ) )
				{
					wounds.EraseFast( i );
				}
			}
		}
		else
		{
			fxMask = 0;
		}
		
		if ( wounds.Size() > 0 )
		{
			wound = wounds[ RandRange( wounds.Size() ) ];
		}
		else
		{
			return;
		}
		
		npcVictim = (CNewNPC)action.victim;
		if(npcVictim)
		{
			npcVictim.DisableAgony();
			StopVO( npcVictim );
		}
		
		actorVictim.SetDismembermentInfo( wound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), true, fxMask );
		actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
		if( wound == 'explode_02' || wound == 'explode2' || wound == 'explode_02_ep2' || wound == 'explode2_ep2' )
		{
			ProcessDismembermentDeathAnim( wound, true, EFDT_LegLeft );
			npcVictim.SetKinematic(false);
		}
		else
		{
			ProcessDismembermentDeathAnim( wound, false );
		}
		DropEquipmentFromDismember( wound, true, true );
		
		if( attackAction )			
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
			
		if(playerAttacker)
			theGame.VibrateControllerHard();	//dismemberment
	}
	
	
	private function ProcessDismembermentDeathAnim( nearestWound : name, forceDeathType : bool, optional deathType : EFinisherDeathType )
	{
		var dropCurveName : name;
		
		if ( forceDeathType )
		{
			if ( deathType == EFDT_Head )
				StopVO( actorVictim );
				
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)deathType );
			
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( dropCurveName == 'head' )
		{
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Head );
			StopVO( actorVictim );
		}
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Torso );
		else if ( dropCurveName == 'arm_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmRight );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmLeft );
		else if ( dropCurveName == 'leg_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegLeft );
		else if ( dropCurveName == 'leg_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegRight );
		else 
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_None );
	}
	
	private function StopVO( actor : CActor )
	{
		actor.SoundEvent( "grunt_vo_death_stop", 'head' );
	}

	private function DropEquipmentFromDismember( nearestWound : name, optional dropLeft, dropRight : bool )
	{
		var dropCurveName : name;
		
		if( actorVictim.HasAbility( 'DontDropWeaponsOnDismemberment' ) )
		{
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( ChangeHeldItemAppearance() )
		{
			actorVictim.SignalGameplayEvent('DropWeaponsInDeathTask');
			return;
		}
		
		if ( dropLeft || dropRight )
		{
			
			if ( dropLeft )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if ( dropRight )
				actorVictim.DropItemFromSlot( 'r_weapon', true );			
			
			return;
		}
		
		if ( dropCurveName == 'arm_right' )
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.DropItemFromSlot( 'l_weapon', true );
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
		{
			actorVictim.DropItemFromSlot( 'l_weapon', true );
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		}			
		else if ( dropCurveName == 'head' || dropCurveName == 'leg_left' || dropCurveName == 'leg_right' )
		{
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'r_weapon', true );
		} 
	}
	
	function ChangeHeldItemAppearance() : bool
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		
		inv = actorVictim.GetInventory();
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
	
		return false;
	}
	
	//If player has proper skill then oils applied on used weapon also grant additional resists against given monster type.
	private function GetOilProtectionAgainstMonster(dmgType : name, out resist : float, out reduct : float)
	{
		var i : int;
		var heldWeapons : array< SItemUniqueId >;
		var weapon : SItemUniqueId;
		
		resist = 0;
		reduct = 0;
		
		//get held weapon - we cannot use weaponID as this has to work also with non attackActions, like signs 
		heldWeapons = thePlayer.inv.GetHeldWeapons();
		
		//filter out fists
		for( i=0; i<heldWeapons.Size(); i+=1 )
		{
			if( !thePlayer.inv.IsItemFists( heldWeapons[ i ] ) )
			{
				weapon = heldWeapons[ i ];
				break;
			}
		}
		
		//abort if no weapon drawn
		if( !thePlayer.inv.IsIdValid( weapon ) )
		{
			return;
		}
	
		//no active oil of proper type
		if( !thePlayer.inv.ItemHasActiveOilApplied( weapon, attackerMonsterCategory ) )
		{
			return;
		}
		
		resist = CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Alchemy_s05, 'defence_bonus', false, true ) );		
	}
	
	//toxi cloud from dragon's dream level 3 will explode targets if they die in explosion and by doing so will do additional damage (corpse explosion kind of)
	private function ProcessToxicCloudDismemberExplosion(damages : array<SRawDamage>)
	{
		var act : W3DamageAction;
		var i, j : int;
		var ents : array<CGameplayEntity>;
		
		//check data
		if(damages.Size() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessToxicCloudDismemberExplosion: trying to process but no damages are passed! Aborting!");
			return;
		}		
		
		//get alive actors in sphere
		FindGameplayEntitiesInSphere(ents, action.victim.GetWorldPosition(), 3, 1000, , FLAG_OnlyAliveActors);
		
		//deal additional damage
		for(i=0; i<ents.Size(); i+=1)
		{
			act = new W3DamageAction in this;
			act.Initialize(action.attacker, ents[i], action.causer, 'Dragons_Dream_3', EHRT_Heavy, CPS_Undefined, false, false, false, true);
			
			for(j=0; j<damages.Size(); j+=1)
			{
				act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
			}
			
			theGame.damageMgr.ProcessAction(act);
			delete act;
		}
	}
	
	//sparks - if armored opponent blocked all damage
	private final function ProcessSparksFromNoDamage()
	{
		var sparksEntity, weaponEntity : CEntity;
		var weaponTipPosition : Vector;
		var weaponSlotMatrix : Matrix;
		
		//only if: player attacks melee and no damage was dealt
		if(!playerAttacker || !attackAction || !attackAction.IsActionMelee() || attackAction.DealsAnyDamage())
			return;
		
		//only if damage got reduced to 0 by high enough armor attribute. Skip if attack was parried or countered as that already displays sparks.
		if( ( !attackAction.DidArmorReduceDamageToZero() && !actorVictim.IsVampire() && ( attackAction.IsParried() || attackAction.IsCountered() ) ) 
			|| ( ( attackAction.IsParried() || attackAction.IsCountered() ) && !actorVictim.IsHuman() && !actorVictim.IsVampire() )
			|| actorVictim.IsCurrentlyDodging() )
			return;
		
		//don't show if customly set not to show
		if(actorVictim.HasTag('NoSparksOnArmorDmgReduced'))
			return;
		
		//don't show when hitting invisible opponent
		if (!actorVictim.GetGameplayVisibility())
			return;
		
		//get position of weapon tip
		weaponEntity = playerAttacker.inv.GetItemEntityUnsafe(weaponId);
		weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
		weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
		
		//spawn sparks fx
		sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sword_colision_fx' ), weaponTipPosition );
		sparksEntity.PlayEffect('sparks');
	}
	
	private function ProcessPreHitModifications()
	{
		var fireDamage, totalDmg, maxHealth, currHealth : float;
		var attribute, min, max : SAbilityAttributeValue;
		var infusion : ESignType;
		var hack : array< SIgniEffects >;
		var dmgValTemp : float;
		var igni : W3IgniEntity;
		var quen : W3QuenEntity;

		if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
		{
			if( actorVictim.HasTag( 'fairytale_witch' ) )
			{
				//if( actorVictim.GetStatPercents( BCS_Essence ) > 0.6 )
				//{
				//	actorVictim.DrainEssence( actorVictim.GetStatMax( BCS_Essence ) * 0.1 );
				//}
				//else
				//{
					((CNewNPC)actorVictim).SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
				//}
			}
			else
			{
				quen = (W3QuenEntity)action.causer; 
			
				if( !quen )
				{
					if( actorVictim.HasTag( 'dettlaff_vampire' ) )
					{
						actorVictim.StopEffect( 'shadowdash' );
					}
					
					action.ClearDamage();
					if( action.IsActionMelee() )
					{
						actorVictim.PlayEffect( 'special_attack_break' );
					}
					actorVictim.SetBehaviorVariable( 'repelType', 0 );
					//action.AddEffectInfo( EET_CounterStrikeHit );
					actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); // i know this is hacky but upper line doesnt work with Igni for some reason
					action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				}
			}
			
			((CNewNPC)actorVictim).SetHitWindowOpened( false );
		}
		
		//Runeword infusing sword attacks with previously cast sign's power. Ability check is doubled here to prevent cases where
		//player would cast sign to infuse and then switch gear.
		if(playerAttacker && attackAction && attackAction.IsActionMelee() && (W3PlayerWitcher)thePlayer && thePlayer.HasAbility('Runeword 1 _Stats', true))
		{
			infusion = GetWitcherPlayer().GetRunewordInfusionType();
			
			switch(infusion)
			{
				case ST_Aard:
					action.AddEffectInfo(EET_KnockdownTypeApplicator);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					actorVictim.CreateFXEntityAtPelvis( 'runeword_1_aard', false );
					break;
				case ST_Axii:
					action.AddEffectInfo(EET_Confusion);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				case ST_Igni:
					//damage
					totalDmg = action.GetDamageValueTotal();
					attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
					fireDamage = totalDmg * attribute.valueMultiplicative;
					action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireDamage);
					
					//hit reaction
					action.SetCanPlayHitParticle(false);					
					action.victim.AddTimer('Runeword1DisableFireFX', 1.f);
					action.SetHitReactionType(EHRT_Heavy);	//EHRT_Igni does not work for NPCs anymore...					
					action.victim.PlayEffect('critical_burning');
					break;
				case ST_Yrden:
					attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
					action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				default:		//Quen done after the attack
					break;
			}
		}
		
		//mutation 9
		if( playerAttacker && actorVictim && (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && (W3BoltProjectile)action.causer )
		{
			maxHealth = actorVictim.GetMaxHealth();
			currHealth = actorVictim.GetHealth();
			
			//health reduction when at full health. 1 point difference is due to the fact that e.g. 51480.0 != 51480.0 according to our engine
			if( AbsF( maxHealth - currHealth ) < 1.f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'health_reduction', min, max);
				actorVictim.ForceSetStat( actorVictim.GetUsedHealthType(), maxHealth * ( 1 - min.valueMultiplicative ) );
			}
			
			//knockdown applicator with 100% chance
			action.AddEffectInfo( EET_KnockdownTypeApplicator, 0.1f, , , , 1.f );
		}
	}
}

exec function ForceDismember( b: bool, optional chance : int, optional n : name, optional e : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forceDismember = b;
	temp.forceDismemberName = n;
	temp.forceDismemberChance = chance;
	temp.forceDismemberExplosion = e;
} 

exec function ForceFinisher( b: bool, optional n : name, optional rightStance : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forcedStance = rightStance;
	temp.forceFinisher = b;
	temp.forceFinisherAnimName = n;
} 
