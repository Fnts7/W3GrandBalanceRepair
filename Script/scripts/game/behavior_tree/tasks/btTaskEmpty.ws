class BTTaskEmpty extends IBehTreeTask
{	
	function OnActivate() : EBTNodeStatus
	{	
		return BTNS_Active;
	}
}

class BTTaskEmptyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEmpty';
}
