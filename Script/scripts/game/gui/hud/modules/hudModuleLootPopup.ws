class CR4HudModuleLootPopup extends CR4HudModuleBase
{
	private const var KEY_LOOT_ITEM_LIST				:string; 		default KEY_LOOT_ITEM_LIST 		= "LootItemList";
	
	//private var _dpLootItems : W3HudLootItemsDataProvider;
	private var container : W3Container;
	
	private var m_flashValueStorage 	: CScriptedFlashValueStorage;
	private	var m_fxSetWindowTitle		: CScriptedFlashFunction;
	private	var m_fxOpenPC				: CScriptedFlashFunction;
	private	var m_fxOpenConsole			: CScriptedFlashFunction;
	private	var m_fxSetSelectionIndex	: CScriptedFlashFunction;

	public var bCurrentShowState 		: bool;	default bCurrentShowState = false;
	
	private var m_indexToSelect			: int;
	
	///////////////////////////////////////////////////////////////////////////////////////////
	//    W           W       A      TTTTTTTT   CCCC   H   H           OOOO  U    U TTTTTTT
	//    W           W      A A        T      C    c  H   H          O    O U    U    T
	//     W    W    W      A   A       T      C       HHHHH          O    O U    U    T
	//      W  W  W W      A AAA A      T      C    c  H   H          O    O U    U    T
	//        W    W      A       A     T       CCCC   H   H           OOOO   UUUU     T
	///////////////////////////////////////////////////////////////////////////////////////////
	// This file is deprecated system. Looting moved to LootPopup.ws. Did not delete to avoid
	// breaking things. Also used a reference to how it worked before in case anything broke.
	///////////////////////////////////////////////////////////////////////////////////////////

	event /* flash */ OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();

		m_anchorName = "mcAnchorLootPopup";
		
		super.OnConfigUI();		
		flashModule 			= GetModuleFlash();	
		m_flashValueStorage 	=  GetModuleFlashValueStorage();
		
		m_fxSetWindowTitle		= flashModule.GetMemberFlashFunction( "SetWindowTitle" );
		m_fxOpenPC				= flashModule.GetMemberFlashFunction( "OpenPC" );
		m_fxOpenConsole			= flashModule.GetMemberFlashFunction( "OpenConsole" );
		m_fxSetSelectionIndex	= flashModule.GetMemberFlashFunction( "SetSelectionIndex" );
		
		// OPEN PC OR CONSOLE VERSION
		//m_fxOpenPC.InvokeSelf();
		m_fxOpenConsole.InvokeSelf();
		
		//ShowElement(false);		
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return super.UpdateScale( scale - theGame.GetUIGamepadScaleGain(), flashModule );
	}
	
	function PopulateData()
	{
		var i, j, length					: int;
		var l_lootItemsFlashArray			: CScriptedFlashArray;
		var l_lootItemsDataFlashObject 		: CScriptedFlashObject;
		var l_lootItemStatsFlashArray		: CScriptedFlashArray;
		var l_lootItemStatsDataFlashObject	: CScriptedFlashObject;
		
		var l_containerInv 					: CInventoryComponent = container.GetInventory();
		var l_item 							: SItemUniqueId;
		var l_itemName						: string;
		var l_itemIconPath					: string;
		var l_itemQuantity					: int;
		var l_itemPrice						: float;
		var l_weight 						: float;
		var itemUIData						: SInventoryItemUIData;
		
		var l_allItems						: array<SItemUniqueId>;
		
		var l_primaryStatLabel   			: string;
		var l_primaryStatValue    			: float;

		var l_statsList						: CScriptedFlashArray;
		var l_itemStats 					: array<SAttributeTooltip>;
		var l_compareItem 					: SItemUniqueId;
		var l_compareItemStats				: array<SAttributeTooltip>;
		var l_itemTags 						: array<name>;
		var l_typeStr 						: string;
		
		l_containerInv.GetAllItems( l_allItems );
		
		//remove items that shouldn't be shown		
		for(i=l_allItems.Size()-1; i>=0; i-=1)
			if( l_containerInv.ItemHasTag(l_allItems[i], theGame.params.TAG_DONT_SHOW ) && !l_containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
				l_allItems.Erase(i);
		
		length	= l_allItems.Size();
		
		l_lootItemsFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_lootItemsFlashArray.SetLength( length );
		
		for	( i = 0 ; i < length; i+=1 )
		{
			l_item			= l_allItems[i];
			l_itemName 		= l_containerInv.GetItemLocalizedNameByUniqueID(l_item);
			
			l_itemName = GetLocStringByKeyExt(l_itemName);
			if(l_containerInv.IsItemSingletonItem(l_item))
			{
				l_itemQuantity = thePlayer.inv.SingletonItemGetAmmo(l_item); // #B SINGLETON ITEM CHECK !!!
			}
			else
			{
				l_itemQuantity = l_containerInv.GetItemQuantity( l_item );
			}
			// Pop-up does not display a Price.
			//l_itemPrice = l_containerInv.GetItemPrice( l_item );
			l_itemIconPath	= l_containerInv.GetItemIconPathByUniqueID( l_item );
			
			if( l_containerInv.ItemHasTag(l_item, 'Quest') || l_containerInv.IsItemIngredient(l_item) || l_containerInv.IsItemAlchemyItem(l_item) ) // #B item weight check
			{
				l_weight = 0;
			}
			else
			{
				l_weight = l_containerInv.GetItemEncumbrance( l_item );
			}
			
			l_lootItemsDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_lootItemsDataFlashObject.SetMemberFlashString ( "WeightValue", NoTrailZeros(l_weight));
			l_lootItemsDataFlashObject.SetMemberFlashString	( "label", l_itemName );
			l_lootItemsDataFlashObject.SetMemberFlashInt	( "quantity", l_itemQuantity );
			l_lootItemsDataFlashObject.SetMemberFlashNumber	( "PriceValue", l_itemPrice );
			l_lootItemsDataFlashObject.SetMemberFlashString ( "iconPath", l_itemIconPath );
			l_lootItemsDataFlashObject.SetMemberFlashInt	( "quality", l_containerInv.GetItemQuality( l_item ) );
			
			l_containerInv.GetItemTags(l_item,l_itemTags);
			GetWitcherPlayer().GetItemEquippedOnSlot(GetSlotForItem(l_containerInv.GetItemCategory(l_item),l_itemTags, true), l_compareItem);
			
			if( l_containerInv.GetItemName(l_item) != GetWitcherPlayer().GetInventory().GetItemName(l_compareItem) ) // #B by name because they could be in different inventoryComponents, and then they have different id
			{
				GetWitcherPlayer().GetInventory().GetItemStats(l_compareItem, l_compareItemStats);
			}
			l_statsList = m_flashValueStorage.CreateTempFlashArray();
			l_containerInv.GetItemStats(l_item, l_itemStats);
			CompareItemsStats(l_itemStats, l_compareItemStats, l_statsList);
			
			l_lootItemsDataFlashObject.SetMemberFlashArray("StatsList", l_statsList);
			
			l_typeStr = GetLocStringByKeyExt(GetFilterTypeName( l_containerInv.GetFilterTypeByItem(l_item) )) + " / " + GetItemRarityDescription(l_item, l_containerInv);
			l_lootItemsDataFlashObject.SetMemberFlashString("itemType", l_typeStr );
				
			if(l_containerInv.HasItemDurability(l_item))
			{
				l_lootItemsDataFlashObject.SetMemberFlashString("DurabilityValue", NoTrailZeros(l_containerInv.GetItemDurability(l_item)/l_containerInv.GetItemMaxDurability(l_item) * 100));
			}
			else
			{
				l_lootItemsDataFlashObject.SetMemberFlashString("DurabilityValue", "");
			}
			l_containerInv.GetItemPrimaryStat(l_item, l_primaryStatLabel, l_primaryStatValue);
			
			l_lootItemsDataFlashObject.SetMemberFlashString("PrimaryStatLabel", l_primaryStatLabel);
			l_lootItemsDataFlashObject.SetMemberFlashNumber("PrimaryStatValue", l_primaryStatValue);	
			
			l_lootItemsFlashArray.SetElementFlashObject( i, l_lootItemsDataFlashObject );
		}
		
		m_flashValueStorage.SetFlashArray( KEY_LOOT_ITEM_LIST, l_lootItemsFlashArray );
		
		m_fxSetWindowTitle.InvokeSelfOneArg( FlashArgString( container.GetDisplayName() ) );		
	}
	
	function CompareItemsStats(itemStats : array<SAttributeTooltip>, compareItemStats : array<SAttributeTooltip>, out compResult : CScriptedFlashArray)
	{
		var l_flashObject	: CScriptedFlashObject;
		var attributeVal 	: SAbilityAttributeValue;
		var strDifference 	: string;		
		var percentDiff 	: float;
		var nDifference 	: float;
		var i, j, price 	: int;
		
		strDifference = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);
			l_flashObject.SetMemberFlashString("color",itemStats[i].attributeColor);
			
			//HERE, WE'RE COMPARING STATS AGAINST POSSIBLE OVERLAPS WITH A POSSIBLY EQUIPPED SIMILAR ITEM IN ORDER TO SHOW BENEFIT DIFFERENCE
			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					nDifference = itemStats[j].value - compareItemStats[i].value;
					percentDiff = AbsF(nDifference/itemStats[j].value);
					
					//better
					if(nDifference > 0)
					{
						if(percentDiff < 0.25) //1 arrow
							strDifference = "better";
						else if(percentDiff > 0.75) //3 arrows
							strDifference = "wayBetter";
						else						//2 arrows
							strDifference = "reallyBetter";
					}
					//worse
					else if(nDifference < 0)
					{
						if(percentDiff < 0.25) //1 arrow
							strDifference = "worse";
						else if(percentDiff > 0.75) //3 arrows
							strDifference = "wayWorse";
						else						//2 arrows
							strDifference = "reallyWorse";					
					}
					break;					
				}
			}
			l_flashObject.SetMemberFlashString("icon", strDifference);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				if(itemStats[i].value < 0)
					l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value));
				else
					l_flashObject.SetMemberFlashString("value","+" + NoTrailZeros(itemStats[i].value));				
			}
			compResult.PushBackFlashObject(l_flashObject);
		}	
	}
	
	function GetItemRarityDescription( item : SItemUniqueId, tooltipInv : CInventoryComponent ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}

	function Open( con : W3Container )
	{
		container =  con;
		
		theSound.SoundEvent("gui_loot_popup_open");

		m_fxSetSelectionIndex.InvokeSelfOneArg( FlashArgInt( 0 ) );
		PopulateData();

		thePlayer.SetIsMovable(false);
		theGame.GetFocusModeController().Deactivate();
		bCurrentShowState = true;
		//ignoreActions(true); 	WZ: removed because changing context already does the job of blocking actions, and this line only caused interior camera to kick in
		thePlayer.LockButtonInteractions( PIL_Default );
		
		theInput.StoreContext( 'LootPopup' );
		
		//tutorial
		if(ShouldProcessTutorial('TutorialContainers'))
		{
			FactsAdd("tutorial_container_open", 1, 1 );	
		}
		
		SignalLootingReactionEvent();
	}

	event /*flash*/ OnCloseLootWindow() //#B event because it is also called from LootPopup swf during hide
	{
		var hud : CR4ScriptedHud;
		
		if( bCurrentShowState && container ) // #B don't close it to many times
		{
			SignalContainerClosedEvent();
			ShowElement(false); // #B Show
			container.OnContainerClosed();
			GetWitcherPlayer().SetUITakeInput(false);
			bCurrentShowState = false;
			thePlayer.SetIsMovable(true);
			//ignoreActions(false);
			thePlayer.UnlockButtonInteractions( PIL_Default );
			
			theInput.RestoreContext( 'LootPopup', false);
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			//tutorial
			if(ShouldProcessTutorial('TutorialLootWindow'))
			{
				FactsAdd("tutorial_container_close", 1, 1 );	
			}
		}
	}
	
	event OnPopupTakeAllItems( ) : void
	{
		if( !bCurrentShowState )
		{
			return true;
		}
		SignalStealingReactionEvent();
		TakeAllAction();
		OnCloseLootWindow();
	}
	
	event OnPopupTakeItem( Id : int ) : void
	{
		var containerInv 		: CInventoryComponent;
		var playerInv 			: CInventoryComponent;
		var item 				: SItemUniqueId;
		var invalidatedItems 	: array< SItemUniqueId >;
		var itemName 			: name;
		var itemQuantity, i		: int;
		var category			: name;
		
		var l_allItems						: array<SItemUniqueId>;
				
		if( !bCurrentShowState )
		{
			return true;
		}
		
		SignalStealingReactionEvent();
		
		/*if( StealingCheck( container ) ) // #B add information about stealing not allowed
		{
			// ShowElement(false); //#B Show
			container.OnContainerClosed();
			GetWitcherPlayer().SetUITakeInput(false);
			thePlayer.SetIsMovable(true);
			ignoreActions(false);
			return false;
		}*/
		
		m_indexToSelect = Id;
		
		containerInv 	= container.GetInventory();
		playerInv 		= GetWitcherPlayer().inv;
		containerInv.GetAllItems( l_allItems );
		
		for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
		{
			if( ( containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
			{
				l_allItems.Erase(i);
			}
		}
		
		item 			= l_allItems[ Id ];
		itemName 		= containerInv.GetItemName(item);
		itemQuantity 	= containerInv.GetItemQuantity(item);
		if( containerInv.ItemHasTag(item, 'HerbGameplay') )
		{
			category	 	= 'herb';
		}
		else
		{
			category	 	= containerInv.GetItemCategory(item);
		}
		
		containerInv.NotifyItemLooted( item );
		containerInv.GiveItemTo( playerInv, item, itemQuantity, true, false, true );
		PlayItemEquipSound( category );
		
		containerInv.GetAllItems( l_allItems );
		for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
		{
			if( (containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
			{
				l_allItems.Erase(i);
			}
		}
		
		if( container )
		{
			container.InformClueStash();
		}
		
		if( l_allItems.Size() == 0)
		{
			OnCloseLootWindow();
			container.Enable( false);
		}
		else
		{
			m_fxSetSelectionIndex.InvokeSelfOneArg( FlashArgInt( m_indexToSelect ) );
			PopulateData();
		}
	}
	
	private var safeLock : int;
	default safeLock = -1;
	
	protected function SignalLootingReactionEvent()
	{
		if ( container.disableStealing || container.HasQuestItem() || (W3Herb)container || (W3ActorRemains)container )
			return;
		
		theGame.CreateNoSaveLock("Stealing",safeLock,true);
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'LootingAction', -1, 10.0f, -1.f, -1, true); //reactionSystemSearch
	}
	
	protected function SignalStealingReactionEvent()
	{
		if ( container.disableStealing || container.HasQuestItem() || (W3Herb)container || (W3ActorRemains)container )
			return;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'StealingAction', -1, 10.0f, -1.f, -1, true); //reactionSystemSearch
	}
	
	protected function SignalContainerClosedEvent()
	{
		theGame.ReleaseNoSaveLock(safeLock);
		
		if ( container.disableStealing || container.HasQuestItem() || (W3Herb)container || (W3ActorRemains)container )
			return;
			
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'ContainerClosed', 10, 15.0f, -1.f, -1, true); //reactionSystemSearch
	}
	
	// 
	// -------------------------------------------------------------------------------	
	function TakeAllAction() : void
	{
		container.TakeAllItems();
		OnCloseLootWindow();
	}
	
	function ignoreActions ( _Ignore:bool )
	{
		thePlayer.BlockAllActions( 'Loot Popup', _Ignore );
	}
	
	public function ShowElement( bShow : bool, optional bImmediately : bool )
	{
		m_indexToSelect = 0;
		
		if( bShow )
		{
			super.ShowElement( bCurrentShowState, bImmediately );
			return;
		}
		else
		{
			theSound.SoundEvent("gui_loot_popup_close");
			bCurrentShowState = false;
		}
		super.ShowElement(bShow);		
	}
	
	/*function StealingCheck( container : W3Container ) : bool
	{
		var actorsInRange : array<CActor>;
		var actorsInRangeSize : int;
		var range : float = 15.0;
		var npc : CNewNPC;
		var i : int;
		var stealingHappened : bool;
		
		stealingHappened = false;
			
		if( !container.HasTag( 'Stealing' ) )
		{
			return false;
		}
		
		actorsInRange = GetActorsInRange( thePlayer, range, 100, '', true );
		actorsInRangeSize = actorsInRange.Size();
		
		if( actorsInRangeSize == 0 )
		{
			return false;
		}
		else
		{
			for( i = 0; i < actorsInRangeSize; i += 1 )
			{
				if( (CNewNPC)actorsInRange[i] && TestLineOfSight( (CNode)actorsInRange[i] ) && 
					IsNPCLookingAtPlayer( (CNode)actorsInRange[i] ) && !( actorsInRange[i].IsKnockedUnconscious() ) )
				{
					ProcessReaction( (CNewNPC)actorsInRange[i] );
					stealingHappened = true;
				}
			}
			
			return stealingHappened;
		}
	}*/
	
	function TestLineOfSight( node : CNode ) : bool
	{
		var traceStartPos, traceEndPos, traceEffect, normal : Vector;
		
		traceStartPos = thePlayer.GetWorldPosition();
		traceEndPos = node.GetWorldPosition();
		
		traceStartPos.Z += 1.8;
		traceEndPos.Z += 1.8;
		
		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			if( traceEndPos == traceEffect )
			{
				return true;
			}
			return false;
		}
		else
		{
			return true;
		}
	}
	
	function IsNPCLookingAtPlayer( node : CNode ) : bool
	{
		var maxAngle : float = 120.0; // times 2, so its 240
		var result : float;
		
      	result = AbsF( NodeToNodeAngleDistance( thePlayer, node ) );
		
		if( result < maxAngle )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function ProcessReaction( npc : CNewNPC )
	{
		GetWitcherPlayer().DisplayHudMessage( GetLocStringByKeyExt("panel_hud_message_thief") );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( npc, 'AttackAction', 1.0, 1.0f, 999.0f, 1, true); //reactionSystemOld
		LogReactionSystem( "'AttackAction' was sent by " + npc.GetName() + " - single broadcast - distance: 1.0" );
	}
}
