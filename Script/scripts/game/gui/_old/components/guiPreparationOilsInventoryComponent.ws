class W3GuiPreparationOilsInventoryComponent extends W3GuiPlayerInventoryComponent
{	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var bShow : bool;
		var itemName : name;
		itemName = _inv.GetItemName(item);
		return isOilItem(item);
	}
}