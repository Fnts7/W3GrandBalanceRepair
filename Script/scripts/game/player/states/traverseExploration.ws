﻿/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




state TraverseExploration in CPlayer extends Base
{
	private var exploration : SExplorationQueryToken;
	default exploration = NULL;
	
	private var running : bool;
	default running = false;
	
	private var prevState : name;
	
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		prevState = prevStateName;
		running = true;
		
		parent.AddTimer( 'UpdateTraverser', 0.f, true, false, TICK_PrePhysics );
		
		
		theGame.GetGameCamera().ChangePivotPositionController('Default');
		theGame.GetGameCamera().ChangePivotDistanceController('Default');
		
		ProcessExploration();
	}
	
	
	event OnCanLeaveState( newState : name )
	{
		if ( newState == 'PlayerDialogScene' ) 
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
		
		
		super.OnLeaveState(nextStateName);
	}
	
	
	
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
				
				LogChannel( 'Exploration' , "TRUE" );
			}
			else
			{
				
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
