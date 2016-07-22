/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state MeditationWait in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var WAIT : name;
	
		default WAIT = 'TutorialMeditation';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		ShowHint(WAIT, 0.6, 0.6, ETHDT_Input);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint(WAIT);
		
		super.OnLeaveState(nextStateName);
	}
}