class CR4HudModulePickedItemsInfo extends CR4HudModuleBase // #B deprecated
{
	//private var _dpPickedItemsInfo : W3HudPickedItemsInfoDataProvider;
	private var _RecentlyAddedItemListSize : int;
	
	public var bCurrentShowState : bool;			default bCurrentShowState = false;
	public var bShouldShowElement : bool;			default bShouldShowElement = false;
	private const var _PickedItemListSize : int;	default _PickedItemListSize = 4;

	/* flash */ event OnConfigUI()
	{
		super.OnConfigUI();

		//_dpPickedItemsInfo = (W3HudPickedItemsInfoDataProvider)RegisterDataProvider( 'hud.pickeditems', 'W3HudPickedItemsInfoDataProvider' );
		//_dpPickedItemsInfo.Initialize();
		//SetInt('pickeditem.lastid',_PickedItemListSize-1);

		ShowElement(false);
	}

	event OnTick( timeDelta : float )
	{
		var inv : CInventoryComponent;
		var itemList : array<SItemUniqueId>;
		var i : int;
		var dpSize : int;
		
		inv = GetWitcherPlayer().inv;
		
		if( (inv.GetRecentlyAddedItemsListSize() != _RecentlyAddedItemListSize ) && bShouldShowElement == bCurrentShowState )
		{
			_RecentlyAddedItemListSize = inv.GetRecentlyAddedItemsListSize();
			itemList = inv.GetRecentlyAddedItems();
			// PM commented out
			/*
			dpSize = _dpPickedItemsInfo.itemIds.Size();
			if( dpSize < _PickedItemListSize )
			{
				for( i = dpSize; i < Min(_PickedItemListSize,_RecentlyAddedItemListSize); i += 1 )
				{
					_dpPickedItemsInfo.itemIds.PushBack(itemList[i]);					
				}
				_dpPickedItemsInfo.InvalidateData();
				if( _dpPickedItemsInfo.itemIds.Size() == 0 )
				{
					bCurrentShowState = false;
					ShowElement(false);
				}
				else
				{
					bCurrentShowState = true;
					ShowElement(true);
				}
			}
			*/
		}
	}
	
	public function ShowElement( bShow : bool, optional bImmediately : bool )
	{
		bShouldShowElement = bShow;
		if( bShow )
		{
			super.ShowElement( bCurrentShowState, bImmediately );
			return;
		}
		super.ShowElement( bShow, bImmediately );
	}
	
	event OnRemovePickedItemsInfoFirstItem()
	{
		var inv : CInventoryComponent;
		inv = GetWitcherPlayer().inv;
		// PM commented out
		/*
		if(_dpPickedItemsInfo.itemIds.Size() > 0)
		{
			inv.RemoveItemFromRecentlyAddedList(_dpPickedItemsInfo.itemIds[0]);
			_dpPickedItemsInfo.itemIds.Erase(0);
		}
		*/
	}
}

/*
class W3HudPickedItemsInfoDataProvider extends CGuiDataProviderProxy
{	
	public var itemIds : array<SItemUniqueId>;
	
	public function Initialize()
	{
		itemIds.Clear();
	}

	protected function DoGetLength( out length: int )
	{
		length = itemIds.Size();
	}
	
	protected function DoRequestItems( out valueSetter : SGuiDataProviderValueSetter )
	{
		var i : int;
		var inv : CInventoryComponent;
		inv = GetWitcherPlayer().inv;
		
		while ( valueSetter.CanCreateNextElement() )
		{
			valueSetter.CreateNextElement();
			i = valueSetter.GetCurrentIndex();
			valueSetter.SetMemberString( 'label', GetLocStringByKeyExt(inv.GetItemLocalizedNameByUniqueID(itemIds[i])) );
			// @FIXME BIDON - add display of icon ?
			valueSetter.SetMemberString( 'quantity', inv.GetItemQuantity(itemIds[i]));
		}
	}
}
*/