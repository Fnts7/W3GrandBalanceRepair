/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Idle state
/////////////////////////////////////////////

state NewIdle in CNewNPC extends Base
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter/Leave events
	
	/**
	
	*/
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	
		this.IdleInit();
	}
	
	/**
	
	*/
	event OnLeaveState( nextStateName : name )
	{ 
		// Pass to base class
		super.OnLeaveState(nextStateName);
	}
	
	/**
	
	*/
	entry function IdleInit()
	{
		//set default behavior graph
		parent.ActivateAndSyncBehavior('Exploration');
		StateIdle();
	}	

	/**
		FIXMEFLASH temporary solution
	*/
	latent function StateIdle()
	{
		while ( true )
		{
			Sleep( 10.0f );
		}
	}
}
