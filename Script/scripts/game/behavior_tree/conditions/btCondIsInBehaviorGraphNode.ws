//>--------------------------------------------------------------------------
// BTCondIsInBehaviorGraphNode
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if the NPC is currently in a specific Behavior Graph Node - 
// This test is not fully reliable so it should be used with caution
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 09-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIsInBehaviorGraphNode extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	public var activationScriptEvent 			: name;
	public var deactivateScriptEvent 			: name;
	
	private var m_availability					: bool;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function Initialize()
	{
		GetNPC().ActivateSignalBehaviorGraphNotification( activationScriptEvent );		
		GetNPC().ActivateSignalBehaviorGraphNotification( deactivateScriptEvent );		
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		return m_availability;
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == activationScriptEvent )
		{
			m_availability = true;
		}
		if( eventName == deactivateScriptEvent )
		{
			m_availability = false;
		}
		
		return true;
	}	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondIsInBehaviorGraphNodeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsInBehaviorGraphNode';
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var activationScriptEvent 			: name;
	editable var deactivateScriptEvent 			: name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		if ( IsNameValid( activationScriptEvent ) )
		{
			listenToGameplayEvents.PushBack( activationScriptEvent );
		}
		if ( IsNameValid( deactivateScriptEvent ) )
		{
			listenToGameplayEvents.PushBack( deactivateScriptEvent );
		}
	}
}
