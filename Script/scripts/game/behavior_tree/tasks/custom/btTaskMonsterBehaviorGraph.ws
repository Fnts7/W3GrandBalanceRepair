class CBehTreeTaskMonsterBehaviorGraph extends IBehTreeTask
{
	var graphName : name;
	var res : bool;
	var owner : CNewNPC;
	
	latent function Main() : EBTNodeStatus
	{
		owner  = GetNPC();
		
		if ( !IsNameValid(graphName) )
		{
			return BTNS_Failed;
		}
		
		res = owner.ActivateAndSyncBehavior( graphName );

		return BTNS_Active;
	}
}

class CBehTreeMonsterBehaviorGraphDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskMonsterBehaviorGraph';

	editable var graphName : name;
}