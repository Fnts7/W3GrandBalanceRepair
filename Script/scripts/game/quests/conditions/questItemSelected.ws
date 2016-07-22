/***********************************************************************/
/** Witcher script file
/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_ItemSelected extends CQuestScriptedCondition
{
	editable var itemName : name;
	
	function Evaluate() : bool
	{
		var id : SItemUniqueId;
		
		id = thePlayer.GetSelectedItemId();
		
		//any item
		if(itemName == '')
		{			
			return thePlayer.inv.IsIdValid(id);
		}
		else
		{
			return itemName == thePlayer.inv.GetItemName(id);
		}
	}
}