/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

/*
disabled

state NoticeBoard in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var NOTICE_BOARD : name;
	
		default NOTICE_BOARD = 'TutorialQuestBoard';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(NOTICE_BOARD, 0.67f, 0.7f, ETHDT_Infinite);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(NOTICE_BOARD);
		theGame.GetTutorialSystem().MarkMessageAsSeen(NOTICE_BOARD);
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'NoticeBoardMenu')
			QuitState();
	}
	
	event OnMenuClosed(menuName : name)
	{
		if(menuName == 'NoticeBoardMenu')
			QuitState();
	}
}
*/