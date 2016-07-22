state MutationsEquippedCharPanel in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var EQUIPPED, MUTAGENS, MASTER : name;
	private var isClosing : bool;
	
		default EQUIPPED = 'TutorialMutationsEquippedCharPanel';
		default MUTAGENS = 'TutorialMutationsMutagens';
		default MASTER = 'TutorialMutationsMasterMutation';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
		
		ShowHint( EQUIPPED, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightsCharPanelMutation() );
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( EQUIPPED );
		CloseStateHint( MUTAGENS );
		CloseStateHint( MASTER );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
	
	event OnTutorialClosed( hintName : name, closedByParentMenu : bool )
	{
		var highlights : array< STutorialHighlight >;
		
		if( closedByParentMenu || isClosing )
		{
			return true;
		}
		
		if( hintName == EQUIPPED )
		{
		/*
			ShowHint( MUTAGENS, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightsCharPanelMutagenSlots() );
		}
		else if( hintName == MUTAGENS )
		{*/
			ShowHint( MASTER, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightsCharPanelMutationSkillSlots() );
		}
		else if( hintName == MASTER )
		{
			QuitState();
		}
	}
}