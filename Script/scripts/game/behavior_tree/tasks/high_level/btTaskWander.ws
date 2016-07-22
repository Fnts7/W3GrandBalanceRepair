class CBehTreeHLTaskWander extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		GetActor().ActivateAndSyncBehavior('Exploration');
		//owner.GetMovingAgentComponent().SetMoveType( MT_Walk );
		return BTNS_Active;
	}
};


class CBehTreeHLTaskWanderDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskWander';
}
