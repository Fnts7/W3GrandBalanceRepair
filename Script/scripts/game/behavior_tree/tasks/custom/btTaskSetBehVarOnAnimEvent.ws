/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013 CD Projekt RED
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskSetBehVarOnAnimEvent extends IBehTreeTask
{	
	var npc 							: CNewNPC;
	var eventName 						: name;
	var behVarName 						: name;
	var behVarValue						: float;
	var eventReceived 					: bool;
	var onDurationEvent 				: bool;
	var behValueOnDurationEventStart	: float;
	var behValueOnDurationEventEnd 		: float;
	
	latent function Main() : EBTNodeStatus
	{
		npc = GetNPC();
		
		while ( true )
		{
			if ( eventReceived && IsNameValid(eventName) && eventName != 'AllowBlend' )
			{
				npc.SetBehaviorVariable( behVarName, behVarValue );
				eventReceived = false;
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
	//	AllowBlend handled on OnDeactivate because AtomicPlayAnimationEvent
	//	should always be used with PlayAnimationEventDecorator which Completes task on AllowBlend
		if ( eventReceived && IsNameValid(eventName) && eventName == 'AllowBlend' )
		{
			npc.SetBehaviorVariable( behVarName, behVarValue );
			eventReceived = false;
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == eventName && !onDurationEvent )
		{
			eventReceived = true;
			return true;
		}
		else if ( animEventName == eventName && onDurationEvent && animEventType == AET_DurationStart )
		{
			npc.SetBehaviorVariable( behVarName, behValueOnDurationEventStart );
			return true;
		}
		else if ( animEventName == eventName && onDurationEvent && animEventType == AET_DurationEnd )
		{
			npc.SetBehaviorVariable( behVarName, behValueOnDurationEventEnd );
			return true;
		}
		
		return false;
	}
};

class CBTTaskSetBehVarOnAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVarOnAnimEvent';

	editable var eventName 						: name;
	editable var behVarName 					: name;
	editable var behVarValue					: float;
	editable var onDurationEvent 				: bool;
	editable var behValueOnDurationEventStart	: float;
	editable var behValueOnDurationEventEnd 	: float;
	
	default eventName = 'AllowBlend';
};
