
class CBTTaskHasVoiceSet extends IBehTreeTask
{
	public var voiceSet 					: string;
	
	function IsAvailable() : bool
	{
		var hasVoicesetResult : EAsyncCheckResult;
		hasVoicesetResult = GetActor().HasVoiceset(voiceSet);
		return hasVoicesetResult == ASR_ReadyTrue;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskHasVoiceSetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHasVoiceSet';

	editable var voiceSet 					: CBehTreeValString;
}