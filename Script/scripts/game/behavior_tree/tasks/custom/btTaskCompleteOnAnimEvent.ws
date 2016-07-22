//>--------------------------------------------------------------------------
// BTTaskCompleteOnAnimEvent
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Complete the branch when the anim event is received
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 09-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskCompleteOnAnimEvent extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var animEvent			: name;
	editable var sucess				: bool;
	//>----------------------------------------------------------------------
	//>----------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if ( animEventName == animEvent )
		{
			Complete( sucess );
		}		
		return true;
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskCompleteOnAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCompleteOnAnimEvent';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	editable var animEvent			: name;
	editable var sucess				: bool;
	
	default sucess = true;
	
	hint success = "Should the task report success or fail?";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( animEvent ) )
		{
			listenToAnimEvents.PushBack( animEvent );
		}
	}
}
