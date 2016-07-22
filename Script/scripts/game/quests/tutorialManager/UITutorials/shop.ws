/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state Shop in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, BUY, CLOSE : name;
	private var isClosing : bool;
	private const var SHOP_POS_CLOSE_X, SHOP_POS_CLOSE_Y, SHOP_POS_X, SHOP_POS_Y : float;
	
		default DESCRIPTION = 'TutorialShopDescription';
		default BUY = 'TutorialShopBuy';
		default CLOSE = 'TutorialShopClose';
		default SHOP_POS_X = 0.3;
		default SHOP_POS_Y = 0.4;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, SHOP_POS_X, SHOP_POS_Y);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(BUY);
		CloseStateHint(CLOSE);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(hintName == DESCRIPTION && !closedByParentMenu && !isClosing)
		{
			CloseStateHint(DESCRIPTION);
			ShowHint(BUY, SHOP_POS_X, SHOP_POS_Y);
		}
		else if(hintName == BUY && !closedByParentMenu && !isClosing)
		{
			CloseStateHint(BUY);
			ShowHint(CLOSE, SHOP_POS_X, SHOP_POS_Y);
		}
	}
	
	event OnBoughtItem()
	{
		/*
		CloseStateHint(BUY);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY);
		ShowHint(CLOSE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
		*/
	}
}