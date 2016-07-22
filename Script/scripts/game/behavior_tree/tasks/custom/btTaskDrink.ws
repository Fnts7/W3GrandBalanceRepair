
class CBTTaskDrink extends IBehTreeTask
{
	var available : bool;
	default available = false;

	var Delay : float;
	var Event : name;
	
	function IsAvailable() : bool
	{
		if ( isActive )
		{
			return true;
		}
		
		if (available)
		{
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		available = false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		return BTNS_Completed;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == Event )
		{
			GetNPC().RaiseForceEvent(Event);
			available = true;
			return true;
		}
		return false;
	}
}

class CBTTaskDrinkDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDrink';

	editable var Delay : float;
	editable var Event : name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( Event ) )
		{
			listenToGameplayEvents.PushBack( Event );
		}
	}
}

