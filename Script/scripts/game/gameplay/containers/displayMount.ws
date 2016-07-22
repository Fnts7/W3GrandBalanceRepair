/***********************************************************************/
/** Witcher Script file - Container controll class for herbs containers
/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

// Class to handle displaying and mounting of a single item
class W3DisplayMount extends W3Container
{
	var ids    				 : array<SItemUniqueId>;
	var i					 : int;
	//var inv					 : CInventoryComponent;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		super.OnSpawned(spawnData);

		//force this since someone might ignore the fields in entity template - could break OnInteractionActivated in parent class
		lockedByKey = false;
		UpdateDisplayMount();
	}
	
	event OnStreamIn()
	{
		super.OnStreamIn();
	}
	
	event OnUpdateContainer()
	{
		super.OnUpdateContainer();
		
		UpdateDisplayMount();
	}
	
	function UpdateDisplayMount()
	{
		if( inv && !inv.IsEmpty() )
		{
			inv.GetAllItems(ids);
			
			inv.MountItem(ids[0],true);
			
			for (i=ids.Size()-1; i>0; i-=1)
			{
				if ((inv.GetItemCategory(ids[i]) == 'steel_scabbards') ||  ( inv.GetItemCategory(ids[i]) == 'silver_scabbards'))
				{
					inv.RemoveItem(ids[i]);
					
				}
			}
		}
	}
}