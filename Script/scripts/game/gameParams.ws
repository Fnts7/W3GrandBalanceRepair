/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/
struct SDurabilityThreshold
{
	var thresholdMax : float;	//upper value of threshold
	var multiplier : float;		//stat multiplier
	var difficulty : EDifficultyMode;
};

// struct for holding global consts, mainly loaded from xmls
import class W3GameParams extends CObject
{
	private var dm : CDefinitionsManagerAccessor;					//definitions manager	
	private var main : SCustomNode;									//main node for the XML settings file	
	
	//abilities
	public const var BASE_ABILITY_TAG : name;																					//tag used with base character abilities
	public const var PASSIVE_BONUS_ABILITY_TAG : name;																			//tag used with passive attribute bonuses
		default BASE_ABILITY_TAG = 'base';
		default PASSIVE_BONUS_ABILITY_TAG = 'passive';
	private var forbiddenAttributes : array<name>;				//Ability Manager's static var : all stats that have their own getters must be get using those getters 
																//instead of GetAttribute. There is no point in caching other stats as they are most of the time got 
																//with particular tag only. These however are got using final values, regardless of tags.	
	public var GLOBAL_ENEMY_ABILITY : name;						//ability added by scripts by default to ALL non-players (should be in entites but we're too deep in the sh*t to do it properly now)
		default GLOBAL_ENEMY_ABILITY = 'all_NPC_ability';
	
	public var ENEMY_BONUS_PER_LEVEL : name;					// ability added by script to all enemies with level higher than 1, added multiple time based on enemy level
		default ENEMY_BONUS_PER_LEVEL = 'NPCLevelBonus';
		
	public var ENEMY_BONUS_FISTFIGHT_LOW : name;					
		default ENEMY_BONUS_FISTFIGHT_LOW = 'NPCLevelModFistFightLower';
	
	public var ENEMY_BONUS_FISTFIGHT_HIGH : name;					
		default ENEMY_BONUS_FISTFIGHT_HIGH = 'NPCLevelModFistFightHigher';
		
	public var ENEMY_BONUS_LOW : name;					
		default ENEMY_BONUS_LOW = 'NPCLevelBonusLow';
		
	public var ENEMY_BONUS_HIGH : name;					
		default ENEMY_BONUS_HIGH = 'NPCLevelBonusHigh';
		
	public var ENEMY_BONUS_DEADLY : name;					
		default ENEMY_BONUS_DEADLY = 'NPCLevelBonusDeadly';
		
	public var MONSTER_BONUS_PER_LEVEL : name;					// ability added by script to all monsters with level higher than 1, added multiple time based on enemy level
		default MONSTER_BONUS_PER_LEVEL = 'MonsterLevelBonus';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP : name;					// ability added by script to all monsters with level higher than 1, added multiple time based on enemy level
		default MONSTER_BONUS_PER_LEVEL_GROUP = 'MonsterLevelBonusGroup';
		
	public var MONSTER_BONUS_PER_LEVEL_ARMORED : name;					// ability added by script to all monsters with level higher than 1, added multiple time based on enemy level
		default MONSTER_BONUS_PER_LEVEL_ARMORED = 'MonsterLevelBonusArmored';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED : name;					// ability added by script to all monsters with level higher than 1, added multiple time based on enemy level
		default MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED = 'MonsterLevelBonusGroupArmored';
		
	public var MONSTER_BONUS_LOW : name;						
		default MONSTER_BONUS_LOW = 'MonsterLevelBonusLow';
		
	public var MONSTER_BONUS_HIGH : name;						
		default MONSTER_BONUS_HIGH = 'MonsterLevelBonusHigh';
		
	public var MONSTER_BONUS_DEADLY : name;						
		default MONSTER_BONUS_DEADLY = 'MonsterLevelBonusDeadly';
	
	public var BOSS_NGP_BONUS : name;
		default BOSS_NGP_BONUS = 'BossNGPLevelBonus';
		
	public var GLOBAL_PLAYER_ABILITY : name;					//ability added by scripts by default to ALL players (should be in entites but we're too deep in the sh*t to do it properly now)
		default GLOBAL_PLAYER_ABILITY = 'all_PC_ability';
	
	public const var NOT_A_SKILL_ABILITY_TAG : name;			//tag used for abilitis that aren't a skill and we don't want them to be added to NPC on initialization
		default NOT_A_SKILL_ABILITY_TAG = 'NotASkill';
	
	//alchemy
	public const var ALCHEMY_COOKED_ITEM_TYPE_POTION, ALCHEMY_COOKED_ITEM_TYPE_BOMB, ALCHEMY_COOKED_ITEM_TYPE_OIL : string;		//alchemy cooked item types' string names used in XMLs
	public const var OIL_ABILITY_TAG : name;																					//tags used in oils abilities
	public const var QUANTITY_INCREASED_BY_ALCHEMY_TABLE : int;
		default ALCHEMY_COOKED_ITEM_TYPE_POTION = "Potion";
		default ALCHEMY_COOKED_ITEM_TYPE_BOMB = "Bomb";
		default ALCHEMY_COOKED_ITEM_TYPE_OIL = "Oil";	 
		default	OIL_ABILITY_TAG = 'OilBonus';
		default QUANTITY_INCREASED_BY_ALCHEMY_TABLE = 1;
	
	//basic actions
	public const var ATTACK_NAME_LIGHT, ATTACK_NAME_HEAVY, ATTACK_NAME_SUPERHEAVY, ATTACK_NAME_SPEED_BASED, ATTACK_NO_DAMAGE : name;		//names/tags of basic actions
		default ATTACK_NAME_LIGHT = 'attack_light';
		default ATTACK_NAME_HEAVY = 'attack_heavy';
		default ATTACK_NAME_SUPERHEAVY = 'attack_super_heavy';
		default ATTACK_NAME_SPEED_BASED = 'attack_speed_based';		
		default ATTACK_NO_DAMAGE = 'attack_no_damage';		
	
	//boat
	public const var MAX_DYNAMICALLY_SPAWNED_BOATS : int;		//max amount of saved dynamically spawned boats
		default MAX_DYNAMICALLY_SPAWNED_BOATS = 5;
	
	//bombs
	public const var MAX_THROW_RANGE : float;					//max throwing range in meters
	public const var UNDERWATER_THROW_RANGE : float;					//underwater throwing range in meters, also used for crossbow
	public const var PROXIMITY_PETARD_IDLE_DETONATION_TIME : float;		//time after which proximity petards detonate if nothing triggers them before
	public const var BOMB_THROW_DELAY : float;							//delay between bomb throws
		default MAX_THROW_RANGE = 25.0;
		default UNDERWATER_THROW_RANGE = 5.0;
		default PROXIMITY_PETARD_IDLE_DETONATION_TIME = 10.0;
		default BOMB_THROW_DELAY = 2.f;
		
	//containers
	public const var CONTAINER_DYNAMIC_DESTROY_TIMEOUT : int;	//timeout in seconds for destroying dynamic containers
		default CONTAINER_DYNAMIC_DESTROY_TIMEOUT = 900;
		
	//critical hits
	public const var CRITICAL_HIT_CHANCE : name;					//attribute name for critical hit chance
	public const var CRITICAL_HIT_DAMAGE_BONUS : name;				//attribute name for critical hit damage bonus
	public const var CRITICAL_HIT_REDUCTION : name;					//attribute name for critical hit damage reduction
	public const var CRITICAL_HIT_FX : name;						//name of blood fx to use when critically hit instead of normal hit fx
	public const var HEAD_SHOT_CRIT_CHANCE_BONUS : float;			//bonus for headshots from crossbow
	public const var BACK_ATTACK_CRIT_CHANCE_BONUS : float;			//bonus for back attack
	
		default CRITICAL_HIT_CHANCE = 'critical_hit_chance';
		default CRITICAL_HIT_FX = 'critical_hit';
		default CRITICAL_HIT_DAMAGE_BONUS = 'critical_hit_damage_bonus';
		default CRITICAL_HIT_REDUCTION = 'critical_hit_damage_reduction';
		default HEAD_SHOT_CRIT_CHANCE_BONUS = 0.5;
		default BACK_ATTACK_CRIT_CHANCE_BONUS = 0.5;
	
	//damage
	public const var DAMAGE_NAME_DIRECT, DAMAGE_NAME_PHYSICAL, DAMAGE_NAME_SILVER, DAMAGE_NAME_SLASHING, DAMAGE_NAME_PIERCING, DAMAGE_NAME_BLUDGEONING, DAMAGE_NAME_RENDING, DAMAGE_NAME_ELEMENTAL, DAMAGE_NAME_FIRE, DAMAGE_NAME_FORCE, DAMAGE_NAME_FROST, DAMAGE_NAME_POISON, DAMAGE_NAME_SHOCK, DAMAGE_NAME_MORALE, DAMAGE_NAME_STAMINA : name;
		default DAMAGE_NAME_DIRECT 		= 'DirectDamage';
		default DAMAGE_NAME_PHYSICAL 	= 'PhysicalDamage';
		default DAMAGE_NAME_SILVER 		= 'SilverDamage';
		default DAMAGE_NAME_SLASHING	= 'SlashingDamage';
		default DAMAGE_NAME_PIERCING 	= 'PiercingDamage';
		default DAMAGE_NAME_BLUDGEONING = 'BludgeoningDamage';
		default DAMAGE_NAME_RENDING	 	= 'RendingDamage';
		default DAMAGE_NAME_ELEMENTAL	= 'ElementalDamage';
		default DAMAGE_NAME_FIRE 		= 'FireDamage';
		default DAMAGE_NAME_FORCE 		= 'ForceDamage';
		default DAMAGE_NAME_FROST 		= 'FrostDamage';
		default DAMAGE_NAME_POISON 		= 'PoisonDamage';
		default DAMAGE_NAME_SHOCK 		= 'ShockDamage';
		default DAMAGE_NAME_MORALE 		= 'MoraleDamage';
		default DAMAGE_NAME_STAMINA 	= 'StaminaDamage';
		
	public const var FOCUS_DRAIN_PER_HIT : float;					//amount of focus points lost when you get hit (this gets mutiplied further for specific attacks)	
	public const var UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY, UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY : name;		//name of the camera effect to play when we are in uninterrupted hits flurry
	public const var MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS 	: float;		//monster resistance threshold above which fist attacks on monster will be reflected
	public const var ARMOR_VALUE_NAME : name;
	public const var LOW_HEALTH_EFFECT_SHOW : float;				//at what hp level the effect is on/off
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS : float;					//+X%
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP : float;				//custom for NGP
	public const var ARCHER_DAMAGE_BONUS_NGP : float;				//acrher need damage increase in NGP

		default MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS = 70;
		default ARMOR_VALUE_NAME = 'armor';		
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS = 2;
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP = 6;
		default ARCHER_DAMAGE_BONUS_NGP = 2;
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY = 'combat_radial_blur';
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY = 'combat_radial_blur_big';
		default FOCUS_DRAIN_PER_HIT = 0.02;
		default LOW_HEALTH_EFFECT_SHOW = 0.3;
	
	public const var IGNI_SPELL_POWER_MILT : float;
		default	IGNI_SPELL_POWER_MILT = 1.0f;
		
	public const var INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN : float;					//internal cooldown of instant kill proc (only for player)
		default INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN = 15.f;
	
	//difficulty	
	public var DIFFICULTY_TAG_EASY, DIFFICULTY_TAG_MEDIUM, DIFFICULTY_TAG_HARD, DIFFICULTY_TAG_HARDCORE : name;			//tags for abilities
	public var DIFFICULTY_TAG_DIFF_ABILITY : name;																		//tag informing that this ability is a difficulty mode ability
	public var DIFFICULTY_HP_MULTIPLIER, DIFFICULTY_DMG_MULTIPLIER : name;												//hp & damage global multipliers
	public var DIFFICULTY_TAG_IGNORE : name;																			//tag which if added to any ability makes the actor ignore difficulty modes' settings
	
		default DIFFICULTY_TAG_DIFF_ABILITY = 'DifficultyModeAbility';		
		default DIFFICULTY_TAG_EASY			= 'Easy';
		default DIFFICULTY_TAG_MEDIUM		= 'Medium';
		default DIFFICULTY_TAG_HARD			= 'Hard';
		default DIFFICULTY_TAG_HARDCORE 	= 'Hardcore';
		default DIFFICULTY_HP_MULTIPLIER 	= 'health_final_multiplier';
		default DIFFICULTY_DMG_MULTIPLIER 	= 'damage_final_multiplier';
		default DIFFICULTY_TAG_IGNORE		= 'IgnoreDifficultyAbilities';
		
	//dismemberment
	public const var DISMEMBERMENT_ON_DEATH_CHANCE : int;				//in percents [0-100]
		default DISMEMBERMENT_ON_DEATH_CHANCE = 30;
		
	//finishers
	public const var FINISHER_ON_DEATH_CHANCE : int;					//in percents [0-100]
		default FINISHER_ON_DEATH_CHANCE = 30;		
	
	//durability
	public const var DURABILITY_ARMOR_LOSE_CHANCE, DURABILITY_WEAPON_LOSE_CHANCE : int;			//percentage chance that the durability will be lost
	public const var DURABILITY_ARMOR_LOSE_VALUE : float;										//value of durability lost (in points)
	private const var DURABILITY_WEAPON_LOSE_VALUE, DURABILITY_WEAPON_LOSE_VALUE_HARDCORE : float;
	public const var DURABILITY_ARMOR_CHEST_WEIGHT, DURABILITY_ARMOR_PANTS_WEIGHT, DURABILITY_ARMOR_BOOTS_WEIGHT, DURABILITY_ARMOR_GLOVES_WEIGHT, DURABILITY_ARMOR_MISS_WEIGHT : int; //wages for choosing armor piece
	protected var durabilityThresholdsWeapon, durabilityThresholdsArmor : array<SDurabilityThreshold>;					//durability thresholds for items
	public const var TAG_REPAIR_CONSUMABLE_ARMOR, TAG_REPAIR_CONSUMABLE_STEEL, TAG_REPAIR_CONSUMABLE_SILVER : name;		//tags for consumable repair items
	public const var ITEM_DAMAGED_DURABILITY : int;												//when item is considered damaged and we show UI notification
	public var INTERACTIVE_REPAIR_OBJECT_MAX_DURS : array<int>;									//max percentages of durability [0-100] that can be repaired at interactive objects. Index is quality level
		
		default TAG_REPAIR_CONSUMABLE_ARMOR = 'RepairArmor';
		default TAG_REPAIR_CONSUMABLE_STEEL = 'RepairSteel';
		default TAG_REPAIR_CONSUMABLE_SILVER = 'RepairSilver';
		
		default ITEM_DAMAGED_DURABILITY = 50;
	
		default DURABILITY_ARMOR_LOSE_CHANCE = 100;
		default DURABILITY_WEAPON_LOSE_CHANCE = 100;
		default DURABILITY_ARMOR_LOSE_VALUE = 0.6;	//was 0.2	
		default DURABILITY_WEAPON_LOSE_VALUE = 0.26; //was 0.2
		default DURABILITY_WEAPON_LOSE_VALUE_HARDCORE = 0.1;
		
		//50% chest, 10% head, 10% gloves, 15% pants and boots (pants cover more but get less hits)
		default DURABILITY_ARMOR_MISS_WEIGHT = 10;
		default DURABILITY_ARMOR_CHEST_WEIGHT = 50;			
		default DURABILITY_ARMOR_BOOTS_WEIGHT = 15;
		default DURABILITY_ARMOR_PANTS_WEIGHT = 15;
		default DURABILITY_ARMOR_GLOVES_WEIGHT = 10;
	
	//focus mode
	public const var CFM_SLOWDOWN_RATIO : float;					//slowdown ratio of CFM
		default CFM_SLOWDOWN_RATIO = 0.01;
	
	//hit fx
	public const var LIGHT_HIT_FX, LIGHT_HIT_BACK_FX, LIGHT_HIT_PARRIED_FX, LIGHT_HIT_BACK_PARRIED_FX, HEAVY_HIT_FX, HEAVY_HIT_BACK_FX, HEAVY_HIT_PARRIED_FX, HEAVY_HIT_BACK_PARRIED_FX : name;
		default LIGHT_HIT_FX = 'light_hit';			//no name concat :/
		default LIGHT_HIT_BACK_FX = 'light_hit_back';
		default LIGHT_HIT_PARRIED_FX = 'light_hit_parried';
		default LIGHT_HIT_BACK_PARRIED_FX = 'light_hit_back_parried';
		default HEAVY_HIT_FX = 'heavy_hit';
		default HEAVY_HIT_BACK_FX = 'heavy_hit_back';
		default HEAVY_HIT_PARRIED_FX = 'heavy_hit_parried';
		default HEAVY_HIT_BACK_PARRIED_FX = 'heavy_hit_back_parried';
		
	public const var LOW_HP_SHOW_LEVEL : float;							//red screen effect threshold value
		default LOW_HP_SHOW_LEVEL = 0.25;

	//items
	public const var TAG_ARMOR : name;								//tag for armors (any armor piece, not just chest armor)
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_YES : name;			//forces item to count towards encumbrance
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_NO : name;			//forces item to not count towards encumbrance
	public const var TAG_ITEM_UPGRADEABLE : name;					//tag given to items that can be upgraded
	public const var TAG_DONT_SHOW : name;							//tag for items that should not be shown in inventory panels of any kind
	public const var TAG_DONT_SHOW_ONLY_IN_PLAYERS : name;			//should not be shown ONLY in players inventory - visible in other panels
	public const var TAG_ITEM_SINGLETON : name;						//single instance item: can be only 1 in inventory, not more
	public const var TAG_INFINITE_AMMO : name;						//item has infinite ammo (set to 1 always)
	public const var TAG_UNDERWATER_AMMO : name;					//crossbow ammo used underwater
	public const var TAG_GROUND_AMMO : name;	
	public const var TAG_ILLUSION_MEDALLION : name;
	public const var TAG_PLAYER_STEELSWORD : name;					//steelsword usable by player
	public const var TAG_PLAYER_SILVERSWORD : name;					//silversword usable by player
	public const var TAG_INFINITE_USE : name;						//item can be used infinitely
	private var ARMOR_MASTERWORK_ABILITIES 	: array<name>;			//abilities randomly added to masterwork or better armors
	private var ARMOR_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better armors
	private var GLOVES_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better gloves
	private var GLOVES_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better gloves
	private var PANTS_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better pants
	private var PANTS_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better pants
	private var BOOTS_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better boots
	private var BOOTS_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better boots
	private var WEAPON_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better weapons
	private var WEAPON_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better armors
	public const var ITEM_SET_TAG_BEAR, ITEM_SET_TAG_GRYPHON, ITEM_SET_TAG_LYNX, ITEM_SET_TAG_WOLF, ITEM_SET_TAG_RED_WOLF, ITEM_SET_TAG_VAMPIRE, ITEM_SET_TAG_VIPER : name;		//item sets tags
	public const var BOUNCE_ARROWS_ABILITY : name;					//ability that bounces arrows (they cannot hit us)
	public const var TAG_ALCHEMY_REFILL_ALCO : name;				//tag used to mark items that can be used to refill alchemical items in meditation
	public const var REPAIR_OBJECT_BONUS_ARMOR_ABILITY : name;		//name of ability added to armors from 'repair objects'
	public const var REPAIR_OBJECT_BONUS_WEAPON_ABILITY : name;		//name of ability added to armors from 'repair objects'
	public const var REPAIR_OBJECT_BONUS : name;					//name of attribute which holds amount of bonus granted by repair objects (same attribute name for weapons and armor)
	public const var CIRI_SWORD_NAME : name;
	public const var TAG_OFIR_SET : name;							//Ofir set items
		
		default TAG_ARMOR = 'Armor';
		default TAG_ENCUMBRANCE_ITEM_FORCE_YES = 'EncumbranceOn';
		default TAG_ENCUMBRANCE_ITEM_FORCE_NO = 'EncumbranceOff';
		default TAG_ITEM_UPGRADEABLE = 'Upgradeable';
		default TAG_DONT_SHOW = 'NoShow';
		default TAG_DONT_SHOW_ONLY_IN_PLAYERS = 'NoShowInPlayersInventory';
		default TAG_ITEM_SINGLETON = 'SingletonItem';
		default TAG_INFINITE_AMMO = 'InfiniteAmmo';
		default TAG_UNDERWATER_AMMO = 'UnderwaterAmmo';
		default TAG_GROUND_AMMO = 'GroundAmmo';
		default TAG_ILLUSION_MEDALLION = 'IllusionMedallion';
		default TAG_PLAYER_STEELSWORD = 'PlayerSteelWeapon';
		default TAG_PLAYER_SILVERSWORD = 'PlayerSilverWeapon';
		default TAG_INFINITE_USE = 'InfiniteUse';
		default ITEM_SET_TAG_BEAR = 'BearSet';
		default ITEM_SET_TAG_GRYPHON = 'GryphonSet';
		default ITEM_SET_TAG_LYNX = 'LynxSet';
		default ITEM_SET_TAG_WOLF = 'WolfSet';
		default ITEM_SET_TAG_RED_WOLF = 'RedWolfSet';
		default ITEM_SET_TAG_VIPER = 'ViperSet';
		default ITEM_SET_TAG_VAMPIRE = 'VampireSet';
		default BOUNCE_ARROWS_ABILITY = 'bounce_arrows';
		default TAG_ALCHEMY_REFILL_ALCO = 'StrongAlcohol';
		default REPAIR_OBJECT_BONUS_ARMOR_ABILITY = 'repair_object_armor_bonus';
		default REPAIR_OBJECT_BONUS_WEAPON_ABILITY = 'repair_object_weapon_bonus';
		default REPAIR_OBJECT_BONUS = 'repair_object_stat_bonus';
		default CIRI_SWORD_NAME = 'Zireael Sword';
		default TAG_OFIR_SET = 'Ofir';
	
	//new game +
	private var newGamePlusLevel : int;						//'final' NewGame+ level - calculated on player spawn
	private const var NEW_GAME_PLUS_LEVEL_ADD : int;		//level addition to player level to form 'final' NewGame+ level
	public const var NEW_GAME_PLUS_MIN_LEVEL : int;				//min Geralt level for base NG+
	public const var NEW_GAME_PLUS_EP1_MIN_LEVEL : int;			//min Geralt level for NG+ with EP1
		default NEW_GAME_PLUS_LEVEL_ADD = 0;
		default NEW_GAME_PLUS_MIN_LEVEL = 30;
		default NEW_GAME_PLUS_EP1_MIN_LEVEL = 30;
	
	//oils
	public const var TAG_STEEL_OIL, TAG_SILVER_OIL : name;
		default TAG_STEEL_OIL = 'SteelOil';
		default TAG_SILVER_OIL = 'SilverOil';
	
	//parry
	public const var HEAVY_STRIKE_COST_MULTIPLIER : float;								//multiplier for heavy strike parry stamina cost		
	public const var PARRY_HALF_ANGLE : int;											//half of the angle in which we can parry the incoming attacks. If this is 120 then we have a coverage of 120 degrees left and right from front
	public const var PARRY_STAGGER_REDUCE_DAMAGE_LARGE : float;							//percentage of damage player takes from large npcs when he is parry staggered
	public const var PARRY_STAGGER_REDUCE_DAMAGE_SMALL : float;							//percentage of damage player takes from humanoid or smaller npcs when he is parry staggered
		default PARRY_HALF_ANGLE = 180;//120;
		default HEAVY_STRIKE_COST_MULTIPLIER = 2.0;
		default PARRY_STAGGER_REDUCE_DAMAGE_LARGE = 0.6f;
		default PARRY_STAGGER_REDUCE_DAMAGE_SMALL = 0.3f;
		
	//potions
	public const var POTION_QUICKSLOTS_COUNT : int;										//how many potion quick slots are there
		default POTION_QUICKSLOTS_COUNT = 4;
	
	//set bonuses
	public const var ITEMS_REQUIRED_FOR_MINOR_SET_BONUS : int;
	public const var ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS : int;
	public const var ITEM_SET_TAG_BONUS					: name;
		default ITEMS_REQUIRED_FOR_MINOR_SET_BONUS = 3;
		default ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS = 6;
		default ITEM_SET_TAG_BONUS = 'SetBonusPiece';
	
	//sockets
	public const var TAG_STEEL_SOCKETABLE, TAG_SILVER_SOCKETABLE, TAG_ARMOR_SOCKETABLE, TAG_ABILITY_SOCKET : name;
		default TAG_STEEL_SOCKETABLE = 'SteelSocketable';							//tag for items that can upgrade steel sword
		default TAG_SILVER_SOCKETABLE = 'SilverSocketable';							//tag for items that can upgrade silver  sword
		default TAG_ARMOR_SOCKETABLE = 'ArmorSocketable';							//tag for items that can upgrade armor
		default TAG_ABILITY_SOCKET = 'Socket';										//tag for abilities that are added onto upgraded items
		
	//stamina cost attribute names
	public const var STAMINA_COST_PARRY_ATTRIBUTE, STAMINA_COST_COUNTERATTACK_ATTRIBUTE, STAMINA_COST_EVADE_ATTRIBUTE, STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE, 
					 STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_LIGHT_ACTION_ATTRIBUTE, STAMINA_COST_DODGE_ATTRIBUTE,
					 STAMINA_COST_SPRINT_ATTRIBUTE, STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE, STAMINA_COST_JUMP_ATTRIBUTE, STAMINA_COST_USABLE_ITEM_ATTRIBUTE,
					 STAMINA_COST_DEFAULT, STAMINA_COST_PER_SEC_DEFAULT, STAMINA_COST_ROLL_ATTRIBUTE, STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE : name;
					 
	public const var STAMINA_DELAY_PARRY_ATTRIBUTE, STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE, STAMINA_DELAY_EVADE_ATTRIBUTE, STAMINA_DELAY_SWIMMING_ATTRIBUTE, 
					 STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE, STAMINA_DELAY_DODGE_ATTRIBUTE,
					 STAMINA_DELAY_SPRINT_ATTRIBUTE, STAMINA_DELAY_JUMP_ATTRIBUTE, STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE, STAMINA_DELAY_DEFAULT, STAMINA_DELAY_ROLL_ATTRIBUTE,
					 STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE: name;
					 
	public const var STAMINA_SEGMENT_SIZE : int;									//size of stamina segment (in points)
		
		default STAMINA_SEGMENT_SIZE = 10;
		
		default STAMINA_COST_DEFAULT = 'stamina_cost';
		default STAMINA_COST_PER_SEC_DEFAULT = 'stamina_cost_per_sec';
		default STAMINA_COST_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_cost';
		default STAMINA_COST_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_cost';
		default STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_cost';
		default STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_cost';
		default STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_cost';
		default STAMINA_COST_PARRY_ATTRIBUTE = 'parry_stamina_cost';
		default STAMINA_COST_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_cost';
		default STAMINA_COST_DODGE_ATTRIBUTE = 'dodge_stamina_cost';
		default STAMINA_COST_EVADE_ATTRIBUTE = 'evade_stamina_cost';
		default STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE = 'swimming_stamina_cost_per_sec';
		default STAMINA_COST_SPRINT_ATTRIBUTE = 'sprint_stamina_cost';
		default STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE = 'sprint_stamina_cost_per_sec';
		default STAMINA_COST_JUMP_ATTRIBUTE = 'jump_stamina_cost';
		default STAMINA_COST_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_cost';
		default STAMINA_COST_ROLL_ATTRIBUTE = 'roll_stamina_cost';
	
		default STAMINA_DELAY_DEFAULT = 'stamina_delay';
		default STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_delay';
		default STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_delay';			 
		default STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_delay';
		default STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_delay';
		default STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_delay';	
		default STAMINA_DELAY_PARRY_ATTRIBUTE = 'parry_stamina_delay';
		default STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_delay';
		default STAMINA_DELAY_DODGE_ATTRIBUTE = 'dodge_stamina_delay';
		default STAMINA_DELAY_EVADE_ATTRIBUTE = 'evade_stamina_delay';
		default STAMINA_DELAY_SWIMMING_ATTRIBUTE = 'swimming_stamina_delay';
		default STAMINA_DELAY_SPRINT_ATTRIBUTE = 'sprint_stamina_delay';
		default STAMINA_DELAY_JUMP_ATTRIBUTE = 'jump_stamina_delay';
		default STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_delay';
		default STAMINA_DELAY_ROLL_ATTRIBUTE = 'roll_stamina_delay';

	//toxicity
	public const var TOXICITY_DAMAGE_THRESHOLD : float;									//threshold at which the hp damage effect kicks in (% of max)
		default TOXICITY_DAMAGE_THRESHOLD = 0.75;
		
	//other
	public const var DEBUG_CHEATS_ENABLED : bool;										//if true then we have a lot of debug / game in progress cheats
	public const var SKILL_GLOBAL_PASSIVE_TAG : name;									//tag used in skill abilities to mark the skill as GLOBAL PASSIVE bonus
	public const var TAG_OPEN_FIRE : name;												//tag used by entites that carry open fire (for gas explosions)
	public const var TAG_MONSTER_SKILL : name;											//tag used to mark that ability is a monster skill
	public const var TAG_EXPLODING_GAS : name;											//tag of exploding gas entities
	public const var ON_HIT_HP_REGEN_DELAY : float;										//hp regen delay when being hit
	public const var TAG_NPC_IN_PARTY : name;											//tag added to NPCs when they are considered to be in player's party
	public const var TAG_PLAYERS_MOUNTED_VEHICLE : name;								//tag added/removed when player mounted a vehicle
	public const var TAG_SOFT_LOCK : name;												//tag removed to get rid of soft camera lock
	public const var MAX_SPELLPOWER_ASSUMED : float;									//assumed max spell power player can achieve
	public const var NPC_RESIST_PER_LEVEL : float;										//resistance to effects gained by NPCs per level
	public const var XP_PER_LEVEL : int;												//amount of xp granted per NPC level
	public const var XP_MINIBOSS_BONUS : float;											//bonus xp granted for killing human mini boss opponent
	public const var XP_BOSS_BONUS : float;												//bonus xp granted for killing human boss opponent
	public const var ADRENALINE_DRAIN_AFTER_COMBAT_DELAY : float;						//time after combat after which adrenaline drain effect is applied
	public const var KEYBOARD_KEY_FONT_COLOR : string;									//font color for keyboard keys shown in hint messages
	public const var MONSTER_HUNT_ACTOR_TAG : name;										//tag added to any Monster Hunt monster
	public const var GWINT_CARD_ACHIEVEMENT_TAG : name;									//tag added to gwint cards which count towards the achievement
	public const var TAG_AXIIABLE, TAG_AXIIABLE_LOWER_CASE : name;						//tag for NPCs that can be axiied
	public const var LEVEL_DIFF_DEADLY, LEVEL_DIFF_HIGH : int;							//level difference
	public const var LEVEL_DIFF_XP_MOD : float;											//XP modifier for level difference
	public const var MAX_XP_MOD : float;												//maximum XP bonus multiplier
	public const var DEVIL_HORSE_AURA_MIN_DELAY, DEVIL_HORSE_AURA_MAX_DELAY : int;		//min and max
	public const var TOTAL_AMOUNT_OF_BOOKS	: int;										// Total amount of Books in W3 + EP1 + EP2
	
		default DEBUG_CHEATS_ENABLED = true;
		default SKILL_GLOBAL_PASSIVE_TAG = 'GlobalPassiveBonus';
		default TAG_MONSTER_SKILL = 'MonsterSkill';
		default TAG_OPEN_FIRE = 'CarriesOpenFire';
		default TAG_EXPLODING_GAS = 'explodingGas';
		default ON_HIT_HP_REGEN_DELAY = 2;
		default TAG_NPC_IN_PARTY = 'InPlayerParty';
		default TAG_PLAYERS_MOUNTED_VEHICLE = 'PLAYER_mounted_vehicle';
		default TAG_SOFT_LOCK = 'softLock';
		default MAX_SPELLPOWER_ASSUMED = 2;
		default NPC_RESIST_PER_LEVEL = 0.016;
		default XP_PER_LEVEL = 1;
		default XP_MINIBOSS_BONUS = 1.77;
		default XP_BOSS_BONUS = 2.5;
		default ADRENALINE_DRAIN_AFTER_COMBAT_DELAY = 3;
		default KEYBOARD_KEY_FONT_COLOR = "#CD7D03";
		default MONSTER_HUNT_ACTOR_TAG = 'MonsterHuntTarget';
		default GWINT_CARD_ACHIEVEMENT_TAG = 'GwintCollectorAchievement';
		default TAG_AXIIABLE = 'Axiiable';
		default TAG_AXIIABLE_LOWER_CASE = 'axiiable';
		default LEVEL_DIFF_HIGH = 6;
		default LEVEL_DIFF_DEADLY = 15;
		default LEVEL_DIFF_XP_MOD = 0.16f;
		default MAX_XP_MOD = 1.5f;
		default DEVIL_HORSE_AURA_MIN_DELAY = 2;
		default DEVIL_HORSE_AURA_MAX_DELAY = 6;
		default TOTAL_AMOUNT_OF_BOOKS = 130;
		
	//Initializes all the global consts
	public function Init()
	{
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('global_params');
				
		//forbidden stats attributes
		InitForbiddenAttributesList();
		
		SetWeaponDurabilityModifiers();
		
		SetArmorDurabilityModifiers();
			
		// Abilities for masterwork and magical items
		InitArmorAbilities();
		InitGlovesAbilities();
		InitPantsAbilities();
		InitBootsAbilities();
		InitWeaponAbilities();
		
		//interactive repairing objects max durability caps
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS.Resize(5);
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[0] = 70;		//70% max for normal items
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[1] = 50;		//magic items
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[2] = 0;		//rare items
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[3] = 0;		//relics cannot be repaired
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[4] = 0;		//witcher sets
		
		newGamePlusLevel = FactsQuerySum("FinalNewGamePlusLevel");
	}
	
	private final function SetWeaponDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		//easy
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		//medium
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		//hard
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		//hardcore
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsWeapon.PushBack(dur);
	}
	
	private final function SetArmorDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		//easy
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		//medium
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		//hard
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		//hardcore
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsArmor.PushBack(dur);
	}
	
	public final function GetWeaponDurabilityLoseValue() : float
	{
		if(theGame.GetDifficultyMode() == EDM_Hardcore)
			return DURABILITY_WEAPON_LOSE_VALUE_HARDCORE;
		else
			return DURABILITY_WEAPON_LOSE_VALUE;		
	}
	
	private function InitArmorAbilities()
	{
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_SlashingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_PiercingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BludgeoningResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_RendingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_ElementalResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_Vitality');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitGlovesAbilities()
	{
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AttackPowerMult');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_CriticalChance');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_CriticalDamage');
	}
	
	private function InitPantsAbilities()
	{
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_SlashingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_PiercingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BludgeoningResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_RendingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_ElementalResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		PANTS_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_Vitality');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_StaminaRegeneration');
	}
	
	private function InitBootsAbilities()
	{
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_Armor');
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_PoisonResistance');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_BleedingResistance');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_StaminaRegeneration');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
	}
	
	private function InitWeaponAbilities()
	{
		//WEAPON_MASTERWORK_ABILITIES.PushBack('MA_AttackPowerAdd');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_ArmorPenetration');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_CriticalChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_CriticalDamage');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BleedingChance');
		
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AdrenalineGain');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_PoisonChance');
		
	}
	
	//all stats that have their own getters cannot be gotten using GetAttriubute function!
	private function InitForbiddenAttributesList()
	{
		var i,size : int;
	
		size = EnumGetMax('EBaseCharacterStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(StatEnumToName(i));
			
		size = EnumGetMax('ECharacterDefenseStats')+1;
		for(i=0; i<size; i+=1)
		{
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, true));
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, false));
		}
			
		size = EnumGetMax('ECharacterPowerStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(PowerStatEnumToName(i));
	}
	
	public function IsForbiddenAttribute(nam : name) : bool
	{
		if(!IsNameValid(nam))
			return true;
		
		return forbiddenAttributes.Contains(nam);
	}
	
	// gets durability bonus multiplier for given durability ratio
	public function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
	{
		if(isWeapon)
			return GetDurMult(durabilityRatio, durabilityThresholdsWeapon);
		else
			return GetDurMult(durabilityRatio, durabilityThresholdsArmor);
	}
	
	private function GetDurMult(durabilityRatio : float, durs : array<SDurabilityThreshold>) : float
	{
		var i : int;
		var currDiff : EDifficultyMode;
	
		currDiff = theGame.GetDifficultyMode();
		
		for(i=durs.Size()-1; i>=0; i-=1)
		{
			if(durs[i].difficulty == currDiff)			
				if(durabilityRatio <= durs[i].thresholdMax)
					return durs[i].multiplier;
		}
		
		return durs[0].multiplier;
	}
	
	// get one random ability of a specific type
	public function GetRandomMasterworkArmorAbility() : name
	{
		return ARMOR_MASTERWORK_ABILITIES[RandRange(ARMOR_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalArmorAbility() : name
	{
		return ARMOR_MAGICAL_ABILITIES[RandRange(ARMOR_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_ABILITIES[RandRange(GLOVES_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalGlovesAbility() : name
	{
		return GLOVES_MAGICAL_ABILITIES[RandRange(GLOVES_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkPantsAbility() : name
	{
		return PANTS_MASTERWORK_ABILITIES[RandRange(PANTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalPantsAbility() : name
	{
		return PANTS_MAGICAL_ABILITIES[RandRange(PANTS_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkBootsAbility() : name
	{
		return BOOTS_MASTERWORK_ABILITIES[RandRange(BOOTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalBootsAbility() : name
	{
		return BOOTS_MAGICAL_ABILITIES[RandRange(BOOTS_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkWeaponAbility() : name
	{
		return WEAPON_MASTERWORK_ABILITIES[RandRange(WEAPON_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalWeaponAbility() : name
	{
		return WEAPON_MAGICAL_ABILITIES[RandRange(WEAPON_MAGICAL_ABILITIES.Size())];
	}
	
	//returns cost and delay attributes' names for given stamina action type
	public function GetStaminaActionAttributes(action : EStaminaActionType, getCostPerSec : bool, out costAttributeName : name, out delayAttributeName : name)
	{		
		switch(action)
		{
			case ESAT_LightAttack :
				costAttributeName = STAMINA_COST_LIGHT_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_SuperHeavyAttack :
				costAttributeName = STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_LightSpecial :
				costAttributeName = STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_Parry :
				costAttributeName = STAMINA_COST_PARRY_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_PARRY_ATTRIBUTE;
				return;
			case ESAT_Counterattack :
				costAttributeName = STAMINA_COST_COUNTERATTACK_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE;
				return;
			case ESAT_Dodge :
				costAttributeName = STAMINA_COST_DODGE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_DODGE_ATTRIBUTE;
				return;
			case ESAT_Roll :
				costAttributeName = STAMINA_COST_ROLL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_ROLL_ATTRIBUTE;
				return;
			case ESAT_Evade :
				costAttributeName = STAMINA_COST_EVADE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_EVADE_ATTRIBUTE;
				return;
			case ESAT_Swimming :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SWIMMING_ATTRIBUTE;
				return;
			case ESAT_Sprint :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE;
				}
				else
				{
					costAttributeName = STAMINA_COST_SPRINT_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SPRINT_ATTRIBUTE;
				return;
			case ESAT_Jump :
				costAttributeName = STAMINA_COST_JUMP_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_JUMP_ATTRIBUTE;
				return;
			case ESAT_UsableItem :
				costAttributeName = STAMINA_COST_USABLE_ITEM_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE;
				return;
			case ESAT_Ability :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_PER_SEC_DEFAULT;
				}
				else
				{
					costAttributeName = STAMINA_COST_DEFAULT;
				}
				delayAttributeName = STAMINA_DELAY_DEFAULT;
				return;
			default :
				LogAssert(false, "W3GameParams.GetStaminaActionAttributes : unknown stamina action type <<" + action + ">> !!");
				return;
		}		
	}	
	    
  	public function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name) : int
	{
		var stat : SAbilityAttributeValue;
		var stat_f : float;
		var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
		var stat_min, stat_add : float;
		var level : int;
	
		if ( itemCategory == 'armor' )
		{
				stat_min = 25;
				stat_add = 5;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'boots' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'gloves' )
		{
				stat_min = 1;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'pants' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'silversword' )
		{
				stat_min = 90;
				stat_add = 10;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'steelsword' )
		{
				stat_min = 25;
				stat_add = 8;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat7 = itemAttributes[6];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1) + (stat7.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'bolt' )
		{
			if ( itemName == 'Tracking Bolt' ) { level = 2; } else
			if ( itemName == 'Bait Bolt' ) { level = 2; }  else
			if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
			if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
			if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
			if ( itemName == 'Split Bolt' ) { level = 15; }  else
			if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 5; }  else
			if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
			if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
			if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
			if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 
		} else
		if ( itemCategory == 'crossbow' )
		{
			stat = itemAttributes[0];
			level = 1;
			if ( stat.valueMultiplicative > 1.01 ) level = 2;
			if ( stat.valueMultiplicative > 1.1 ) level = 4;
			if ( stat.valueMultiplicative > 1.2 ) level = 8;
			if ( stat.valueMultiplicative > 1.3 ) level = 11;
			if ( stat.valueMultiplicative > 1.4 ) level = 15;
			if ( stat.valueMultiplicative > 1.5 ) level = 19;
			if ( stat.valueMultiplicative > 1.6 ) level = 22;
			if ( stat.valueMultiplicative > 1.7 ) level = 25;
			if ( stat.valueMultiplicative > 1.8 ) level = 27;
			if ( stat.valueMultiplicative > 1.9 ) level = 32;
		} 
		level = level - 1;
		if ( level < 1 ) level = 1;	if ( level > GetWitcherPlayer().GetMaxLevel() ) level = GetWitcherPlayer().GetMaxLevel();
		
		return level;
	}
	
	public final function SetNewGamePlusLevel(playerLevel : int)
	{
		if ( playerLevel > NEW_GAME_PLUS_MIN_LEVEL )
		{
			newGamePlusLevel = playerLevel;
		}
		else
		{
			newGamePlusLevel = NEW_GAME_PLUS_MIN_LEVEL;
		}
			
		FactsAdd("FinalNewGamePlusLevel", newGamePlusLevel);
	}
	
	public final function GetNewGamePlusLevel() : int
	{
		return newGamePlusLevel;
	}
	public final function NewGamePlusLevelDifference() : int
	{
		return ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL );
	}
}
