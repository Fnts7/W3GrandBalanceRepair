/***********************************************************************/
/** Copyright © 2015
/** Authors : Danisz Markiewicz
/***********************************************************************/

class W3ArmorStand extends W3HouseDecorationBase
{
	private editable var m_mountAllItems : bool;
	
	hint m_mountAllItems = "Should this stand mount all items, not only armor.";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		ChangeItemSelectionMode( EISPM_ArmorStand );
		
		//We don't want invisible or body items to be considered
		AddItemSelectionForbiddenFilterTag( 'NoShow' );	
		AddItemSelectionForbiddenFilterTag( 'Body' );	
		
		//Sets categories of items that need to be processed
		AddItemSelectionCategory( 'armor' );
		AddItemSelectionCategory( 'pants' );
		AddItemSelectionCategory( 'gloves' );			
		AddItemSelectionCategory( 'boots' );
		
	}

	//Performs operations upon receiving an item
	public function ProcessItemReceival( optional mute : bool )
	{
		super.ProcessItemReceival();
		ProcessItemMounting( !mute );
	}
	
	//Mounts items based on stand setup
	private function ProcessItemMounting( optional playSound : bool )
	{
		if( m_mountAllItems )
		{
			MountAllStandItems( playSound );
		}
		else
		{
			MountArmorItem( playSound );
		}	
	}
	
	//Mount first (only) armor item from entity's inventory
	private function MountArmorItem( playSound : bool )
	{
		var items : array<SItemUniqueId>;
		var invComp : CInventoryComponent;

		invComp = GetInventory();
		
		if ( invComp )
		{
			items = invComp.GetItemsByCategory( 'armor' );
				
			if( invComp.MountItem( items[0], false, true ) )
			{
				if( playSound )
				{
					theSound.SoundEvent("gui_inventory_armor_back");
				}
			}
		}
	}

	// Mount all items
	private function MountAllStandItems( playSound : bool )
	{
		var items : array<SItemUniqueId>;
		var i : int;
		var itemWasMounted : bool;
		var invComp : CInventoryComponent;

		invComp = GetInventory();
		
		if ( invComp )
		{
			invComp.GetAllItems( items );
		
			for( i=0; i < items.Size(); i+= 1 )
			{
				if( invComp.MountItem( items[i], false, true ) )
				{
					itemWasMounted = true;
				}
			}
		}

		//If any item was mounted play sound event
		if( itemWasMounted && playSound )
		{
			theSound.SoundEvent("gui_inventory_armor_back");
		}
	}

	//Unmount all items
	private function UnmountStandItems()
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		GetInventory().GetAllItems(items);
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			GetInventory().UnmountItem( items[i], true );
		}
		
	}	
	
	//Check if there are any vaild items in the inventory
	private function GetIsDecoractionEmpty() : bool
	{
		return GetIsArmorStandEmpty();
	}

	//Since armor stand always has a technical item for variants check if it contains any other item
	private function GetIsArmorStandEmpty() : bool
	{
		var items : array<SItemUniqueId>;	
		var i : int;
		
		GetInventory().GetAllItems( items );
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			if( GetInventory().GetItemName( items[i] ) != '_armor_stand' )
			{
				return false;
			}
		}
		
		return true;
	}
	
	//Check if player has any armors that are not equiped
	private function GetIfPlayerHasValidItems() : bool
	{
		var i, size : int;
		var items : array<SItemUniqueId>;
		
		items = thePlayer.inv.GetItemsByCategory( 'armor' );
		
		return thePlayer.inv.GetHasValidDecorationItems( items, this );
	}	
	
	//Transfer all the items from the container, except for the item that triggered the transfer and tech item
	private function ForceTransferAllItems( triggeringItem : SItemUniqueId )
	{
		var items : array<SItemUniqueId>;	
		var i : int;
		
		GetInventory().GetAllItems( items );
		
		for( i=0; i < items.Size(); i+= 1 )
		{
			if( GetInventory().GetItemName( items[i] ) != '_armor_stand' && triggeringItem != items[i] )
			{
				GetInventory().GiveItemTo( thePlayer.GetInventory(), items[i], 1 );
			}
		}
		
	}

	//Called when an item is taken from the container
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		
		if( GetInventory().GetItemCategory( itemId ) == 'armor' )
		{
			ForceTransferAllItems( itemId );
			UpdateContainer();
		}
	}	
	
	//When player moves close to Geralt's house armor stands should mount items before player can see it.
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		ProcessItemMounting( false );
	}
	
	//Whenever player moves away from Geralt's house armors should be unmounted, since item entites are not streamed.	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		UnmountStandItems();
	}		

}


	

	