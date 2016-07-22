
// Class responsible for bolt damage processing related with CrossbowDamageBoostAndBalance mod
class CrossbowDamageBoostProcessor
{
	public var crossbowDamageBoostData : CrossbowDamageBoostData;
	
	private var victimsSplitBolt : array<CActor>;
	
	private var	baseSplitReduction : float;
	default baseSplitReduction = 0.5;
	
	private var extraSplitReduction : float;
	default extraSplitReduction = 0.15;
	
	private var cachedLevel : int;
	default cachedLevel = 0;
	private var cachedExtraDamage : float;
	default cachedExtraDamage = 0.0f;

	public function Init()
	{
		crossbowDamageBoostData = new CrossbowDamageBoostData in this;
		crossbowDamageBoostData.Init();
	}

	// CrossbowDamageBoost
	public function GetExtraBoltDamage(level : int) : float
	{
		if (level != cachedLevel) {
			cachedLevel = level;
			CalcExtraBoltDamage();
		}
		
		return cachedExtraDamage;
	}
	
	private function CalcExtraBoltDamage()
	{
		var loopEnd : int;
		var i : int;

		loopEnd = Min(crossbowDamageBoostData.boltBaseDamage.Size(), cachedLevel);
		cachedExtraDamage = 0.0f;

		for(i=0; i < loopEnd; i+=1)
		{
			cachedExtraDamage += crossbowDamageBoostData.boltBaseDamage[i];
		}
	}
	
	public function GetBoltDamageMod(boltName : name) : float
	{
		switch ( boltName )
		{
		case 'Bodkin Bolt':
			return 0.6f;
		case 'q704_vampire_lure_bolt':
		case 'Bait Bolt':
		case 'Tracking Bolt':
		case 'Blunt Bolt':
			return 0.75f;
		case 'Broadhead Bolt':
			return 0.85f;
		case 'Split Bolt':
		case 'Explosive Bolt':
		case 'Blunt Bolt Legendary':
			return 0.9f;
		case 'Explosive Bolt Legendary':
			return 1.05f;
		case 'Target Point Bolt Legendary':
			return 1.15f;		
		default:
			return 1.0f;
		}
	}
	
	public function GetBoltDamageModCatEyes(boltName : name) : float
	{
		switch ( boltName )
		{
		case 'Bodkin Bolt':
			return 0.6f;
		case 'Bait Bolt':
		case 'Tracking Bolt':
		case 'Blunt Bolt':
		case 'q704_vampire_lure_bolt':
			return 0.7f;
		case 'Broadhead Bolt':
		case 'Split Bolt':
			return 0.8f;
		case 'Explosive Bolt':
		case 'Blunt Bolt Legendary':
			return 0.85f;
		case 'Target Point Bolt Legendary':
			return 1.2f;		
		default:
			return 1.0f;
		}
	}

	public function ProcessBoltDamage(out dmgInfos : array< SRawDamage >, action : W3Action_Attack, bolt : W3BoltProjectile, actorVictim : CActor)
	{
		var extraBoltDamage : float;
		var victimAsNPC : CNewNPC ;
		var i : int;
		var isAimedBolt, flyingTarget, splitBoltReduction : bool;
		var boltName : name;
		var witcher : W3PlayerWitcher;
		var explosiveBolt : W3ExplosiveBolt;
		
		witcher = (W3PlayerWitcher)(action.attacker);
		explosiveBolt = (W3ExplosiveBolt)bolt;

		extraBoltDamage = GetExtraBoltDamage(witcher.GetLevel());
		splitBoltReduction = false;
		boltName = bolt.GetBoltName();
		
		if (boltName == 'Split Bolt' || boltName == 'Split Bolt Legendary')
		{
			splitBoltReduction = CheckWasHitBySplitBolt(actorVictim);
		}

		if (explosiveBolt)
		{
			extraBoltDamage *= crossbowDamageBoostData.ExplosiveWitcherFactor * explosiveBolt.GetDamageMod();
		}
		
		isAimedBolt = bolt.GetWasAimedBolt();
		victimAsNPC = (CNewNPC)actorVictim;
		flyingTarget = victimAsNPC && victimAsNPC.IsFlying();

		for(i=0; i<dmgInfos.Size(); i+=1)
		{
			if (explosiveBolt) {
				dmgInfos[i].dmgVal *= crossbowDamageBoostData.ExplosiveBoltFactor * explosiveBolt.GetDamageMod();
			}

			if (dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_SILVER)
			{
				dmgInfos[i].dmgVal *= crossbowDamageBoostData.SilverBoltFactor;
				dmgInfos[i].dmgVal += crossbowDamageBoostData.SilverWitcherFactor * GetBoltDamageMod(boltName) * extraBoltDamage;

				if (!isAimedBolt && flyingTarget)
				{
					dmgInfos[i].dmgVal /= 2.0;
				}					
			}
			else
			{
				dmgInfos[i].dmgVal *= crossbowDamageBoostData.SteelBoltFactor;
				dmgInfos[i].dmgVal += crossbowDamageBoostData.SteelWitcherFactor * GetBoltDamageMod(boltName) * extraBoltDamage;
			}
			
			if (splitBoltReduction)
				dmgInfos[i].dmgVal = ReduceSplitBoltDamage(dmgInfos[i].dmgVal, isAimedBolt, flyingTarget);
				
			if (isAimedBolt)
			{
				if (witcher.CanUseSkill(S_Perk_02))
					dmgInfos[i].dmgVal *= 1.2;
				else
					dmgInfos[i].dmgVal *= 1.1;
			}
			else
			{
				dmgInfos[i].dmgVal = RandRangeF( dmgInfos[i].dmgVal * 1.1, dmgInfos[i].dmgVal * 0.9 );
			}
		}
	}
	
	public function ProcessBoltBuffs(action : W3DamageAction, boltCauser : W3BoltProjectile)
	{
		var effects : array< SEffectInfo >;
		var effectsSize, i : int;
		var ourEffect : SEffectInfo;
		var catEyes : bool;
		var knockdownChance : float;
		
		if (!action.HasBuff(EET_HeavyKnockdown))
			return;
			
		catEyes = ((W3PlayerWitcher)(action.attacker)).IsMutationActive( EPMT_Mutation9 );
	
		effectsSize = action.GetEffects(effects);
		for ( i=0 ; i < effectsSize ; i+=1 )
		{
			if( effects[i].effectType == EET_HeavyKnockdown)
			{
				knockdownChance = effects[i].applyChance;
				
				if (catEyes)
				{
					ourEffect = effects[i];
					ourEffect.applyChance += 0.25f;
					ourEffect.applyChance = MinF(ourEffect.applyChance , 1.0f);
					
					action.RemoveBuff(i);
					action.AddEffectInfo(ourEffect.effectType, , , ourEffect.effectAbilityName, ,ourEffect.applyChance);
					break;
				}
			}
		}

		knockdownChance += 0.3f;
		if (catEyes)
			knockdownChance += 0.4f;

		knockdownChance = MinF(knockdownChance, 1.0f);

		action.AddEffectInfo(EET_Knockdown, , , 'KnockdownEffect', ,knockdownChance);
	}

	private function ReduceSplitBoltDamage(initialDmg : float, isAimed : bool, flyingTarget : bool) : float
	{
		var level : int;
		var totalReduction : float;
		
		level = GetWitcherPlayer().GetLevel();
		
		level = Max(20, level);
		level = Min(80, level);
		
		totalReduction = baseSplitReduction + ((level - 20) / 60.0 ) * extraSplitReduction;
		if (isAimed)
		{
			if (flyingTarget)
				totalReduction /= 2.0;
			else
				totalReduction /= 1.5;
		}
		
		return initialDmg * (1.0 - totalReduction);
	}
	
	private function CheckWasHitBySplitBolt(victim : CActor) : bool
	{
		var i : int;
		var loopEnd : int;
		
		loopEnd = victimsSplitBolt.Size();
	
		for(i=0; i < loopEnd; i+=1)
		{
			if (victim == victimsSplitBolt[i])
			{
				return true;
			}
		}
		
		GetWitcherPlayer().AddTimer('OnCrossbowDmgProcessorTimer', 0.1);
		victimsSplitBolt.PushBack(victim);

		return false;
	}

	public function OnTimer()
	{
		victimsSplitBolt.Clear();
	}
}
