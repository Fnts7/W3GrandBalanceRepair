/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state AlchemyMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var MUTAGENS : name;	//hints
	private var currentlySelectedRecipe, requiredRecipeName, selectRecipe : name;
	
		default MUTAGENS 		= 'TutorialMutagenPotion';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		currentlySelectedRecipe = '';
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(MUTAGENS);
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		QuitState();
	}
	
	public final function CookedItem(recipeName : name)
	{
		if(theGame.GetDefinitionsManager().IsRecipeForMutagenPotion(recipeName))
		{		
			ShowHint(MUTAGENS, POS_ALCHEMY_X, POS_ALCHEMY_Y);
		}
	}
}
exec function tut_alch_mut()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('MutagenPotion', '');
}