/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondActorInIdleTrigger extends IBehTreeTask
{
	var inIdleTrigger : bool;

	function IsAvailable() : bool
	{
		if ( inIdleTrigger )
		{
			return true;
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'InIdleTrigger' )
		{
			inIdleTrigger = true;
			return true;
		}
		if ( eventName == 'LeftIdleTrigger' )
		{
			inIdleTrigger = false;
			return true;
		}
		return false;
	}
};

class CBTCondActorInIdleTriggerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondActorInIdleTrigger';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'InIdleTrigger' );
		listenToGameplayEvents.PushBack( 'LeftIdleTrigger' );
	}
};