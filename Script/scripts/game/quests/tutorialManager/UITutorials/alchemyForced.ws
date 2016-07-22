/***********************************************************************/
/** Copyright © 2014-2015
/** Author : Tomek Kozera
/***********************************************************************/

state ForcedAlchemy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var ALCHEMY_GO_TO, OPEN_MENU : name;
	
		default ALCHEMY_GO_TO = 'TutorialAlchemyForcedEnterAlchemy';
		default OPEN_MENU = 'TutorialAlchemyForcedOpenMenu';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		//disallow leaving UI panels
		theGame.GetTutorialSystem().uiHandler.LockCloseUIPanels(true);
		
		//close hint asking to open menus
		theGame.GetTutorialSystem().HideTutorialHint( OPEN_MENU );
		
		//hint about going to alchemy panel
		ShowHint(ALCHEMY_GO_TO, 0.35f, 0.6f, ETHDT_Infinite);	

		//Remove any Thunderbolts. Player will be forced to make one in the tutorial, there cannot be multiple and at this point he will not notice the loss ]:->
		thePlayer.inv.RemoveItemByName('Thunderbolt 1', -1);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(ALCHEMY_GO_TO);
		
		super.OnLeaveState(nextStateName);
	}	
}
