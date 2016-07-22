class CBTTaskRaiseAnimationEvent extends IBehTreeTask
{	
	var eventName : name;
	var forceEvent : bool;
	var onActivate : bool;
	var onDeactivate : bool;
	var raiseEventAfter : float;
	
	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			RaiseAnimationEvent();
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if( raiseEventAfter )
		{
			Sleep( raiseEventAfter );
			RaiseAnimationEvent();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			RaiseAnimationEvent();
		}
	}
	
	private function RaiseAnimationEvent()
	{
		var owner : CActor = GetActor();
		
		if( forceEvent )
		{
			owner.RaiseForceEvent( eventName );
		}
		else
		{
			owner.RaiseEvent( eventName );
		}
	}
};

class CBTTaskRaiseAnimationEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRaiseAnimationEvent';

	editable var eventName : name;
	editable var forceEvent : bool;
	editable var onActivate : bool;
	editable var onDeactivate : bool;
	editable var raiseEventAfter : float;
	
	default onActivate = true;
	default onDeactivate = false;
	default raiseEventAfter = 0.0;
};