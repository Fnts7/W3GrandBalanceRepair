/***********************************************************************/
/** Types for ability manager classes
/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

// Base stat e.g. vitality, stamina, etc.
import struct SBaseStat
{
	import saved var current	: float;			//current and max level
	import saved var max		: float;			//current and max level
	import saved var type 		: EBaseCharacterStats;
};

//An ability that was disabled (but not removed!) for a specified amount of time - it can be later reenabled.
struct SBlockedAbility
{
	editable saved var abilityName : name;
	editable saved var timeWhenEnabledd : float;		//lock remaining time or -1 if disabled until manually enabled again
	saved var count : int;							//how many instances of ability does actor have (for multiple abilities)
};

//skills have colors in the UI
enum ESkillColor
{
	SC_None,
	SC_Blue,
	SC_Green,
	SC_Red,
	SC_Yellow		//perk - has no color actually
}

function SkillColorStringToType( str : string ) : ESkillColor
{
	switch( StrLower( str ) )
	{
		case "blue" : 		return SC_Blue;
		case "green" : 		return SC_Green;
		case "red" :		return SC_Red;
		case "yellow" :     return SC_Yellow;
		default :			return SC_None;
	}
}

struct SMutagenSlot
{
	saved var item : SItemUniqueId;				//mutagen item
	saved var unlockedAtLevel : int;			//level on which this slot is unlocked
	saved var skillGroupID : int;				//id of skill group to which this mutagen is linked
	saved var equipmentSlot : EEquipmentSlots;	//equipment slot in which the mutagen is equipped
};

struct SSkillSlot
{
	saved var id : int;							//ids start from 1 not 0 because 0 is reserved for XML read data error (no data)
	saved var unlockedOnLevel : int;
	saved var socketedSkill : ESkill;			//skill inserted into this slot
	saved var unlocked : bool;					//true if skill slot is unlocked and thus can be used
	saved var groupID : int;					//ID of the skill group to which this slot is assigned
}

//player (only!) skills
struct SSkill
{
	////////////////////////////////////
	////////  ACHTUNG !!!  /////////////
	////////////////////////////////////
	//the restore is using custom code - support your saved vars in W3PlayerAbilityManager.RestoreSkills() and SRestoredSkill struct below

	saved var skillType : ESkill;									//skill (context sensitive - for skills ESkill, for perks EPerk and for books EBookPerk)
		  var skillPath : ESkillPath;								//skill path of this skill (~ skill tree) e.g.: Sword Skill
		  var skillSubPath : ESkillSubPath;							//skill subpath of this skill, e.g.: Strong Sword Skill, Aard Skill
	saved var level : int;											//current skill level
		  var maxLevel : int;										//max skill level attainable
		  
		  default level = -1;
		  default maxLevel = -1;
	
	  	  var requiredSkills : array<ESkill>;						//list of skills required to learn this skill
		  var requiredSkillsIsAlternative : bool;					//if true you need one of those skills, otherwise all of them
		  var requiredPointsSpent : int;							//required amount of skillpoints spent in this skill's skill path 
		  var priority : int;										//skill priority used when added with autoleveling
		  var cost : int;											//cost of purchasing this skill/perk
	saved var isTemporary : bool;									//if it's not permanently learned but gained temporarily due to some bonuses	  
		  
		  var abilityName : name;									//ability given by the skill
		  var modifierTags : array<name>;							//list of tags names of abilities whose attributes sum up with this skill (e.g. stamina lower cost 
																	//for aard signs)
		  
		  var localisationNameKey : string;							//localisation key for skill name
		  var localisationDescriptionKey : string;					//localisation key for level 1 skill description
		  var localisationDescriptionLevel2Key : string;			//localisation key for level 2 skill description
		  var localisationDescriptionLevel3Key : string;			//localisation key for level 3 skill description
	
		  var iconPath : string;									//path to file containing skill icon	
		  var positionID : int;										//GUI position ID
	saved var isNew : bool;											//true if new
		  var isCoreSkill : bool;									//core skills are always active - cannot be socketed into skill slots
		  var wasEquippedOnUIEnter : bool;							//set on opening character panel to later check if skill was removed or not in the end
		  
	saved var remainingBlockedTime : float;							//remaining time till skill will be unblocked (-1: only when explicitly unlocked; 0: skill is unlocked; >0: seconds till it will be enabled automatically)
	
			var precachedModifierSkills : array< ESkill >;
};

//used for skill restoring after load (performance)
struct SRestoredSkill
{
	var level : int;
	var skillType : ESkill;
	var isNew : bool;
	var remainingBlockedTime : float;	
};

struct SSimpleSkill
{
	var level : int;
	var skillType : ESkill;
};

struct STutorialSavedSkill
{
	var skillSlotID : int;
	var skillType : ESkill;
};

//used to add temp fake skills for duration of tutorial
struct STutorialTemporarySkill
{
	var wasLearned : bool;
	var skillType : ESkill;
};

struct SMutagenBonusAlchemy19
{
	var abilityName : name;
	var count : int;
}

enum ESkillPath
{
	ESP_NotSet,
	ESP_Sword,
	ESP_Signs,
	ESP_Alchemy,
	ESP_Perks
}

function SkillPathNameToType(n : name) : ESkillPath
{
	switch(n)
	{
		case 'Sword' :		return ESP_Sword;
		case 'Signs' : 		return ESP_Signs;		
		case 'Alchemy' : 	return ESP_Alchemy;
		case 'Perks' :	 	return ESP_Perks;
		default :			return ESP_NotSet;
	}
}

function SkillPathTypeToName(s : ESkillPath) : name // #B
{
	switch(s)
	{
		case ESP_Sword :		return 'Sword';
		case ESP_Signs : 		return 'Signs';		
		case ESP_Alchemy : 		return 'Alchemy';
		case ESP_Perks : 		return 'Perks';
		default :				return '';
	}
}

function SkillPathTypeToLocalisationKey(s : ESkillPath) : name // #B
{
	switch(s)
	{
		case ESP_Sword :		return 'panel_character_skill_sword';
		case ESP_Signs : 		return 'panel_character_skill_signs';		
		case ESP_Alchemy : 		return 'panel_character_skill_alchemy';
		case ESP_Perks : 		return 'panel_character_perks_name';
		default :				return '';
	}
}

function SkillSubPathToLocalisationKey(s : ESkillSubPath) : string
{
	switch(s)
	{
		case ESSP_Sword_StyleFast    : return "skill_name_sword_1";
		case ESSP_Sword_StyleStrong  : return "skill_name_sword_2";
		case ESSP_Sword_Utility 	 : return "skill_name_sword_3";
		case ESSP_Sword_Crossbow 	 : return "skill_name_sword_4";		
		case ESSP_Sword_BattleTrance : return "skill_name_sword_5";
		
		case ESSP_Signs_Aard   : return "skill_name_magic_1";
		case ESSP_Signs_Igni   : return "skill_name_magic_2";
		case ESSP_Signs_Yrden  : return "skill_name_magic_3";
		case ESSP_Signs_Quen   : return "skill_name_magic_4";
		case ESSP_Signs_Axi    : return "skill_name_magic_5";
		
		case ESSP_Alchemy_Potions  : return "skill_name_alchemy_1";
		case ESSP_Alchemy_Oils 	   : return "skill_name_alchemy_2";
		case ESSP_Alchemy_Bombs    : return "skill_name_alchemy_3";
		case ESSP_Alchemy_Mutagens : return "skill_name_alchemy_4";
		case ESSP_Alchemy_Grasses  : return "skill_name_alchemy_5";
		
		default : return "";
	}
}

enum ESkillSubPath
{
	ESSP_NotSet,	
	ESSP_Sword_StyleStrong,
	ESSP_Sword_StyleFast,
	ESSP_Sword_Crossbow,
	ESSP_Sword_Utility,
	ESSP_Sword_BattleTrance,
	ESSP_Sword_Offense,
	ESSP_Sword_Defence,
	ESSP_Sword_General,
	
	ESSP_Signs_Aard,
	ESSP_Signs_Igni,
	ESSP_Signs_Yrden,
	ESSP_Signs_Quen,
	ESSP_Signs_Axi,
	ESSP_Signs_Offense,
	ESSP_Signs_Defence,
	ESSP_Signs_General,
	
	ESSP_Alchemy_Potions,
	ESSP_Alchemy_Oils,
	ESSP_Alchemy_Bombs,
	ESSP_Alchemy_Mutagens,
	ESSP_Alchemy_Grasses,
	ESSP_Alchemy_Offense,
	ESSP_Alchemy_Defence,
	ESSP_Alchemy_General,
	
	ESSP_Perks,
	ESSP_Perks_col1,
	ESSP_Perks_col2,
	ESSP_Perks_col3,
	ESSP_Perks_col4,
	ESSP_Perks_col5,
	
	ESSP_Core
}

function SkillSubPathNameToType(n : name) : ESkillSubPath
{
	switch(n)
	{		
		case 'Sword_StyleStrong' :		return ESSP_Sword_StyleStrong;
		case 'Sword_StyleFast' :		return ESSP_Sword_StyleFast;
		case 'Sword_Crossbow' :			return ESSP_Sword_Crossbow;
		case 'Sword_Utility' :			return ESSP_Sword_Utility;
		case 'Sword_BattleTrance' :		return ESSP_Sword_BattleTrance;
		case 'Sword_Offense' :			return ESSP_Sword_Offense;
		case 'Sword_Defence' :			return ESSP_Sword_Defence;
		case 'Sword_General' :			return ESSP_Sword_General;

		case 'Signs_Aard' :				return ESSP_Signs_Aard;
		case 'Signs_Igni' :				return ESSP_Signs_Igni;
		case 'Signs_Yrden' :			return ESSP_Signs_Yrden;
		case 'Signs_Quen' :				return ESSP_Signs_Quen;		
		case 'Signs_Axi' :				return ESSP_Signs_Axi;
		case 'Signs_Offense' :			return ESSP_Signs_Offense;
		case 'Signs_Defence' :			return ESSP_Signs_Defence;
		case 'Signs_General' :			return ESSP_Signs_General;

		case 'Alchemy_Potions' :		return ESSP_Alchemy_Potions;
		case 'Alchemy_Oils' :			return ESSP_Alchemy_Oils;
		case 'Alchemy_Bombs' :			return ESSP_Alchemy_Bombs;
		case 'Alchemy_Mutagens' :		return ESSP_Alchemy_Mutagens;
		case 'Alchemy_Grasses' :		return ESSP_Alchemy_Grasses;
		case 'Alchemy_Offense' :		return ESSP_Alchemy_Offense;
		case 'Alchemy_Defence' :		return ESSP_Alchemy_Defence;
		case 'Alchemy_General' :		return ESSP_Alchemy_General;
		
		case 'Perks' : 					return ESSP_Perks;
		case 'Perks_col1' : 			return ESSP_Perks_col1;
		case 'Perks_col2' : 			return ESSP_Perks_col2;
		case 'Perks_col3' : 			return ESSP_Perks_col3;
		case 'Perks_col4' : 			return ESSP_Perks_col4;
		case 'Perks_col5' : 			return ESSP_Perks_col5;
		
		case 'Core' :					return ESSP_Core;
		
		default :						return ESSP_NotSet;
	}
}

function SkillSubPathTypeToName(s : ESkillSubPath) : name // #B
{
	switch(s)
	{		
		case ESSP_Sword_StyleStrong :		return 'Sword_StyleStrong';
		case ESSP_Sword_StyleFast :			return 'Sword_StyleFast' ;
		case ESSP_Sword_Crossbow :			return 'Sword_Crossbow';
		case ESSP_Sword_Utility :			return 'Sword_Utility';
		case ESSP_Sword_BattleTrance :		return 'Sword_BattleTrance';
		case ESSP_Sword_Offense :			return 'Sword_Offense';
		case ESSP_Sword_Defence :			return 'Sword_Defence';
		case ESSP_Sword_General :			return 'Sword_General';

		case ESSP_Signs_Igni :				return 'Signs_Igni';
		case ESSP_Signs_Aard :				return 'Signs_Aard';
		case ESSP_Signs_Yrden :				return 'Signs_Yrden';
		case ESSP_Signs_Axi :				return 'Signs_Axi';
		case ESSP_Signs_Quen :				return 'Signs_Quen';
		case ESSP_Signs_Offense :			return 'Signs_Offense';
		case ESSP_Signs_Defence :			return 'Signs_Defence';
		case ESSP_Signs_General :			return 'Signs_General';

		case ESSP_Alchemy_Potions :			return 'Alchemy_Potions';
		case ESSP_Alchemy_Oils :			return 'Alchemy_Oils';
		case ESSP_Alchemy_Bombs :			return 'Alchemy_Bombs';
		case ESSP_Alchemy_Mutagens :		return 'Alchemy_Mutagens';
		case ESSP_Alchemy_Grasses :			return 'Alchemy_Grasses';
		case ESSP_Alchemy_Offense :			return 'Alchemy_Offense';
		case ESSP_Alchemy_Defence :			return 'Alchemy_Defence';
		case ESSP_Alchemy_General :			return 'Alchemy_General';
		
		case ESSP_Perks :					return 'Perks';
		case ESSP_Perks_col1 :				return 'Perks_col1';
		case ESSP_Perks_col2 :				return 'Perks_col2';
		case ESSP_Perks_col3 :				return 'Perks_col3';
		case ESSP_Perks_col4 :				return 'Perks_col4';
		case ESSP_Perks_col5 :				return 'Perks_col5';
		
		case ESSP_Core :					return 'Core';
		
		default :							return '';
	}
}

import struct SResistanceValue
{
	import saved var points 	: SAbilityAttributeValue;
	import saved var percents 	: SAbilityAttributeValue;
	import saved var type 		: ECharacterDefenseStats;
};

//returns true if given skill is sign skill
function IsSkillSign(skill : ESkill) : bool
{
	switch(skill)
	{
		case S_Magic_1:
		case S_Magic_2:
		case S_Magic_3:
		case S_Magic_4:
		case S_Magic_5:
		case S_Magic_s01:
		case S_Magic_s02:
		case S_Magic_s03:
		case S_Magic_s04:
		case S_Magic_s05:
			return true;
		default:
			return false;
	}
}

enum EPlayerMutationType
{
	EPMT_None,
	EPMT_Mutation1,
	EPMT_Mutation2,
	EPMT_Mutation3,
	EPMT_Mutation4,
	EPMT_Mutation5,
	EPMT_Mutation6,
	EPMT_Mutation7,
	EPMT_Mutation8,
	EPMT_Mutation9,
	EPMT_Mutation10,
	EPMT_Mutation11,
	EPMT_Mutation12,
	EPMT_MutationMaster
}

function MutationNameToType( mutName : name ) : EPlayerMutationType
{
	switch( mutName )
	{
		case 'mutation1' : 			return EPMT_Mutation1;
		case 'mutation2' : 			return EPMT_Mutation2;
		case 'mutation3' :			return EPMT_Mutation3;
		case 'mutation4' : 			return EPMT_Mutation4;
		case 'mutation5' :			return EPMT_Mutation5;
		case 'mutation6' : 			return EPMT_Mutation6;
		case 'mutation7' : 			return EPMT_Mutation7;
		case 'mutation8' : 			return EPMT_Mutation8;
		case 'mutation9' : 			return EPMT_Mutation9;
		case 'mutation10' : 		return EPMT_Mutation10;
		case 'mutation11' : 		return EPMT_Mutation11;
		case 'mutation12' : 		return EPMT_Mutation12;
		case 'mutationMaster' : 	return EPMT_MutationMaster;
		
		default : 					return EPMT_None;
	}
	
	return EPMT_None;
}

struct SMutationProgress
{
	var redUsed : int;					//amount of red research points used
	var redRequired : int;				//amount of red research points required
	var blueUsed : int;					//amount of blue research points used
	var blueRequired : int;				//amount of blue research points required
	var greenUsed : int;				//amount of green research points used
	var greenRequired : int;			//amount of green research points required
	var skillpointsUsed : int;			//amount of skill points used			
	var skillpointsRequired : int;		//amount of skill points required
	var overallProgress : int;			//overal progress in percents [0-100]. If value is -1 it is unknown and must be calculated. If it's >= 0 it's cached.
}

struct SMutation
{
	var type : EPlayerMutationType;								//mutation type
	var colors : array< ESkillColor >;							//mutation colors
	var progress : SMutationProgress;							//research progress	
	var requiredMutations : array< EPlayerMutationType >;		//list of mutations required before this one can be researched
	var localizationNameKey : name;								//name localization key
	var localizationDescriptionKey : name;						//description localization key
	var iconPath : name;										//path to icon
	var soundbank : string;										//soundbank name
}
