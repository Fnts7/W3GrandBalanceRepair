/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013 CD Projekt RED
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskSetBehVarOnScriptEvent extends IBehTreeTask
{
	var activationEventName 		: name;
	var behVarName 					: name;
	var behVarValue					: float;
	var prevBehVarValue				: float;
	var delay						: float;
	var activationEventReceived 	: bool;
	var previousValueOnDurationEnd	: bool;
	

	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		while ( true )
		{
			if ( activationEventReceived )
			{
				if ( delay )
				{
					Sleep( delay );
				}
				prevBehVarValue = npc.GetBehaviorVariable( behVarName );
				npc.SetBehaviorVariable( behVarName, behVarValue );
			}
			else
			{
				if ( previousValueOnDurationEnd )
				{
					npc.SetBehaviorVariable( behVarName, prevBehVarValue );
				}
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		activationEventReceived = false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == activationEventName )
		{
			activationEventReceived = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskSetBehVarOnScriptEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVarOnScriptEvent';

	editable var activationEventName 					: name;
	editable var behVarName 				: name;
	editable var behVarValue				: float;
	editable var delay						: float;
	editable var previousValueOnDurationEnd	: bool;
	
	default activationEventName = 'Run';
	default previousValueOnDurationEnd = true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		if ( IsNameValid( activationEventName ) )
		{
			listenToAnimEvents.PushBack( activationEventName );
		}
	}
};
