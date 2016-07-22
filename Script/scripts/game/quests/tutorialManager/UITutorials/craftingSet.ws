/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

state CraftingSet in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SET : name;
	
		default SET	= 'TutorialCraftingSets';
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(SET);
		
		//remove listener only if saw message
		if(theGame.GetTutorialSystem().HasSeenTutorial(SET))
			super.OnLeaveState(nextStateName);
	}
	
	event OnCraftedSetItem()
	{
		ShowHint( SET, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Input, , , , true );		
	}
}