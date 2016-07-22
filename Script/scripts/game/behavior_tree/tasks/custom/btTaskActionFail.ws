/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskActionFail extends CBTTaskPlayAnimationEventDecorator
{
	var failedActionType : EActionFail;
	default failedActionType = EAF_ActionFail1;

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( npc )
		{
			npc.SetBehaviorVariable( 'FailedAction', (int)failedActionType );
		}
		else
		{
			BTNS_Failed;
		}
		return super.OnActivate();
	}
}

class CBTTaskActionFailDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskActionFail';

	editable var failedActionType : EActionFail;

	default failedActionType = EAF_ActionFail1;
}