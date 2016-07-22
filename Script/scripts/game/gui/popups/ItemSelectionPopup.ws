/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

enum EItemSelectionPopupMode
{
	EISPM_Default,
	EISPM_ArmorStand,
	EISPM_SwordStand,
	EISPM_Painting,	
}


class W3ItemSelectionPopupData extends CObject
{
	var targetInventory : CInventoryComponent;
	var filterTagsList : array<name>;
	var filterForbiddenTagsList : array<name>;	
	var categoryFilterList : array<name>;	
	var collectorTag : name;
	var targetItems : array<name>;
	var selectionMode : EItemSelectionPopupMode;
	var overrideQuestItemRestrictions : bool;
}

class CR4ItemSelectionPopup extends CR4PopupBase
{
	var m_DataObject     : W3ItemSelectionPopupData;
	var m_playerInv      : W3GuiSelectItemComponent;
	var m_containerInv   : W3GuiContainerInventoryComponent;
	var m_containerOwner : CGameplayEntity;
	var m_selectedItemCategory : int;
	
	default m_selectedItemCategory = 0;
	
	event  OnConfigUI()
	{
		super.OnConfigUI();
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		m_DataObject = (W3ItemSelectionPopupData)GetPopupInitData();		
		
		if (!m_DataObject)
		{
			ClosePopup();
		}
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.5, 0.5);
		}
		
		m_playerInv = new W3GuiSelectItemComponent in this;
		m_playerInv.Initialize( thePlayer.GetInventory() );
		m_playerInv.filterTagList = m_DataObject.filterTagsList;
		m_playerInv.filterForbiddenTagList = m_DataObject.filterForbiddenTagsList;
		
		switch( m_DataObject.selectionMode )
		{
			case EISPM_Default :
			{
				
				m_playerInv.SetFilterType( IFT_QuestItems );
			}
			break;
			
			case EISPM_ArmorStand :
			{
				
				m_playerInv.SetFilterType( IFT_Armors );
				
				if( m_DataObject.categoryFilterList.Size() > 0 )
				{
					m_playerInv.SetItemCategoryType( m_DataObject.categoryFilterList[m_selectedItemCategory] );	
				}
				else
				{
					m_playerInv.SetItemCategoryType( 'armor' );
				}
				
				
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );
			}
			break;
			
			case EISPM_SwordStand :
			{
				
				m_playerInv.SetFilterType( IFT_Weapons );
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
			}
			break;	
			
			case EISPM_Painting :
			{
				
				m_playerInv.SetFilterType( IFT_None );
				m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
			}
			break;
			
		}
		
		
		m_containerOwner = (CGameplayEntity)theGame.GetEntityByTag( m_DataObject.collectorTag );
		
		
		
		UpdateData();
		
		
		m_guiManager.RequestMouseCursor(true);
		theGame.ForceUIAnalog(true);
		
		theGame.Pause("ItemSelectionPopup");
	}
	
	event  OnCloseSelectionPopup()
	{
		ClosePopup();
	}
	
	event  OnCallSelectItem(itemId : SItemUniqueId)
	{
		var len, i : int;
		
		switch( m_DataObject.selectionMode )
		{
			
			case EISPM_Default :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					len = m_DataObject.targetItems.Size();
					for (i = 0; i < len; i=i+1 )
					{
						
						if (m_DataObject.targetItems[i] == m_playerInv.GetItemName(itemId))
						{
							thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
							break;
						}
					}
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_ArmorStand :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					
					while( m_selectedItemCategory <= m_DataObject.categoryFilterList.Size() )
					{
						if(TryToOpenNextCategory())
						{
							return true;
						}
					}
					
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_SwordStand :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					ClosePopup();
				}
			}
			break;
			
			
			case EISPM_Painting :
			{
				if (thePlayer.GetInventory().IsIdValid(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					ClosePopup();
				}
			}
			break;		
			
		}
	}
	
	event  OnInventoryItemSelected(itemId : SItemUniqueId)
	{
		
	}
	
	event  OnClosingPopup()
	{
		theGame.Unpause("ItemSelectionPopup");
		
		if (m_containerInv)
		{
			delete m_containerInv;
		}
		
		if (m_playerInv)
		{
			delete m_playerInv;
		}
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		theGame.ForceUIAnalog(false);
		m_guiManager.RequestMouseCursor(false);
		
		super.OnClosingPopup();
	}
	
	
	private function ClearPopupSelection()
	{
		m_playerInv.SetItemCategoryType( 'none' );
		UpdateData();
	}
	
	
	private function TryToOpenNextCategory() : bool
	{
		var stand : W3HouseDecorationBase;
		
		m_selectedItemCategory += 1;
		ClearPopupSelection();
		
		stand = (W3HouseDecorationBase) m_containerOwner;
		
		
		if( !stand )
		{
			return false;
		}
		
		
		if( stand.GetHasSleevlessArmor() && m_DataObject.categoryFilterList[m_selectedItemCategory] == 'gloves' )
		{
			return false;
		}
		
		
		if( !thePlayer.GetInventory().GetHasValidDecorationItems( thePlayer.inv.GetItemsByCategory( m_DataObject.categoryFilterList[m_selectedItemCategory] ), stand ) )
		{
			return false;
		}
		
		m_playerInv.SetItemCategoryType( m_DataObject.categoryFilterList[m_selectedItemCategory] );
		UpdateData();		
		
		return true;
	}
	
	
	private function UpdateData():void
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();		
		m_playerInv.GetInventoryFlashArray(l_flashArray, l_flashObject);		
		m_flashValueStorage.SetFlashArray( "repair.grid.player", l_flashArray );
	}
	
}