/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

// types of craftsmen
enum ECraftsmanType
{
	ECT_Undefined,
	ECT_Smith,
    ECT_Armorer,
    ECT_Crafter,
	ECT_Enchanter
}

enum ECraftingException
{
	ECE_NoException,
	ECE_TooLowCraftsmanLevel,
	ECE_MissingIngredient,
	ECE_TooFewIngredients,
	ECE_WrongCraftsmanType,
	ECE_NotEnoughMoney,
	ECE_UnknownSchematic,
	ECE_CookNotAllowed
}

struct SCraftable
{
	var type : name;
	var cnt : int;
};

function CraftingExceptionToString( result : ECraftingException ) : string
{
	switch ( result )
	{
		case ECE_NoException:			return "panel_crafting_craft_item";
		case ECE_TooLowCraftsmanLevel:	return "panel_crafting_exception_too_low_craftsman_level";
		case ECE_MissingIngredient:		return "panel_crafting_exception_missing_ingridient";
		case ECE_TooFewIngredients:		return "panel_crafting_exception_missing_ingridients";
		case ECE_WrongCraftsmanType:	return "panel_crafting_exception_wrong_craftsman_type";
		case ECE_NotEnoughMoney:		return "panel_crafting_exception_not_enough_money";
		case ECE_UnknownSchematic:		return "panel_crafting_exception_unknown_schematic";
		case ECE_CookNotAllowed:		return "panel_crafting_exception_cook_not_allowed";
	}
	return "";
}

// Struct for holding crafted attribute
struct SCraftAttribute{
	var attributeName : name;		//attribute name
	var valAdditive : float;		//additive value
	var valMultiplicative : float;	//multiplicative value
	var displayPercMul : bool;		//should the mul value be displayed
	var displayPercAdd : bool;		//should the add value be displayed
};

//must be added by ascending levels (requirement checking)
enum ECraftsmanLevel
{
	ECL_Undefined,
	ECL_Journeyman,
	ECL_Master,
	ECL_Grand_Master,
	ECL_Arch_Master
}

function ParseCraftsmanTypeStringToEnum(s : string) : ECraftsmanType
{
	switch(s)
	{
		case "Crafter" 	: return ECT_Crafter;
		case "Smith" 	: return ECT_Smith;
		case "Armorer" 	: return ECT_Armorer;
		case "Armourer"	: return ECT_Armorer; // TBD - Remove
		case "Enchanter": return ECT_Enchanter; // TBD - Unused
	}

	return ECT_Undefined;
}

function ParseCraftsmanLevelStringToEnum(s : string) : ECraftsmanLevel
{
	switch(s)
	{
		case "Journeyman" : return ECL_Journeyman;
		case "Master" : return ECL_Master;
		case "Grand Master" : return ECL_Grand_Master;
		case "Arch Master" : return ECL_Arch_Master;
	}
	
	return ECL_Undefined;
}

function CraftsmanTypeToLocalizationKey(type : ECraftsmanType) : string
{
	switch( type )
	{
		case ECT_Crafter : return "map_location_craftman";
		case ECT_Smith : return "map_location_blacksmith";
		case ECT_Armorer : return "Armorer";
		case ECT_Enchanter : return "map_location_alchemic";
		default: return "map_location_craftman";
	}
	return "map_location_craftman";
}

function CraftsmanLevelToLocalizationKey(type : ECraftsmanLevel) : string
{
	switch( type )
	{
		case ECL_Journeyman : return "panel_shop_crating_level_journeyman";
		case ECL_Master : return "panel_shop_crating_level_master";
		case ECL_Grand_Master: return "panel_shop_crating_level_grand_master";
		case ECL_Arch_Master: return "panel_shop_crating_level_arch_master";
		default: return "";
	}
	return "";
}

// Class representing schematics. Because it's a class we pass it by reference instead of by value.
struct SCraftingSchematic
{
	var craftedItemName			: name;					//name of the crafted item
	var craftedItemCount 		: int;					//amount of items crafted
	var requiredCraftsmanType	: ECraftsmanType;		//required type of craftsman
	var requiredCraftsmanLevel	: ECraftsmanLevel;		//required level of craftsman
	var baseCraftingPrice		: int;					//base price of crafting
	var ingredients				: array<SItemParts>;	//required ingredients
	var schemName				: name;					//name of schematic	
};

struct SEnchantmentSchematic
{
	var schemName				 : name;				//name of schematic	
	var baseCraftingPrice		 : int;					//base price of crafting
	var level					 : int;					//enchantment level
	var ingredients				 : array<SItemParts>;	//required ingredients
	var localizedName 			 : name;
	var localizedDescriptionName : string;
};

struct SItemUpgradeListElement
{
	var itemId : SItemUniqueId;
	var upgrade : SItemUpgrade;
};

struct SItemUpgrade
{
	var upgradeName : name;						//upgrade name
	var localizedName : name;					//localization key for upgrade name
	var localizedDescriptionName : name;		//localization key for upgrade description
	var cost : int;								//gold upgrade cost
	var iconPath : string;						//string with path to icon
	var ability : name;							//name of the ability added to item when the upgrade is purchased
	var ingredients : array<SItemParts>;		//array of ingredients
	var requiredUpgrades : array<name>;			//array of required prerequisite upgrades
};

enum EItemUpgradeException
{
	EIUE_NoException,
	EIUE_NotEnoughGold,
	EIUE_MissingIngredient,
	EIUE_NotEnoughIngredient,
	EIUE_MissingRequiredUpgrades,
	EIUE_AlreadyPurchased,
	EIUE_ItemNotUpgradeable,
	EIUE_NoSuchUpgradeForItem
}


function IsCraftingSchematic(recipeName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var i : int;

	if(!IsNameValid(recipeName))
		return false;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		if ( dm.GetSubNodeByAttributeValueAsCName( main.subNodes[i], 'crafting_schematics', 'name_name', recipeName ) && recipeName == recipeName )
		{
			return true;
		}
	}
	
	return false;
}

function getEnchamtmentStatName(enchantmentName:name):name
{
	switch (enchantmentName)
	{
		case 'Runeword 1':
			return 'Runeword 1 _Stats';
			break;
		case 'Runeword 2':
			return 'Runeword 2 _Stats';
			break;
		case 'Runeword 4':
			return 'Runeword 4 _Stats';
			break;
		case 'Runeword 5':
			return 'Runeword 5 _Stats';
			break;
		case 'Runeword 6':
			return 'Runeword 6 _Stats';
			break;
		case 'Runeword 7':
			return 'Runeword 7 _Stats';
			break;
		case 'Runeword 8':
			return 'Runeword 8 _Stats';
			break;
		case 'Runeword 10':
			return 'Runeword 10 _Stats';
			break;
			
		case 'Runeword 11':
			return 'Runeword 11 _Stats';
			break;
		case 'Runeword 12':
			return 'Runeword 12 _Stats';
			break;
		case 'Runeword 13':
			return 'Runeword 13 _Stats';
			break;
		case 'Runeword 14':
			return 'Runeword 14 _Stats';
			break;
		case 'Runeword 15':
			return 'Runeword 15 _Stats';
			break;
		case 'Runeword 16':
			return 'Runeword 16 _Stats';
			break;
		case 'Runeword 17':
			return 'Runeword 17 _Stats';
			break;
		case 'Runeword 18':
			return 'Runeword 18 _Stats';
			break;
		case 'Runeword 19':
			return 'Runeword 19 _Stats';
			break;
		case 'Runeword 20':
			return 'Runeword 20 _Stats';
			break;
			
		case 'Glyphword 1':
			return 'Glyphword 1 _Stats';
			break;
		case 'Glyphword 2':
			return 'Glyphword 2 _Stats';
			break;
		case 'Glyphword 3':
			return 'Glyphword 3 _Stats';
			break;
		case 'Glyphword 4':
			return 'Glyphword 4 _Stats';
			break;
		case 'Glyphword 5':
			return 'Glyphword 5 _Stats';
			break;
		case 'Glyphword 6':
			return 'Glyphword 6 _Stats';
			break;
		case 'Glyphword 7':
			return 'Glyphword 7 _Stats';
			break;
		case 'Glyphword 8':
			return 'Glyphword 8 _Stats';
			break;
		case 'Glyphword 9':
			return 'Glyphword 9 _Stats';
			break;
		case 'Glyphword 10':
			return 'Glyphword 10 _Stats';
			break;
			
		case 'Glyphword 11':
			return 'Glyphword 11 _Stats';
			break;
		case 'Glyphword 12':
			return 'Glyphword 12 _Stats';
			break;
		case 'Glyphword 13':
			return 'Glyphword 13 _Stats';
			break;
		case 'Glyphword 14':
			return 'Glyphword 14 _Stats';
			break;
		case 'Glyphword 15':
			return 'Glyphword 15 _Stats';
			break;
		case 'Glyphword 16':
			return 'Glyphword 16 _Stats';
			break;
		case 'Glyphword 17':
			return 'Glyphword 17 _Stats';
			break;
		case 'Glyphword 18':
			return 'Glyphword 18 _Stats';
			break;
		case 'Glyphword 20':
			return 'Glyphword 20 _Stats';
			break;
		
		default:
			break;
	}
	return '';
}

function GetAllRunewordSchematics():array< CName >
{
	var resultList  : array< CName >;
	
	resultList.PushBack( 'Runeword 5' );
	resultList.PushBack( 'Runeword 6' );
	resultList.PushBack( 'Runeword 8' );
	resultList.PushBack( 'Runeword 9' );
	
	resultList.PushBack( 'Glyphword 1' );
	resultList.PushBack( 'Glyphword 10' );
	resultList.PushBack( 'Glyphword 12' );
	resultList.PushBack( 'Glyphword 4' );
	resultList.PushBack( 'Glyphword 6' );
	
	resultList.PushBack( 'Runeword 2' );
	resultList.PushBack( 'Runeword 10' );
	resultList.PushBack( 'Runeword 11' );
	resultList.PushBack( 'Runeword 12' );
	
	resultList.PushBack( 'Glyphword 3' );
	resultList.PushBack( 'Glyphword 7' );
	resultList.PushBack( 'Glyphword 14' );
	resultList.PushBack( 'Glyphword 15' );
	resultList.PushBack( 'Glyphword 17' );
	
	resultList.PushBack( 'Runeword 1' );
	resultList.PushBack( 'Runeword 3' );
	resultList.PushBack( 'Runeword 4' );
	
	resultList.PushBack( 'Glyphword 2' );
	resultList.PushBack( 'Glyphword 5' );
	resultList.PushBack( 'Glyphword 18' );
	resultList.PushBack( 'Glyphword 19' );
	resultList.PushBack( 'Glyphword 20' );
	
	return resultList;
}