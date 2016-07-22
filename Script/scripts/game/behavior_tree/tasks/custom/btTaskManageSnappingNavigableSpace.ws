
class BTTaskManageSnappingNavigableSpace extends IBehTreeTask
{
	var snap						: bool;
	var onDeactivate 				: bool;	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !onDeactivate )
		{
			((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( snap );
		}
			
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( snap );
		}
	}
}

class BTTaskManageSnappingNavigableSpaceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSnappingNavigableSpace';

	editable var snap						: bool;
	editable var onDeactivate 				: bool;
};