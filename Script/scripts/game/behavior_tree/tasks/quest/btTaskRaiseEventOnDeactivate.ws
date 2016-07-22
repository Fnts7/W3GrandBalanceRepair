class BTTaskRaiseEventOnDeactivate extends IBehTreeTask
{
	public var eventName : name;
	
	function OnDeactivate()
	{	
		GetActor().RaiseEvent(eventName);
	}
}

class BTTaskRaiseEventOnDeactivateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRaiseEventOnDeactivate';

	editable var eventName : CBehTreeValCName;
}
