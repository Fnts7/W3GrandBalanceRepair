//>--------------------------------------------------------------------------
// BTTaskAddRemoveAbility
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Add or remove an ability on the NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 08-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskAddRemoveAbility extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var abilityName					: name;
	public var allowMultiple				: bool;
	public var removeAbility				: bool;
	public var delayUntilInCameraFrame 		: bool;
	public var onDeactivate					: bool;
	public var onAnimEventName				: name;
	
	private var eventReceived 				: bool;
	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate && !delayUntilInCameraFrame ) Execute();
		return BTNS_Active;
	}
	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	latent function Main() : EBTNodeStatus
	{
		var res 	: bool;
		var actor 	: CActor = GetActor();
		
		if ( delayUntilInCameraFrame )
		{
			while ( !res )
			{
				if ( thePlayer.WasVisibleInScaledFrame( actor, 1.f, 1.f ) )
				{
					if ( IsNameValid( onAnimEventName ) && eventReceived )
					{
						Execute();
						res = true;
					}
					else
					{
						Execute();
						res = true;
					}
				}
				Sleep( 0.25f );
			}
		}
		
		return BTNS_Active;
	}
	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnDeactivate()
	{
		if( onDeactivate ) Execute();
	}
	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( onAnimEventName ) && animEventName == onAnimEventName )
		{
			eventReceived = true;
			if ( !delayUntilInCameraFrame )
			{
				Execute();
			}
			return true;
		}
		return false;
	}
	
	
	private function Execute()
	{
		var l_npc : CNewNPC = GetNPC();
		
		if( removeAbility )
		{
			l_npc.RemoveAbility( abilityName );
		}
		else
		{
			l_npc.AddAbility( abilityName, allowMultiple );
		}
	}

}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskAddRemoveAbilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddRemoveAbility';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	editable var abilityName				: name;
	editable var allowMultiple				: bool;
	editable var removeAbility				: bool;
	editable var delayUntilInCameraFrame 	: bool;
	editable var onDeactivate				: bool;
	editable var onAnimEventName			: name;
	
	default allowMultiple = true;
	
	hint onDeactivate = "Execute on deactivate instead on on Activate";
}
