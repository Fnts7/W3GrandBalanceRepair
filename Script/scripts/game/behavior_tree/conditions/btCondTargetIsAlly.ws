//>--------------------------------------------------------------------------
// BTCondTargetIsAlly
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if the target is an ally
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 08-July-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondTargetIsAlly extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	public var useNamedTarget 				: name;
	public var useCombatTarget				: bool;
	public var saveTargetOnGameplayEvents	: array<name>;
	
	private var m_Target					: CActor;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var l_npc	 : CNewNPC = GetNPC();		
		
		if( saveTargetOnGameplayEvents.Size() == 0 )
		{
			SaveTarget();
		}
		
		if( !m_Target )
		{
			return false;
		}
		
		if( l_npc.GetAttitude( m_Target ) != AIA_Friendly )
		{
			return false;
		}
		
		return true;
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	final function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( saveTargetOnGameplayEvents.Contains( eventName ) )
		{
			SaveTarget();
		}
		
		return true;		
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	private final function SaveTarget()
	{
		if( IsNameValid( useNamedTarget ) )
		{
			m_Target = (CActor) GetNamedTarget( useNamedTarget );
		}
		else if (useCombatTarget )
		{
			m_Target = (CActor) GetCombatTarget();
		}
		else
		{		
			m_Target = (CActor) GetActionTarget();
		}
	}
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondTargetIsAllyDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondTargetIsAlly';
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	private editable var useNamedTarget 			: CBehTreeValCName;
	private editable var useCombatTarget			: bool;
	private editable var saveTargetOnGameplayEvents : array<name>;
	
	// This is used when you check for ReactionTarget, because ReactionTarget can change between the actual reaction event and the isAvailable check
	// (if another reaction is triggered in between)
	hint saveTargetOnGameplayEvents = "To only change the target on a specific event. Leave empty to change target at every check";
	
	function InitializeEvents()
	{
		var i : int;
		
		super.InitializeEvents();
		
		for( i = 0; i < saveTargetOnGameplayEvents.Size() ; i += 1 )
		{
			if( IsNameValid( saveTargetOnGameplayEvents[i] ) )
			{
				listenToGameplayEvents.PushBack( saveTargetOnGameplayEvents[i] );
			}
		}
	}
}