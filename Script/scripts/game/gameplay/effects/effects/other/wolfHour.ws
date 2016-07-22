class W3Effect_WolfHour extends CBaseGameplayEffect
{
	default effectType = EET_WolfHour;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAddedPost()
	{
		var invMenu : CR4InventoryMenu;
		
		super.OnEffectAddedPost();
		
		invMenu = (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
		if(invMenu)
		{
			invMenu.PopulateTabData(InventoryMenuTab_Weapons);
		}
	}
}