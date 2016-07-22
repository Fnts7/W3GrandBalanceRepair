state MutationsFirstOpen in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var GET_STUFF : name;
	
		default GET_STUFF = 'TutorialMutationsMissingResources';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		if( GetWitcherPlayer().HasResourcesToStartAnyMutationResearch() )
		{
			QuitState();
		}
		else
		{
			ShowHint( GET_STUFF, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input );
		}
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
	
	event OnTutorialClosed( hintName : name, closedByParentMenu : bool )
	{
		if( hintName == GET_STUFF )
		{
			QuitState();
		}
	}
}