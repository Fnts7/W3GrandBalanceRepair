class BTCondWasNPCInTalkInteraction extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().wasInTalkInteraction;
	}
}

class BTCondWasNPCInTalkInteractionDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondWasNPCInTalkInteraction';
} 