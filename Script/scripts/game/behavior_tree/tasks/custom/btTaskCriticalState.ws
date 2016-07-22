/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBehTreeTaskCriticalState extends IBehTreeTask
{
	private var activate 			: bool;
	private var activateTimeStamp 	: float;
	private var forceActivate		: bool;
	
	private var currentCS : ECriticalStateType;		
	
	function IsAvailable () : bool
	{
		if ( forceActivate )
			return true;
			
		if ( activateTimeStamp + 3 < GetLocalTime() )
			activate = false;
			
		return activate && !GetNPC().IsUnstoppable();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		activate = false;
		
		forceActivate = false;
		
		GetNPC().SetIsInHitAnim(true);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{	
		var currBuff : CBaseGameplayEffect;
		var nextBuff : CBaseGameplayEffect;
		var nextBuffType : ECriticalStateType;
		var owner : CNewNPC;
		var forceRemoveCurrentBuff : bool;
		var tempB : bool;
		
		owner = GetNPC();
		
		if( owner.IsInFinisherAnim() )
		{
			activate = true;
			return;
		}		
		
		nextBuff = owner.ChooseNextCriticalBuffForAnim();
		nextBuffType = GetBuffCriticalType(nextBuff);
		if ( nextBuffType == ECST_BurnCritical && owner.HasAbility( 'BurnNoAnim' ) )
		{
			tempB = true;
		}
		
		//force remove current buff if there is no other buff (CS anim is shorter then buff duration) 
		//or next buff is the same as current buff (task ended before anim end info reached effect manager)
		if(!nextBuff || (currentCS == nextBuffType))
		{			
			forceRemoveCurrentBuff = true;
		}
		else
		{
			forceRemoveCurrentBuff = false;
		}
		
		owner.CriticalStateAnimStopped(forceRemoveCurrentBuff);
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( owner, 'RecoveredFromCriticalEffect', -1, 30.0f, -1.f, -1, true ); //reactionSystemSearch
		
		activate = false;
		
		if(!nextBuff)
		{
			//if no other critical buffs to play then disallow play anim of current buff
			currBuff = owner.GetCurrentlyAnimatedCS();
			CriticalBuffDisallowPlayAnimation(currBuff);
		}
		else if ( !tempB && !owner.HasAbility( 'ablIgnoreSigns' ) )
		{
			forceActivate = true;
		}
		
		currentCS = ECST_None;
		owner.EnableCollisions( true );
		owner.SetIsInHitAnim(false);
		owner.SetBehaviorVariable('bCriticalStopped',1.f);
	}
	
	function OnListenedGameplayEvent( gameEventName : name ) : bool
	{
		var npc : CNewNPC;
		
		var receivedBuffType 	: ECriticalStateType;
		var receivedBuff	: CBaseGameplayEffect;
		
		var currentBuffPriority		: int;
		var receivedBuffPriority	: int;
		
		if ( gameEventName == 'ForceCS' )
		{
			forceActivate = true;
		}
		else if ( gameEventName == 'CriticalState' )
		{
			receivedBuffType = this.GetEventParamInt(-1);
			
			npc = GetNPC();
			
			// We no longer have seperate trees for critical states. Previously we could disable critical state animation by removing
			// critical state tree in ai parametrization. This is a workaround that prevents animation from playing.
			if ( receivedBuffType == ECST_BurnCritical && npc.HasAbility( 'BurnNoAnim' ) )
			{
				npc.SignalGameplayEvent('CSBurningNoAnim');
				return false;
			}
			// Ability condition that blocks critical state animations - for handling critical states with additive anims
			if ( npc.HasAbility( 'ablIgnoreSigns' ) )
				return false;
			
			if ( ShouldBeScaredOnOverlay() )
			{
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( GetNPC(), 'TauntAction', -1, 1.f, -1.f, 1, false ); //reactionSystemSearch
				return false;
			}
			
			activate = true;
			activateTimeStamp = GetLocalTime();
			
			if( isActive ) 
			{
				if( IsStagger( receivedBuffType ) && IsStagger( currentCS ) )
				{
					Complete( true );
				}
				else
				{
					currentBuffPriority = CalculateCriticalStateTypePriority( currentCS );
					receivedBuffPriority = CalculateCriticalStateTypePriority( receivedBuffType );
					
					if ( receivedBuffPriority > currentBuffPriority )
					{
						Complete( true );
					}
				}
			}
		}
		else if ( gameEventName == 'RagdollFromHorse'  )
		{
			forceActivate = true;
		}
		
		currentCS = receivedBuffType;
		
		return IsAvailable();
	}
	
	function ShouldBeScaredOnOverlay() : bool
	{
		var res : int;
		
		res = GetNPC().SignalGameplayEventReturnInt('AI_ShouldBeScaredOnOverlay',-1);
		
		return res > 0;
	}
	
	private function IsStagger( type : ECriticalStateType ) : bool
	{
		return type == ECST_Stagger || type == ECST_LongStagger;
	}
}

class CBehTreeTaskCriticalStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskCriticalState';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CriticalState' );
		listenToGameplayEvents.PushBack( 'RagdollFromHorse' );
		listenToGameplayEvents.PushBack( 'ForceCS' );
	}
}
