//>--------------------------------------------------------------------------
// BTCondThreatLevelDifference
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Compare the threat level of the NPC with a target
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 27-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondThreatLevelDifference extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var operator 					: EOperator;
	public var value						: int;
	public var useCombatTarget				: bool;
	public var useNamedTarget 				: name;
	public var saveTargetOnGameplayEvent	: name;
	
	private var m_Target					: CNode;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var threatLevel			: int;
		var targetThreatLevel	: int;
		var oppNo 				: int;
		var actionTarget		: CNode;
		var result				: bool;
		var npc					: CNewNPC = GetNPC();
		
		threatLevel = npc.GetThreatLevel();
		
		if( !IsNameValid( saveTargetOnGameplayEvent) )
		{
			SaveTarget();
		}
		
		if( (CNewNPC) m_Target )
			targetThreatLevel = ((CNewNPC) m_Target ).GetThreatLevel();
		
		if( m_Target == thePlayer )
			targetThreatLevel = 5;
		
		oppNo = targetThreatLevel - threatLevel;
		
		switch ( operator )
		{
			case EO_Equal:			result = (oppNo == value); break;
			case EO_NotEqual:		result = (oppNo != value); break;
			case EO_Less:			result = (oppNo < value); break;
			case EO_LessEqual:		result = (oppNo <= value); break;
			case EO_Greater:		result = (oppNo > value); break;
			case EO_GreaterEqual:	result = (oppNo >= value); break;
			default : 				result = false; break;
		}
		
		// More complex syntax, just so I can put a break point separately when it fails or succeed
		if( result )
			return true;
		else
			return false;
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	final function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == saveTargetOnGameplayEvent )
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
			m_Target = GetNamedTarget( useNamedTarget );
		}
		else
		{		
			if( useCombatTarget )
			{
				m_Target = GetCombatTarget();
			}
			else
			{
				m_Target = GetActionTarget();
			}
		}
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondThreatLevelDifferenceDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondThreatLevelDifference';

	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var operator 					: EOperator;
	private editable var value						: int;
	private editable var useCombatTarget			: bool;
	private editable var useNamedTarget 			: CBehTreeValCName;
	private editable var saveTargetOnGameplayEvent 	: CBehTreeValCName;
	
	// This is used when you check for ReactionTarget, because ReactionTarget can change between the actual reaction event and the isAvailable check
	// (if another reaction is triggered in between)
	hint saveTargetOnGameplayEvent 	= "To only change the target on a specific event. Leave empty to change target at every check";	
	hint useNamedTarget				= "Overrides the 'useCombatTarget' flag";
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var eventName : name;
		
		eventName = GetValCName( saveTargetOnGameplayEvent );
		if( IsNameValid( eventName ) )
		{
			ListenToGameplayEvent( eventName );
		}
	}
}