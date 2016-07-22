class W3GuiSelectItemComponent extends W3GuiPlayerInventoryComponent
{

	public /* override */ function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByUniqueID(item)) );
		flashObject.SetMemberFlashBool( "isNew", false ); // ignore 
	}
}