/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

//**********************************************************************************************************************************************
//**********************************************************************************************************************************************
state JournalQuest in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialJournalQuests';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(TUTORIAL, POS_QUESTS_X, POS_QUESTS_Y, ETHDT_Infinite);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(TUTORIAL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'JournalQuestMenu')
			QuitState();
	}
}

//**********************************************************************************************************************************************
//**********************************************************************************************************************************************
/*
state JournalMonsterHunt in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialJournalMonsterHunt';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(TUTORIAL, 0.7, 0.3, ETHDT_Infinite);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(TUTORIAL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'JournalQuestMenu')
			QuitState();
	}
}

//**********************************************************************************************************************************************
//**********************************************************************************************************************************************
state JournalTreasureHunt in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TUTORIAL : name;
	
		default TUTORIAL = 'TutorialJournalTreasureHunt';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(TUTORIAL, 0.7, 0.3, ETHDT_Infinite);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(TUTORIAL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnMenuClosing(menuName : name)
	{
		if(menuName == 'JournalQuestMenu')
			QuitState();
	}
}
*/
exec function jour()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('journal', '');
}