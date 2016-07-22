class W3GuiShopInventoryComponent extends W3GuiBaseInventoryComponent
{
	protected function InvalidateItems( items : array<SItemUniqueId> )
	{
		//_dpShop.InvalidateData(); // #B deprecated
	}

	function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var isQuest	 : bool;
		var l_questTag	: string;
		
		super.SetInventoryFlashObjectForItem(item, flashObject);
		
		
		l_questTag = "";
		if(_inv.ItemHasTag(item, 'Quest'))
		{
			l_questTag = "Quest";
			isQuest = true;
		}
		
		if (_inv.ItemHasTag(item, 'QuestEP1'))
		{
			l_questTag = "QuestEP1";
			isQuest = true;
		}
		
		if (_inv.ItemHasTag(item, 'QuestEP2'))
		{
			l_questTag = "QuestEP2";
			isQuest = true;
		}
		
		flashObject.SetMemberFlashBool( "isQuest", isQuest );
		flashObject.SetMemberFlashBool( "isNew", false ); // ignore for shop
		flashObject.SetMemberFlashString( "questTag", l_questTag );
	}
	
	protected function GridPositionEnabled() : bool
	{
		return false;
	}
	
	// For override
	protected function ShopHasInfiniteFunds() : bool
	{
		return _inv.GetFundsType() == EInventoryFunds_Unlimited;
	}

	// Shop is selling Item to the Player
	public function GiveItem( itemId : SItemUniqueId, customer : W3GuiBaseInventoryComponent, optional quantity : int, optional out newItemID : SItemUniqueId ) : bool
	{
		var customerMoney : int;
		var itemPrice : int;
		var success : bool;
		var invItem : SInventoryItem;

		success = false;
		
		if( quantity < 1 )
		{
			quantity = 1;
		}

		customerMoney = customer._inv.GetMoney();

		invItem = _inv.GetItem( itemId );
		
		itemPrice = _inv.GetInventoryItemPriceModified( invItem, false ) * quantity;
		
		if ( customerMoney >= itemPrice )
		{
			success = super.GiveItem( itemId, customer, quantity, newItemID );
			if ( success )
			{
				customer._inv.RemoveMoney( itemPrice );
				
				if ( !ShopHasInfiniteFunds() )
				{
					_inv.AddMoney( itemPrice );
				}
			}
		}
		return success;
	}
	
	// Shop is purchasing Item from the Player; Giver = Player
	public function ReceiveItem( itemId : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional out newItemID : SItemUniqueId ) : bool
	{
		var shopMoney : int;
		var itemCost : int;
		var success : bool;
		var invItem : SInventoryItem;

		shopMoney = _inv.GetMoney();

		invItem = giver._inv.GetItem( itemId );
		
		itemCost = _inv.GetInventoryItemPriceModified( invItem, true ) * quantity;

		success = false;

		if ( itemCost >= 0 && ( shopMoney >= itemCost || ShopHasInfiniteFunds() ) )
		{
			success = super.ReceiveItem( itemId, giver, quantity, newItemID );
			if ( success )
			{
				if ( !ShopHasInfiniteFunds() )
				{
					_inv.RemoveMoney( itemCost );
				}
				giver._inv.AddMoney( itemCost );
			}
		}
		return success;
	}
	
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool ) : EInventoryActionType
	{
		return IAT_Buy;
	}
	public function GetItemName(item : SItemUniqueId):name
	{
		return _inv.GetItemName(item);
	}
}

//--------------------------------------------------------------------------------------------------------
