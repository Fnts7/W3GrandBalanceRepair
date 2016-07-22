/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013-2014 CDProjektRed
/** Author : Radosław Grabowski
/***********************************************************************/

//////////////////////////////////////////////////////////////////////////
// CBoatBodyComponent states

state Idle in CBoatBodyComponent
{
	event OnCutsceneStarted()
	{
		parent.PushState('Cutscene');
	}
}

state Cutscene in CBoatBodyComponent
{
	event OnEnterState( prevStateName : name )
	{
		parent.TriggerCutsceneStart();
	}
	
	event OnCutsceneEnded()
	{
		parent.TriggerCutsceneEnd();
		parent.PopState( false );
	}
}

//////////////////////////////////////////////////////////////////////////
// CBoatComponent states

state Idle in CBoatComponent
{
	event OnCutsceneStarted()
	{
		parent.PushState('Cutscene');
	}
}

state Cutscene in CBoatComponent
{
	event OnEnterState( prevStateName : name )
	{
		parent.TriggerCutsceneStart();
	}
	
	event OnCutsceneEnded()
	{
		parent.TriggerCutsceneEnd();
		parent.PopState( false );
	}
}

//////////////////////////////////////////////////////////////////////////