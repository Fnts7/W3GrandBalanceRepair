/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Play voice set latent action
/** Copyright © 2012
/***********************************************************************/

class W3ActorLatentActionPlayVoiceSet extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/play_voice_set";
	
	editable var voiceSet : string;
	editable var priority : int;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIPlayVoiceSetAction;
		
		action = new CAIPlayVoiceSetAction in parentObj;
		action.OnCreated();
		
		action.voiceSet = voiceSet;
		action.priority = priority;
		
		return action;
	}
}
