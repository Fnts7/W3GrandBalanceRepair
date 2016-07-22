class CBehTreeCombatTargetSelectionTask extends IBehTreeTask
{	
	var maxTargetDistance : float;
	var testMaxFrequency : float;
	var nextTestDelay : float;
	var nextTarget : CActor;
	var playerPriority : int;
	var targetOnlyPlayer : bool;
	var ForceTarget : CActor;
	
	default maxTargetDistance = 10.0;
	default testMaxFrequency = 1.0;
	default nextTestDelay = -1.0;
	default playerPriority = 100;
	
	function IsAvailable() : bool
	{		
		var owner : CNewNPC = GetNPC();
		var tooFar : bool;
		var target : CActor;
		var localTime : float;
		
		
		if ( ForceTarget )
		{
			if ( ForceTarget != GetCombatTarget() )
			{
				nextTarget = ForceTarget;
				return true;
			}
			return false;
		}
		
		localTime = GetLocalTime();
		
		if ( nextTestDelay > localTime )
		{
			return false;
		}
		nextTestDelay = localTime + testMaxFrequency;
		
		target = GetCombatTarget(); 
		tooFar = (target && !IsTargetInRange());
		
		// No target
		// OR target dead
		// OR was hit
		// OR is in combat and too far from current target
		if( !target || (target && !target.IsAlive()) || owner.lastAttacker || tooFar )
		{
			if( FindTarget() )
			{
				return true;
			}
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		SetCombatTarget( nextTarget );
		nextTarget = NULL;
		return BTNS_Completed;
	} 
	
	// Values to be tweaked!
	function EvaluatePotentialTarget( target : CActor) : float
	{	
		var owner : CNewNPC = GetNPC();
		var sum : float;
		var npcTarget : CNewNPC;
		var dist : float;
		
		npcTarget = (CNewNPC)target;
		
		// Ignore friendlies
		if ( !owner.IsDangerous( target ) )
		{
			return 0;
		}
		
		// Attitude for player mismatch - potential enemy	
		//FIXME what if I'm hostile and npcTarget is neutral - should he still be my enemy?
		if ( npcTarget && owner.GetAttitude( thePlayer ) != npcTarget.GetAttitude( thePlayer ) )
		{
			sum = sum + 10.0;
		}
		
		// Evaluate if was previously targeted and is still alive and kicking
		if( target == GetCombatTarget() && target.IsAlive() )
		{
			sum = sum + 50.0;
		}
		
		// Evaluate if they just attacked us
		if( target == owner.lastAttacker )
		{
			sum = sum + 100.0;
		}	
		
		// Evaluate distance
		dist = VecDistance2D( owner.GetWorldPosition(), target.GetWorldPosition() );
		sum = sum + 1000.0 * (1.0 - (dist / maxTargetDistance));
		
		// Player priority
		if( target == thePlayer )
		{
			if( RandRange(100) < playerPriority )
			{
				sum = sum + 600.0f;
			}
		}
		
		// Final evaluation score
		return sum;		
	}
	
	function FindTarget() : bool
	{
		var score : float;
		var maxScore : float;
		var bestTarget : CActor;
		var newTarget : CActor;
		var index : int;
		var owner : CNewNPC = GetNPC();
		
		if( targetOnlyPlayer )
		{
			bestTarget = NULL;
			if( thePlayer.IsAlive() && owner.IsDangerous( thePlayer ) )
			{
				bestTarget = thePlayer;
			}
		}
		else
		{	
			// Iterate through detected opponents and evaluate them
			maxScore = 0;
			index = 0;
			newTarget = owner.GetNoticedObject( index );
			while( newTarget )
			{		
				if(newTarget.IsAlive())
				{
					score = EvaluatePotentialTarget( newTarget );
				
					if( score > maxScore )
					{
						maxScore = score;
						bestTarget = newTarget;
					}
				}
			
				index = index + 1;
				newTarget = owner.GetNoticedObject( index );
			}
		}
		
		// Reset last attacker after calculations were done
		owner.lastAttacker = NULL;
		
		// Target found and changed
		if( bestTarget != GetCombatTarget() )
		{
			nextTarget = bestTarget;
			
			return true;
		}
		
		// Target was not changed
		return false;
	}

	function IsTargetInRange() : bool
	{
		var owner : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var res : bool = false;
		
		if( target )
		{
			res = VecDistance2D( owner.GetWorldPosition(), target.GetWorldPosition() ) < maxTargetDistance;
		}
		
		return res;
	}
	
	function OnGameplayEvent( eventName : CName ) : bool
	{		
		var owner 	: CNewNPC = GetNPC();
		var data 	: CDamageData;
		// Respond to hit immediately
		if ( eventName == 'BeingHit' )
		{
			data 				= (CDamageData) GetEventParamBaseDamage();
			owner.lastAttacker 	= (CActor)data.attacker;
			return true;
		}
		if ( eventName == 'ForceTarget' )
		{
			this.ForceTarget = (CActor)GetEventParamObject();
			return true;
		}
		if ( eventName == 'UnforceTarget' )
		{
			this.ForceTarget = NULL;
			SetCombatTarget(NULL);
			return true;
		}
		if ( eventName == 'ReevaluateCombatTarget' )
		{
			SetCombatTarget(NULL);
		}
		return false;
	}
};

class CBehTreeCombatTargetSelectionTaskDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeCombatTargetSelectionTask';
	
	editable var maxTargetDistance : float;
	editable var playerPriority : int;
	editable var targetOnlyPlayer : bool;
	
	default maxTargetDistance 	= 10;
	default playerPriority 		= 100;
	default targetOnlyPlayer 	= true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
		listenToGameplayEvents.PushBack( 'ForceTarget' );
		listenToGameplayEvents.PushBack( 'UnforceTarget' );
		listenToGameplayEvents.PushBack( 'ReevaluateCombatTarget' );
	}
}
