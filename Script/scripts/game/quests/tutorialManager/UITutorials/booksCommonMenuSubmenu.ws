state BooksCommonMenuSubmenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_BOOKS : name;
		
		default SELECT_BOOKS 		= 'TutorialBooksOpenBooks';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint( SELECT_BOOKS, 0.35f, 0.65f, ETHDT_Infinite, GetHighlightHubMenuBooks() );	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SELECT_BOOKS);
		
		super.OnLeaveState(nextStateName);
	}	
}