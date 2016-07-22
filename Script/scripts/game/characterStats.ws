﻿/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CCharacterStats
/** Copyright © 2010
/***********************************************************************/

/* imported
// actor's stats
enum EBaseCharacterStats
{
	BCS_Vitality,
	BCS_Essence,
	BCS_Stamina,
	BCS_Toxicity,
	BCS_Focus,
	BCS_Morale,
	BCS_Air,
	BCS_Panic,			// default panic val is now 100
	BCS_PanicStatic,	// Used when reducing BCS_Panic. BCS_Panic can't go below BCS_PanicStatic value
	BCS_SwimmingStamina,
	BCS_Undefined
}
*/

function StatNameToEnum(n : name) : EBaseCharacterStats
{
	switch(n)
	{
		case 'vitality' : 			return BCS_Vitality;
		case 'essence' : 			return BCS_Essence;
		case 'stamina' : 			return BCS_Stamina;
		case 'toxicity' : 			return BCS_Toxicity;
		case 'focus' : 				return BCS_Focus;
		case 'morale' : 			return BCS_Morale;
		case 'air' : 				return BCS_Air;
		case 'panic' : 				return BCS_Panic;
		case 'panicStatic' :		return BCS_PanicStatic;
		case 'swimmingStamina' :	return BCS_SwimmingStamina;
		default:					return BCS_Undefined;
	}
}

function StatEnumToName(s : EBaseCharacterStats) : name
{
	switch(s)
	{
		case BCS_Vitality : 		return 'vitality';
		case BCS_Essence : 			return 'essence';
		case BCS_Stamina : 			return 'stamina';
		case BCS_Toxicity : 		return 'toxicity';
		case BCS_Focus : 			return 'focus';
		case BCS_Morale : 			return 'morale';
		case BCS_Air 		: 		return 'air';
		case BCS_Panic	:			return 'panic';
		case BCS_PanicStatic :		return 'panicStatic';
		case BCS_SwimmingStamina :	return 'swimmingStamina';
		default:					return '';
	}
}

// power stats - used as damage bonus for attacks or signs
enum ECharacterPowerStats
{
	CPS_AttackPower,
	CPS_SpellPower,
	CPS_Undefined
}

function PowerStatNameToEnum(n : name) : ECharacterPowerStats
{
	switch(n)
	{
		case 'attack_power'	:		return CPS_AttackPower;
		case 'spell_power' : 		return CPS_SpellPower;
		default:					return CPS_Undefined;
	}
}

function PowerStatEnumToName(s : ECharacterPowerStats) : name
{
	switch(s)
	{
		case CPS_AttackPower :		return 'attack_power';
		case CPS_SpellPower : 		return 'spell_power';
		default:					return '';
	}
}

function RegenStatNameToEnum(n : name) : ECharacterRegenStats
{
	switch(n)
	{
		case 'vitalityCombatRegen' :
		case 'vitalityRegen' :			return CRS_Vitality;
		case 'essenceRegen' :			return CRS_Essence;
		case 'staminaRegen' :			return CRS_Stamina;		
		case 'moraleRegen' :			return CRS_Morale;
		case 'airRegen' : 				return CRS_Air;
		case 'panicRegen' :				return CRS_Panic;
		case 'swimmingStaminaRegen' :	return CRS_SwimmingStamina;
		default:						return CRS_Undefined;
	}
}

function RegenStatEnumToName(s : ECharacterRegenStats) : name
{
	switch(s)
	{
		case CRS_Vitality :			return 'vitalityRegen';
		case CRS_Essence :			return 'essenceRegen';
		case CRS_Stamina :			return 'staminaRegen';		
		case CRS_Morale :			return 'moraleRegen';
		case CRS_Air :  			return 'airRegen';
		case CRS_Panic :			return 'panicRegen';
		case CRS_SwimmingStamina :	return 'swimmingStaminaRegen';
		default:					return '';
	}
}

function GetStatForRegenStat(stat : ECharacterRegenStats) : EBaseCharacterStats
{
	switch(stat)
	{
		case CRS_Vitality :			return BCS_Vitality;
		case CRS_Essence :			return BCS_Essence;
		case CRS_Stamina :			return BCS_Stamina;
		case CRS_Morale :			return BCS_Morale;
		case CRS_Air : 				return BCS_Air;
		case CRS_Panic :			return BCS_Panic;
		case CRS_SwimmingStamina :	return BCS_SwimmingStamina;
		default:					return BCS_Undefined;
	}
}	

function GetRegenStatForStat(stat : EBaseCharacterStats) : ECharacterRegenStats
{
	switch(stat)
	{
		case BCS_Vitality :			return CRS_Vitality;
		case BCS_Essence :			return CRS_Essence;
		case BCS_Stamina :			return CRS_Stamina;
		case BCS_Morale :			return CRS_Morale;
		case BCS_Panic :			return CRS_Panic;
		case BCS_SwimmingStamina :	return CRS_SwimmingStamina;
		default:					return CRS_Undefined;
	}
}	

enum ECharacterRegenStats
{
	CRS_Undefined,
	CRS_Vitality,
	CRS_Essence,
	CRS_Morale,
	CRS_UNUSED,
	CRS_Stamina,
	CRS_Air,
	CRS_Panic,
	CRS_SwimmingStamina,
}

function ResistStatPointNameToEnum( n : name ) : ECharacterDefenseStats
{
	var isPointResistance : bool;
	var stat : ECharacterDefenseStats;
	stat = ResistStatNameToEnum( n, isPointResistance );
	if ( !isPointResistance )
	{
		return CDS_None;
	}
	return stat;
}

function ResistStatPercentNameToEnum( n : name ) : ECharacterDefenseStats
{
	var isPointResistance : bool;
	var stat : ECharacterDefenseStats;
	stat = ResistStatNameToEnum( n, isPointResistance );
	if ( isPointResistance )
	{
		return CDS_None;
	}
	return stat;
}

function ResistStatPointEnumToName( s : ECharacterDefenseStats ) : name
{
	return ResistStatEnumToName( s, true );
}

function ResistStatPercentEnumToName( s : ECharacterDefenseStats ) : name
{
	return ResistStatEnumToName( s, false );
}

function ResistStatNameToEnum(n : name, out isPointResistance : bool) : ECharacterDefenseStats
{	
	isPointResistance = true;
	switch(n)
	{
		case 'physical_resistance' 				: return CDS_PhysicalRes;
		case 'poison_resistance' 				: return CDS_PoisonRes;
		case 'fire_resistance' 					: return CDS_FireRes;
		case 'frost_resistance' 				: return CDS_FrostRes;
		case 'shock_resistance' 				: return CDS_ShockRes;
		case 'force_resistance' 				: return CDS_ForceRes;
		case 'slashing_resistance' 				: return CDS_SlashingRes;
		case 'piercing_resistance'				: return CDS_PiercingRes;
		case 'bludgeoning_resistance'			: return CDS_BludgeoningRes;
		case 'rending_resistance'				: return CDS_RendingRes;
		case 'elemental_resistance'				: return CDS_ElementalRes;
		case 'burning_DoT_damage_resistance'	: return CDS_DoTBurningDamageRes;
		case 'poison_DoT_damage_resistance'		: return CDS_DoTPoisonDamageRes;
		case 'bleeding_DoT_damage_resistance'	: return CDS_DoTBleedingDamageRes;
		default :								;//nothing, just continue
	}
	
	isPointResistance = false;
	switch(n)
	{
		case 'physical_resistance_perc' 			: return CDS_PhysicalRes;
		case 'bleeding_resistance_perc' 			: return CDS_BleedingRes;
		case 'poison_resistance_perc' 				: return CDS_PoisonRes;
		case 'fire_resistance_perc' 				: return CDS_FireRes;
		case 'frost_resistance_perc' 				: return CDS_FrostRes;
		case 'shock_resistance_perc' 				: return CDS_ShockRes;
		case 'force_resistance_perc' 				: return CDS_ForceRes;
		case 'will_resistance_perc' 				: return CDS_WillRes;
		case 'burning_resistance_perc' 				: return CDS_BurningRes;
		case 'slashing_resistance_perc'				: return CDS_SlashingRes;
		case 'piercing_resistance_perc'				: return CDS_PiercingRes;
		case 'bludgeoning_resistance_perc'			: return CDS_BludgeoningRes;
		case 'rending_resistance_perc'				: return CDS_RendingRes;
		case 'elemental_resistance_perc'			: return CDS_ElementalRes;
		case 'burning_DoT_damage_resistance_perc'	: return CDS_DoTBurningDamageRes;
		case 'poison_DoT_damage_resistance_perc'	: return CDS_DoTPoisonDamageRes;
		case 'bleeding_DoT_damage_resistance_perc'	: return CDS_DoTBleedingDamageRes;
		default 									: return CDS_None;
	}
}

//if isPointResistance is set returns point resistance otherwise percent resistance
function ResistStatEnumToName(s : ECharacterDefenseStats, isPointResistance : bool) : name
{
	if(isPointResistance)
	{
		switch(s)
		{
			case CDS_PhysicalRes :				return 'physical_resistance';
			case CDS_PoisonRes :				return 'poison_resistance';
			case CDS_FireRes :					return 'fire_resistance';
			case CDS_FrostRes :					return 'frost_resistance';
			case CDS_ShockRes :					return 'shock_resistance';
			case CDS_ForceRes :					return 'force_resistance';
			case CDS_SlashingRes :	 			return 'slashing_resistance';
			case CDS_PiercingRes :				return 'piercing_resistance';
			case CDS_BludgeoningRes:			return 'bludgeoning_resistance';
			case CDS_RendingRes : 				return 'rending_resistance';
			case CDS_ElementalRes : 			return 'elemental_resistance';
			case CDS_DoTBurningDamageRes : 		return 'burning_DoT_damage_resistance';
			case CDS_DoTPoisonDamageRes :		return 'poison_DoT_damage_resistance';
			case CDS_DoTBleedingDamageRes : 	return 'bleeding_DoT_damage_resistance';
			default :							return '';
		}
	}
	else
	{
		switch(s)
		{
			case CDS_PhysicalRes :				return 'physical_resistance_perc';
			case CDS_BleedingRes : 				return 'bleeding_resistance_perc';
			case CDS_PoisonRes :				return 'poison_resistance_perc';
			case CDS_FireRes :					return 'fire_resistance_perc';
			case CDS_FrostRes :					return 'frost_resistance_perc';
			case CDS_ShockRes :					return 'shock_resistance_perc';
			case CDS_ForceRes :					return 'force_resistance_perc';
			case CDS_WillRes :					return 'will_resistance_perc';
			case CDS_BurningRes : 				return 'burning_resistance_perc';
			case CDS_SlashingRes :	 			return 'slashing_resistance_perc';
			case CDS_PiercingRes :				return 'piercing_resistance_perc';
			case CDS_BludgeoningRes:			return 'bludgeoning_resistance_perc';
			case CDS_RendingRes : 				return 'rending_resistance_perc';
			case CDS_ElementalRes :				return 'elemental_resistance_perc';
			case CDS_DoTBurningDamageRes : 		return 'burning_DoT_damage_resistance_perc';
			case CDS_DoTPoisonDamageRes :		return 'poison_DoT_damage_resistance_perc';
			case CDS_DoTBleedingDamageRes : 	return 'bleeding_DoT_damage_resistance_perc';
			default :							return '';
		}
	}
}

function GetStatValue(statName : name):string
{
	var characterStat	: EBaseCharacterStats;
	var powerStat		: ECharacterPowerStats;
	var regenStat		: ECharacterRegenStats;
	var defenseStat		: ECharacterDefenseStats;
	
	var isPoint			: bool;
	var powerStatValue	: SAbilityAttributeValue;
	var points 			: float;
	var percents 		: float;
	
	characterStat = StatNameToEnum(statName);
	if( characterStat != BCS_Undefined )
	{
		return (string)RoundMath(thePlayer.GetStat(characterStat, true));
	}
	
	powerStat = PowerStatNameToEnum(statName);
	if( powerStat != CPS_Undefined )
	{
		powerStatValue = thePlayer.GetPowerStatValue(powerStat);
		return (string)RoundMath(powerStatValue.valueMultiplicative * 100);
	}
	
	regenStat = RegenStatNameToEnum(statName);
	if( regenStat != CRS_Undefined )
	{
		return (string)NoTrailZeros(RoundTo(CalculateAttributeValue(thePlayer.GetAttributeValue(RegenStatEnumToName(regenStat))),1));
	}	
	
	defenseStat = ResistStatNameToEnum(statName,isPoint);
	if( defenseStat != CDS_None )
	{
		thePlayer.GetResistValue(defenseStat, points, percents);
		
		if(isPoint)
			return NoTrailZeros(RoundMath(points));
		else
			return NoTrailZeros(RoundMath(percents*100));
	}
	
	points = thePlayer.GetStat(characterStat, true);
	if (points != -1)
	{
		return (string)RoundMath(points);
	}
	
	return "";
}

function GetGenericStatValue(statName : name, out valueStr : string):void
{
	var resultValue:string;
	
	// try get stat value
	//resultValue = GetStatValue(statName);
	//if (resultValue)
	//{
	//	valueStr = resultValue;
	//	return;
	//}
	// is generic stat
	switch (statName)
	{
		case 'stat_offense':
			resultValue = (string)thePlayer.GetOffenseStat();
			break;
		case 'stat_defense':
			resultValue = (string)thePlayer.GetDefenseStat();
			break;
		case 'stat_signs':
			resultValue = (string)RoundMath(thePlayer.GetSignsStat() * 100);
			break;
		case 'vitality':
			resultValue = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
			break;
		default:
			valueStr = GetStatValue(statName);
			break;
	}
	valueStr = resultValue;
}

/* imported
// character resistances
enum ECharacterDefenseStats
{
	CDS_None,
	CDS_PhysicalRes,
	CDS_BleedingRes,
	CDS_PoisonRes,
	CDS_FireRes,
	CDS_FrostRes,
	CDS_ShockRes,
	CDS_ForceRes,
	CDS_FreezeRes,	// #B deprecated
	CDS_WillRes,
	CDS_BurningRes,
	CDS_SlashingRes,
	CDS_PiercingRes,
	CDS_BludgeoningRes,
	CDS_RendingRes,
	CDS_ElementalRes,
	CDS_DoTBurningDamageRes,
	CDS_DoTPoisonDamageRes,
	CDS_DoTBleedingDamageRes
}
*/

function IsNonPhysicalResistStat(stat : ECharacterDefenseStats) : bool
{
	switch(stat)
	{
		case CDS_PoisonRes:
		case CDS_FireRes:
		case CDS_FrostRes:
		case CDS_BurningRes:
		case CDS_ElementalRes:
		case CDS_DoTBurningDamageRes:
		case CDS_DoTPoisonDamageRes:
		case CDS_ShockRes:		return true;
		default : 				return false;
	}
}

function IsPhysicalResistStat(stat : ECharacterDefenseStats) : bool
{
	switch(stat)
	{
		case CDS_PhysicalRes:
		case CDS_SlashingRes:
		case CDS_PiercingRes :		
		case CDS_BludgeoningRes:
		case CDS_RendingRes:
		case CDS_DoTBleedingDamageRes:
		case CDS_ForceRes:		return true;
		default : 				return false;
	}
}

struct SPlayerOffenseStats
{
	var steelFastDmg:float;
	var steelFastCritChance:float;
	var steelFastCritDmg:float;
	var steelFastDPS:float;
	
	var steelStrongDmg:float;
	var steelStrongCritChance:float;
	var steelStrongCritDmg:float;
	var steelStrongDPS:float;
	
	var silverFastDmg:float;
	var silverFastCritChance:float;
	var silverFastCritDmg:float;
	var silverFastDPS:float;
	
	var silverStrongDmg:float;
	var silverStrongCritChance:float;
	var silverStrongCritDmg:float;
	var silverStrongDPS:float;
	
	var crossbowCritChance:float;
	var crossbowSteelDmg:float;
	var crossbowSteelDmgType:name;
	var crossbowSilverDmg:float;
}
	
import class CCharacterStats
{	
	import final function GetAttributeValue( attributeName : name, abilityTags : array< name >, optional withoutTags : bool ) : SAbilityAttributeValue;
	
	import final function GetAbilityAttributeValue(attributeName : name, abilityName : name) : SAbilityAttributeValue;
	
	// Give ability - default dont allow multiple 
	import final function AddAbility( abilityName : name, optional allowMultiple : bool ) : bool;
	
	// Take away ability
	import final function RemoveAbility( abilityName : name ) : bool;
	
	// Check ability
	import final function HasAbility( abilityName : name, optional includeInventoryAbl : bool ) : bool;
	import final function HasAbilityWithTag( tag : name, optional includeInventoryAbl : bool ) : bool;
	
	// Returns true if ability can be bought due to other abilities prerequisites
	import final function IsAbilityAvailableToBuy( abilityName : name ) : bool;
	
	import final function GetAbilities( out abilities : array< name >, optional includeInventoryAbl : bool );
	
	import final function GetAllAttributesNames( out attributes : array< name > );
	
	import final function GetAllContainedAbilities( out abilities : array< name > );
	
	public function AddAbilityMultiple(abilityName : name, count : int)
	{
		while(count > 0)
		{
			count -= 1;
			AddAbility(abilityName, true);
		}
	}
	
	public function RemoveAbilityMultiple(abilityName : name, count : int)
	{
		while(count > 0)
		{
			count -= 1;
			RemoveAbility(abilityName);
		}
	}
	
	public function RemoveAbilityAll(abilityName : name)
	{
		while ( HasAbility(abilityName) )
		{
			RemoveAbility(abilityName);
		}
	}
	
	public function GetAbilityCount(abilityName : name) : int
	{
		var i, cnt : int;
		var all : array<name>;
	
		GetAbilities(all, true);
		cnt = 0;
		for(i=0; i<all.Size(); i+=1)
			if(all[i] == abilityName)
				cnt += 1;
				
		return cnt;
	}

	public function GetAbilitiesWithTag(tag : name) : array<name>
	{
		var abs,ret : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		GetAbilities(abs, true);
		for(i=0; i<abs.Size(); i+=1)		
		{
			if(dm.AbilityHasTag(abs[i], tag))
				ret.PushBack(abs[i]);			
		}
		
		return ret;
	}
}