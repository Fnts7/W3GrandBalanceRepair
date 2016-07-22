// copyrajt orajt
// W. Żerek

// TO DO:
//	- not only player?
//	- enable on animevent

class CBTTaskEnableLookAt extends IBehTreeTask
{
	var duration : float;
	var owner : CActor;
	var useReactionTarget : bool;
	var useActionTarget : bool;
	var useAsDecorator : bool;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var target : CNode;
		if ( useAsDecorator )
		{
			target = GetLookAtTarget();
				
			GetActor().EnableDynamicLookAt( target, 999 );
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var target : CNode;
		
		if ( useAsDecorator )
			return BTNS_Active;
		
		target = GetLookAtTarget();
			
		GetActor().EnableDynamicLookAt( target, duration );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		var target : CNode;
		
		if ( useAsDecorator )
		{
			target = GetLookAtTarget();
				
			GetActor().EnableDynamicLookAt( target, duration );
		}
	}
	
	function GetLookAtTarget() : CNode
	{
		var target : CNode;
		if ( useReactionTarget )
		{
				target = GetNamedTarget('ReactionTarget');
		}
		else if ( useActionTarget )
		{
			target = GetActionTarget();
		}
		else
		{
			target = thePlayer;
		}
		
		return target;
	}
}

class CBTTaskEnableLookAtDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskEnableLookAt';

	editable var duration 			: float;
	editable var useReactionTarget 	: bool;
	editable var useActionTarget 	: bool; default useActionTarget = false;
	editable var useAsDecorator 	: bool;
}