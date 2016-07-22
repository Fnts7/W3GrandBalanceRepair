/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state OpenWorldMap in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_MAP : name;
	
		default OPEN_FAST_MENU = 'TutorialMapOpenFastMenu';
		default OPEN_MAP = 'TutorialMapOpenMap';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		//close hint asking to open menus
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_FAST_MENU );
		
		ShowHint(OPEN_MAP, 0.35f, 0.6f, ETHDT_Infinite, GetHighlightHubMenuMap() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_MAP);
		
		super.OnLeaveState(nextStateName);
	}	
}
