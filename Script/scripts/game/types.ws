/////////////////////////////////////////////
// EActorImmortalityMode
/////////////////////////////////////////////
enum EActorImmortalityMode
{
	AIM_None,
	AIM_Immortal,				//will have always 1 hp left
	AIM_Invulnerable,			//will never lose any hp
	AIM_Unconscious				//hp will drop to 0, but insted of dying will be unconsious and can be revived
}

enum EActorImmortalityChanel
{
	//Bit flags each element must be equal to power of 2. max 8 chanels
	AIC_Default = 1,
	AIC_Combat = 2,
	AIC_Scene = 4,
	AIC_Mutation11 = 8,
	AIC_Fistfight = 16,
	AIC_SyncedAnim = 32,
	AIC_WhiteRaffardsPotion = 64,
	AIC_IsAttackableByPlayer = 128
	// = 256
}

////////////////////////////////////// ///////
// EAnimationEventType 
/////////////////////////////////////////////
/*
enum EAnimationEventType
{
	AET_Tick,
	AET_DurationStart,
	AET_DurationStartInTheMiddle,
	AET_DurationEnd,
	AET_Duration,
};
*/

/////////////////////////////////////////////
// TERRAIN
/////////////////////////////////////////////

enum ETerrainType
{
	TT_Normal,
	TT_Rough,
	TT_Swamp,
	TT_Water
}

/////////////////////////////////////////////
// GAME AREAS
/////////////////////////////////////////////

enum EAreaName
{
	AN_Undefined,
	AN_NMLandNovigrad,
	AN_Skellige_ArdSkellig,
	AN_Kaer_Morhen,
	AN_Prologue_Village,
	AN_Wyzima,
	AN_Island_of_Myst,
	AN_Spiral,
	AN_Prologue_Village_Winter,
	AN_Velen,
	AN_CombatTestLevel,
	// DO NOT ADD ANYTHING HERE, ENUM FOR BOB IS ADDED IN RUNTIME, IF YOU NEED TO REFER TO BOB, USE ENUM BELOW
}

enum EDlcAreaName
{
	//Needs to have a value following on from EAreaName as set out in activation_bob.reddlc (e.g. AN_Bob)
	AN_Dlc_Bob = 11, 
}

function AreaNameToType( lName : string ) : EAreaName
{
	var areaTypeInt : int;
	var areaType : EAreaName;
	switch(lName)
	{
		case "novigrad":
			return AN_NMLandNovigrad;
		case "skellige":
			return AN_Skellige_ArdSkellig;
		case "kaer_morhen":
			return AN_Kaer_Morhen;
		case "prolog_village":
			return AN_Prologue_Village;
		case "wyzima_castle":
			return AN_Wyzima;
		case "island_of_mist":
			return AN_Island_of_Myst;
		case "spiral":
			return AN_Spiral;
		case "no_mans_land":
			return AN_Velen;
		default:
		{
			areaTypeInt = theGame.GetWorldDLCExtender().AreaNameToType( lName );
			areaType = (EAreaName)areaTypeInt;
			return areaType;
		}
	}
}
	
function AreaTypeToName( type : EAreaName ) : string // #B obsolete
{
	switch(type)
	{
		case AN_NMLandNovigrad:
			return "novigrad";
		case AN_Skellige_ArdSkellig:
			return "skellige";
		case AN_Kaer_Morhen:
			return "kaer_morhen";
		case AN_Prologue_Village:
			return "prolog_village";
		case AN_Wyzima:
			return "wyzima_castle";
		case AN_Island_of_Myst:
			return "island_of_mist";
		case AN_Spiral:
			return "spiral";
		case AN_Velen:
			return "no_mans_land";
		default:
			return theGame.GetWorldDLCExtender().AreaTypeToName( (int)type );
	}
}

/////////////////////////////////////////////
// GAME ZONES
/////////////////////////////////////////////

enum EZoneName
{
	ZN_Undefined,
	ZN_NML_CrowPerch,
	ZN_NML_SpitfireBluff,
	ZN_NML_TheMire,
	ZN_NML_Mudplough,
	ZN_NML_Grayrocks,
	ZN_NML_TheDescent,
	ZN_NML_CrookbackBog,
	ZN_NML_BaldMountain,
	ZN_NML_Novigrad,
	ZN_NML_Homestead,
	ZN_NML_Gustfields,
	ZN_NML_Oxenfurt,
	// don't change the order of enums, just add another one here if you need
}

function ZoneNameToType( lName : name ) : EZoneName
{
	switch( lName )
	{
		case 'CrowPerch':
			return 	ZN_NML_CrowPerch;
		case 'SpitfireBluff':
			return 	ZN_NML_SpitfireBluff;
		case 'TheMire':
			return 	ZN_NML_TheMire;
		case 'Mudplough':
			return 	ZN_NML_Mudplough;
		case 'Grayrocks':
			return 	ZN_NML_Grayrocks;
		case 'TheDescent':
			return 	ZN_NML_TheDescent;
		case 'CrookbackBog':
			return 	ZN_NML_CrookbackBog;
		case 'BaldMountain':
			return 	ZN_NML_BaldMountain;
		case 'Novigrad':
			return 	ZN_NML_Novigrad;
		case 'Homestead':
			return 	ZN_NML_Homestead;
		case 'Gustfields':
			return 	ZN_NML_Gustfields;
		case 'Oxenfurt':
			return 	ZN_NML_Oxenfurt;
		default:
			return 	ZN_Undefined;
	}
}
	
function ZoneTypeToName( type : EZoneName ) : name
{
	switch( type )
	{
		case ZN_NML_CrowPerch:
			return 	'CrowPerch';
		case ZN_NML_SpitfireBluff:
			return 	'SpitfireBluff';
		case ZN_NML_TheMire:
			return 	'TheMire';
		case ZN_NML_Mudplough:
			return 	'Mudplough';
		case ZN_NML_Grayrocks:
			return 	'Grayrocks';
		case ZN_NML_TheDescent:
			return 	'TheDescent';
		case ZN_NML_CrookbackBog:
			return 	'CrookbackBog';
		case ZN_NML_BaldMountain:
			return 	'BaldMountain';
		case ZN_NML_Novigrad:
			return 	'Novigrad';
		case ZN_NML_Homestead:
			return 	'Homestead';
		case ZN_NML_Gustfields:
			return 	'Gustfields';
		case ZN_NML_Oxenfurt:
			return 	'Oxenfurt';
		default:
			return 	'';
	}
}

/////////////////////////////////////////////
// DIFFICULTY
////////////////////////////////////////////
/* imported
enum EDifficultyMode
{
	EDM_NotSet,
	EDM_Easy,
	EDM_Medium,
	EDM_Hard,
	EDM_Hardcore
}
*/

//gets lower of the two difficulty modes
function MinDiffMode(a, b : EDifficultyMode) : EDifficultyMode
{
	if(a == EDM_NotSet)
		return b;
	else if(b == EDM_NotSet)
		return a;
	else
		return Min( (int)a, (int)b );
	//so far safe...
	
/*
	if(a == EDM_NotSet || b == EDM_NotSet)				return EDM_NotSet;
	else if(a == EDM_VeryEasy || b == EDM_VeryEasy)		return EDM_VeryEasy;
	else if(a == EDM_Easy || b == EDM_Easy)				return EDM_Easy;
	else if(a == EDM_Medium || b == EDM_Medium)			return EDM_Medium;
	else if(a == EDM_Hard || b == EDM_Hard)				return EDM_Hard;
	
	return EDM_NotSet;*/
}

//gets ability tag for given difficulty mode
function GetDifficultyTagForMode(d : EDifficultyMode) : name
{
	switch(d)
	{
		case EDM_Easy : 		return theGame.params.DIFFICULTY_TAG_EASY;
		case EDM_Medium : 		return theGame.params.DIFFICULTY_TAG_MEDIUM;
		case EDM_Hard : 		return theGame.params.DIFFICULTY_TAG_HARD;
		case EDM_Hardcore : 	return theGame.params.DIFFICULTY_TAG_HARDCORE;
		default : 				return '';
	}
}

/////////////////////////////////////////////
// NATIVES
/////////////////////////////////////////////
/*

enum EVisibilityTest
{
	VT_None,
	VT_LineOfSight,
	VT_RangeAndLineOfSight,
};
*/

/*
enum EAIPriority
{
	AIP_Lowest,
	AIP_Low,
	AIP_Normal,
	AIP_High,
	AIP_Highest,
	AIP_BlockingScene,
	AIP_Cutscene,
	AIP_Combat,
	AIP_Custom,
	AIP_Minigame,
	AIP_Audience,
	AIP_Unconscious,
};
*/

struct SCombatParams
{
	var goalId : int;
//	var dynamicsType : ECombatDynamicsType;
//	var forcedDistanceType : ECombatDistanceType;
//	var fistfightArea : W2FistfightArea;
};

struct SAttackEventData
{
	var animData : CPreAttackEventData;
	var weaponId : SItemUniqueId;				//weapon id of weapon held in *weaponSlot*
	var parriedBy : array<CActor>;				//array of actors who parried the attack
};

enum EHitReactionType
{
	EHRT_None,
	EHRT_Light,
	EHRT_Heavy,
	EHRT_Igni,
	EHRT_Reflect,
	EHRT_LightClose
}

function ModifyHitSeverityReaction(target : CActor, type : EHitReactionType) : EHitReactionType
{
	var severityReduction, severity : int;

	severityReduction = RoundMath(CalculateAttributeValue(target.GetAttributeValue('hit_severity')));
	if(severityReduction == 0 || type == EHRT_Igni)
		return type;
		
	//get severity
	switch(type)
	{
		case EHRT_Heavy :
			severity = 2;
			break;
		case EHRT_Light :
		case EHRT_LightClose :
			severity = 1; 
			break;
		default :
			severity = 0;
			break;
	}
	
	//modify
	severity -= severityReduction;
	
	//return
	switch(severity)
	{
		case 2:		return EHRT_Heavy;
		case 1:		return EHRT_Light;
		default :	return EHRT_None;
	}
}

/*
from C++

enum EFocusModeVisibility
{
	FMV_None,
	FMV_Interactive,
	FMV_Clue
}
*/

enum EFocusHitReaction
{
	EFHR_None,
	EFHR_Type1,
	EFHR_Type2,
	EFHR_Type3,
	EFHR_Type4,
	EFHR_Type5
}

enum EAttackSwingType
{
	AST_Horizontal,
	AST_Vertical,
	AST_DiagonalUp,
	AST_DiagonalDown,
	AST_Jab,
	AST_NotSet
}

enum EAttackSwingDirection
{
	ASD_UpDown,
	ASD_DownUp,
	ASD_LeftRight,
	ASD_RightLeft,
	ASD_NotSet
}

enum EManageGravity
{
	EMG_DisableGravity,
	EMG_EnableGravity,
	EMG_SwitchGravity
}

enum ECounterAttackSwitch
{
	CAS_Disabled,
	CAS_Enabled
}

import struct CPreAttackEventData
{
    import var attackName           : name;                    		   //name of the attack event
    import var weaponSlot           : name;              			   //which weapon to use during the attack to deal damage and buffs
    import var hitReactionType    	: int; //EHitReactionType;         //standard hit reaction for this attack
    import var swingDir            	: int; //EAttackSwingDirection;    //param for parry
    import var swingType            : int; //EAttackSwingType;         //param for parry
	import var rangeName			: name;							   //attack range name
	import var hitFX				: name;			//custom hit FX
	import var hitBackFX			: name;			//custom hit FX when hit at back
	import var hitParriedFX			: name;			//custom hit FX when hit from front and the attack was parried
	import var hitBackParriedFX		: name;			//custom hit FX when hit at back and the attack was parried
	import var Damage_Friendly : bool;				//does attack hits friendly actors
	import var Damage_Neutral : bool;				//does attack hits neutral actors
	import var Damage_Hostile : bool;				//does attack hits hostile actors
	import var Can_Parry_Attack : bool;				//can attack be parried
	import var canBeDodged : bool;					//can attack be dodged
	//import var cameraAnimOnMissedHit : name;		- we're not using it (and we never managed to)
	import var soundAttackType 		: name;			//used for sounds
};

/*
enum EAIAttitude
{
	AIA_Neutral,
	AIA_Friendly,
	AIA_Hostile
};
*/

enum EAttitudeGroupPriority
{
	AGP_Default,
	AGP_SpawnTree,
	AGP_Axii,
	AGP_Fistfight,
	AGP_Scenes
}

function IsBasicAttack(attackName : name) : bool
{
	switch(attackName)
	{
		case theGame.params.ATTACK_NAME_LIGHT: 
		case theGame.params.ATTACK_NAME_HEAVY:
		case theGame.params.ATTACK_NAME_SUPERHEAVY:
		case theGame.params.ATTACK_NAME_SPEED_BASED:
			return true;
		default : 
			return false;
	}
}

enum ETimescaleSource
{
	ETS_None,
	ETS_PotionBlizzard,
	ETS_SlowMoTask,
	ETS_HeavyAttack,
	ETS_ThrowingAim,
	ETS_RadialMenu,
	ETS_CFM_PlayAnim,
	ETS_CFM_On,
	ETS_DebugInput,
	ETS_SkillFrenzy,
	ETS_RaceSlowMo,
	ETS_HorseMelee,
	ETS_FinisherInput,
	ETS_TutorialFight,
	ETS_InstantKill
}

// struct for holding timescale sources' data
struct STimescaleSource
{
	var sourceName : name;
	var sourceType : ETimescaleSource;
	var sourcePriority : int;			//higher priority value is more important
};

//items dropped on ground (weapons)
struct SDroppedItem
{
	var entity : CEntity;
	var itemName : name;
};

/**
	Monster categories for oils and future features
*/
enum EMonsterCategory
{
	MC_NotSet,
	MC_Relic,
	MC_Necrophage,
	MC_Cursed,
	MC_Beast,
	MC_Insectoid,
	MC_Vampire,
	MC_Specter,
	MC_Draconide,
	MC_Hybrid,
	MC_Troll,
	MC_Human,
MC_Unused,
	MC_Magicals,
	MC_Animal
}

// NPC group types
/* moved do c++
enum ENPCGroupType
{
	ENGT_Enemy,
	ENGT_Commoner,
	ENGT_Quest,
	ENGT_Guard
}*/

// returns true if given category is a monster
function MonsterCategoryIsMonster(type : EMonsterCategory) : bool
{
	if( type == MC_NotSet || type == MC_Unused || type == MC_Human || type == MC_Animal || type == MC_Beast )
		return false;
	
	return true;
}

//for oil bonuses
function MonsterCategoryToAttackPowerBonus(type : EMonsterCategory) : name
{
	switch(type)
	{
		case MC_Beast :				return 'vsBeast_attack_power';
		case MC_Cursed :			return 'vsCursed_attack_power';
		case MC_Draconide :			return 'vsDraconide_attack_power';
		case MC_Human :				return 'vsHuman_attack_power';
		case MC_Hybrid :			return 'vsHybrid_attack_power';
		case MC_Insectoid :			return 'vsInsectoid_attack_power';
		case MC_Magicals :			return 'vsMagicals_attack_power';
		case MC_Necrophage :		return 'vsNecrophage_attack_power';
		case MC_Relic :				return 'vsRelic_attack_power';
		case MC_Specter :			return 'vsSpecter_attack_power';
		case MC_Troll :				return 'vsOgre_attack_power';
		case MC_Vampire :			return 'vsVampire_attack_power';
		
		default :				return '';
	}
}
function MonsterAttackPowerBonusToCategory( ap : name ) : EMonsterCategory
{
	switch(ap)
	{
		case 'vsBeast_attack_power': 		return MC_Beast;
		case 'vsCursed_attack_power': 		return MC_Cursed;
		case 'vsDraconide_attack_power': 	return MC_Draconide;
		case 'vsHuman_attack_power': 		return MC_Human;
		case 'vsHybrid_attack_power': 		return MC_Hybrid;
		case 'vsInsectoid_attack_power': 	return MC_Insectoid;
		case 'vsMagicals_attack_power': 	return MC_Magicals;
		case 'vsNecrophage_attack_power': 	return MC_Necrophage;
		case 'vsRelic_attack_power': 		return MC_Relic;
		case 'vsSpecter_attack_power':		return MC_Specter;
		case 'vsOgre_attack_power': 		return MC_Troll;
		case 'vsVampire_attack_power': 		return MC_Vampire;
		
		default :							return MC_NotSet;
	}
}
function MonsterCategoryToCriticalChanceBonus(type : EMonsterCategory) : name
{
	switch(type)
	{
		case MC_Beast :				return 'vsBeast_critical_hit_chance';
		case MC_Cursed :			return 'vsCursed_critical_hit_chance';
		case MC_Draconide :			return 'vsDraconide_critical_hit_chance';
		case MC_Human :				return 'vsHuman_critical_hit_chance';
		case MC_Hybrid :			return 'vsHybrid_critical_hit_chance';
		case MC_Insectoid :			return 'vsInsectoid_critical_hit_chance';
		case MC_Magicals :			return 'vsMagicals_critical_hit_chance';
		case MC_Necrophage :		return 'vsNecrophage_critical_hit_chance';
		case MC_Relic :				return 'vsRelic_critical_hit_chance';
		case MC_Specter :			return 'vsSpecter_critical_hit_chance';
		case MC_Troll :				return 'vsTroll_critical_hit_chance';
		case MC_Vampire :			return 'vsVampire_critical_hit_chance';
		
		default :				return '';
	}
}
function MonsterCategoryToCriticalDamageBonus(type : EMonsterCategory) : name
{
	switch(type)
	{
		case MC_Beast :				return 'vsBeast_critical_hit_damage_bonus';
		case MC_Cursed :			return 'vsCursed_critical_hit_damage_bonus';
		case MC_Draconide :			return 'vsDraconide_critical_hit_damage_bonus';
		case MC_Human :				return 'vsHuman_critical_hit_damage_bonus';
		case MC_Hybrid :			return 'vsHybrid_critical_hit_damage_bonus';
		case MC_Insectoid :			return 'vsInsectoid_critical_hit_damage_bonus';
		case MC_Magicals :			return 'vsMagicals_critical_hit_damage_bonus';
		case MC_Necrophage :		return 'vsNecrophage_critical_hit_damage_bonus';
		case MC_Relic :				return 'vsRelic_critical_hit_damage_bonus';
		case MC_Specter :			return 'vsSpecter_critical_hit_damage_bonus';
		case MC_Troll :				return 'vsTroll_critical_hit_damage_bonus';
		case MC_Vampire :			return 'vsVampire_critical_hit_damage_bonus';
		
		default :				return '';
	}
}
function MonsterCategoryToResistReduction(type : EMonsterCategory) : name
{
	switch(type)
	{
		case MC_Beast :				return 'vsBeast_resist_reduction';
		case MC_Cursed :			return 'vsCursed_resist_reduction';
		case MC_Draconide :			return 'vsDraconide_resist_reduction';
		case MC_Human :				return 'vsHuman_resist_reduction';
		case MC_Hybrid :			return 'vsHybrid_resist_reduction';
		case MC_Insectoid :			return 'vsInsectoid_resist_reduction';
		case MC_Magicals :			return 'vsMagicals_resist_reduction';
		case MC_Necrophage :		return 'vsNecrophage_resist_reduction';
		case MC_Relic :				return 'vsRelic_resist_reduction';
		case MC_Specter :			return 'vsSpecter_resist_reduction';
		case MC_Troll :				return 'vsTroll_resist_reduction';
		case MC_Vampire :			return 'vsVampire_resist_reduction';
		
		default :				return '';
	}
}

//for tooltips
struct SAttributeTooltip
{
	var originName	  : name;
	var attributeName : string;		//localized
	var attributeColor: string;		//hex
	var value : float;
	var percentageValue : bool;
	var primaryStat : bool; 
	default percentageValue = false;
};

//workaround for not working function 'out' parameters - the function returns a struct with it's return value and the out value
struct SNotWorkingOutFunctionParametersHackStruct1
{
	var outValue : int;				//value saved in the out parameter
	var retValue : bool;			//value returned by the function
};

// combat action buffer action types
enum EButtonStage
{
	BS_Released,
	BS_Pressed,
	BS_Hold,
}

import struct SAbilityAttributeValue
{
	import saved var valueAdditive : float;
	import saved var valueMultiplicative : float;
	import saved var valueBase : float;
}

//THE ONLY function to calculate attribute value
function CalculateAttributeValue(att : SAbilityAttributeValue, optional disallowNegativeMult : bool) : float
{
	//FINAL HACK
	if(disallowNegativeMult && att.valueMultiplicative < 0)
		att.valueMultiplicative = 0.001;
		
	return att.valueBase * att.valueMultiplicative + att.valueAdditive;
}

//randomizes attribute values (base, add, mult) between min and max
function GetAttributeRandomizedValue(min, max : SAbilityAttributeValue) : SAbilityAttributeValue
{
	var ret : SAbilityAttributeValue;
	
	ret.valueBase = RandRangeF(max.valueBase, min.valueBase);
	ret.valueAdditive = RandRangeF(max.valueAdditive, min.valueAdditive);
	ret.valueMultiplicative = RandRangeF(max.valueMultiplicative, min.valueMultiplicative);
	
	return ret;
}

//stamina action types - to get stamina cost / delay data
enum EStaminaActionType
{
	ESAT_Undefined,
	ESAT_LightAttack,
	ESAT_HeavyAttack,
	ESAT_SuperHeavyAttack,
	ESAT_Parry,
	ESAT_Counterattack,
	ESAT_Dodge,
	ESAT_Evade,
	ESAT_Swimming,
	ESAT_Sprint,
	ESAT_Jump,
	ESAT_UsableItem,
	ESAT_Ability,
	ESAT_FixedValue,
	ESAT_Roll,
	ESAT_LightSpecial,
	ESAT_HeavySpecial,
}

function StaminaActionTypeToName(action : EStaminaActionType) : name
{
	if(action == ESAT_LightAttack)				return 'LightAttack';
	else if(action == ESAT_HeavyAttack)			return 'HeavyAttack';
	else if(action == ESAT_SuperHeavyAttack)	return 'SuperHeavyAttack';
	else if(action == ESAT_Parry)				return 'Parry';
	else if(action == ESAT_Counterattack)		return 'Counterattack';
	else if(action == ESAT_Dodge)				return 'Dodge';
	else if(action == ESAT_Evade)				return 'Evade';
	else if(action == ESAT_Swimming)			return 'Swimming';
	else if(action == ESAT_Sprint)				return 'Sprint';
	else if(action == ESAT_Jump)				return 'Jump';
	else if(action == ESAT_UsableItem)			return 'UsableItem';
	else if(action == ESAT_Ability)				return 'Ability';
	else if(action == ESAT_FixedValue)			return 'FixedValue';
	else if(action == ESAT_Roll)				return 'Roll';
	else 										return '';
}

enum EFocusModeSoundEffectType
{
	FMSET_Gray, // default
	FMSET_Red,
	FMSET_Green,
	FMSET_None,
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////  @STATISTICS, @PERKS, @ACHIEVEMENTS, @STATS  ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct SStatistic
{
	var statType : EStatistic;
	var registeredAchievements : array<SAchievement>;
};

enum EStatistic
{
	ES_Undefined,

	ES_BleedingBurnedPoisoned,				//when enemy is bleeding, burned and poison at the same time
	ES_FinesseKills,						//finesse kills
	ES_CharmedNPCKills,						//number of kills done by axii hypnotized enemies
	ES_AardFallKills,						//kills done by falling damage after being hit by aard
	ES_EnvironmentKills,					//kills by environment
	ES_CounterattackChain,					//amount of chained counterstrikes done, not interrupted by parrying or being hit in melee
	ES_DragonsDreamTriggers,				//increased each time a Dragons Dream ignites from an enemy who has Burning Effect on it
	ES_FundamentalsFirstKills,				//kills for fundamentals first achievement
	ES_DestroyedNests,						//# of destroyed monster nests
	ES_KnownPotionRecipes,					//list of known potion & mutagen recipes
	ES_KnownBombRecipes,					//list of known bomb recipes
	ES_ReadBooks,							//number of unique read books (non-quest, non-perk, non-schematic)
	ES_HeadShotKills,						//num of enemies killed by headshot
	ES_SelfArrowKills,						//# of enemies killed with their own arrows
	ES_ActivePotions,						//# of currently active potions
	ES_KilledCows,							//# of killed cows
	ES_SlideTime							//duration of slide
}

function StatisticEnumToName(s : EStatistic) : name
{
	switch(s)
	{
		case ES_CharmedNPCKills:				return 'statistic_charmed_kills';
		case ES_AardFallKills:					return 'statistic_aardfall_kills';
		case ES_EnvironmentKills:				return 'statistic_environment_kills';
		case ES_BleedingBurnedPoisoned:			return 'statistic_bleed_burn_poison';
		case ES_CounterattackChain:				return 'statistic_counterattack_chain';
		case ES_DragonsDreamTriggers:			return 'statistic_burning_gas_triggers';
		case ES_KnownPotionRecipes:				return 'statistic_known_potions';
		case ES_KnownBombRecipes:				return 'statistic_known_bombs';
		case ES_ReadBooks:						return 'statistic_read_books';
		case ES_HeadShotKills:					return 'statistic_head_shot_kills';
		case ES_DestroyedNests:					return 'statistic_destroyed_nests';
		case ES_FundamentalsFirstKills:			return 'statistic_fundamentals_kills';
		case ES_FinesseKills:					return 'statistic_finesse_kills';
		case ES_SelfArrowKills:					return 'statistic_self_arrow_kills';
		case ES_ActivePotions:					return 'statistic_active_potions';
		case ES_KilledCows:						return 'statistic_killed_cows';
		case ES_SlideTime:						return 'statistic_slide_time';
		
		default:								return '';
	}
}

function StatisticNameToEnum(f : name) : EStatistic
{
	switch(f)
	{
		case 'statistic_charmed_kills':				return ES_CharmedNPCKills;
		case 'statistic_aardfall_kills':			return ES_AardFallKills;
		case 'statistic_environment_kills':			return ES_EnvironmentKills;
		case 'statistic_bleed_burn_poison':			return ES_BleedingBurnedPoisoned;
		case 'statistic_counterattack_chain':		return ES_CounterattackChain;
		case 'statistic_burning_gas_triggers':		return ES_DragonsDreamTriggers;
		case 'statistic_known_potions':				return ES_KnownPotionRecipes;
		case 'statistic_known_bombs':				return ES_KnownBombRecipes;
		case 'statistic_head_shot_kills':			return ES_HeadShotKills;
		case 'statistic_read_books':				return ES_ReadBooks;
		case 'statistic_destroyed_nests' :			return ES_DestroyedNests;
		case 'statistic_fundamentals_kills' : 		return ES_FundamentalsFirstKills;
		case 'statistic_finesse_kills' :			return ES_FinesseKills;
		case 'statistic_self_arrow_kills' : 		return ES_SelfArrowKills;
		case 'statistic_active_potions' :			return ES_ActivePotions;
		case 'statistic_killed_cows' :				return ES_KilledCows;
		case 'statistic_slide_time' : 				return ES_SlideTime;
		
		default:									return ES_Undefined;
	}
}


function GetBookReadFactName( bookName : name ) : string
{
	var bookFactName : string;
	bookFactName = "BookReadState_" + bookName;
	bookFactName = StrReplace( bookFactName, " ", "_" );
	return bookFactName;
}

struct SCachedCombatMessage
{
	var finalIncomingDamage : float;
	var resistPoints : float;
	var resistPercents : float;
	var finalDamage : float;
	var attacker : CGameplayEntity;
	var victim : CGameplayEntity;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct SAchievement
{
	var type : EAchievement;
	var requiredValue : float;						//value required to get the achievement
};

enum EAchievement
{
	EA_Undefined,
	
	//quest
	EA_FoundYennefer,
	EA_FreedDandelion,
	EA_YenGetInfoAboutCiri,
	EA_FindBaronsFamily,
	EA_FindCiri,
	EA_ConvinceGeelsToBetrayEredin,
	EA_DefeatEredin,
	EA_FinishTheGameEasy,
	EA_FinishTheGameNormal,
	EA_FinishTheGameHard,
	EA_CompleteWitcherContracts,
	EA_CompleteSkelligeRaceForCrown,
	EA_CompleteWar,
	EA_CompleteKeiraMetz,
	EA_GetAllForKaerMorhenBattle,
	
	//gameplay
	EA_Dendrology,									//fully develop one skill tree
	EA_EnemyOfMyFriend,								//kills made by axii hypnotized oponents
	EA_FusSthSth,									//aard fall damage kills
	EA_EnvironmentUnfriendly,						//kills by environment
	EA_TrainedInKaerMorhen,							//chained counterattacks not interrupted by being hit in melee or parrying
	EA_TheEvilestThing,								//make X burning enemies trigger exploding gas
	EA_TechnoProgress,								//kill X enemies with single headshot
	EA_LearningTheRopes,							//use counter, attack, bomb and sign within 4 secs
	EA_FundamentalsFirst,							//kill 2 monster hunt monsters without using signs, potions, mutagen potions, oils or bombs
	EA_TrialOfGrasses,								//fill all potion mutagen slots, skill mutagen slots and have at least 1 skillgroup synergy
	EA_BreakingBad,									//learn all potion / mutagen recipes
	EA_Bombardier,									//learn all bomb recipes
	EA_Swank,										//kill 5+ enemies under 10 seconds
	EA_Rage,										//have a total of X enemies burning, bleeding and poisoned
	
	//quest
	EA_GwintMaster,									//defeat all quest relevant gwint opponents
EA_Unused,
	EA_MonsterHuntFogling,							//finish monster hunt: fogling
	EA_MonsterHuntEkimma,							//finish monster hunt: ekimma
	EA_MonsterHuntLamia,							//finish monster hunt: lamia
	EA_MonsterHuntFiend,							//finish monster hunt: fiend
	EA_MonsterHuntDao,								//finish monster hunt: dao
	EA_MonsterHuntDoppler,							//finish monster hunt: doppler
	EA_BrawlMaster,									//win all fist fighting tournaments
	EA_NeedForSpeed,								//win all races (boat & horse)
	EA_Brawler,										//defeat specific boss barehanded
	
	//gameplay
	EA_Finesse,										//kill 5+ opponnents in one combat without losing health and without using quen
	EA_PowerOverwhelming,							//have buffs from all minor places of power
	EA_Cerberus,									//kill enemies by at least 3 different means during one combat encounter
	EA_Bookworm,									//read X unique books (non-quest, non-perk, non-recipe)
	EA_Immortal,									//get max level
	EA_FistOfTheSouthStar,							//defeat opponent in fist fight without taking any damage
	EA_Explorer,									//find all fast travel points in the entire game
	EA_PestControl,									//destroy all monster nests in any region (awarded if each nest was destroyed at least once since some nests can respawn)
	EA_FireInTheHole,								//destroy X monster nests
	EA_FullyArmed,									//collect all witcher sets
	EA_GwintCollector,								//collect all gwint cards
	EA_Allin,										//Win a round with only neutral cards
	EA_GeraltandFriends,							//Win a match after using three heroes in one round
	
	//--EP1	
	//quest
	EA_ToadPrince,									//kill toad
	EA_PartyAnimal,									//take part in all wedding activities
	EA_Auctioneer,									//buy all items on auction
	EA_TheCompletePicture,							//find all scenes in painted world
	EA_HeartsOfStone,								//finish EP1 main quest
	EA_KillEtherals,								//wake all Etheral and kill them
	
	//gameplay
	EA_FeatherStrongerThanSword,					//kill 3 enemies with their own arrows
	EA_Thirst,										//have 7+ potions active at the same time
	EA_DivineWhip,									//clear all rose knight camps
	EA_LatestFashion,								//collect ofir armor set
	EA_WantedDeadOrBovine,							//kill 20+ cows
	EA_Slide,										//slide for 10+ secs continuously
	EA_KilledIt,									//win gwent round having 187+ points
	
	//--EP2
	EA_BeauclairWelcomeTo,							//reach new hub
	EA_HeroOfBeauclair,								//epilogue after Henrietta is saved
	EA_BeauclairMostWanted,							//epilogue after Henrietta is killed
	EA_ChampionOfBeauclair,							//win the tournament
	EA_LikeAVirgin,									//mq7006 completed
	EA_HomeSweetHome,								//Fully upgrade your vineyard
	EA_TurnedEveryStone,							//complete all treasure hunts in tuissaint
	EA_GotToHaveThemAll,							//collect whole Skellige gwent deck
	EA_BloodAndWine,								//level up one of wineyards to max level
	EA_ReadyToRoll,									//unlock set bonus for whole set (6 parts)
	EA_SchoolOfTheMutant,							//develop any mutation
	EA_HastaLaVista,								//kill frozen enemy with crossbow
	EA_Goliath										//kill Goliath (giant) with a crossbow eyeshot
}

//needed only for those that define required stat value in custom XML
function AchievementNameToEnum(n : name) : EAchievement
{
	switch(n)
	{
		//quest
		case 'FoundYennefer' :						return EA_FoundYennefer;
		case 'FreedDandelion' :						return EA_FreedDandelion;
		case 'YenGetInfoAboutCiri' :				return EA_YenGetInfoAboutCiri;
		case 'FindBaronsFamily' :					return EA_FindBaronsFamily;
		case 'FindCiri' :							return EA_FindCiri;
		case 'ConvinceGeelsToBetrayEredin' :		return EA_ConvinceGeelsToBetrayEredin;
		case 'DefeatEredin' :						return EA_DefeatEredin;
		case 'FinishTheGameEasy' :					return EA_FinishTheGameEasy;
		case 'FinishTheGameMedium' :				return EA_FinishTheGameNormal;
		case 'FinishTheGameHard' :					return EA_FinishTheGameHard;
		case 'CompleteWitcherContracts' :			return EA_CompleteWitcherContracts;
		case 'CompleteSkelligeRaceForCrown' :		return EA_CompleteSkelligeRaceForCrown;
		case 'CompleteWar' :						return EA_CompleteWar;
		case 'CompleteKeiraMetz' :					return EA_CompleteKeiraMetz;
		case 'GetAllForKaerMorhenBattle' :			return EA_GetAllForKaerMorhenBattle;
		case 'GwintOpponentsDefeated' :				return EA_GwintMaster;
		case 'MonsterHuntFogling' :					return EA_MonsterHuntFogling;
		case 'MonsterHuntEkimma' :					return EA_MonsterHuntEkimma;
		case 'MonsterHuntLamia' :					return EA_MonsterHuntLamia;
		case 'MonsterHuntFiend' :					return EA_MonsterHuntFiend;
		case 'MonsterHuntDao' :						return EA_MonsterHuntDao;
		case 'MonsterHuntDoppler' : 				return EA_MonsterHuntDoppler;
		case 'KillBossFists' :						return EA_Brawler;
		case 'WinFistFights' :						return EA_BrawlMaster;
		case 'WinRaces' :							return EA_NeedForSpeed;
		
		//gameplay
		case 'Bookworm' :							return EA_Bookworm;
		case 'Cerberus' :							return EA_Cerberus;
		case 'TrailOfGrasses' :						return EA_TrialOfGrasses;
		case 'Dendrology' :							return EA_Dendrology;
		case 'EnemyOfMyFriend' :					return EA_EnemyOfMyFriend;
		case 'FusSomethingSomething' :				return EA_FusSthSth;
		case 'EnvironmentUnfriendly' :				return EA_EnvironmentUnfriendly;
		case 'FistOfTheSouthStar' :					return EA_FistOfTheSouthStar;
		case 'FullyArmed' :							return EA_FullyArmed;
		case 'Immortal' :							return EA_Immortal;
		case 'PestControl' :						return EA_PestControl;
		case 'TechnologicalProgress' :				return EA_TechnoProgress;
		case 'TrainedInKaerMorhen' :				return EA_TrainedInKaerMorhen;
		case 'TheEvilestThing' :					return EA_TheEvilestThing;
		case 'LearningTheRopes' :					return EA_LearningTheRopes;
		case 'PowerOverwhelming' : 					return EA_PowerOverwhelming;
		case 'Rage' :								return EA_Rage;
		case 'BreakingBad' :						return EA_BreakingBad;
		case 'Bombardier' : 						return EA_Bombardier;
		case 'Finesse' : 							return EA_Finesse;
		case 'Explorer' :							return EA_Explorer;
		case 'FireInTheHole' :						return EA_FireInTheHole;
		case 'FundamentalsFirst' :					return EA_FundamentalsFirst;
		case 'Allin' :								return EA_Allin;
		case 'GeraltandFriends' : 					return EA_GeraltandFriends;
		
		case 'FeatherStrongerThanSword' :			return EA_FeatherStrongerThanSword;
		case 'Thirst' :								return EA_Thirst;
		case 'WantedDeadOrBovine' :					return EA_WantedDeadOrBovine;
		case 'Slide' : 								return EA_Slide;
		case 'KilledIt' : 							return EA_KilledIt;
		case 'ToadPrince' :							return EA_ToadPrince;
		case 'PartyAnimal' : 						return EA_PartyAnimal;
		case 'Auctioneer' : 						return EA_Auctioneer;
		case 'TheCompletePicture' :					return EA_TheCompletePicture;
		case 'HeartsOfStone' :						return EA_HeartsOfStone;
		case 'KillEthreals' : 						return EA_KillEtherals;
		case 'DivineWhip' : 						return EA_DivineWhip;
		case 'LatestFashion' : 						return EA_LatestFashion;
		
		default :									return EA_Undefined;
	}
}

function AchievementEnumToName(a : EAchievement) : name
{
	switch(a)
	{
		case EA_FoundYennefer : return 'EA_FoundYennefer'; break;
		case EA_FreedDandelion : return 'EA_FreedDandelion'; break;
		case EA_YenGetInfoAboutCiri : return 'EA_YenGetInfoAboutCiri'; break;
		case EA_FindBaronsFamily : return 'EA_FindBaronsFamily'; break;
		case EA_FindCiri : return 'EA_FindCiri'; break;
		case EA_ConvinceGeelsToBetrayEredin : return 'EA_ConvinceGeelsToBetrayEredin'; break;
		case EA_DefeatEredin : return 'EA_DefeatEredin'; break;
		case EA_FinishTheGameEasy : return 'EA_FinishTheGameEasy'; break;
		case EA_FinishTheGameNormal : return 'EA_FinishTheGameNormal'; break;
		case EA_FinishTheGameHard : return 'EA_FinishTheGameHard'; break;
		case EA_CompleteWitcherContracts : return 'EA_CompleteWitcherContracts'; break;
		case EA_CompleteSkelligeRaceForCrown : return 'EA_CompleteSkelligeRaceForCrown'; break;
		case EA_CompleteWar : return 'EA_CompleteWar'; break;
		case EA_CompleteKeiraMetz : return 'EA_CompleteKeiraMetz'; break;
		case EA_GetAllForKaerMorhenBattle : return 'EA_GetAllForKaerMorhenBattle'; break;
		case EA_Dendrology : return 'EA_Dendrology'; break;
		case EA_EnemyOfMyFriend : return 'EA_EnemyOfMyFriend'; break;
		case EA_FusSthSth : return 'EA_FusSthSth'; break;
		case EA_EnvironmentUnfriendly : return 'EA_EnvironmentUnfriendly'; break;
		case EA_TrainedInKaerMorhen : return 'EA_TrainedInKaerMorhen'; break;
		case EA_TheEvilestThing : return 'EA_TheEvilestThing'; break;
		case EA_TechnoProgress : return 'EA_TechnoProgress'; break;
		case EA_LearningTheRopes : return 'EA_LearningTheRopes'; break;
		case EA_FundamentalsFirst : return 'EA_FundamentalsFirst'; break;
		case EA_TrialOfGrasses : return 'EA_TrialOfGrasses'; break;
		case EA_BreakingBad : return 'EA_BreakingBad'; break;
		case EA_Bombardier : return 'EA_Bombardier'; break;
		case EA_Swank : return 'EA_Swank'; break;
		case EA_Rage : return 'EA_Rage'; break;
		case EA_GwintMaster : return 'EA_GwintMaster'; break;
		case EA_MonsterHuntFogling : return 'EA_MonsterHuntFogling'; break;
		case EA_MonsterHuntEkimma : return 'EA_MonsterHuntEkimma'; break;
		case EA_MonsterHuntLamia : return 'EA_MonsterHuntLamia'; break;
		case EA_MonsterHuntFiend : return 'EA_MonsterHuntFiend'; break;
		case EA_MonsterHuntDao : return 'EA_MonsterHuntDao'; break;
		case EA_MonsterHuntDoppler : return 'EA_MonsterHuntDoppler'; break;
		case EA_Allin : return 'EA_Allin'; break;
		case EA_GeraltandFriends : return 'EA_GeraltandFriends'; break;
		case EA_BrawlMaster : return 'EA_BrawlMaster'; break;
		case EA_NeedForSpeed : return 'EA_NeedForSpeed'; break;
		case EA_Brawler : return 'EA_Brawler'; break;
		case EA_Finesse : return 'EA_Finesse'; break;
		case EA_PowerOverwhelming : return 'EA_PowerOverwhelming'; break;
		case EA_Cerberus : return 'EA_Cerberus'; break;
		case EA_Bookworm : return 'EA_Bookworm'; break;
		case EA_Immortal : return 'EA_Immortal'; break;
		case EA_FistOfTheSouthStar : return 'EA_FistOfTheSouthStar'; break;
		case EA_Explorer : return 'EA_Explorer'; break;
		case EA_PestControl : return 'EA_PestControl'; break;
		case EA_FireInTheHole : return 'EA_FireInTheHole'; break;
		case EA_FullyArmed : return 'EA_FullyArmed'; break;
		case EA_GwintCollector : return 'EA_GwintCollector'; break;
				
		//EP1
		case EA_Thirst : return 'EA_Thirst'; break;
		case EA_WantedDeadOrBovine : return 'EA_WantedDeadOrBovine'; break;
		case EA_Slide : return 'EA_Slide'; break;
		case EA_KilledIt : return 'EA_KilledIt'; break;
		case EA_FeatherStrongerThanSword : return 'EA_FeatherStrongerThanSword'; break;
		case EA_ToadPrince : return 'EA_ToadPrince'; break;
		case EA_PartyAnimal : return 'EA_PartyAnimal'; break;
		case EA_Auctioneer : return 'EA_Auctioneer'; break;
		case EA_TheCompletePicture : return 'EA_TheCompletePicture'; break;
		case EA_HeartsOfStone : return 'EA_HeartsOfStone'; break;
		case EA_KillEtherals : return 'EA_KillEtherals'; break;
		case EA_DivineWhip : return 'EA_DivineWhip'; break;
		case EA_LatestFashion : return 'EA_LatestFashion'; break;
		
		//EP2
		case EA_BeauclairWelcomeTo : return 'EA_BeauclairWelcomeTo'; break;
		case EA_HeroOfBeauclair : return 'EA_HeroOfBeauclair'; break;
		case EA_BeauclairMostWanted : return 'EA_BeauclairMostWanted'; break;
		case EA_ChampionOfBeauclair : return 'EA_ChampionOfBeauclair'; break;
		case EA_LikeAVirgin : return 'EA_LikeAVirgin'; break;
		case EA_HomeSweetHome : return 'EA_HomeSweetHome'; break;
		case EA_TurnedEveryStone : return 'EA_TurnedEveryStone'; break;
		case EA_GotToHaveThemAll : return 'EA_GotToHaveThemAll'; break;
		case EA_BloodAndWine : return 'EA_BloodAndWine'; break;
		case EA_ReadyToRoll : return 'EA_ReadyToRoll'; break;
		case EA_SchoolOfTheMutant : return 'EA_SchoolOfTheMutant'; break;
		case EA_HastaLaVista : return 'EA_HastaLaVista'; break;
		//case EA_StyleOfTheDrunkenMaster : return 'EA_StyleOfTheDrunkenMaster'; break;
		case EA_Goliath : return 'EA_Goliath'; break;

		case EA_Undefined :
		case EA_Unused :
		default:
			return '';
	}
	
	return '';
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  TUTORIAL  ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct STutorialMessage
{
	editable saved var type : ETutorialMessageType;			//type of message	

	editable saved var tutorialScriptTag : name;			//tutorial script name
	editable saved var journalEntryName : name;				//name of entry to unlock in journal, if empty does not unlock anything
	editable saved var canBeShownInMenus : bool;
	editable saved var canBeShownInDialogs : bool;	
	editable saved var glossaryLink : bool;					//if glossary link should be shown at the bottom of hint
	editable saved var enableAcceptButton : bool;			//show accept button, tutorial can be closed by user
	editable saved var force : bool;						//if set then message will be shown even it was already seen
	editable saved var disableHorizontalResize : bool;		//if set automatic horizontal resize is disabled
	editable saved var forceToQueueFront : bool;
	
	editable saved var hintPositionType : ETutorialHintPositionType;		//how to handle position
	editable saved var hintPosX : float;					//hint position X (only for hints)  (0,0) is left bottom
	editable saved var hintPosY : float;					//hint position Y (only for hints)
	editable saved var hintDuration : float;				//hint duration (only for hints)
	editable saved var hintCloseOnFactExist : string;		//fact to close hint (only for hints)	
	
	editable saved var highlightAreas : array<STutorialHighlight>;		//highlight areas
	editable saved var disabledPanelsExceptions : array<name>;			//list of panels NOT disabled (if empty NO panels are disabled)
	
	//button press prompt after tutorial message
	editable saved var hintPromptScriptTag : name;			//script name
	editable saved var hintPromptPosX : float;				//pos X
	editable saved var hintPromptPosY : float;				//pos Y
	editable saved var hintPromptDuration : float;			//duration
	editable saved var hintPromptCloseFact : string;		//close fact		
	
	editable saved var markAsSeenOnShow : bool;				//mark as seen when showed
	
	editable saved var isHUDTutorial : bool;				// #B apply hud scaling to tutorial hints
	editable saved var hintDurationType : ETutorialHintDurationType;	//for presets
	
	editable saved var blockInput : bool;
	editable saved var pauseGame : bool;
	editable saved var fullscreen : bool;
	
	//min duration handling
	editable saved var minDuration : float;					//min hint duration, used only if hint has a duration. Hint won't close until this time has elapsed
	saved var remainingMinDuration : float;					//remaining time to display on screen
	saved var hideOnMinDurationEnd : bool;					//if min duration has not passed and tutorial was requested to close - it will close when duration finishes
	editable saved var factOnFinishedDisplay : string;		//fact to add once hint was processed properly (e.g. not interrupted)
};

enum ETutorialHintDurationType
{
	ETHDT_NotSet,
	ETHDT_Short,
	ETHDT_Long,
	ETHDT_Infinite,
	ETHDT_Custom,
	ETHDT_Input
}

enum ETutorialHintPositionType
{
	ETHPT_DefaultGlobal,
	ETHPT_DefaultDialog,
	ETHPT_DefaultCombat,
	ETHPT_Custom,
	ETHPT_DefaultUI,
	ETHPT_DefaultRadialMenu
}

struct STutorialHighlight
{
	editable saved var x, y, width, height : float;			//area bounds as % of screen size
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  SHADER  //////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
import class CGameplayFXSurfacePost extends IGameSystem
{
	//type: 0 - frost, 1 - burn
	//ranges lower than 4-5m can be barely visible
	import final function AddSurfacePostFXGroup( position : Vector, fadeInTime : float, activeTime : float, fadeOutTime : float, range : float, type : int );
	import final function IsActive() : bool;
}

struct SFXSurfacePostParams
{
	editable var fxFadeInTime 		: float;
	editable var fxLastingTime		: float;	
	editable var fxFadeOutTime 		: float;
	editable var fxRadius 			: float;
	editable var fxType 			: int;
			
		hint fxType = "-1 - not used, 0 - frost, 1 - burn";
		
		default fxType = -1;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  RELATIVE SPEED  //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum ESpeedType
{
	EST_Undefined,
	EST_Stopped,
	EST_SlowWalk,		//monsters don't have
	EST_Walk,
	EST_Run,			//Trot for horse
	EST_FastRun,		//monsters don't have, gallop for horse
	EST_Sprint			//monsters don't have, canter for horse
}


/*
enum EAsyncCheckResult
{
	ASR_InProgress,
	ASR_ReadyTrue,
	ASR_ReadyFalse,
	ASR_Failed
};
*/

struct SSwarmVictim
{
	var actor : CActor;
	var timeInSwarm : float;
	var inTrigger : bool;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
enum EBloodType
{
	BT_Undefined,
	BT_Red,
	BT_Yellow,
	BT_Black,
	BT_Green
}