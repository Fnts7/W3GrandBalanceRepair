/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

//class to be derived from to pass custom buff data to buffs (case-by-case)
class W3BuffCustomParams {}

//struct for passing custom params to buffs
struct SCustomEffectParams
{
	var effectType 				: EEffectType;				//effect type
	var creator 				: CGameplayEntity;			//object that created and applies the buff
	var sourceName				: string;					//source name - same source names will cumulate, different will stack
	var duration				: float;					//buff duration, -1 for infinite
	var effectValue				: SAbilityAttributeValue;	//custom value of the effect to pass. Usage depends on buff
	var customAbilityName		: name;						//ability name to be used instead of default ability. Most likely will override duration and effect value
	var customFXName			: name;						//special effect name to be used of default fx.
	var isSignEffect			: bool;						//set to true if buff is added by sign
	var customPowerStatValue	: SAbilityAttributeValue;	//custom value of Power Stat to use (other than the one got from creator)
	var buffSpecificParams		: W3BuffCustomParams;		//struct for passing buff-specific params
	var vibratePadLowFreq 		: float;					//pad vibration
	var vibratePadHighFreq 		: float;					//pad vibration
};

struct SCurrentBuffFX
{
	var fx : name;
	var sources : array<string>;
};

class W3PotionParams extends W3BuffCustomParams
{
	var potionItemName : name;
}

//struct with params passed when initializing buff
struct SEffectInitInfo
{
	var owner : CGameplayEntity;
	var target : CActor;
	var duration : float;
	var sourceName : string;
	var targetEffectManager : W3EffectManager;

	//optional
	var powerStatValue : SAbilityAttributeValue;
	var customEffectValue : SAbilityAttributeValue;
	var customAbilityName : name;
	var customFXName : name;
	var isSignEffect : bool;
	var vibratePadLowFreq 		: float;					//pad vibration
	var vibratePadHighFreq 		: float;					//pad vibration
};

// Struct to pass required effect data from action to effect manager when applying effects from action.
struct SEffectInfo
{
	editable var effectType : EEffectType;
	editable var effectDuration : float;
	editable var effectAbilityName : name;						//optional custom ability
	editable var customFXName : name;
	editable var effectCustomValue : SAbilityAttributeValue;	//custom effect value
	editable var effectCustomParam : W3BuffCustomParams;
	editable var applyChance : float;							//chance to apply buff [0..1]
	
		hint effectDutation = "Set -1 for infinite";
};

// Struct holds cached damages to be dealt by effects in a given tick (e.g. poison, toxicity)
struct SEffectCachedDamage
{
	saved var dmgType : name;	
	saved var attacker : EntityHandle;					//attacker entity (for DM)	#DynSave
	saved var carrier : CBaseGameplayEffect;			//carrier entity (for DM)
	saved var dmgVal	: float;
	saved var dt : float;								//dt used by DoT damage, otherwise 0 (if not DoT)
	saved var dontShowHitParticle : bool;
	saved var powerStatType : ECharacterPowerStats;		//power stat to be used for damage calculation
	saved var isEnvironment : bool;						//if buff is from environment source
	saved var sourceName : string;						//buff sourcename
};

//used by Damage over Time buffs to store its damage types
struct SDoTDamage
{
	saved var damageTypeName : name;					//damage type name
	saved var hitsVitality  : bool;						//cached
	saved var hitsEssence  : bool;						//cached
	saved var resistance : ECharacterDefenseStats;		//cached
};

//map for effect icon types and their paths 
struct SEffectIconType
{
	var typeName : name;
	var path : string;
};

//Interactions between buffs
enum EEffectInteract
{
	EI_Undefined,			//not set
	EI_Deny,				//new effect cannot be added
	EI_Override,			//new effect overrides old effect (old one is removed)
	EI_Pass,				//new effect passes interaction (it can be overriden, passed or cumulated based on the other effect's preference)
	EI_Cumulate				//some old effect will cumulate with this effect (old one will be changed, new will not be applied)
}

function EffectInteractionSuccessfull( e : EEffectInteract ) : bool
{
	if( e == EI_Undefined || e == EI_Deny )
	{
		return false;
	}
	
	return true;
}

//Effects
//if you add any new one add handling to:
// * GameEffectManager.CacheEffect()
// * EffectNameToType() global func
// * EffectTypeToName() global func
enum EEffectType
{
	EET_Undefined,		//default

	// AUTO REGENS
	EET_AutoVitalityRegen,
	EET_AutoStaminaRegen,
	EET_AutoEssenceRegen,
	EET_AutoMoraleRegen,
		
	// CRITICAL
	EET_Confusion,
	EET_HeavyKnockdown,
	EET_Hypnotized,
	EET_Immobilized,
	EET_Knockdown,	
	EET_KnockdownTypeApplicator,
	EET_Frozen,
	EET_Paralyzed,
	EET_Stagger,
	EET_Blindness,
	EET_PoisonCritical,
				
	// DAMAGE OVER TIME
	EET_Bleeding,
	EET_BleedingTracking,
	EET_Burning,
	EET_Poison,
	EET_DoTHPRegenReduce,
		
	//DRAIN	
	EET_Toxicity,
		
	// POTIONS
	EET_BlackBlood,
	EET_Blizzard,
	EET_Cat,
	EET_FullMoon,
	EET_GoldenOriole,
	EET_MariborForest,
	EET_PetriPhiltre,
	EET_Swallow,
	EET_TawnyOwl,
	EET_Thunderbolt,
EET_Unused1,
	EET_WhiteHoney,
	EET_WhiteRaffardDecoction,
	EET_KillerWhale,
	
	// SKILLS
	EET_AxiiGuardMe,
	EET_IgnorePain,
	
	//OTHER	
	EET_StaggerAura,
	EET_OverEncumbered,
	EET_Edible,	
	EET_LowHealth,
	EET_Slowdown,
	EET_Fact,
	EET_WellFed,
	EET_SlowdownFrost,
	
	//NEW
	EET_LongStagger,				//stagger type
	EET_WellHydrated,
	EET_BattleTrance,				//skill
	EET_YrdenHealthDrain,
	EET_AdrenalineDrain,
	EET_WeatherBonus,
	EET_Swarm,						//swarm critical
	EET_Pull,						//web pull critical
	EET_AbilityOnLowHealth,			//adds ability when hp is below given level
	EET_Oil,
	EET_CounterStrikeHit,	
	EET_Drowning,
	EET_Snowstorm,	
	EET_AutoAirRegen,
	
	//SHRINES
	EET_ShrineAard,
	EET_ShrineAxii,
	EET_ShrineIgni,
	EET_ShrineQuen,
	EET_ShrineYrden,
	
	//NEW
	EET_Ragdoll,	
	EET_AutoPanicRegen,	
	EET_VitalityDrain,
	EET_DoppelgangerEssenceRegen,	
	EET_FireAura,	
	EET_BoostedEssenceRegen,
	EET_AirDrain,
	EET_SilverDust,

	// MUTAGENS
	EET_Mutagen01,
	EET_Mutagen02,
	EET_Mutagen03,
	EET_Mutagen04,
	EET_Mutagen05,
	EET_Mutagen06,
	EET_Mutagen07,
	EET_Mutagen08,
	EET_Mutagen09,
	EET_Mutagen10,
	EET_Mutagen11,
	EET_Mutagen12,
	EET_Mutagen13,
	EET_Mutagen14,
	EET_Mutagen15,
	EET_Mutagen16,
	EET_Mutagen17,
	EET_Mutagen18,
	EET_Mutagen19,
	EET_Mutagen20,
	EET_Mutagen21,
	EET_Mutagen22,
	EET_Mutagen23,
	EET_Mutagen24,
	EET_Mutagen25,
	EET_Mutagen26,
	EET_Mutagen27,
	EET_Mutagen28,
	
	//new pack
	EET_AirDrainDive,
	EET_BoostedStaminaRegen,
	EET_WitchHypnotized,
	EET_AirBoost,
	EET_StaminaDrainSwimming,
	EET_AutoSwimmingStaminaRegen,
	EET_Drunkenness,
	EET_WraithBlindness,
	EET_Choking,
	EET_StaminaDrain,
	EET_EnhancedArmor,
	EET_EnhancedWeapon,
	EET_SnowstormQ403,
	EET_SlowdownAxii,
	EET_PheromoneNekker,
	EET_PheromoneDrowner,
	EET_PheromoneBear,
	EET_Tornado,
	EET_WolfHour,
	EET_WeakeningAura,
	EET_Weaken,
	
	EET_Tangled,					//web tangle critical
	EET_Runeword8,
	EET_LynxSetBonus,
	EET_GryphonSetBonus,
	EET_GryphonSetBonusYrden,
	EET_POIGorA10,
	EET_Mutation7Buff,
	EET_Mutation7Debuff,
	EET_Mutation10,
	EET_Perk21InternalCooldown,
	EET_Mutation11Buff,
	EET_Mutation11Debuff,	
	EET_Acid,						// Mutation 4 Acidous Blood - it works against all enemies
	EET_WellRested,
	EET_HorseStableBuff,
	EET_BookshelfBuff,
	EET_PolishedGenitals,
	EET_Mutation12Cat,
	EET_Mutation11Immortal,
	EET_Aerondight,
	EET_Trap,
	EET_Mutation3,
	EET_Mutation4,
	EET_Mutation5,
	EET_ToxicityVenom,
	EET_BasicQuen,
	
	//always add new buffs BEFORE those 2 entries
EET_EffectTypesSize,
EET_ForceEnumTo16Bit = 10000
}

//returns an array of all possible Minor Shrine Buffs
function GetMinorShrineBuffs() : array<EEffectType>
{
	var ret : array<EEffectType>;
	
	ret.PushBack(EET_ShrineAard);
	ret.PushBack(EET_ShrineAxii);
	ret.PushBack(EET_ShrineIgni);
	ret.PushBack(EET_ShrineQuen);
	ret.PushBack(EET_ShrineYrden);
	
	return ret;
}

// Structure holding buff immunity info
import struct CBuffImmunity
{
	//immunity flags - buff types
	import var  potion : Bool ;
	import var  positive  : Bool ;
	import var 	neutral : bool;
	import var  negative : Bool ;
	import var  immobilize : Bool ;
	import var  confuse : Bool ;
	import var  damage : Bool ;
	
	//single, particular buffs
	import var  immunityTo : array<int>;		//EEffectType but must be int since it's passed from code and enum is defined in the scripts (and it should be since it'll change a lot)
}

//spawns of applicator auras' data
struct SApplicatorSpawnEffect
{		
	saved var spawnAbilityName : name;											//custom ability's name
	saved var spawnType : EEffectType;											//spawned buff's type
	saved var spawnFlagsHostile, spawnFlagsNeutral, spawnFlagsFriendly : bool;	//spawned buff's hostility flags
	saved var spawnSourceName : string;											//spawned buff's source name, MUST BE DEFINED BY CHILD CLASS
};

struct SPausedAutoEffect
{
	saved var effectType		: EEffectType;
	saved var duration 			: float;
	saved var sourceName 		: name;
	saved var singleLock 		: bool;
	saved var useMaxDuration 	: bool;
	saved var timeLeft 			: float;
};

struct STemporarilyPausedEffect
{
	saved var buff			: CBaseGameplayEffect;
	saved var timeLeft 		: float;
	saved var source 		: name;
	saved var singleLock 	: bool;
	saved var useMaxDuration 	: bool;
	saved var duration 			: float;
};

struct SBuffPauseLock
{
	saved var sourceName 	: name;
	saved var counter 		: int;
};

/*
	Function picks proper 'hit severity' buff based on target's special effects that
	reduce hit severity (e.g. changes Knockdown to Stagger)
	
	type - initial buff type
	
	@returns - final buff type
*/
function ModifyHitSeverityBuff(target : CActor, type : EEffectType) : EEffectType
{
	var severityReduction, severity : int;
	var npc : CNewNPC;
	var witcher : W3PlayerWitcher;
	var quenEntity : W3QuenEntity;

	severityReduction = RoundMath(CalculateAttributeValue(target.GetAttributeValue('hit_severity')));
		
	//get severity
	switch(type)
	{
		case EET_HeavyKnockdown : 	severity = 4; break;
		case EET_Knockdown :		severity = 3; break;
		case EET_LongStagger : 		severity = 2; break;
		case EET_Stagger :			severity = 1; break;
		default :					severity = 0; break;
	}
	
	//severity reduction
	severity -= severityReduction;
	
	//quen
	if(target.HasAlternateQuen())		
	{
		if( (CNewNPC)target )
		{
			//npc reduces severity by 1
			severity -= 1;
		}
		else
		{
			//player only if he didn't get any damage (quen blocked all)
			witcher = (W3PlayerWitcher)target;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					severity -= 1;
				}
			}
		}
	}
	
	//immunes
	if(severity == 4 && target.IsImmuneToBuff(EET_HeavyKnockdown))		severity = 3;
	if(severity == 3 && target.IsImmuneToBuff(EET_Knockdown))			severity = 2;
	if(severity == 2 && target.IsImmuneToBuff(EET_LongStagger))			severity = 1;
	if(severity == 1 && target.IsImmuneToBuff(EET_Stagger))				severity = 0;
			
	//return
	if(severity >= 4)
		return EET_HeavyKnockdown;
	else if(severity == 3)
		return EET_Knockdown;
	else if(severity == 2)
		return EET_LongStagger;
	else if(severity == 1)
		return EET_Stagger;
	else
		return EET_Undefined;
}

function IsKnockdownEffectType(type : EEffectType) : bool
{
	switch (type)
	{
		case EET_HeavyKnockdown :
		case EET_Knockdown :
		case EET_LongStagger :
		case EET_Stagger :
			return true;
		default: 
			return false;
	}
}

function IsCriticalEffectType(type : EEffectType) : bool
{
	switch (type)
	{
		case EET_Immobilized :
		case EET_Burning :
		case EET_Knockdown :
		case EET_HeavyKnockdown :
		case EET_Blindness :
		case EET_WraithBlindness :
		case EET_Confusion :
		case EET_Paralyzed :
		case EET_Hypnotized :
		case EET_WitchHypnotized :
		case EET_Stagger :
		case EET_CounterStrikeHit :
		case EET_LongStagger :
		case EET_Pull :
		case EET_Tangled :
		case EET_Ragdoll :
		case EET_PoisonCritical :
		case EET_Frozen :
		case EET_Tornado :
		case EET_Trap :
		case EET_Swarm :
		case EET_Snowstorm :
		case EET_SnowstormQ403 :
		case EET_KnockdownTypeApplicator :
			return true;
		default: 
			return false;
	}
}

function IsNegativeEffectType(type : EEffectType) : bool
{
	if ( IsCriticalEffectType( type ) )
		return true;
		
	switch (type)
	{
		case EET_DoTHPRegenReduce :
		case EET_AirDrain :
		case EET_AirDrainDive :
		case EET_StaminaDrain :
		case EET_StaminaDrainSwimming :
		case EET_VitalityDrain :
		case EET_Drunkenness :
		case EET_OverEncumbered :
		case EET_SilverDust :
		case EET_Slowdown :
		case EET_SlowdownFrost :
		case EET_AxiiGuardMe :
		case EET_YrdenHealthDrain :
			return true;
		default: 
			return false;
	}
}
//returns critical state type for given buff
function GetBuffCriticalType(buff : CBaseGameplayEffect) : ECriticalStateType
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return ECST_None;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.GetCriticalStateType();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.GetCriticalStateType();
	}
	
	return ECST_None;
}

function CriticalBuffIsDestroyedOnInterrupt(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.IsDestroyedOnInterrupt();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.IsDestroyedOnInterrupt();
	}
	
	return false;
}

// Checks if given hit type is allowed by current critical buff
function CriticalBuffIsHitAllowed(buff : CBaseGameplayEffect, hit : EHitReactionType) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return true;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.IsHitAllowed(hit);
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.IsHitAllowed(hit);
	}
	
	return true;
}

function IsCriticalEffect(e : CBaseGameplayEffect) : bool
{
	if(!e)
		return false;
		
	return ((W3CriticalEffect)e) || ((W3CriticalDOTEffect)e) || e.GetEffectType() == EET_KnockdownTypeApplicator;
}

function IsDoTEffect(e : CBaseGameplayEffect) : bool
{
	if(!e)
		return false;
		
	return ((W3DamageOverTimeEffect)e) || ((W3CriticalDOTEffect)e);
}

function CriticalEffectCanPlayAnimation(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.CanPlayAnimation();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.CanPlayAnimation();
	}
	
	return false;
}

function CriticalBuffDisallowPlayAnimation(buff : CBaseGameplayEffect)
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.DisallowPlayAnimation();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.DisallowPlayAnimation();
	}
	
	return;
}

function CriticalBuffUsesFullBodyAnim(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.UsesFullBodyAnim();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.UsesFullBodyAnim();
	}
	
	return false;
}


//handling cases for various tricky situations of critical buffs
enum ECriticalHandling
{
	ECH_HandleNow,			//effect will start the animation anyway (force)
	ECH_Postpone,			//effect will postopne the animation. When it will be possible to play it it will do so if buff will still exist
	ECH_Abort				//effect will be deleted and not applied at all
}

struct SBuffImmunity
{
	saved var buffType : EEffectType;
	saved var sources : array<name>;
};
