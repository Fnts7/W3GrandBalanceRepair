/***********************************************************************/
/** Copyright © 2014
/** Author : 
/***********************************************************************/

class W3Mutagen16_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen16;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		UpdateEncumbrance();
	}
	
	event OnEffectRemoved()
	{	
		super.OnEffectRemoved();
		
		//needs to be called after supper as encumbrance checks if we have this buff on character or not
		UpdateEncumbrance();
	}	
	
	private final function UpdateEncumbrance()
	{
		var invMenu : CR4InventoryMenu;
		
		if(isOnPlayer)
		{
			GetWitcherPlayer().UpdateEncumbrance();
			invMenu = (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
			if(invMenu)
				invMenu.UpdateEncumbranceInfo();
		}
	}
}