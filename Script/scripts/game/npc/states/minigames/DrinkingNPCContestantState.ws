/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

state DrinkingNPCContestant in CNewNPC
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		DrinkingNPCContestantStateInit();
	}
	
	entry function DrinkingNPCContestantStateInit()
	{
		parent.ActivateAndSyncBehavior('drinking_contestant');
	}
}