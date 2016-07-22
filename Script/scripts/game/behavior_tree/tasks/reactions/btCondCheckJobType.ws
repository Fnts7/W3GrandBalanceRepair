class CBTCondCheckJobType extends IBehTreeTask
{
	public var jobType : EJobTreeType;
	
	function IsAvailable() : bool
	{
		return GetNPC().IsAtWork() && GetNPC().GetCurrentJTType() == jobType;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondCheckJobTypeDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondCheckJobType';
	
	editable var jobType : EJobTreeType;
}
