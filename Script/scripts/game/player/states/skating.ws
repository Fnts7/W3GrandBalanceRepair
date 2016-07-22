// Skating
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 18/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


function LogSkating(str : string)									
{
	LogChannel('Skate', str);
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
state Skating in CR4Player extends ExtendedMovable
{
	//>-----------------------------------------------------------------------------------------------------------------
	event OnEnterState( prevStateName : name )
	{
		theInput.SetContext( 'Skating' );
		
		parent.SetBIsCombatActionAllowed(false);
		
		
		// init
		SkatingInit();
		
		LogSkating("on enter skating");
	} 
	
	//>-----------------------------------------------------------------------------------------------------------------
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		
		parent.SetBIsCombatActionAllowed(true);
		
		LogSkating("on leave skating");
	}
	
	//>-----------------------------------------------------------------------------------------------------------------
	entry function SkatingInit()
	{
		var behGraphNames : array< name >;		
		
		
		parent.LockEntryFunction( true );
		
		
		// Activate behavior
		parent.BlockAllActions('InitSkating', true, , true);
		
		behGraphNames.PushBack( 'Skating' );
		//parent.ActivateBehaviors( behGraphNames );
		parent.ActivateAndSyncBehaviors( behGraphNames );
		
		parent.BlockAllActions('InitSkating', false);
		
		//set required items
		parent.SetBehaviorVariable( 'playerWeapon', (int)PW_Steel );
		parent.SetBehaviorVariable( 'playerWeaponForOverlay', (int)PW_Steel );
		parent.SetBehaviorVariable( 'SelectedWeapon', 0);
		parent.SetBehaviorVariable( 'WeaponType', 0);
		parent.SetRequiredItems( 'None', 'steelsword' );
		
		parent.ProcessRequiredItems();
		
		
		// Do something else
		parent.SetOrientationTarget( OT_Player );
		parent.ClearCustomOrientationInfoStack();
		
		// Allow input
		parent.SetBIsInputAllowed(true, 'SkatingInit');
		
		parent.WaitForBehaviorNodeDeactivation( 'StateChangeComplete', 0.1f ); // node act/deact does not work when changing behgraphs
		
		parent.LockEntryFunction( false );
	}
}
