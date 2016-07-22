state SetItemsInfo in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INFO : name;
	private var isClosing : bool;
	
		default INFO	= 'TutorialSetBonusesInfo';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( INFO );
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		QuitState();
	}
	
	event OnSetItemSelected()
	{
		ShowHint( INFO, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, , , , true );		
	}
}