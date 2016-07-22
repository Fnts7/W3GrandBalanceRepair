//>--------------------------------------------------------------------------
// BTTaskManageCombatPhases
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Manages times combat phases are active
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Andrzej Kwiatkowski - 18-11-2015
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------

struct SCombatPhaseParameters
{
	editable var setBehVariable 			: int;
	editable var priority					: float;
	editable var duration 					: float;
	editable var cooldown 					: float;
	editable var timerRandomization 		: float;
	editable var minRangeFromTarget 		: float;
	editable var maxRangeFromTarget 		: float;
	editable var activationAnimEvent 		: name;
	editable var deactivationAnimEvent 		: name;
	editable var activationGameplayEvent 	: name;
	editable var deactivationGameplayEvent 	: name;
}

class BTTaskManageCombatPhases extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	// public
	public var rangedCombatPhaseParameters	: SCombatPhaseParameters;
	public var closeCombatPhaseParameters	: SCombatPhaseParameters;
	public var nonCombatPhaseParameters		: SCombatPhaseParameters;
	public var availableCombatPhasesArray 	: array< SCombatPhaseParameters >;
	public var initialCombatPhasesArray 	: array< SCombatPhaseParameters >;
	public var combatPhasesArray 			: array< SCombatPhaseParameters >;
	public var setBehVariableName 			: name;
	
	// private
	private var activationEventReceived 	: float;
	private var rangedCombatTimeStamp 		: float;
	private var closeCombatTimeStamp 		: float;
	private var nonCombatTimeStamp 			: float;
	private var currentCombatPhase 			: int;
	private var afterFirstChoice 			: bool;
	
	default afterFirstChoice 				= false;
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function Initialize()
	{
		var i : int;
		
		initialCombatPhasesArray.PushBack( rangedCombatPhaseParameters );
		initialCombatPhasesArray.PushBack( closeCombatPhaseParameters );
		initialCombatPhasesArray.PushBack( nonCombatPhaseParameters );
		combatPhasesArray = initialCombatPhasesArray;
		
		for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
		{
			combatPhasesArray[i].cooldown = 0;
			combatPhasesArray[i].duration = 0;
		}
	}	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	latent function Main() : EBTNodeStatus
	{
		var npc		: CNewNPC = GetNPC();
		var i, j, k : int;
		var tempF 	: float;
		
		while ( true )
		{
			Sleep( 0.1 );
			
			// check for currently active combat phase
			tempF = npc.GetBehaviorVariable( setBehVariableName );
			
			for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
			{
				if ( combatPhasesArray[i].setBehVariable == tempF )
				{
					currentCombatPhase = i;
					break;
				}
			}
			
			// reduce cooldowns in all combat phases if applicable
			for ( k=0 ; k<combatPhasesArray.Size() ; k+=1 )
			{
				if ( combatPhasesArray[k].cooldown >= 0.1 )
				{
					combatPhasesArray[k].cooldown -= 0.1;
				}
			}
			
			// if currently active combat phase has still some duration left then reduce duration and continue
			if ( combatPhasesArray[currentCombatPhase].duration >= 0.1 )
			{
				combatPhasesArray[currentCombatPhase].duration -= 0.1;
			}
			// if current phase duration has ended, change phase to highest priority one from available phases array
			else
			{
				// set cooldown on current phase before changing it to a new one
				if ( afterFirstChoice )
				{
					combatPhasesArray[currentCombatPhase].cooldown = initialCombatPhasesArray[currentCombatPhase].cooldown 
						- ( initialCombatPhasesArray[currentCombatPhase].cooldown * RandRangeF( initialCombatPhasesArray[currentCombatPhase].timerRandomization, 0 ));
				}
				j = CheckCombatPhase();
				npc.SetBehaviorVariable( setBehVariableName, availableCombatPhasesArray[j].setBehVariable );
				// check again for current phase
				for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
				{
					if ( combatPhasesArray[i].setBehVariable == tempF )
					{
						currentCombatPhase = i;
						break;
					}
				}
				// reset duration on new phase
				combatPhasesArray[currentCombatPhase].duration = initialCombatPhasesArray[currentCombatPhase].duration 
					- ( initialCombatPhasesArray[currentCombatPhase].duration * RandRangeF( initialCombatPhasesArray[currentCombatPhase].timerRandomization, 0 ));
			}
		}
		
		return BTNS_Active;
	}
	
	
	//>----------------------------------------------------------------------
	// Helper functions
	//-----------------------------------------------------------------------
	final function CheckCombatPhase() : int
	{
		var i, j : int;
		
		afterFirstChoice = true;
		availableCombatPhasesArray = combatPhasesArray;
		
		// from all combat phases remove these that are on cooldown, they are not available to choose from
		for ( i=0 ; i<availableCombatPhasesArray.Size() ; i+=1 )
		{
			if ( availableCombatPhasesArray[i].cooldown > 0 )
			{
				availableCombatPhasesArray.Erase(i);
			}
		}
		
		// from the remaining combat phases choose one with highest priority
		j = ArrayFindMaxPriorityFloatFromStruct( availableCombatPhasesArray );
		//return availableCombatPhasesArray[j].setBehVariable;
		return j;
	}
	
	// Returns index of highest element
	final function ArrayFindMaxPriorityFloatFromStruct( a : array< SCombatPhaseParameters > ) : int
	{
		var i, s, index : int;
		var val : float;	
		
		s = a.Size();
		if( s > 0 )
		{
			index = 0;
			val = a[0].priority;
			for( i=1; i<s; i+=1 )
			{
				if( a[i].priority > val )
				{
					index = i;
					val = a[i].priority;
				}
			}
			
			return index;
		}
		
		return -1;			
	}
	
	
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == '' )
		{
			return true;
		}
		
		return false;
	}
	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == '' )
		{
			return true;
		}
		
		return false;
	}
};

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskManageCombatPhasesDef extends IBehTreeTaskDefinition
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable var rangedCombatPhaseParameters	: SCombatPhaseParameters;
	editable var closeCombatPhaseParameters		: SCombatPhaseParameters;
	editable var nonCombatPhaseParameters		: SCombatPhaseParameters;
	editable var setBehVariableName 			: name;
	
	default instanceClass = 'BTTaskManageCombatPhases';
};
