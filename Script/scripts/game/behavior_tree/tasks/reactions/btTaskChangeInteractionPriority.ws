class CBTTaskChangeInteractionPriority extends IBehTreeTask
{
	private var previousInteractionPriority : EInteractionPriority;
	
	private var priorityChanged : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		if ( GetActionTarget() == thePlayer )
		{
			previousInteractionPriority = owner.GetInteractionPriority();
			
			owner.SetOriginalInteractionPriority(IP_Prio_3);
			owner.RestoreOriginalInteractionPriority();
			priorityChanged = true;
		}
		else
		{
			priorityChanged = false;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CActor = GetActor();
		
		if ( priorityChanged )
		{
			owner.SetOriginalInteractionPriority(previousInteractionPriority);
			owner.RestoreOriginalInteractionPriority();
		}
	}
}

class CBTTaskChangeInteractionPriorityDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskChangeInteractionPriority';
}
