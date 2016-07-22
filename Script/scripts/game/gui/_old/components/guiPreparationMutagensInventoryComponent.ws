class W3GuiPreparationMutagensInventoryComponent extends W3GuiPlayerInventoryComponent
{	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var bShow : bool;
		var itemName : name;
		itemName = _inv.GetItemName(item);
		bShow = _inv.ItemHasTag( item, 'Mutagen');
		
		return bShow;
	}
}