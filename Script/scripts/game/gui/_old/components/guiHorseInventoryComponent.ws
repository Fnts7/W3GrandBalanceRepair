
// Used for horse paperdoll

class W3GuiHorseInventoryComponent extends W3GuiBaseInventoryComponent
{
	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		return isEquipped( item );
	}
	
	protected function isEquipped( item : SItemUniqueId ) : bool
	{
		var horseMgr : W3HorseManager;
		
		horseMgr = GetWitcherPlayer().GetHorseManager();
		if (horseMgr)
		{
			return horseMgr.IsItemEquipped(item);
		}
		return false;
	}
	
	protected function GetCurrentSlotForItem( item : SItemUniqueId ) : int
	{
		var horseMgr : W3HorseManager;
		
		horseMgr = GetWitcherPlayer().GetHorseManager();
		if (horseMgr)
		{
			return (int)horseMgr.GetHorseSlotForItem(item);
		}
		return -1;
	}
	
	function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var canDrop	 : bool;
		
		super.SetInventoryFlashObjectForItem( item, flashObject);
		
		canDrop = !_inv.ItemHasTag(item, 'Quest') && !_inv.ItemHasTag(item, 'NoDrop');
		flashObject.SetMemberFlashBool( "canDrop", canDrop );
		flashObject.SetMemberFlashInt( "groupId", EIG_HORSE);
	}
	
}