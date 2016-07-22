state AlchemyBuy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BUY : name;
	private var isClosing : bool;
	
		default BUY = 'TutorialAlchemyBuy';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;		
	}
	
	//Tutorial DOES NOT UNREGISTER when leaving state, only when hint gets shown
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( BUY );
		
		LogTutorial( "UIHandler: leaving state <" + this + ">, next will be <" + nextStateName + ">" );
		
		if( theGame.GetTutorialSystem().HasSeenTutorial( BUY ) )
		{
			theGame.GetTutorialSystem().uiHandler.UnregisterUIState(GetStateName());
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if( hintName == BUY )
		{
			QuitState();
		}
	}
	
	event OnCanSellSomething()
	{
		ShowHint( BUY, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Input, GetHighlightCraftingIngredients(), , , true );
	}
}