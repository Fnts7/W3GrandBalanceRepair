enum ENPCCollisionStance
{
	NCS_InPlace		,
	NCS_PushGentle	,
	NCS_Push		,
	NCS_PushHard	,
};

enum ENPCBaseType
{
	ENBT_Man	,
	ENBT_Woman	,
	ENBT_Dwarf	,
};

class CBTTaskCollideWithCharacterDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCollideWithCharacter';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CollideWithPlayer' );
	}
};

class CBTTaskCollideWithCharacter extends IBehTreeTask
{
	var isAvailable					: bool;		
	var collideEndListenEventName	: name;		default collideEndListenEventName	= 'CollidedEnd';
	var collideBehGrapEventName		: name;		default collideBehGrapEventName		= 'Collided';
	var collidedConfirmedEvent		: name;		default collidedConfirmedEvent		= 'CollidedConfirmed';
	var collidedDirBehGraphVar		: name;		default	collidedDirBehGraphVar		= 'CollisionDirection';
	var collidedPushBehGraphVar		: name;		default	collidedPushBehGraphVar		= 'CollisionIsPushing';
	var cooldownToRestartTotal		: float;	default	cooldownToRestartTotal		= 0.6f;
	var cooldownToStartTotal		: float;	default	cooldownToStartTotal		= 0.2f;
	var	cooldownToRetryTotal		: float;	default	cooldownToRetryTotal		= 0.5f;
	var	cooldownToPlayCur			: float;
	var	cooldownToRestartCur		: float;
	var	cooldownToRetryCur			: float;
	var collidedActor 				: CActor;
	var otherIsPlayer				: bool;
	var otherIsHorse				: bool;
	
	// Ignoring collision
	var	ignoreBumpOnOneGoingAway	: bool;		default	ignoreBumpOnOneGoingAway	= false;
	var	ignoreBumpOnBothGoingAway	: bool;		default	ignoreBumpOnBothGoingAway	= true;
	var	ignoreBumpOnBothStopped		: bool;		default	ignoreBumpOnBothStopped		= true;
	var ignoreMinCoefToGoAway		: float; 	default	ignoreMinCoefToGoAway		= 0.5f;
	var ignoreMinSpeedSqr			: float; 	default	ignoreMinSpeedSqr			= 0.3f;
	
	default isAvailable = false;
	
	
	function IsAvailable(): bool
	{
		if( !isAvailable )
		{
			return false;
		}
		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		// Timeout makes it unavailable
		if( cooldownToPlayCur > theGame.GetEngineTimeAsSeconds() )
		{
			Bump();
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			// Safety time to disable
			if( isAvailable && cooldownToRestartCur <= theGame.GetEngineTimeAsSeconds() )
			{
				return BTNS_Completed;
			}
			Sleep( 0.1f );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		var npcActor : CActor;
		
		isAvailable	= false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == 'CollideWithPlayer' ) // !isAvailable &&
		{	
			// Skip activation from the root
			if( cooldownToRetryCur >= theGame.GetEngineTimeAsSeconds() )
			{
				return false;
			}
			cooldownToRetryCur	= cooldownToRetryTotal + theGame.GetEngineTimeAsSeconds();
			
			if( CanNPCBeInterrupted() )
			{
				// Set ready to bump
				isAvailable	= true;
				
				// Get to whom we are colliding
				collidedActor = (CActor)GetEventParamObject();
				
				// Set the safety time to start
				cooldownToPlayCur = cooldownToStartTotal + theGame.GetEngineTimeAsSeconds();
				
				SetEventRetvalInt( 1 );
				return true;
			}
			else
				GetActor().SignalGameplayEvent('SoftReactionBump');
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if( isAvailable && eventName == collideEndListenEventName )
		{		
			// Deactivate it
			isAvailable	= false;
			Complete( true );
			
			SetEventRetvalInt( 1 );
			return true;
		}
		
		return false;
	}
	
	private function CanNPCBeInterrupted() : bool
	{
		var actionPointId	: SActionPointId;
		var npc 			: CNewNPC = GetNPC();
		var isBreakable		: bool;
		var category		: name;
		
		
		actionPointId	= npc.GetActiveActionPoint();	
		
		if( IsAPValid( actionPointId ) ) 
		{
			isBreakable		= theGame.GetAPManager().IsBreakable( actionPointId );
			
			return isBreakable;
		}
		
		// No action point, we can interrupt
		else
		{
			return true;
		}
	}
	
	function Bump()
	{
		var npc 		: CNewNPC = GetNPC();
		var fromOther	: Vector;
		var angle		: float;
		var direction	: EAttackDirection;
		var pushValue	: ENPCCollisionStance;
		var baseName	: string;
		
		
		// Pre initialize some flags
		otherIsHorse	= false;
		
		// Do we have a proper actor?
		if( !collidedActor )
		{
			// Fail safe, use the player
			collidedActor	= ( CActor ) thePlayer;
			otherIsPlayer	= true;
		}
		// To what are we colliding
		else
		{	
			otherIsPlayer	= collidedActor == ( CActor ) thePlayer;			
			otherIsHorse	= IsOtherAHorse();
		}
		
		
		// Get the direction tot he collision point
		fromOther	= npc.GetWorldPosition() - collidedActor.GetWorldPosition();
		
		// Are we skipping the reaction?
		if( HasToIgnoreBump( fromOther ) )
		{
			return;
		}
		
		// Get the angle of the hit
		angle		= GetAngleToMove( fromOther );
		
		// Set the direction of the hit
		direction	= GetDirectionToMove( angle );	
		
		// The type of push
		pushValue	= GetPushType();
		
		// Add rotation
		PrepareRotation( pushValue, angle, direction );
		
		// ChangeVariables
		npc.SetBehaviorVariable( collidedDirBehGraphVar, ( float ) ( int ) direction );
		npc.SetBehaviorVariable( collidedPushBehGraphVar, ( float ) (int ) pushValue );
		
		// Raise the event
		 npc.RaiseEvent( collideBehGrapEventName );
		
		// Set the safety time to start
		cooldownToRestartCur = cooldownToRestartTotal + theGame.GetEngineTimeAsSeconds();
	}
	
	private function IsOtherAHorse() : bool
	{
		var horseComp	: W3HorseComponent;
		
		if( otherIsPlayer )
		{
			if( thePlayer.GetIsHorseMounted() )
			{
				return true;
			}
		}
		else
		{
			horseComp		= ( W3HorseComponent )collidedActor.GetComponentByClassName( 'W3HorseComponent' );
			if( horseComp )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function HasToIgnoreBump( fromOther : Vector ) : bool
	{
		var npc				: CNewNPC	= GetNPC();
		var dotMine			: float;
		var dotHis			: float;
		var speedMineSqr	: float;
		var speedHisSqr		: float;
		
		
		if( otherIsPlayer )
		{
			return false;
		}
		
		speedMineSqr	= VecLengthSquared( npc.GetMovingAgentComponent().GetVelocity() ) ;
		speedHisSqr		= VecLengthSquared( collidedActor.GetMovingAgentComponent().GetVelocity() );
		
		// Stopped 
		if( ignoreBumpOnBothStopped && speedMineSqr <= ignoreMinSpeedSqr && speedHisSqr <= ignoreMinSpeedSqr )
		{
			return true;
		}
		
		// Going away from the collision
		if( ignoreBumpOnOneGoingAway )
		{
			dotHis	= VecDot( collidedActor.GetWorldForward(), fromOther );
			if( dotHis <= ignoreMinCoefToGoAway && speedHisSqr > ignoreMinSpeedSqr )
			{
				return true;
			}
			dotMine	= VecDot( npc.GetWorldForward(), -fromOther );
			if( dotMine <= ignoreMinCoefToGoAway && speedMineSqr > ignoreMinSpeedSqr )
			{
				return true;
			}
		}		
		else if( ignoreBumpOnBothGoingAway )
		{
			dotHis	= VecDot( collidedActor.GetWorldForward(), fromOther );
			dotMine	= VecDot( npc.GetWorldForward(), -fromOther );
			if( dotHis <= ignoreMinCoefToGoAway && dotMine <= ignoreMinCoefToGoAway && speedMineSqr > ignoreMinSpeedSqr && speedHisSqr > ignoreMinSpeedSqr )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private function GetAngleToMove( fromOther : Vector ) : float
	{
		var angle			: float;
		var shouldMoveLeft	: bool;
		
		
		// check if the npc shpould move left or right of collider's way
		shouldMoveLeft	= VecDot( collidedActor.GetWorldRight(), fromOther ) >= 0.0f;
		
		// Compute the angle difference
		if( shouldMoveLeft )
		{
			angle	= VecHeading( -fromOther - collidedActor.GetWorldRight() * 0.75f );
		}
		else
		{
			angle	= VecHeading( -fromOther + collidedActor.GetWorldRight() * 0.75f );
		}
		
		//thePlayer.GetVisualDebug().AddArrow( 'Desired angle', npc.GetWorldPosition(), npc.GetWorldPosition() + VecFromHeading( angle ), 1.f, .2f, .2f, true, Color( 0, 255, 255), true, 5.f );
		
		//angle	= AngleDistance( npc.GetHeading(), angle );
		//angle	= AngleNormalize180( angle );
		
		//thePlayer.GetVisualDebug().AddArrow( 'Bump Added', npc.GetWorldPosition(), npc.GetWorldPosition() + VecFromHeading( npc.GetHeading() + angle ), 1.f, .2f, .2f, true, Color( 255, 255, 255), true, 6.f );
		
		
		return angle;
	}
	
	private function GetDirectionToMove( angle : float ) : EAttackDirection 
	{
		var npc : CNewNPC = GetNPC();
		
		angle	= AngleDistance( npc.GetHeading(), angle );
		
		
		if( angle < -135.0f )
		{
			return AD_Back;
		}
		else if( angle < -45.0f )
		{
			return AD_Left;
		}
		else if( angle < 45.0f )
		{
			return AD_Front;
		}
		else if( angle < 135.0f )
		{
			return AD_Right;
		}
		
		return AD_Back;
	}
	
	private function GetPushType() : ENPCCollisionStance
	{
		var npcActor 		: CActor;
		var originalPriority: EInteractionPriority;
		var playerPriority	: EInteractionPriority;
		var pushValue		: ENPCCollisionStance;
		var auxBool			: bool;
		var velocity		: float;
		
		
		// Get push prorities
		npcActor 			= ( CActor ) GetNPC();
		originalPriority	= npcActor.GetInteractionPriority();
		
		if ( npcActor.GetBehaviorVariable('heldItemType') > 0.5 )
		{
			return NCS_InPlace;
		}
		
		if( otherIsPlayer )
		{
			playerPriority	= thePlayer.GetOriginalInteractionPriority();
		}
		else
		{
			playerPriority	= collidedActor.GetInteractionPriority();
		}
		
		// Pushing in place
		if( playerPriority < originalPriority )
		{
			pushValue	= NCS_InPlace; 
		}
		// Move away
		else
		{
			// Do we need a hard push reaction?
			auxBool	= otherIsPlayer && ( thePlayer.GetIsSprinting() || thePlayer.IsInAir() );
			if( !auxBool )
			{
				velocity	= VecLengthSquared( collidedActor.GetMovingAgentComponent().GetVelocity() );
				auxBool		= otherIsHorse && velocity > 10.0f;
			}
			
			if( auxBool )
			{
				pushValue	= NCS_PushHard;
			}
			else
			{ 
				// Do we need a normal push reaction
				auxBool	= otherIsPlayer && ( thePlayer.GetIsRunning() );
				if( !auxBool )
				{
					if( velocity == 0.0f )
					{
						velocity	= VecLengthSquared( collidedActor.GetMovingAgentComponent().GetVelocity() );
					}
					
					auxBool	= otherIsHorse && velocity > 0.0f;
				}
				
				if( auxBool )
				{
					pushValue	= NCS_Push;
				}
				
				// Gentle reaction
				else
				{
					pushValue	= NCS_PushGentle;
				}
			}
		}
		
		return pushValue;
	}
	
	private function PrepareRotation( push : ENPCCollisionStance, angle : float, direction : EAttackDirection )
	{
		var owner 				: CNewNPC;
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var rotateAngle			: float;
		
		
		// Should we rotate?
		if( push == NCS_InPlace )
		{
			return;
		}
		
		owner 				= GetNPC();
		
		// Get the angle
		switch( direction )
		{
			case AD_Front:
				rotateAngle	= angle;
				break;
			case AD_Back:
				rotateAngle	= AngleNormalize180( angle - 180.0f );
				break;
			case AD_Left:
				rotateAngle	= AngleNormalize180( angle - 90.0f );
				break;
			case AD_Right:
				rotateAngle	= AngleNormalize180( angle + 90.0f );
				break;
			default :
				return;
		}
		
		movementAdjustor	= owner.GetMovingAgentComponent().GetMovementAdjustor();
		ticket				= movementAdjustor.CreateNewRequest( 'Bump' );
		
		movementAdjustor.AdjustmentDuration( ticket, 0.1f );
		movementAdjustor.RotateTo( ticket, rotateAngle );
	}
};
