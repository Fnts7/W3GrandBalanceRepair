class W3GuiPreparationPotionsAndBombsInventoryComponent extends W3GuiPlayerInventoryComponent
{	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var bShow : bool;
		var itemName : name;
		itemName = _inv.GetItemName(item);
		
		if( _inv.IsItemQuickslotItem(item) ) // #B shuld be isPetards or isBombs
		{
			bShow = true;
		}
		else
		{
			bShow = isPotionItem( item );
		}
		
		return bShow;
	}
}