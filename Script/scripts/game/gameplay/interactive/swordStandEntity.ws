/***********************************************************************/
/** Copyright © 2015
/** Authors : Danisz Markiewicz
/***********************************************************************/

class W3SwordStand extends W3HouseDecorationBase
{

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		
		ChangeItemSelectionMode( EISPM_SwordStand );
		
		//Only one handed swords should be valid, no secondaries that are in fact steel weapons
		AddItemSelectionFilterTag( 'sword1h' );
		AddItemSelectionForbiddenFilterTag( 'SecondaryWeapon' );		
	}

	//Performs operations upon receiving an item
	public function ProcessItemReceival( optional mute : bool )
	{
		super.ProcessItemReceival();
		MountNewItem( !mute );
	}
	
	//Mounting silver or steel sword depending which one was put into the container
	private function MountNewItem( optional playSound : bool )
	{
		var items : array<SItemUniqueId>;
		
		items = GetInventory().GetItemsByCategory( 'steelsword' );
		
		if( items.Size() >= 1 )
		{
			if( GetInventory().MountItem( items[0], false, true ) )
			{
				if( playSound )
				{
					theSound.SoundEvent("gui_inventory_steelsword_back");
				}
			}
		}
		else
		{
			items = GetInventory().GetItemsByCategory( 'silversword' );
			
			if( items.Size() >= 1 )
			{
				if( GetInventory().MountItem( items[0], false, true ) )
				{
					if( playSound )
					{				
						theSound.SoundEvent("gui_inventory_silversword_back");
					}
				}	
			}
		}
		
	}

	//Check if there are any vaild items in the inventory
	private function GetIsDecoractionEmpty() : bool
	{
		return GetIsWeaponStandEmpty();
	}

	//Check if there are any one handed swords in the inventory 
	private function GetIsWeaponStandEmpty() : bool
	{		
		var items : array<SItemUniqueId>;
		
		items = GetInventory().GetItemsByTag( 'sword1h' );
		
		if( items.Size() == 0 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	//Check if player has any armors that are not equiped
	private function GetIfPlayerHasValidItems() : bool
	{
		var items : array<SItemUniqueId>;
		
		items = thePlayer.inv.GetItemsByTag( 'sword1h' );
		
		return thePlayer.inv.GetHasValidDecorationItems( items, this );
	}		
	
	
}


	