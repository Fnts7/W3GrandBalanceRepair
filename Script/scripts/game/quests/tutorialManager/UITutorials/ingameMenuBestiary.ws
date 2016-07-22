/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state IngameMenuBestiary in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_GLOSSARY, OPEN_GAME_MENU : name;
	
		default OPEN_GLOSSARY = 'TutorialBestiaryOpenGlossary';
		default OPEN_GAME_MENU = 'TutorialBestiaryOpenMenu';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_GAME_MENU );
				
		ShowHint( OPEN_GLOSSARY, 0.65f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuGlossary() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_GLOSSARY);
		
		super.OnLeaveState(nextStateName);
	}

	event OnMenuClosing(menuName : name)
	{		
		QuitState();
	}
}