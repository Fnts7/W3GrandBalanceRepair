/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Walk to tagged target, wait actor latent action
/** Copyright © 2012
/***********************************************************************/

class W3ActorLatentActionWalkToTargetWaitActor extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/walk_to_target_wait";
	
	editable var tag : CName;
	
	editable var maxDistance : float;
	editable var moveSpeed : float;
	editable var moveType : EMoveType;
		
	editable var waitForTag : CName;	
	editable var timeout : float;
	editable var testDistance : float;
	
	default maxDistance = 3.0;
	default moveSpeed = 1.0;
	default moveType = MT_Walk;
		
	default testDistance = 10.0;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIWalkToTargetWaitingForActorAction;
		
		action = new CAIWalkToTargetWaitingForActorAction in parentObj;
		action.OnCreated();
		
		action.tag				= tag;
		action.maxDistance		= maxDistance;
		action.moveSpeed		= moveSpeed;
		action.moveType			= moveType;
		action.waitForTag		= waitForTag;
		action.timeout			= timeout;
		action.testDistance		= testDistance;
		
		return action;
	}

}
