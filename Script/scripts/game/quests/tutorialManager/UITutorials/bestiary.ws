/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state Bestiary in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BESTIARY_DESCRIPTION, BESTIARY_CLOSE, OPEN_BESTIARY : name;
	private var isClosing : bool;
	
		default OPEN_BESTIARY = 'TutorialBestiaryOpenBestiary';
		default BESTIARY_DESCRIPTION = 'TutorialBestiary';
		default BESTIARY_CLOSE = 'TutorialBestiaryClose';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_BESTIARY );
		ShowHint(BESTIARY_DESCRIPTION, 0.02f, 0.65f);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(BESTIARY_DESCRIPTION);
		CloseStateHint(BESTIARY_CLOSE);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == BESTIARY_DESCRIPTION)
			ShowHint(BESTIARY_CLOSE, 0.02f, 0.65f, ETHDT_Infinite);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'GlossaryBestiaryMenu')
			QuitState();
	}
}