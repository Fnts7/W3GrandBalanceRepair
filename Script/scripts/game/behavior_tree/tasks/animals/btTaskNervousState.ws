/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskNervousState extends IBehTreeTask
{
	public var dangerRadius, rearingChance, kickChance : float;
	public var callFromQuestOnly : bool;
	public var force : bool;
	public var called : bool;
	private var dangerNode : CNode;
	
	default callFromQuestOnly = false;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if ( callFromQuestOnly )
		{
			if ( called )
			{
				return true;
			}
		}
		else if ( /*owner.GetMovementType() == MT_Run &&*/ !force )
		{
			return true;
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		if( /*owner.GetMovementType() != MT_Run ||*/ callFromQuestOnly || force )
		{
			owner.ActionCancelAll();
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		// just in case
		if( true/*owner.GetMovementType() == MT_Run*/ )
		{
			Complete(false);
			return BTNS_Failed;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CActor = GetActor();
		owner.ActionCancelAll();
		callFromQuestOnly = false;
	}

	/*
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CActor = GetActor();
		
		if( animEventName == 'Idle' && callFromQuest )
		{
			owner.RaiseEvent( 'rearing' );
		}
		else if( animEventName == 'Idle' )
		{
			if( RandF() < rearingChance )
			{
				owner.RaiseEvent( 'rearing' );
			}
			else if( RandF() < kickChance )
			{
				owner.RaiseEvent( 'kick' );
			}
			else
			{
				Complete(true);
			}
		}
		return false;
	}
	*/
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AnimalNervous' )
		{
			called = true;
			return true;
		}
		if ( eventName == 'CalmDown' )
		{
			GetActor().RaiseForceEvent('ForceIdle');
			Complete(true);
		}
		return false;
	}
};

class CBTTaskNervousStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskNervousState';

	editable var callFromQuestOnly : bool;
	editable var dangerRadius : float;
	editable var rearingChance : float;
	editable var kickChance : float;
	
	default callFromQuestOnly = false;
	default dangerRadius = 4.0;
	default rearingChance = 0.5;
	default kickChance = 0.5;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AnimalNervous' );
		listenToGameplayEvents.PushBack( 'CalmDown' );
	}
};