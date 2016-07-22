/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Rotate towards actor latent action
/** Copyright © 2012
/***********************************************************************/

class W3ActorLatentActionRotateTo extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/rotate_towards";
	
	editable var targetTag : CName;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIRotateToAction;
		
		action = new CAIRotateToAction in parentObj;
		action.OnCreated();
		
		action.targetTag = targetTag;
		
		return action;
	}
}
