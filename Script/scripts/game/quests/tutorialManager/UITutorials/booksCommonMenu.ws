state BooksCommonMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_COMMON_MENU, SELECT_GLOSSARY : name;
		
		default OPEN_COMMON_MENU	= 'TutorialBooksOpenCommonMenu';
		default SELECT_GLOSSARY		= 'TutorialBooksSelectGlossary';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		//close hint asking to open menus
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_COMMON_MENU );
		theGame.GetTutorialSystem().MarkMessageAsSeen( OPEN_COMMON_MENU );
		
		//hint about going to glossary panel
		ShowHint( SELECT_GLOSSARY, 0.35f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuGlossary(), , , true );		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SELECT_GLOSSARY);
		
		super.OnLeaveState(nextStateName);
	}	
}