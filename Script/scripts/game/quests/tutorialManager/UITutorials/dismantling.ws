/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state Dismantling in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, ITEMS, COMPONENTS, COST, DISMANTLING : name;
	private var isClosing : bool;
	
		default DESCRIPTION 	= 'TutorialDismantleDescription';
		default ITEMS 			= 'TutorialDismantleItems';
		default COMPONENTS 		= 'TutorialDismantleComponents';
		default COST 			= 'TutorialDismantlePrice';
		default DISMANTLING 	= 'TutorialDismantleDismantling';		
		
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, POS_DISMANTLE_X, POS_DISMANTLE_Y, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(ITEMS);
		CloseStateHint(COMPONENTS);
		CloseStateHint(COST);
		CloseStateHint(DISMANTLING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		GameplayFactsRemove("tut_dismantle_cond");	//not needed anymore, let's not store it in saves
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == DESCRIPTION)
		{
			ShowHint( ITEMS, POS_DISMANTLE_X, POS_DISMANTLE_Y, ETHDT_Input, GetHighlightDismantleItems() );
		}		
		else if(hintName == ITEMS)
		{
			ShowHint(COMPONENTS, POS_DISMANTLE_X, POS_DISMANTLE_Y, ETHDT_Input, GetHighlightDismantleComponents() );
		}
		else if(hintName == COMPONENTS)
		{
			ShowHint( COST, POS_DISMANTLE_X, POS_DISMANTLE_Y, ETHDT_Input, GetHighlightDismantleCost() );
		}
		else if(hintName == COST)
		{
			ShowHint(DISMANTLING, POS_DISMANTLE_X, POS_DISMANTLE_Y, ETHDT_Input);
		}
		else if(hintName == DISMANTLING)
		{
			QuitState();
		}
	}
}