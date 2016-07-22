class BTTaskSetIsTargetableByPlayer extends IBehTreeTask
{
	var value : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		
		if( onActivate )
		{
			actor.SetTatgetableByPlayer( value );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor : CActor = GetActor();
		
		if( !onActivate )
		{
			actor.SetTatgetableByPlayer( value );
		}
	}
}

class BTTaskSetIsTargetableByPlayerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetIsTargetableByPlayer';
	
	editable var value : bool;
	editable var onActivate : bool;
	
	default value = true;
	default onActivate = true;
}