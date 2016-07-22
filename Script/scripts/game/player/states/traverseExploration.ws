/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/***********************************************************************/

state TraverseExploration in CPlayer extends Base
{
	private var exploration : SExplorationQueryToken;
	default exploration = NULL;
	
	private var running : bool;
	default running = false;
	
	private var prevState : name;
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Enter/Leave events	
	/**
	
	*/
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		prevState = prevStateName;
		running = true;
		
		parent.AddTimer( 'UpdateTraverser', 0.f, true, false, TICK_PrePhysics );
		
		//We always want to use default Camera in explorations
		theGame.GetGameCamera().ChangePivotPositionController('Default');
		theGame.GetGameCamera().ChangePivotDistanceController('Default');
		
		ProcessExploration();
	}
	
	
	event OnCanLeaveState( newState : name )
	{
		if ( newState == 'PlayerDialogScene' ) // Allow dialogs to force state change
		{
			return true;
		}
	
		return !running;
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		LogAssert( !traverser, "TraverseExploration::SetExploration, 'traverser' is still set" );
		LogAssert( exploration.valid, "TraverseExploration::OnLeaveState, 'exploration' is still valid" );
	
		traverser = NULL;
		exploration.valid = false;
		
		parent.RemoveTimer( 'UpdateTraverser' );
		
		// Pass to base class
		super.OnLeaveState(nextStateName);
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	final function SetExploration( e : SExplorationQueryToken )
	{
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		LogAssert( exploration.valid, "TraverseExploration::SetExploration, 'exploration' is already set" );
		LogAssert( traverser, "TraverseExploration::SetExploration, 'traverser' is already set" );
		
		exploration = e;
	}
	
	entry function ProcessExploration()
	{
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		var actionResult : bool;
		
		if ( exploration.valid )
		{
			LogChannel( 'Exploration' , "Start..." );
			
			actionResult = parent.ActionExploration( exploration );
			if ( actionResult )
			{
				//parent.explorationFailed = false; - not used anywhere, removed
				LogChannel( 'Exploration' , "TRUE" );
			}
			else
			{
				//parent.explorationFailed = true; - not used anywhere, removed
				LogChannel( 'Exploration' , "FALSE" );
			}
			
			LogChannel( 'Exploration' , "End..." );
		}
		else
		{
			LogAssert( exploration.valid, "TraverseExploration::SetExploration, 'exploration' is not set" );
			LogAssert( traverser, "TraverseExploration::SetExploration, 'traverser' is not set" );
		}
		
		exploration.valid = false;
		traverser = NULL;
		
		running = false;
		
		parent.PopState();
	}
}
