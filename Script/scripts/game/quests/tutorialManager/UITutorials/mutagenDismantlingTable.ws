state MutagenDismantlingTable in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, WHY_DO_IT : name;
	private var isClosing : bool;
	
		default DESCRIPTION 	= 'TutorialMutagenTableDescription';
		default WHY_DO_IT 		= 'TutorialMutagenTableWhyDoIt';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint( DESCRIPTION, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		theGame.GetTutorialSystem().MarkMessageAsSeen( DESCRIPTION );
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(WHY_DO_IT);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == DESCRIPTION)
		{
			ShowHint( WHY_DO_IT, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if(hintName == WHY_DO_IT)
		{
			QuitState();
		}
	}
}