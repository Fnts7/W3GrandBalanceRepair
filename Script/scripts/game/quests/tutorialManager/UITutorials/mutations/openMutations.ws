state MutationsOpenMutations in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialMutationsOpenMutations';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		ShowHint( TUTORIAL, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite, GetHighlightsCharPanelMutation() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint( TUTORIAL );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
}