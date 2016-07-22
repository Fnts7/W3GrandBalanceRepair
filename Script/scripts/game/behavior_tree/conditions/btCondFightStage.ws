class BTCondFightStage extends IBehTreeTask
{
	var currentFightStageIs : ENPCFightStage;
	
	function IsAvailable() : bool
	{
		return currentFightStageIs == GetNPC().GetCurrentFightStage();
	}
}

class BTCondFightStageDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondFightStage';

	editable var currentFightStageIs : ENPCFightStage;
}