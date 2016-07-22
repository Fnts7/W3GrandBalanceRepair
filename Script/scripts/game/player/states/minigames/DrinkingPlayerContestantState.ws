/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

state DrinkingPlayerContestant in CPlayer
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		theSound.EnterGameState( ESGS_Minigame );
		//theSound.SoundState( "game_state", "minigames" );		// SET MINIGAME SOUND STATE
		Init();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		theSound.LeaveGameState( ESGS_Minigame );
	}
	
	entry function Init()
	{
		parent.ActivateAndSyncBehavior('drinking_contestant');
	}
}