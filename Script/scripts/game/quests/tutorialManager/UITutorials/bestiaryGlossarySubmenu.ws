state BestiaryGlossarySubmenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_GLOSSARY, OPEN_BESTIARY : name;
	
		default OPEN_GLOSSARY = 'TutorialBestiaryOpenGlossary';
		default OPEN_BESTIARY = 'TutorialBestiaryOpenBestiary';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_GLOSSARY );
				
		ShowHint( OPEN_BESTIARY, 0.65f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuGlossary() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(OPEN_BESTIARY);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{		
		QuitState();
	}
}