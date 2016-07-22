/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state OpenInventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_INVENTORY : name;
	
		default OPEN_FAST_MENU = 'TutorialFoodOpenFastMenu';
		default OPEN_INVENTORY = 'TutorialFoodOpenInventory';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		//close hint asking to open menus
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_FAST_MENU );
		
		ShowHint(OPEN_INVENTORY, 0.35f, 0.6f, ETHDT_Infinite, GetHighlightHubMenuInventory() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_INVENTORY);
		
		super.OnLeaveState(nextStateName);
	}	
}
