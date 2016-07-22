/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state HighLevelQuests in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION : name;
	private var isClosing : bool;
	
		default DESCRIPTION = 'TutorialHighLevelQuests';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, POS_QUESTS_X, POS_QUESTS_Y, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
		super.OnLeaveState(nextStateName);
	}	
}