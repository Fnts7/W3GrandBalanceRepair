/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state Books in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_TAB, SELECT_BOOK, USE : name;
	private var isClosing : bool;
	
		default SELECT_TAB 		= 'TutorialBooksSelectTab';
		default SELECT_BOOK 	= 'TutorialBooksSelectBook';
		default USE 			= 'TutorialBooksUse';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		if(currentTab == InventoryMenuTab_Potions)
		{
			OnSelectedTab(true);
		}
		else
		{
			highlights.Resize(1);
			highlights[0].x = 0.268;
			highlights[0].y = 0.145;
			highlights[0].width = 0.06;
			highlights[0].height = 0.09;
				
			ShowHint(SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, highlights);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(SELECT_TAB);
		CloseStateHint(SELECT_BOOK);
		CloseStateHint(USE);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT_BOOK) && thePlayer.inv.ItemHasTag(itemId, 'ReadableItem') )
		{
			//if selected book
			CloseStateHint(SELECT_BOOK);
			ShowHint(USE, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(IsCurrentHint(USE) && !thePlayer.inv.ItemHasTag(itemId, 'ReadableItem') )
		{
			//if had book selected but then changed selection to not a book
			CloseStateHint(USE);
			ShowHint(SELECT_BOOK, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}

	event OnSelectedTab(properTab : bool)
	{
		if(IsCurrentHint(SELECT_TAB) && properTab)
		{
			CloseStateHint(SELECT_TAB);
			ShowHint(SELECT_BOOK, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(!IsCurrentHint(SELECT_TAB) && !properTab)
		{
			CloseStateHint(SELECT_BOOK);
			CloseStateHint(USE);
			ShowHint(SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
	
	event OnBookRead()
	{
		QuitState();
	}
}