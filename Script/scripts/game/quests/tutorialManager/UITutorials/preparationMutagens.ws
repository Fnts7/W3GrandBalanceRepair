/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/
/*


disabled, might be added in patch




state PreparationMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var MUTAGENS, JOURNAL_MUTAGENS : name;
	
		default MUTAGENS 			= 'TutorialMutagenPotion';
		default JOURNAL_MUTAGENS 	= 'TutorialJournalMutagenPotion';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		highlights.Resize(2);
		highlights[0].x = 0.395;
		highlights[0].y = 0.57;
		highlights[0].width = 0.21;
		highlights[0].height = 0.12;
		
		highlights[1].x = 0.28;
		highlights[1].y = 0.22;
		highlights[1].width = 0.04;
		highlights[1].height = 0.07;
		
		ShowHint(MUTAGENS, ETHDT_Infinite, highlights);
		theGame.GetTutorialSystem().ActivateJournalEntry(JOURNAL_MUTAGENS);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(MUTAGENS);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(MUTAGENS);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnMutagenEquipped()
	{
		QuitState();
	}
}
*/