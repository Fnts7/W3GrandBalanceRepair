/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state Betting in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION : name;
	private var isClosing : bool;
	
		default DESCRIPTION = 'TutorialBetting';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, 0.05f, 0.7f, , , true);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
		super.OnLeaveState(nextStateName);
	}	
}