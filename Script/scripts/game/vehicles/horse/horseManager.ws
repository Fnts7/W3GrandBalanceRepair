/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014-2015
/** Author : Tomek Kozera
/***********************************************************************/

/*
	#Y Use: 
	EEquipmentSlots
		EES_InvalidSlot
		EES_HorseTrophy
		EES_HorseSaddle
		EES_HorseBlinders	
		EES_HorseBag
*/

/*
	Horse Manager is a hack to access horse inventory and stats when the horse is despawned.
	For this reason all horse items are actually held in Horse Manager and then added to horse whenever it spawns.
	Also the Manager caches horse abilities so that we could get horse stats when it's despawned.
	
	Note: design of how and when all this is accessed has changed so many times that it would be a good idea to
	burn this with napalm and rewrite. Or at least refactor...
*/
class W3HorseManager extends CPeristentEntity
{
	private autobind inv : CInventoryComponent = single;		//horse manager holds its own inventory. When horse is spawned manager syncs his inventory with horse's (horse's will match manager's)
	private saved var horseAbilities : array<name>;				//since horse may not be spawned we need to cache it's abilities to show it's stats when horse is not present
	private saved var itemSlots : array<SItemUniqueId>;			//horse's paperdoll
	private saved var wasSpawned : bool;						//flag for marking if horse was spawned at least once
	private saved var horseMode : EHorseMode;					//horse mode
	
	default wasSpawned = false;
	
	public function OnCreated()
	{
		itemSlots.Grow(EnumGetMax('EEquipmentSlots')+1);
		
		Debug_TraceInventories( "OnCreated" );
	}
	
	public function GetInventoryComponent() : CInventoryComponent
	{
		return inv;
	}
	
	/*public final function GetIsReinsAndSaddleVisible() : bool
	{
		return horseMode != EHM_Unicorn;
	}*/
	
	public final function GetShouldHideAllItems() : bool
	{
		return horseMode == EHM_Unicorn;
	}
	
	private final function GetAppearanceName() : name
	{
		var worldName : String;
		var isOnBobLevel : bool;
		
		worldName =  theGame.GetWorld().GetDepotPath();
		if( StrFindFirst( worldName, "bob" ) < 0 )
			isOnBobLevel = false;
		else
			isOnBobLevel = true; 
	
		if( horseMode == EHM_Unicorn )
		{
			return 'unicorn_wild_01';
		}
		else if( horseMode == EHM_Devil )
		{
			if( isOnBobLevel )
				return 'player_horse_with_devil_saddle_mimics';
			else
				return 'player_horse_with_devil_saddle';
		}		
		else if( FactsQuerySum( "q110_geralt_refused_pay" ) > 0 ) // change horse appearance if player received new horse through storyline
		{
			if( isOnBobLevel )
				return 'player_horse_after_q110_mimics';
			else
				return 'player_horse_after_q110';
		}	
		else
		{
			if( isOnBobLevel )
				return 'player_horse_mimics';
			else
				return 'player_horse';
		}
	}	
	
	public function SetHorseMode( m : EHorseMode )
	{
		var horse : CNewNPC;		
		
		//because flowers beat darkness
		if( horseMode == EHM_Unicorn && m == EHM_Devil )
		{
			return;
		}
		
		horse = thePlayer.GetHorseWithInventory();
		
		//clean up after old mode
		if( horse && horseMode == EHM_Devil && m != horseMode )
		{
			horse.RemoveBuff( EET_WeakeningAura, true );
			horse.StopEffect( 'demon_horse' );
		}
		
		horseMode = m;
		
		//update new mode
		if( horse )
		{
			if( horseMode == EHM_Devil )
			{
				horse.PlayEffectSingle( 'demon_horse' );
				if( !horse.HasBuff( EET_WeakeningAura ) )
					horse.AddEffectDefault( EET_WeakeningAura, horse, 'horse saddle', false );
			}
			
			horse.AddTimer( 'SetShowAllHorseItems', 0.3f );
			
			//appearance
			horse.ApplyAppearance( GetAppearanceName() );
		}
	}
		
	//called when horse spawns to update it's inventory with what was set in the manager and new abilities added to horse
	public function ApplyHorseUpdateOnSpawn() : bool
	{
		var ids, items 		: array<SItemUniqueId>;
		var eqId  			: SItemUniqueId;
		var i 				: int;
		var horseInv 		: CInventoryComponent;
		var horse			: CNewNPC;
		var itemName		: name;
		
		horse = thePlayer.GetHorseWithInventory();
		if( !horse )
		{
			return false;
		}
		
		horseInv = horse.GetInventory();
		
		if( !horseInv )
		{
			return false;
		}
		
		horseInv.GetAllItems(items);
		
		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] BEFORE" );
		
		//if spawned for the first time, get horse items and move with equip to horse manager
		if (!wasSpawned)
		{
			for(i=items.Size()-1; i>=0; i-=1)
			{
				if ( horseInv.ItemHasTag(items[i], 'HorseTail') || horseInv.ItemHasTag(items[i], 'HorseReins') || horseInv.GetItemCategory( items[i] ) == 'horse_hair' )
				{
					continue;
				}
				eqId = horseInv.GiveItemTo(inv, items[i], 1, false);
				EquipItem(eqId);
			}
			wasSpawned = true;
		}
		
		//remove all gameplay items from horse - manager handles that!
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if ( horseInv.ItemHasTag(items[i], 'HorseReins') || horseInv.GetItemCategory( items[i] ) == 'horse_hair' )
			{
				if( !horseInv.IsItemMounted( items[i] ) )
				{
					horseInv.MountItem( items[i] );
				}
				continue;
			}
			horseInv.RemoveItem(items[i]);
		}
		
		//add items in current horse equipment slots
		for( i = 0; i < itemSlots.Size(); i += 1 )
		{
			if( inv.IsIdValid( itemSlots[i] ) )
			{
				itemName = inv.GetItemName( itemSlots[i] );
				ids = horseInv.AddAnItem( itemName );
				horseInv.MountItem( ids[0] );
			}
		}
	
		//cache current horse abilities (we'll need those when horse will be despawned)
		horseAbilities.Clear();
		horseAbilities = horse.GetAbilities(true);
		
		//Check for Stable Buff
		if( GetWitcherPlayer().HasBuff( EET_HorseStableBuff ) && !horse.HasAbility( 'HorseStableBuff', false ) )
		{
			horse.AddAbility( 'HorseStableBuff' );
		}
		else if( !GetWitcherPlayer().HasBuff( EET_HorseStableBuff ) && horse.HasAbility( 'HorseStableBuff', false ) )
		{
			horse.RemoveAbility( 'HorseStableBuff' );
		}
		
		ReenableMountHorseInteraction( horse );
		
		//backwards compatibility
		if( horseMode == EHM_NotSet )
		{
			if( horseInv.HasItem( 'Devil Saddle' ) )
			{
				horseMode = EHM_Devil;
			}
			else
			{
				horseMode = EHM_Normal;
			}
		}
		
		//set current appearance		
		SetHorseMode( horseMode );

		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] AFTER" );
				
		return true;
	}
	
	public function ReenableMountHorseInteraction( horse : CNewNPC )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var hc : W3HorseComponent;
		var i : int;

		if ( horse )
		{
			hc = horse.GetHorseComponent();
			if ( hc && !hc.GetUser() ) // just to be sure there's no rider
			{
				components = horse.GetComponentsByClassName( 'CInteractionComponent' );
				for ( i = 0; i < components.Size(); i += 1 )
				{
					ic = ( CInteractionComponent )components[ i ];
					if ( ic && ic.GetActionName() == "MountHorse" )
					{
						if ( !ic.IsEnabled() )
						{
							ic.SetEnabled( true );
						}
						return;
					}
				}
			}
		}
	}
	
	public function IsItemEquipped(id : SItemUniqueId) : bool
	{
		return itemSlots.Contains(id);
	}
	
	public function IsItemEquippedByName( itemName : name ) : bool
	{
		var i : int;
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			if( inv.GetItemName( itemSlots[i] ) == itemName )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function GetItemInSlot( slot : EEquipmentSlots ) : SItemUniqueId
	{
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		else
			return itemSlots[slot];
	}
	
	public function GetHorseAttributeValue(attributeName : name, excludeItems : bool) : SAbilityAttributeValue
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var min, max, val : SAbilityAttributeValue;
	
		//if horse was never spawned but exists - cache horse abilities data. Otherwise we ignore horse data as we know nothing about the horse
		if(horseAbilities.Size() == 0)
		{
			if(thePlayer.GetHorseWithInventory())
			{
				horseAbilities = thePlayer.GetHorseWithInventory().GetAbilities(true);			
			}
			else if(!excludeItems)
			{
				//horse was never spawned so we don't know its stats - take only from items
				for(i=0; i<itemSlots.Size(); i+=1)
				{
					if(itemSlots[i] != GetInvalidUniqueId())
					{
						val += inv.GetItemAttributeValue(itemSlots[i], attributeName);
					}
				}
				
				return val;
			}
		}
		
		dm = theGame.GetDefinitionsManager();
		//get attribute from horse stats
		for(i=0; i<horseAbilities.Size(); i+=1)
		{
			dm.GetAbilityAttributeValue(horseAbilities[i], attributeName, min, max);
			val += GetAttributeRandomizedValue(min, max);
		}
		
		//get from items
		if(excludeItems)
		{
			for(i=0; i<itemSlots.Size(); i+=1)
			{
				if(itemSlots[i] != GetInvalidUniqueId())
				{
					val -= inv.GetItemAttributeValue(itemSlots[i], attributeName);
				}
			}
		}
		
		return val;
	}
	
	public function EquipItem(id : SItemUniqueId) : SItemUniqueId
	{
		var horse    : CActor;
		var ids      : array<SItemUniqueId>;
		var slot     : EEquipmentSlots;
		var itemName : name;
		var resMount, usePerk : bool;
		var abls	 : array<name>;
		var i		 : int;
		var unequippedItem : SItemUniqueId;
		var itemNameUnequip : name;
	
		//if no item
		if(!inv.IsIdValid(id))
			return GetInvalidUniqueId();
			
		//find proper slot
		slot = GetHorseSlotForItem(id);
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - BEFORE" );
		
		//unmount previous item if any
		if(inv.IsIdValid(itemSlots[slot]))
		{
			itemNameUnequip = inv.GetItemName(itemSlots[slot]);
			unequippedItem = UnequipItem(slot);
		}
			
		//mount item
		itemSlots[slot] = id;
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			itemName = inv.GetItemName(id);
			ids = horse.GetInventory().AddAnItem(itemName);
			resMount = horse.GetInventory().MountItem(ids[0]);
			if (resMount)
			{
				horse.GetInventory().GetItemAbilities(ids[0], abls);
				for (i=0; i < abls.Size(); i+=1)
					horseAbilities.PushBack(abls[i]);
			}
			
			if ( itemNameUnequip == 'Devil Saddle' && horseMode != EHM_Unicorn)
			{
				SetHorseMode( EHM_Normal );				
			}
			
			if ( itemName == 'Devil Saddle' ) 
			{
				SetHorseMode( EHM_Devil );			
			}
		}
		else
		{
			inv.GetItemAbilities(id, abls);
			for (i=0; i < abls.Size(); i+=1)
				horseAbilities.PushBack(abls[i]);
			SetHorseMode( EHM_NotSet );
		}
		
		//add horse trophy abilities to player
		if ( slot == EES_HorseTrophy )
		{
			abls.Clear();
			inv.GetItemAbilities(id, abls);
			for (i=0; i < abls.Size(); i += 1)
			{
				if ( abls[i] == 'base_trophy_stats' )
					continue;

				thePlayer.AddAbility(abls[i]);
			}
		}
		
		// report global event
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		if(inv.IsItemHorseBag(id))
			GetWitcherPlayer().UpdateEncumbrance();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - AFTER" );
		
		
		
		if( horse )
		{
			horse.AddTimer( 'SetShowAllHorseItems', 0.0f );
		}
		
		return unequippedItem;
	}
	
	public function AddAbility(abilityName : name)
	{
		var horse : CNewNPC;
		
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			horse.AddAbility(abilityName, true);
		}
		
		horseAbilities.PushBack(abilityName);
	}
	
	public function UnequipItem(slot : EEquipmentSlots) : SItemUniqueId
	{
		var itemName : name;
		var horse : CActor;
		var ids : array<SItemUniqueId>;
		var abls : array<name>;
		var i : int;
		var usePerk : bool;
		var oldItem : SItemUniqueId;
		var newId : SItemUniqueId;
	
		//if not item
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
			
		//if nothing equipped
		if(!inv.IsIdValid(itemSlots[slot]))
			return GetInvalidUniqueId();
			
		oldItem = itemSlots[slot];
			
		//remove trophy ability from player
		if ( slot == EES_HorseTrophy )
		{
			inv.GetItemAbilities(oldItem, abls);
			for (i=0; i < abls.Size(); i += 1)
			{
				if ( abls[i] == 'base_trophy_stats' )
					continue;
				
				thePlayer.RemoveAbility(abls[i]);
			}
		}
			
		//unmount		
		if(inv.IsItemHorseBag( itemSlots[slot] ))
			GetWitcherPlayer().UpdateEncumbrance();
		
		itemName = inv.GetItemName(itemSlots[slot]);
		itemSlots[slot] = GetInvalidUniqueId();
		horse = thePlayer.GetHorseWithInventory();
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - BEFORE" );
		
		if ( itemName == 'Devil Saddle' && horseMode == EHM_Devil) 
		{
			SetHorseMode( EHM_Normal );			
		}
		
		// Remove item from horse inventory
		if( horse )
		{
			ids = horse.GetInventory().GetItemsByName( itemName );
			horse.GetInventory().UnmountItem( ids[ 0 ] );
			horse.GetInventory().RemoveItem( ids[ 0 ] );
		}
		
		// Remove item abilities
		abls.Clear();
		ids = inv.GetItemsByName( itemName );
		inv.GetItemAbilities( ids[ 0 ], abls );
		for( i = 0; i < abls.Size(); i += 1 )
		{
			horseAbilities.Remove( abls[ i ] );
		}
		
		// Remove item from manager inventory
		newId = inv.GiveItemTo(thePlayer.inv, oldItem, 1, false, true, false);

		// Report global event
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - AFTER" );

		return newId;
	}
	
	public function Debug_TraceInventory( inventory : CInventoryComponent, optional categoryName : name )
	{
		var i : int;
		var itemsNames : array< name >;
		var items : array< SItemUniqueId >;
		if( categoryName == '' )
		{
			itemsNames = inventory.GetItemsNames();
			for( i = 0; i < itemsNames.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', itemsNames[ i ] );
			}
		}
		else
		{
			items = inventory.GetItemsByCategory( categoryName );
			for( i = 0; i < items.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', inventory.GetItemName( items[ i ] ) );
			}
		}
	}
	
	public function Debug_TraceInventories( optional heading : string )
	{
		//----------------------------------------------------------
		return; // COMMENT OUT THIS LINE TO TURN ON THE DEBUG OUTPUT
		//----------------------------------------------------------
	
		if( heading != "" )
		{
			LogChannel( 'Dbg_HorseInv', "----------------------------------] " + heading );
		}
	
		if( thePlayer && thePlayer.GetHorseWithInventory() )
		{
			LogChannel( 'Dbg_HorseInv', "] Entity Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( thePlayer.GetHorseWithInventory().GetInventory() );
			//Debug_TraceInventory( thePlayer.GetHorseWithInventory().GetInventory(), 'horse_bag' ); // Use this to filter specific categories
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
		
		if( inv )
		{
			LogChannel( 'Dbg_HorseInv', "] Manager Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( inv );
			//Debug_TraceInventory( inv, 'horse_bag' ); // Use this to filter specific categories
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
	}
	
	public function MoveItemToHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return thePlayer.inv.GiveItemTo(inv, id, quantity, false, true, false);
	}
	
	public function MoveItemFromHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return inv.GiveItemTo(thePlayer.inv, id, quantity, false, true, false);
	}
	
	public function GetHorseSlotForItem(id : SItemUniqueId) : EEquipmentSlots
	{
		return inv.GetHorseSlotForItem(id);
	}
	
		//returns removed amount
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsIds(itemName);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByName(itemName, quantity);
	}
	
	//returns removed amount
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - BEFORE" );
		
		ids = inv.GetItemsByCategory(itemCategory);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByCategory(itemCategory, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - AFTER" );
	}
	
	//returns removed amount
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - BEFORE" );
		
		ids = inv.GetItemsByTag(itemTag);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByTag(itemTag, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - AFTER" );
	}
	
	public function RemoveAllItems()
	{
		var playerInvId : SItemUniqueId;
		
		playerInvId = UnequipItem(EES_HorseBlinders);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseSaddle);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseBag);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseTrophy);
		thePlayer.inv.RemoveItem(playerInvId);
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		return GetWitcherPlayer().GetInventory();
	}
}
