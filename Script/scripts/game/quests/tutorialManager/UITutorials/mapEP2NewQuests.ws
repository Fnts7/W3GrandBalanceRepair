state MapEP2NewQuests in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION : name;
	
		default DESCRIPTION = 'TutorialMapEP2QuestPins';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint( DESCRIPTION, POS_MAP_X, POS_MAP_Y );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(DESCRIPTION);
		
		super.OnLeaveState(nextStateName);
	}	
}