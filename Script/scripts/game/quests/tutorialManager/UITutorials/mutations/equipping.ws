state MutationsEquipping in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var EQUIPPING : name;
	private var activated : bool;
	
		default EQUIPPING = 'TutorialMutationsEquipping';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
				
		activated = false;
		
		//if we researched mutation in full during initial tutorial
		if( ( ( W3PlayerAbilityManager ) thePlayer.abilityManager ).GetResearchedMutationsCount() > 0 )
		{
			OnMutationFullyResearched();
		}
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseStateHint( EQUIPPING );
		
		theGame.GetTutorialSystem().MarkMessageAsSeen( EQUIPPING );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		if( activated )
		{
			QuitState();
		}
	}
	
	public final function OnMutationFullyResearched()
	{
		ShowHint( EQUIPPING, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Infinite );
		activated = true;
	}
	
	public final function OnMutationEquippedPost()
	{
		QuitState();
	}
}