/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state CharacterDevelopmentFastMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PANEL, CHAR_DEV_OPEN : name;
	
		default PANEL 				= 'TutorialCharDevPanel';
		default CHAR_DEV_OPEN 		= 'TutorialCharDevOpen';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( CHAR_DEV_OPEN );
		
		ShowHint(PANEL, 0.5, 0.7, ETHDT_Infinite, GetHighlightHubMenuCharDev() );
	}

	event OnLeaveState( nextStateName : name )
	{		
		CloseStateHint(PANEL);
		
		super.OnLeaveState(nextStateName);
	}		
}