/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

/*
disabled

state Preparation in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PREPARATION_GO_TO, POTIONS, PETARDS, OILS, MUTAGENS, ALCHEMY_GO_TO : name;
	private var isClosing : bool;
	
		default PREPARATION_GO_TO = 'TutorialPreparationGoTo';
		default POTIONS = 'TutorialPreparationPotions';
		default PETARDS = 'TutorialPreparationPetards';
		default OILS = 'TutorialPreparationOils';
		default MUTAGENS = 'TutorialPreparationMutagens';
		default ALCHEMY_GO_TO = 'TutorialPreparationGoToAlchemy';
	
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		CloseHint(PREPARATION_GO_TO);
				
		highlights.Resize(1);
		highlights[0].x = 0.385;
		highlights[0].y = 0.23;
		highlights[0].width = 0.095;
		highlights[0].height = 0.09;
		
		ShowHint(POTIONS, 0.7, 0.3,  , highlights);
		
		thePlayer.BlockAction(EIAB_OpenInventory, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_RadialMenu, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_preparation_go_to');
		thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_preparation_go_to');
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(PREPARATION_GO_TO);
		CloseHint(POTIONS);
		CloseHint(PETARDS);
		CloseHint(OILS);
		CloseHint(MUTAGENS);
		CloseHint(ALCHEMY_GO_TO);
		
		thePlayer.BlockAllActions('tutorial_preparation_go_to', false);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == POTIONS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.515;
			highlights[0].y = 0.23;
			highlights[0].width = 0.095;
			highlights[0].height = 0.09;
			
			ShowHint(PETARDS, 0.7, 0.3, , highlights);
		}
		else if(hintName == PETARDS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.355;
			highlights[0].y = 0.41;
			highlights[0].width = 0.28;
			highlights[0].height = 0.12;
			
			ShowHint(OILS, 0.7, 0.3, , highlights);
		}
		else if(hintName == OILS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.395;
			highlights[0].y = 0.57;
			highlights[0].width = 0.21;
			highlights[0].height = 0.12;
			
			ShowHint(MUTAGENS, 0.7, 0.3, , highlights);
		}
		else if(hintName == MUTAGENS)
		{			
			ShowHint(ALCHEMY_GO_TO, 0.7, 0.3, ETHDT_Infinite);
		}
	}
}
*/