abstract class W3CommonContainerInventoryComponent extends W3GuiBaseInventoryComponent
{
	//protected var _dpContainer : W3ContainerDataProvider; // #B deprecated

	public function GiveAllItems( receiver : W3GuiBaseInventoryComponent )
	{
		// Just get an array of item ids from flash (but then flash would need to convert and send an array... on top of everything else).
	// TBD: Consider caching the item ids after filtering, or flash giving us an array of items
		
		/*
		for ( i = 0; i < items.Size(); i += 1 )
		{		
			item = rawItems[i];
			
			if ( ShouldShowItem( item ) )
			{
				GiveItem( item, receiver );
			}
		}
		*/
	}
		
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool) : EInventoryActionType
	{
		return IAT_Transfer;
	}	

	public function HideAllItems( ) : void // #B
	{
		var i : int;
		var item : SItemUniqueId;
		var rawItems : array< SItemUniqueId >;
		var itemTags : array<name>;
		
		_inv.GetAllItems( rawItems );
		
		for ( i = 0; i < rawItems.Size(); i += 1 )
		{		
			item = rawItems[i];
			itemTags.Clear();
			_inv.GetItemTags( item, itemTags );
		
			if ( !itemTags.Contains( 'NoShowInContainer' ) )
			{
				_inv.AddItemTag(item,'NoShowInContainer');
			}
		}
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		var itemTags : array<name>;
		
		_inv.GetItemTags( item, itemTags );
		
		// Automatically exclude
		if ( itemTags.Contains( 'NoShowInContainer' ) )
		{
			return false;
		}
		
		return super.ShouldShowItem( item );
	}
}

class W3GuiTakeOnlyContainerInventoryComponent extends W3CommonContainerInventoryComponent
{	
	public function ReceiveItem( item : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional newItemID : SItemUniqueId ) : bool
	{
//		LogError( "W3GuiContainerInventoryComponent::ReceiveItem: Can't give an item to a container! Item name=" + giver._inv.GetItemName( item ) );
		return false;
	}
}

//--------------------------------------------------------------------------------------------------------

class W3GuiContainerInventoryComponent extends W3CommonContainerInventoryComponent // #B deprecated
{
	public var dontShowEquipped:bool; default dontShowEquipped = false;
	
	public function ReceiveItem( item : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional newItemID : SItemUniqueId  ) : bool //#B
	{
		var invalidatedItems, newIds : array< SItemUniqueId >;
		var newItem : SItemUniqueId;
		var success: bool;
		var itemName : name;
		//var itemQuantity : int;
		if( quantity  < 1 )
		{
			quantity = 1;
		}
		success = false;
		itemName = giver._inv.GetItemName(item);
		//quantity = giver._inv.GetItemQuantity(item);
		giver._inv.RemoveItem(item,quantity); //#B FIXME - item quantity
		newIds = _inv.AddAnItem(itemName,quantity,true,true);
		newItem = newIds[0];
		if ( newItem != GetInvalidUniqueId() )
		{
			success = true;
		}
		
		return success;
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		if (dontShowEquipped)
		{
			if (isHorseItem(item))
			{
				if (GetWitcherPlayer().GetHorseManager().IsItemEquipped(item))
				{
					return false;
				}
			}
			else
			{
				if ( _inv == GetWitcherPlayer().GetInventory() && GetWitcherPlayer().IsItemEquipped(item))
				{
					return false;
				}
			}
		}
		
		return super.ShouldShowItem( item );
	}
	
	protected function GridPositionEnabled() : bool
	{
		return false;
	}
}

//--------------------------------------------------------------------------------------------------------
