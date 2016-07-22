/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

//class that handles item upgrades
class W3ItemUpgradeManager
{
	private var upgrades : array<SItemUpgradeListElement>;						//list of all available upgrades to all items currently in inventory
	
	public function Init()
	{
		LoadXMLData();
	}
	
	//purchases given upgrade for given item. Returns error exception or EIUE_NoException if successfull
	public function PurchaseUpgrade(item : SItemUniqueId, upgradeName : name) : EItemUpgradeException
	{
		var check : EItemUpgradeException;
		var i, idx : int;
	
		//check first
		check = CanPurchaseUpgrade(item, upgradeName);
		if(check != EIUE_NoException)
			return check;
			
		idx = GetUpgradeIndex(item, upgradeName);
		
		//remove money
		thePlayer.RemoveMoney( upgrades[idx].upgrade.cost );
		
		//remove ingredients
		for(i=0; i<upgrades[idx].upgrade.ingredients.Size(); i+=1)
		{
			thePlayer.inv.RemoveItemByName(upgrades[idx].upgrade.ingredients[i].itemName, upgrades[idx].upgrade.ingredients[i].quantity);
		}
		
		//add ability
		thePlayer.inv.AddItemCraftedAbility(item, upgrades[idx].upgrade.ability);
		
		return EIUE_NoException;
	}
	
	private function GetUpgradeIndex(item : SItemUniqueId, upgradeName : name) : int
	{
		var i : int;
		
		for(i=0; i<upgrades.Size(); i+=1)
		{
			if(upgrades[i].upgrade.upgradeName == upgradeName && upgrades[i].itemId == item)
				return i;
		}
		return -1;
	}
	
	// Checks if given item can be upgraded with given upgrade. Returns exception type or EIUE_NoException if upgrade can be done
	public function CanPurchaseUpgrade(item : SItemUniqueId, upgradeName : name) : EItemUpgradeException
	{
		var i, j, idx, cnt : int;
		var upg : SItemUpgrade;
		var requiredName, requiredAbilityName : name;
	
		//check item
		if(!thePlayer.inv.IsItemUpgradeable(item))
			return EIUE_ItemNotUpgradeable;
		
		//check upg
		idx = GetUpgradeIndex(item, upgradeName);
				
		if(idx < 0)
			return EIUE_NoSuchUpgradeForItem;
		
		upg = upgrades[idx].upgrade;
		
		//check money
		if(thePlayer.GetMoney() < upg.cost)
			return EIUE_NotEnoughGold;
			
		//check ingredients
		for(i=0; i<upg.ingredients.Size(); i+=1)
		{
			cnt = thePlayer.inv.GetItemQuantityByName(upg.ingredients[i].itemName);
			if(cnt <= 0)
				return EIUE_MissingIngredient;
			else if(cnt < upg.ingredients[i].quantity)
				return EIUE_NotEnoughIngredient;
		}
		
		//missing required upgrades
		for(i=0; i<upg.requiredUpgrades.Size(); i+=1)
		{
			//get required upgrade name
			requiredName = upg.requiredUpgrades[i];
			
			//get required upgrade's given ability
			requiredAbilityName = '';
			for(j=0; j<upgrades.Size(); j+=1)
			{
				if(upgrades[j].itemId == item && upgrades[j].upgrade.upgradeName == requiredName)
				{
					requiredAbilityName = upgrades[j].upgrade.ability;
					break;
				}
			}
			
			//check if item has this ability
			if(IsNameValid(requiredAbilityName))
			{
				if(!thePlayer.inv.ItemHasAbility(item, requiredAbilityName))
					return EIUE_MissingRequiredUpgrades;
			}
		}
		
		//check if this upgrade is already purchased
		if(thePlayer.inv.ItemHasAbility(item, upg.ability))
			return EIUE_AlreadyPurchased;
			
		//all ok
		return EIUE_NoException;
	}

	private function LoadXMLData()
	{
		var items : array<SItemUniqueId>;
		var i,j,k,m,tmpInt : int;
		var tmpName, upgradesListName : name;
		var tmpString : string;
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients, requirements : SCustomNode;
		var upgradesDefs : array< SCustomNode >;
		var ing : SItemParts;
		var upgradeElement : SItemUpgradeListElement;		
		
		thePlayer.inv.GetAllItems(items);
		
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if(!thePlayer.inv.IsItemUpgradeable(items[i]))
				items.Erase(i);
		}
		
		//no upgradeable items
		if(items.Size() <= 0)
			return;
			
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('upgrades_lists');
		
		for(j=0; j<items.Size(); j+=1)
		{
			upgradesListName = dm.GetItemUpgradeListName(thePlayer.inv.GetItemName(items[j]), true);
			
			if(!IsNameValid(upgradesListName))
			{
				LogAssert(false, "W3ItemUpgradeManager.LoadXMLData: item <<" + thePlayer.inv.GetItemName(items[j]) + ">> has non-valid upgrades list name <<" + upgradesListName + ">>");
				continue;
			}
			
			for(i=0; i<main.subNodes.Size(); i+=1)
			{
				dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
				if(tmpName != upgradesListName)
					continue;
				
				upgradesDefs = main.subNodes[i].subNodes;
				for(k=0; k<upgradesDefs.Size(); k+=1)
				{
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'name_name', tmpName))
						upgradeElement.upgrade.upgradeName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'localizedName_name', tmpName))
						upgradeElement.upgrade.localizedName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'localizedDescription_name', tmpName))
						upgradeElement.upgrade.localizedDescriptionName = tmpName;
					if(dm.GetCustomNodeAttributeValueInt(upgradesDefs[k], 'cost', tmpInt))
						upgradeElement.upgrade.cost = tmpInt;
					if(dm.GetCustomNodeAttributeValueString(upgradesDefs[k], 'icon', tmpString))
						upgradeElement.upgrade.iconPath = tmpString;
					if(dm.GetCustomNodeAttributeValueName(upgradesDefs[k], 'ability_name', tmpName))
						upgradeElement.upgrade.ability = tmpName;
					
					//ingredients
					ingredients = dm.GetCustomDefinitionSubNode(upgradesDefs[k],'ingredients');					
					for(m=0; m<ingredients.subNodes.Size(); m+=1)
					{	
						if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[m], 'name_name', tmpName))
							ing.itemName = tmpName;
						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[m], 'quantity', tmpInt))
							ing.quantity = tmpInt;
							
						upgradeElement.upgrade.ingredients.PushBack(ing);
						ing.itemName = '';
						ing.quantity = 0;
					}
					
					//requirements
					requirements = dm.GetCustomDefinitionSubNode(upgradesDefs[k],'required_upgrades');					
					for(m=0; m<requirements.values.Size(); m+=1)
					{
						if(IsNameValid(requirements.values[m]))
							upgradeElement.upgrade.requiredUpgrades.PushBack(requirements.values[m]);
						else
							LogAssert(false, "W3ItemUpgradeManager.LoadXMLData: found not valid (non-name) required upgrade <<" + requirements.values[m] + ">>!!");
					}
					
					upgradeElement.itemId = items[j];
					
					upgrades.PushBack(upgradeElement);
					
					upgradeElement.itemId = GetInvalidUniqueId();
					upgradeElement.upgrade.upgradeName = '';
					upgradeElement.upgrade.localizedName = '';
					upgradeElement.upgrade.localizedDescriptionName = '';
					upgradeElement.upgrade.cost = 0;
					upgradeElement.upgrade.iconPath = "";
					upgradeElement.upgrade.ability = '';
					upgradeElement.upgrade.ingredients.Clear();
					upgradeElement.upgrade.requiredUpgrades.Clear();
				}
			}
		}
	}
}