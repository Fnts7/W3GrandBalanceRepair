class CBTCondCheckNPCType extends IBehTreeTask
{
	public var npcType : ENPCGroupType;
	
	function IsAvailable() : bool
	{
		return GetNPC().GetNPCType() == npcType;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondCheckNPCTypeDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondCheckNPCType';
	
	editable var npcType : ENPCGroupType;
}
