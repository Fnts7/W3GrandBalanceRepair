/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state Runes in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT, RUNE, SWORD : name;
	
		default SELECT 		= 'TutorialRunesSelectRune';
		default RUNE 		= 'TutorialRunesUseRune';
		default SWORD 		= 'TutorialRunesSelectSword';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint( SELECT, .5f, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabWeapons() );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SELECT);
		CloseStateHint(RUNE);
		CloseStateHint(SWORD);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SWORD);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT) && thePlayer.inv.ItemHasTag(itemId, 'WeaponUpgrade'))
		{
			//if selected rune
			CloseStateHint(SELECT);
			ShowHint(RUNE, .5f, POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(IsCurrentHint(RUNE) && !thePlayer.inv.ItemHasTag(itemId, 'WeaponUpgrade'))
		{
			//if had rune selected but then changed selection to not a rune or when aborted selection menu and moved around
			CloseStateHint(RUNE);
			ShowHint(SELECT, .5f, POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
	
	event OnSelectingSword()
	{
		CloseStateHint(RUNE);
		ShowHint(SWORD, .5f, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnSelectingSwordAborted()
	{
		CloseStateHint(SWORD);
		ShowHint(RUNE, .5f, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnUpgradedItem()
	{
		QuitState();
	}
}

exec function tut_runes()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('runes', '');
	thePlayer.inv.AddAnItem('Veles rune',3);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 3',1);
}