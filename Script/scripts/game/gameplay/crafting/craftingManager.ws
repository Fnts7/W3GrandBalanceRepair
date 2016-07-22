/***********************************************************************/
/** Copyright © 2012-2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Class handles the crafting process. In order to craft an item we must visit
	a craftsman of proper type (e.g. weaponsmith) and level (e.g. grand master).
	We must also have a proper schematic.
	
	In general, items used to craft an item add their craft bonus abilities to
	the item.
*/
class W3CraftingManager
{
	protected var schematics : array<SCraftingSchematic>;		//schematics known to player
	protected var craftMasterComp : W3CraftsmanComponent;		//crafting NPC component, holds crafter data
	
	/**
		Initializes crafting - must be called!
	*/
	public function Init( masterComp : W3CraftsmanComponent )
	{
		craftMasterComp = masterComp;
		LoadSchematicsXMLData( GetWitcherPlayer().GetCraftingSchematicsNames() );
	}
	
	// Caches recipes' data from XML for given recipes
	protected function LoadSchematicsXMLData( schematicsNames : array<name> ) : void
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName : name;
		var tmpInt : int;
		var schem : SCraftingSchematic;
		var i,j,k : int;
		var ing : SItemParts;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('crafting_schematics');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			
			for(j=0; j<schematicsNames.Size(); j+=1)
			{
				if(tmpName == schematicsNames[j])
				{
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftedItem_name', tmpName))
						schem.craftedItemName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanType_name', tmpName))
						schem.requiredCraftsmanType = ParseCraftsmanTypeStringToEnum(tmpName);
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'craftedItemQuantity', tmpInt))
						schem.craftedItemCount = tmpInt;
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanLevel_name', tmpName))
						schem.requiredCraftsmanLevel = ParseCraftsmanLevelStringToEnum(tmpName);
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
						schem.baseCraftingPrice = tmpInt;	
					
					//ingredients
					ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
					for(k=0; k<ingredients.subNodes.Size(); k+=1)
					{		
						ing.itemName = '';
						ing.quantity = -1;
					
						if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
							ing.itemName = tmpName;
						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
							ing.quantity = tmpInt;
							
						schem.ingredients.PushBack(ing);						
					}
					
					schem.schemName = schematicsNames[j];
					
					schematics.PushBack(schem);		

					//clear
					schem.baseCraftingPrice = -1;
					schem.craftedItemName = '';
					schem.ingredients.Clear();
					schem.requiredCraftsmanLevel = ECL_Undefined;
					schem.requiredCraftsmanType = ECT_Undefined;
					schem.schemName = '';
					schem.craftedItemCount = 0;
					break;
				}
			}
		}
	}
		
	/**
		Checks for potential crafting errors (eg. not enough gold) and sets the out error string when necessary
	*/
	public function CanCraftSchematic(schematicName : name, checkMerchant : bool) : ECraftingException
	{
		var schem : SCraftingSchematic;
		var i, cnt : int;
			
		GetSchematic(schematicName, schem);
		
		if (checkMerchant)
		{
			if ( !GetSchematic( schematicName, schem ) )
			{
				return ECE_UnknownSchematic;
			}

			if ( !craftMasterComp.IsCraftsmanType( schem.requiredCraftsmanType ) )
			{
				return ECE_WrongCraftsmanType;
			}

			if ( craftMasterComp.GetCraftsmanLevel( schem.requiredCraftsmanType ) < schem.requiredCraftsmanLevel )
			{
				return ECE_TooLowCraftsmanLevel;
			}
		}
		
		for(i=0; i<schem.ingredients.Size(); i+=1)
		{
			cnt = thePlayer.inv.GetItemQuantityByName(schem.ingredients[i].itemName);							
			if(cnt < schem.ingredients[i].quantity)
				return ECE_TooFewIngredients;
		}
		
		if (checkMerchant)
		{
			if(thePlayer.GetMoney() < GetCraftingCost(schematicName))
				return ECE_NotEnoughMoney;
		}
			
		return ECE_NoException;
	}
	
	//returns true if schematic was found at all
	public function GetSchematic(s : name, out ret : SCraftingSchematic) : bool
	{
		var i : int;
		
		for(i=0; i<schematics.Size(); i+=1)
		{
			if(schematics[i].schemName == s)
			{
				ret = schematics[i];
				return true;
			}
		}
		
		return false;
	}
		
	public function GetCraftingCost(schematic : name) : int
	{
		var schem : SCraftingSchematic;
	
		if ( GetSchematic(schematic, schem) )
		{
			return craftMasterComp.CalculateCostOfCrafting( schem.craftedItemName );
		}

		return -1;
	}

	//Crafts given schematic
	public function Craft(schemName : name, out item : SItemUniqueId) : ECraftingException
	{
		var error : ECraftingException;
		var i, j, size : int;
		var schem : SCraftingSchematic;
		var items, upgradeItem : array<SItemUniqueId>;
		var itemsingr : array<SItemUniqueId>;
		var equipAfterCrafting : bool;
		var tutStateSet : W3TutorialManagerUIHandlerStateCraftingSet;
		var craftsman : CGameplayEntity;
		var upgrades, temp : array<name>;
	
		error = CanCraftSchematic(schemName, true);
		if(error != ECE_NoException)
		{
			item = GetInvalidUniqueId();
			LogCrafting("Cannot craft schematic <<" + schemName + ">>. Exception is <<" + error + ">>");
			return error;
		}
			
		GetSchematic(schemName, schem);
		
		//take money
		craftsman = (CGameplayEntity)craftMasterComp.GetEntity();
		thePlayer.inv.GiveMoneyTo(craftsman.GetInventory(), GetCraftingCost(schemName), false);
		
		//take ingredients
		equipAfterCrafting = false;
		for(i=0; i<schem.ingredients.Size(); i+=1)
		{
			itemsingr = thePlayer.inv.GetItemsByName( schem.ingredients[i].itemName );
			for(j=0; j<itemsingr.Size(); j+=1)
			{
				if ( thePlayer.inv.IsItemMounted( itemsingr[j] ) || thePlayer.inv.IsItemHeld( itemsingr[j] ) ) 
				{
					equipAfterCrafting = true;
				}
			}
			//store used socketable items
			thePlayer.inv.GetItemEnhancementItems(itemsingr[0], temp);
			ArrayOfNamesAppend(upgrades, temp);
			temp.Clear();
			
			thePlayer.inv.RemoveItemByName(schem.ingredients[i].itemName, schem.ingredients[i].quantity);
		}
		
		//add item
		items = thePlayer.inv.AddAnItem(schem.craftedItemName, schem.craftedItemCount);
		item = items[0];
		
		if ( equipAfterCrafting )
			thePlayer.EquipItem( item );
			
		//restore upgrtades in sockets
		size = Min(thePlayer.inv.GetItemEnhancementSlotsCount(item), upgrades.Size());	//amount of given upgrades is capped by how many new item can have
		for(i=0; i<size; i+=1)
		{
			upgradeItem = thePlayer.inv.AddAnItem(upgrades[i], 1, true, true);
			thePlayer.inv.EnhanceItemScript(item, upgradeItem[0]);
		}
		
		LogCrafting("Item <<" + schem.craftedItemName + ">> crafted successfully");
		
		if(thePlayer.inv.IsItemSetItem(item) && ShouldProcessTutorial('TutorialCraftingSets'))
		{
			tutStateSet = (W3TutorialManagerUIHandlerStateCraftingSet)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateSet)
			{
				tutStateSet.OnCraftedSetItem();
			}
		}
		
		return ECE_NoException;
	}
}

function getCraftingSchematicFromName(schematicName : name):SCraftingSchematic
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpName : name;
	var tmpInt : int;
	var schem : SCraftingSchematic;
	var i,k : int;
	var ing : SItemParts;
	var schematicsNames : array<name>;
					
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('crafting_schematics');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		if(tmpName == schematicName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftedItem_name', tmpName))
				schem.craftedItemName = tmpName;
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanType_name', tmpName))
				schem.requiredCraftsmanType = ParseCraftsmanTypeStringToEnum(tmpName);
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanLevel_name', tmpName))
				schem.requiredCraftsmanLevel = ParseCraftsmanLevelStringToEnum(tmpName);
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
				schem.baseCraftingPrice = tmpInt;	
			
			//ingredients
			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{		
				ing.itemName = '';
				ing.quantity = -1;
			
				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;
					
				schem.ingredients.PushBack(ing);						
			}
			
			schem.schemName = schematicName;
			
			
			break;
		}
	}
		
	return schem;
}

