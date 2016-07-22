//>--------------------------------------------------------------------------
// Complete the branch when gameplay event is received
//---------------------------------------------------------------------------
class BTTaskCompleteOnGameplayEvent extends IBehTreeTask
{
	editable var gameplayEvent		: name;
	editable var sucess				: bool;
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		if ( eventName == gameplayEvent )
		{
			Complete( sucess );
		}		
		return true;
	}
}

class BTTaskCompleteOnGameplayEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCompleteOnGameplayEvent';

	editable var gameplayEvent		: name;
	editable var sucess				: bool;
	
	default sucess = true;
	
	hint success = "Should the task report success or fail?";
}