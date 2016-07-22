/***********************************************************************/
/** Witcher Script file - preparation mutagens
/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4PreparationMutagensMenu extends CR4MenuBase // #B obsolete
{
	private var _gridInv : W3GuiPreparationMutagensInventoryComponent;
	private var _currentInv : W3GuiBaseInventoryComponent;
	protected var _inv : CInventoryComponent;
	private var optionsItemActions : array<EInventoryActionType>;
	
	private var _currentQuickSlot : EEquipmentSlots;
	default _currentQuickSlot = EES_InvalidSlot;	
	
	private const var TOXICTY_BAR_DATA_BINDING_KEY : string; 		default TOXICTY_BAR_DATA_BINDING_KEY = "preparation.toxicity.bar.";	
	private const var MUTAGENS_SIZE			:int; 			default MUTAGENS_SIZE 		= 4;

	private var initialized : bool;
	default initialized = false;
	
	event /*flash*/ OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		if( initialized )
		{
			return false;
		}
		super.OnConfigUI();
		//theSound.SoundEvent( 'gui_global_panel_open' );  // #B sound - open
		
		_inv = thePlayer.GetInventory();
		_gridInv = new W3GuiPreparationMutagensInventoryComponent in this;
		_gridInv.Initialize( _inv );	
		_currentInv = _gridInv;
		
		UpdateData();
		m_flashValueStorage.SetFlashString("common.grid.name",GetLocStringByKeyExt("panel_preparation_mutagens_grid_name"),-1);
		
		m_flashValueStorage.SetFlashString( TOXICTY_BAR_DATA_BINDING_KEY+"description", GetLocStringByKeyExt("panel_preparation_toxicitybar_description"), -1 );

		m_flashValueStorage.SetFlashString( "preparation.mutagens.sublist.name", GetLocStringByKeyExt("panel_preparation_mutagens_sublist_name"), -1 );
		UpdatePlayerOrens();
		UpdatePlayerLevel();
		
		UpdateNavigationTitles();
		UpdateToxicityBar();
		initialized = true;
	}
	
	function UpdateData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		_gridInv.GetInventoryFlashArray(l_flashArray,l_flashObject);
		
		m_flashValueStorage.SetFlashArray( "common.grid", l_flashArray );
		UpdateMutagens();
	}	

	function UpdateToxicityBar()
	{
		var curToxicity 	: float = thePlayer.GetStat( BCS_Toxicity );
		var curMaxToxicity 	: float = thePlayer.GetStatMax( BCS_Toxicity );
		var lockedToxicity	: float = curToxicity - thePlayer.GetStat(BCS_Toxicity, true);
		
		m_flashValueStorage.SetFlashNumber( TOXICTY_BAR_DATA_BINDING_KEY+"max", curMaxToxicity, -1 );
		m_flashValueStorage.SetFlashNumber( TOXICTY_BAR_DATA_BINDING_KEY+"value", curToxicity, -1 );
		m_flashValueStorage.SetFlashNumber( TOXICTY_BAR_DATA_BINDING_KEY+"locked", lockedToxicity, -1 );
	}
	
	function UpdateMutagens()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var items				: array<SItemUniqueId>;
		var item 					: SItemUniqueId;
		var i 						: int;
		var _inv					: CInventoryComponent;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		_inv = GetWitcherPlayer().GetInventory();
				
		for(i = EES_PotionMutagen1; i < EES_PotionMutagen4 + 1; i += 1 ) // @FIXME TK - getting eqiupped mutagens
		{
			GetWitcherPlayer().GetItemEquippedOnSlot(i, item);
			items.PushBack(item);
		}
		
		for( i = 0; i < MUTAGENS_SIZE; i += 1 )
		{
			item = items[i];
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			l_flashObject.SetMemberFlashInt( "id", ItemToFlashUInt(item) );
			if(_inv.IsItemSingletonItem(item))
			{
				l_flashObject.SetMemberFlashInt( "quantity", thePlayer.inv.SingletonItemGetAmmo(item) );
			}
			else
			{
				l_flashObject.SetMemberFlashInt( "quantity", _inv.GetItemQuantity( item ) );
			}
			l_flashObject.SetMemberFlashString( "iconPath",  _inv.GetItemIconPathByUniqueID(item) );
			l_flashObject.SetMemberFlashInt( "gridPosition", i );
			l_flashObject.SetMemberFlashInt( "gridSize", 1 );
			l_flashObject.SetMemberFlashInt( "slotType", 1 );	
			l_flashObject.SetMemberFlashBool( "isNew", false );
			l_flashObject.SetMemberFlashBool( "needRepair", false );
			l_flashObject.SetMemberFlashInt( "actionType", IAT_None );
			l_flashObject.SetMemberFlashInt( "price", 0 ); 		
			l_flashObject.SetMemberFlashString( "userData", "");//GetTooltipText(item) );
			l_flashObject.SetMemberFlashString( "category", "" );
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
				
		m_flashValueStorage.SetFlashArray( "preparation.mutagens.equipped.items", l_flashArray );
	}
	
	private function UpdatePlayerOrens()
	{
		var orens:int;
		orens = thePlayer.GetMoney();
		
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.money",orens,-1);
	}

	private function UpdatePlayerLevel()
	{
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.level",GetCurrentLevel(),-1);
		m_flashValueStorage.SetFlashString("inventory.playerdetails.experience",GetCurrentExperience(),-1);
	}
	
	private function GetCurrentLevel() : int
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetLevel();
	}	

	private function GetCurrentExperience() : string
	{
		var levelManager : W3LevelManager;
		var str : string;
		levelManager = GetWitcherPlayer().levelManager;
		
		str = (string)levelManager.GetPointsTotal(EExperiencePoint) + "/" +(string)levelManager.GetTotalExpForNextLevel(); // #B maybe total - previous lvl exp ??
		return str;
	}
	
	function UpdateTooltipCompareData( item : SItemUniqueId, compareItem : SItemUniqueId, tooltipInv : CInventoryComponent , tooltipName : string ) // could not work
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		var compareItemStats : array<SAttributeTooltip>;
		var itemStats : array<SAttributeTooltip>;
		var i,j, price : int;
		var nam, descript, fluff, category : string;
		var itemName : string;
		var attributeVal : SAbilityAttributeValue;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		if( tooltipInv.IsIdValid( item ) )
		{
			itemName = tooltipInv.GetItemLocalizedNameByUniqueID(item);
			itemName = GetLocStringByKeyExt(itemName);
			m_flashValueStorage.SetFlashString(tooltipName+".title", itemName, -1 );
		}
		else
		{
			m_flashValueStorage.SetFlashString(tooltipName+".title", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".price", "", -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".weight", "", -1 );
			m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
			m_flashValueStorage.SetFlashString(tooltipName+".description", "", -1 );
			if( theGame.IsPadConnected() )
			{
				m_flashValueStorage.SetFlashString(tooltipName+".icon", "", -1 );
				m_flashValueStorage.SetFlashString(tooltipName+".category", "", -1 );
			}
			return;
		}
		
		if( tooltipInv.GetItemName(item) != _inv.GetItemName(compareItem) ) // #B by name because they could be in different inventoryComponents, and then they have different id
		{
			_inv.GetTooltipData(compareItem, nam, descript, price, category, compareItemStats, fluff );
		}
		tooltipInv.GetTooltipData(item, nam, descript, price, category, itemStats, fluff);
		
		//price *= _inv.GetMerchantPriceModifier(_shopNpc);
		itemName = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);

			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				itemName = "positive";
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					if( itemStats[j].value < compareItemStats[i].value )
					{
						itemName = "negative";
					}
					else if( itemStats[j].value == compareItemStats[i].value )
					{
						itemName = "neutral";
					}	
					break;
				}
			}
			l_flashObject.SetMemberFlashString("icon",itemName);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				l_flashObject.SetMemberFlashString("value","+"+(int)NoTrailZeros(itemStats[i].value));
			}
			l_flashArray.PushBackFlashObject(l_flashObject);
		}	
		
		m_flashValueStorage.SetFlashArray( tooltipName+".stats", l_flashArray );
		m_flashValueStorage.SetFlashString(tooltipName+".price", tooltipInv.GetItemPrice(item), -1 );
							
		attributeVal = _inv.GetItemAttributeValue( item , 'weight');			
		m_flashValueStorage.SetFlashString(tooltipName+".weight", attributeVal.valueAdditive, -1  );
		m_flashValueStorage.SetFlashString(tooltipName+".description", GetLocStringByKeyExt("panel_inventory_tooltip_description_selected"), -1 ); // #B equiped/selected
		m_flashValueStorage.SetFlashBool(tooltipName+".display", true, -1 );
		if( theGame.IsPadConnected() )
		{
			m_flashValueStorage.SetFlashString(tooltipName+".icon", tooltipInv.GetItemIconPathByUniqueID(item), -1 );
			m_flashValueStorage.SetFlashString(tooltipName+".category", tooltipInv.GetItemCategory( item ), -1 );
		}
		
		UpdateToxicityBar();
	}
		
	function UpdateNavigationTitles() // @FIXME BIDON - bindings are ok ?
	{
		/*if( _shopNpc )
		{
			m_flashValueStorage.SetFlashString("inventory.navigation.title", GetLocStringByKeyExt("panel_title_shop"), -1 );
			m_flashValueStorage.SetFlashString("inventory.navigation.previous", "", -1 );
			m_flashValueStorage.SetFlashString("inventory.navigation.next", "", -1 );
			//m_flashValueStorage.SetFlashString("inventory.navigation.enabled", 2, -1 );
		}
		else
		{
			m_flashValueStorage.SetFlashString("inventory.navigation.title", GetLocStringByKeyExt("panel_title_inventory"), -1 );
			m_flashValueStorage.SetFlashString("inventory.navigation.previous", GetLocStringByKeyExt("panel_title_journal"), -1 );
			m_flashValueStorage.SetFlashString("inventory.navigation.next", GetLocStringByKeyExt("panel_title_alchemy"), -1 );
			m_flashValueStorage.SetFlashString("inventory.navigation.enabled", 2, -1 );
		}*/
	}

	function UpdateRightMenuOptionsData( item : SItemUniqueId)
	{
		/*var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var i 						: int;
		var itemAction 				: EInventoryActionType;
		
		optionsItemActions.Clear();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt(GetItemDefaultAction(item)));
		l_flashArray.PushBackFlashObject(l_flashObject);		
		
		if( _currentInv == _gridInv )
		{
			optionsItemActions.PushBack(IAT_Drop);
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("panel_button_common_drop"));
			l_flashArray.PushBackFlashObject(l_flashObject);	
		}
		
		if( _containerInv )
		{
			optionsItemActions.PushBack(IAT_Transfer);
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name","DEBUG_TRANSFER");
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		else if (_shopNpc)
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			if ( _currentInv == _shopInv || _currentInv == _containerInv )
			{
				itemAction = IAT_Buy;
			}
			else
			{
				itemAction = IAT_Sell;
			}
			optionsItemActions.PushBack(itemAction);
			l_flashObject.SetMemberFlashString("name","DEBUG_SELL_BUY"); // GetItemActionFriendlyName(itemAction,GetWitcherPlayer().IsItemEquipped(item));
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		
		m_flashValueStorage.SetFlashArray( "inventory.rightclickmenu.options", l_flashArray );*/
	}
	
	function GetItemDefaultAction( item : SItemUniqueId ) : string
	{
		/*var itemAction : EInventoryActionType;
		itemAction = _gridInv.GetItemActionType( item, true );
		
		optionsItemActions.PushBack(itemAction);
		return GetItemActionFriendlyName(itemAction,GetWitcherPlayer().IsItemEquipped(item)); */
		return "FIXME";
	}

	event /*flash*/ OnCloseMenu()
	{
		//theSound.SoundEvent( 'gui_global_quit' ); // #B sound - quit
		var parentMenu : CR4MenuBase;
		CloseMenu();
		parentMenu = (CR4MenuBase)GetMenuInitData();
		parentMenu.OnCloseMenu();
		parentMenu.CloseMenu();
	}
	
	// ITEMS EVENTS
	
	event /*flash*/ OnEquipItem( item : SItemUniqueId, slot : int, quantity : int ) // ?
	{
		var i : int;
		var itemOnSlot : SItemUniqueId;
		//if( slot == EES_PotionMutagen1 )
	//	{
			slot = EES_PotionMutagen1;
			for(i = EES_PotionMutagen1; i < EES_PotionMutagen4 + 1; i += 1 )
			{
				GetWitcherPlayer().GetItemEquippedOnSlot(i, itemOnSlot);
				
				if( !_inv.IsIdValid(itemOnSlot) )
				{
					slot = i;
					break;
				}
			}
			//deprecated anyways
			/*
			if (GetWitcherPlayer().DrinkMutagenPotion( item, slot ) )
			{
				_gridInv.EquipItemInGivenSlot( item, slot ); // ?
			}*/
	//	}
		UpdateData(); //@FIXME BIDON - now we can update only two , previous and new one
		UpdateToxicityBar();
	}
		
	event /*flash*/ OnSetCurrentPlayerGrid( value : string )
	{
		
	}
	
	event /*flash*/ OnMoveItem( item : SItemUniqueId, moveToIndex : int )
	{
		//PlaySoundEvent();
		_gridInv.MoveItem( item , moveToIndex );
		UpdateData(); //@FIXME BIDON - now we can update only two , previous and new one
	}

	event /*flash*/ OnMoveItems( item : SItemUniqueId, moveToIndex : int, itemSecond : SItemUniqueId, moveToSecondIndex : int )
	{
		//PlaySoundEvent();
		_gridInv.MoveItems( item, moveToIndex, itemSecond, moveToSecondIndex);
		UpdateData(); //@FIXME BIDON - now we can update only two , previous and new one
	}

	// TOOLTIPS EVENTS

	event /*flash*/ OnUpdateTooltipCompareData( item : SItemUniqueId, compareItemType : int, tooltipName : string )
	{
		/*var itemName : string;
		var compareItem : SItemUniqueId;
		var tooltipInv : CInventoryComponent;
		
		GetWitcherPlayer().GetItemEquippedOnSlot(compareItemType,compareItem);
		
		itemName = _inv.GetItemName(item);
		if( tooltipName == "" ) // #B a little haxy
		{
			tooltipName= "tooltip";
		}
		if( _currentInv == _shopInv )
		{
			tooltipInv = _shopNpc.GetInventory();
		}	
		else if( _currentInv == _containerInv)
		{
			tooltipInv = _container.GetInventory();
		}
		else
		{
			tooltipInv = _inv;
		}
		
		UpdateTooltipCompareData(item,compareItem,tooltipInv,tooltipName);*/
	}	

	event /*flash*/ OnUpdateRightMenuOptions( item : SItemUniqueId )
	{
		//theSound.SoundEvent('gui_inventory_item_menu');
		//UpdateRightMenuOptionsData(item);
	}	

	event /*flash*/ OnRightMenuOptionChoosen( itemId : SItemUniqueId, quantity : int, actionValue : int )
	{
		/*var itemName : name;
		
		itemName = _inv.GetItemName(itemId);
	
		LogChannel('INVENTORY',"OnRightMenuOptionChoosen "+actionValue+" item name "+itemName );
		
		if( quantity < 0 )
		{
			quantity = 1;
		}
		
		switch( optionsItemActions[actionValue] )
		{
			case IAT_Equip :
				if( GetWitcherPlayer().IsItemEquipped(itemId) )
				{
					_gridInv.UnequipItem( itemId );
				}
				else
				{
					OnEquipItem( itemId, _inv.GetSlotForItemId(itemId), quantity );
				}
				UpdateData(); //@FIXME BIDON - now we can update only two , previous and new one
				break;	
			case IAT_Consume :
				_gridInv.ConsumeItem( itemId );
				FactsAdd("item_use_" + itemName, 1, 3);
				break;
			case IAT_MobileCampfire:
				GetWitcherPlayer().PlaceMobileCampfire(itemId);
				FactsAdd("item_use_" + itemName, 1, 3);
				break;
			case IAT_Read :
				ReadBook(itemId);
				break;			
			case IAT_Drop :
				_gridInv.DropItem( itemId, quantity );
				UpdateData(); //@FIXME BIDON - now we can update only one - previous	
			case IAT_Transfer :
				if( _currentInv == _containerInv )
				{
					TakeItem(itemId,quantity);
				}	
				else
				{
					GiveItem(itemId, quantity);
				}
				UpdateData(); //@FIXME BIDON - now we can update only one - previous
				UpdateContainer();
				break;	
			case IAT_Sell :
				SellItem(itemId,quantity);
				UpdateData(); //@FIXME BIDON - now we can update only one - previous
				UpdateShop();
				break;	
			case IAT_Buy :
				BuyItem(itemId,quantity);
				UpdateData(); //@FIXME BIDON - now we can update only one - previous
				UpdateShop();
				break;
		}*/
	}	
}
