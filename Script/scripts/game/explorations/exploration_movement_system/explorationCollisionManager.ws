// CExplorationCollisionManager
//------------------------------------------------------------------------------------------------------------------
//
// Eduard Lopez Plans	( 29/04/2014 )	 
//------------------------------------------------------------------------------------------------------------------

	
//------------------------------------------------------------------------------------------------------------------
enum ESideSelected
{
	SS_SelectedNone		,
	SS_SelectedLeft		,
	SS_SelectedRight	,
	SS_SelectedCenter	,
};

enum EPlayerCollisionStance
{
	GCS_Idle	,
	GCS_Walk	,
	GCS_Run		,
	GCS_Sprint	,
	GCS_Combat	,
};

	
//>-----------------------------------------------------------------------------------------------------------------
class CExplorationCollisionManager
{
	// Owner
	private 			var m_ExplorationO						: CExplorationStateManager;
	
	
	// Beh graph
	private	editable	var	m_CollideWithNPCEventCenter			: name;		default	m_CollideWithNPCEventCenter			= 'CollideCenter';
	private	editable	var	m_CollideWithNPCEventLeft			: name;		default	m_CollideWithNPCEventLeft			= 'CollideLeft';
	private	editable	var	m_CollideWithNPCEventRight			: name;		default	m_CollideWithNPCEventRight			= 'CollideRight';
	private editable	var m_CollideNameS						: name;		default	m_CollideNameS						= 'Colliding';
	private editable	var m_CollideBehGraphSideNameS			: name;		default	m_CollideBehGraphSideNameS			= 'CollidingSide';
	private editable	var m_CollideBehGraphStanceNameS		: name;		default	m_CollideBehGraphStanceNameS		= 'CollisionStance';
	private editable	var m_CollideAngleNameS					: name;		default	m_CollideAngleNameS					= 'PlayerCollisionAngle';
	private editable	var m_CollideBehGraphStrengthRelNameS	: name;		default	m_CollideBehGraphStrengthRelNameS	= 'PlayerCollisionRelStrength';
	private editable	var m_CollideBehGraphHeightN			: name;		default	m_CollideBehGraphHeightN			= 'PlayerCollisionHeight';
	
	// Conditions to collide
	private	editable	var	m_CanCollideWithStaticaB			: bool;		default	m_CanCollideWithStaticaB		= false;
	private	editable	var	m_VisualReactionToPushB				: bool;		default	m_VisualReactionToPushB			= false;
	private	editable	var	m_SpeedToCollideWihNPCsF			: float;	default	m_SpeedToCollideWihNPCsF		= 0.1f;
	private editable	var m_TimeCollidingToStopF				: float;	default	m_TimeCollidingToStopF			= 0.2f;
	private				var m_TimeCollidingCurF					: float;
	private editable	var m_AcceptableZToBumpF				: float;	default	m_AcceptableZToBumpF			= 0.4f;
	private editable	var playerHandHeightRange				: float;	default	playerHandHeightRange			= 0.5f;
	
	// Traces
	private				var	m_LandWaterMinDepthF				: float;	default	m_LandWaterMinDepthF			= 1.9f;
	private 			var m_CollisionGroupsNamesNArr			: array<name>;
	private 			var m_CollisionSightNArr				: array<name>;
	public	 			var m_CollisionObstaclesNArr			: array<name>;
	
	// State
	private				var m_CollidingB						: bool;
	private				var	m_IsThereAnyCollisionB				: bool;
	private				var m_CollidingWithNpcB					: bool;
	private				var m_CollidingWithStaticsB				: bool;
	private editable 	var m_AngleToSideF						: float;	default	m_AngleToSideF					= 22.0f;
	private				var m_CollidingAngleF					: float;
	private editable	var m_CollideCenterIfBothSidesB			: bool;		default	m_CollideCenterIfBothSidesB		= true;
	private				var	m_CollidingSideE					: ESideSelected;
	private				var	m_CollidingSideLastE				: ESideSelected;
	private				var	m_CollidingSideCooldownF			: float;
	public				var	forceFallEnabled					: bool;		default	forceFallEnabled				= false;
	public				var	forceFallRequireCenter				: bool;		default	forceFallRequireCenter			= false;
	public				var	forceFallRunning					: bool;		default	forceFallRunning				= false;
	
	public				var	m_CollidingStrengthOtherF			: float;
	public				var	m_CollidingStrengthRelativeF		: float;
	public				var	m_CollidingDirOtherV				: Vector;
	public				var	m_CollidingSpeedOtherV				: Vector;
	private editable	var m_CollidingStrengthFadeSpeedF		: float;	default	m_CollidingStrengthFadeSpeedF	= 20.0f;
	
	public				var	m_CollidingIsLowB					: bool;
	public editable		var	m_CollidingLowMinHeightF			: float;	default	m_CollidingLowMinHeightF		= 1.7f;
	
	// Debug
	public	editable	var	debugEnabled						: bool;		default	debugEnabled					= true;
	
	// Auxiliars
	private 			var m_UpV								: Vector;
	private 			var m_ZeroV								: Vector;
	public 				var lastWaterCheckPoint					: Vector;
	
	
	//------------------------------------------------------------------------------------------------------------------
	public function Initialize( explorationManager : CExplorationStateManager )
	{
		m_ExplorationO					= explorationManager;
		m_TimeCollidingCurF				= 0.0f;
		
		m_UpV							= Vector( 0.0f, 0.0f, 1.0f );
		m_ZeroV							= Vector( 0.0f, 0.0f, 0.0f );
		
		m_CollidingStrengthOtherF		= -1.0f;
		m_CollidingStrengthRelativeF	= -1.0f;
		
		m_CollidingDirOtherV			= m_ZeroV;
		m_CollidingSideLastE			= SS_SelectedNone;
		m_CollidingSideCooldownF		= 0.0f;
		
		m_CollidingB				= false;
		m_CollidingWithStaticsB		= false;
		m_CollidingWithNpcB			= false;
		m_CollidingAngleF			= 0.0f;
		m_CollidingSideE			= SS_SelectedNone;
		
		
		// Set collision flags
		m_CollisionSightNArr.PushBack( 'Terrain' );
		m_CollisionSightNArr.PushBack( 'Static' );
		m_CollisionSightNArr.PushBack( 'Destructible' );
		
		m_CollisionObstaclesNArr.PushBack( 'Terrain' );
		m_CollisionObstaclesNArr.PushBack( 'Static' );
		m_CollisionObstaclesNArr.PushBack( 'Foliage' );
		m_CollisionObstaclesNArr.PushBack( 'Dynamic' );
		m_CollisionObstaclesNArr.PushBack( 'Destructible' );
		m_CollisionObstaclesNArr.PushBack( 'RigidBody' );
		m_CollisionObstaclesNArr.PushBack( 'Platforms' );
		m_CollisionObstaclesNArr.PushBack( 'Boat' );
		m_CollisionObstaclesNArr.PushBack( 'BoatDocking' );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function Update( _Dt : float )
	{
		var isThereAnyCollision			: bool;
		var canPlayerReactToCollisions	: bool;
		var canPlayerReactToPushes		: bool;
		var canNpcsReactToCollisions	: bool;
		
		
		if( m_CollidingStrengthFadeSpeedF <= 0.0f )
		{
			m_CollidingStrengthRelativeF	= -1.0f;
		}
		else
		{
			m_CollidingStrengthRelativeF	= MaxF( -1.0f, m_CollidingStrengthRelativeF - _Dt * m_CollidingStrengthFadeSpeedF );
		}
		
		isThereAnyCollision			= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount() > 0;
		if( m_CanCollideWithStaticaB && !isThereAnyCollision )
		{
			isThereAnyCollision		= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount() > 0;
		}
		
		if( isThereAnyCollision || isThereAnyCollision != m_IsThereAnyCollisionB )
		{			
			// Pre init data		
			m_CollidingB				= false;
			m_CollidingWithStaticsB		= false;
			m_CollidingWithNpcB			= false;
			m_CollidingAngleF			= 0.0f;
			m_CollidingSideE			= SS_SelectedNone;
			m_CollidingStrengthOtherF	= -1.0f;
		}
		m_IsThereAnyCollisionB	= isThereAnyCollision;
		
		if( m_IsThereAnyCollisionB )
		{		
			canPlayerReactToCollisions	= CanPlayerCollide();
			
			// Check collisions with statics
			if( m_CanCollideWithStaticaB && canPlayerReactToCollisions )
			{
				UpdateCollisionsWithStatics();
			}
			
			// Check Character collisions
			if( !m_CollidingWithStaticsB && m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount() > 0 )
			{
				// Init data
				canPlayerReactToPushes		= CanPlayerBePushed();
				canNpcsReactToCollisions	= CanNPCsCollide();
				
				if( canPlayerReactToCollisions || canPlayerReactToPushes || canNpcsReactToCollisions )
				{
					UpdateCollisionWithNPCs( canPlayerReactToCollisions, canPlayerReactToPushes, canNpcsReactToCollisions );
				}
			}
		}
		
		//SetPlayerCollisionBehaviorData();
		
		//UpdateCollisionTime( _Dt );
		UpdateCollidingSideEvent( _Dt );		
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCollisionWithNPCs( canPlayerReactToCollisions, canPlayerReactToPushes : bool, canNpcsReactToCollisions : bool )
	{
		var collisionData	: SCollisionData;
		var npc				: CNewNPC;
		var collisionNum	: int;
		var i				: int;
		var playerPos		: Vector;
		var playerHandHeight: float;
		
		
		playerPos			= m_ExplorationO.m_OwnerE.GetWorldPosition();
		playerHandHeight	= playerPos.Z + 1.2f;
		
		collisionNum		= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionCharacterData( i );
			
			npc	= ( CNewNPC ) collisionData.entity;
			if( !npc )
			{
				continue; // something wrong happened, skip it
			}
			
			//if( AbsF( collisionData.point.Z - playerHandHeight ) > playerHandHeightRange )
			//{
			//	continue;
			//} 
			
			if( !CanThisNpcCollide( npc ) )
			{
				continue;
			}
			
			// Make the NPC collide
			if( canNpcsReactToCollisions )
			{
				m_CollidingB		= true;
				m_CollidingWithNpcB	= true;
				
				// Tell the npc
				MakeNPCCollide( npc );
			}
			
			// Player collision
			if( canPlayerReactToCollisions )
			{
				if( CanPlayerReactToThisNPC( npc ) )
				{
					UpdatePlayerCollidingSide( npc.GetWorldPosition(), 0.0f );
					UpdatePlayerCollidingHeight( npc );
				}
			}
			
			// Player pushes
			if( canPlayerReactToPushes )
			{
				UpdatePlayerCollidingStrength( npc.GetWorldPosition(), npc.GetMovingAgentComponent().GetVelocityBasedOnRequestedMovement() );
			}
		}
	}
	
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCollisionsWithStatics()
	{
		if( m_ExplorationO.m_MovementCorrectorO.GetIsCollisionCorrected() )
		{
			m_CollidingWithStaticsB	= true;
			m_CollidingB			= true;
			m_CollidingSideE 		= SS_SelectedCenter;
		}
		
		
		/*
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			m_CollidingWithStaticsB	= true;
			m_CollidingB			= true;
			collisionData			= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			UpdatePlayerCollidingSide( collisionData.point, collisionData.normal.Z );
		}
		*/
		
		/*
		// Only walk reactions for static collisions
		if( m_CollidingWithStaticsB )
		{
			if( m_CollidingSideE == SS_SelectedLeft )
			{
				m_CollidingSideE = SS_SelectedRight;
			}
			else if( m_CollidingSideE == SS_SelectedRight )
			{
				m_CollidingSideE = SS_SelectedLeft;
			}
		}
		*/
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function IsCollidingWithStatics() : bool
	{
		return m_ExplorationO.m_OwnerMAC.GetCollisionDataCount() > 0; 
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function GetAngleBlockedByStatics( out min : float, out max : float, angleBlocked : float ) : bool
	{
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		var collisionAngle	: float;
		var collided		: bool;
		
		
		// Init angles
		min					= 360.0f;
		max					= -360.0f;
		collided			= false;
		
		collisionNum		= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			
			if( AbsF( collisionData.normal.Z ) > 0.45f )
			{
				continue;
			}
			
			collisionAngle	= VecHeading( -collisionData.normal );
			min				= MinF( min, collisionAngle - angleBlocked );
			max				= MaxF( max, collisionAngle + angleBlocked );
			collided		= true;
		}
		
		min	= AngleNormalize180( min );
		max	= AngleNormalize180( max );
		
		return collided;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function IsAngleBlockedByStatics( angle : float, angleNeeded : float ) : bool
	{
		var collisionData	: SCollisionData;
		var collisionNum	: int;
		var i				: int;
		var playerPos		: Vector;
		var	collisionAngle	: float;
		
		
		playerPos		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		collisionNum	= m_ExplorationO.m_OwnerMAC.GetCollisionDataCount();			
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData	= m_ExplorationO.m_OwnerMAC.GetCollisionData( i );
			
			if( AbsF( collisionData.normal.Z ) > 0.45f )
			{
				continue;
			}
			
			collisionAngle	= VecHeading( collisionData.point - playerPos );
			if( AbsF( AngleDistance( angle, collisionAngle ) ) > angleNeeded )
			{
				return true;
			}
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCollisionTime( _Dt : float )
	{
		if( m_CollidingB )
		{
			m_TimeCollidingCurF += _Dt;
		}
		else
		{
			m_TimeCollidingCurF	= 0.0f;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CanPlayerCollide() : bool
	{
		if( ( m_ExplorationO.GetStateCur() == 'Idle' || m_ExplorationO.GetStateCur() == 'Pushed' )
			&& ( !thePlayer.rangedWeapon || thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponWait' ) )
		{
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CanPlayerBePushed() : bool
	{
		if( m_ExplorationO.GetStateCur() == 'CombatExploration' )
		{
			return true;
		}
		
		if( m_ExplorationO.GetStateCur() == 'Idle'  || m_ExplorationO.GetStateCur() == 'Pushed' ) //&& !thePlayer.GetIsWalking() )
		{
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CanPlayerReactToThisNPC( npc :CNewNPC ) : bool
	{
		// No collision with vehicles ( like the horse )
		if( npc.GetComponentByClassName('CVehicleComponent') )
		{
			return false;
		}
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CanNPCsCollide() : bool
	{
		/*if( m_ExplorationO.m_MoverO.GetMovementSpeedF() >= m_SpeedToCollideWihNPCsF )
		{
			return true;
		}*/
		if( m_ExplorationO.GetStateCur() != 'Idle' && VecLengthSquared( m_ExplorationO.m_OwnerMAC.GetVelocity() ) >= m_SpeedToCollideWihNPCsF * m_SpeedToCollideWihNPCsF )
		{
			return true;
		}
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private  function CanThisNpcCollide( npc : CNewNPC ) : bool
	{
		var actor		: CActor;
		var cantPush	: int	= 0;
		
		
		if( !npc.IsAlive() || npc.IsInAgony())
		{
			return false;
		}
		else if( npc.IsAnimal())
		{
			return false;
		}
		
		/*cantPush	= npc.SignalGameplayEventReturnInt( 'AI_CantPush', 0 );
		if( cantPush == 1 )
		{
			return false;
		}	*/
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function MakeNPCCollide( npc : CNewNPC )
	{
		//npc.SignalGameplayEvent( 'AI_GetOutOfTheWay' ); // break the job if we can
		npc.SignalGameplayEventParamObject( 'CollideWithPlayer', m_ExplorationO.m_OwnerE ); // Actual collision
		theGame.GetBehTreeReactionManager().CreateReactionEvent( npc, 'BumpAction', 1, 1, 1, 1, false );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdatePlayerCollidingSide( pointToConsider : Vector, normalZ : float )
	{
		var newAngle	: float;
		var auxAngle	: float;	
		
		
		// Can we react to another collision
		if( m_CollidingSideE != SS_SelectedNone && ( !m_CollideCenterIfBothSidesB || m_CollidingSideE == SS_SelectedCenter ) )
		{
			return;
		}
		
		// Is collision considerable
		if( normalZ > m_AcceptableZToBumpF )
		{
			return;
		}	
		
		// Consider the collision
		m_CollidingB	= true;
		
		auxAngle		= VecHeading( pointToConsider - m_ExplorationO.m_OwnerMAC.GetWorldPosition() );
		newAngle		= AngleDistance( m_ExplorationO.m_OwnerMAC.GetHeading(), auxAngle );
		newAngle		= AngleNormalize180( newAngle );
		
		if( newAngle <= -m_AngleToSideF )
		{
			if( m_CollidingSideE == SS_SelectedNone )
			{
				m_CollidingSideE = SS_SelectedLeft;
			}
			else if( m_CollideCenterIfBothSidesB && m_CollidingSideE == SS_SelectedRight )
			{
				newAngle	= 0.0f;
				m_CollidingSideE = SS_SelectedCenter;
			}
		}
		else if( newAngle < m_AngleToSideF )
		{
			m_CollidingSideE = SS_SelectedCenter;
		}
		else if( newAngle >= m_AngleToSideF )
		{
			if( m_CollidingSideE == SS_SelectedNone )
			{
				m_CollidingSideE = SS_SelectedRight;
			}
			else if( m_CollideCenterIfBothSidesB && m_CollidingSideE == SS_SelectedLeft )
			{
				newAngle			= 0.0f;
				m_CollidingSideE	= SS_SelectedCenter;
			}
		}
		
		m_CollidingAngleF	= newAngle;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdatePlayerCollidingHeight( npc : CNewNPC )
	{
		var mac				: CMovingAgentComponent;
		var mpac			: CMovingPhysicalAgentComponent;
		var height			: float;
		var positionOwner	: Vector;
		var positionNpc		: Vector;
		
		
		mac					= npc.GetMovingAgentComponent();
		mpac				= ( CMovingPhysicalAgentComponent ) mac;
		if( !mpac )
		{
			m_CollidingIsLowB	= true;
			
			return;
		}
		
		height				= mpac.GetCapsuleHeight();
		positionOwner		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		positionNpc			= npc.GetWorldPosition();
		
		m_CollidingIsLowB	= positionOwner.Z + m_CollidingLowMinHeightF > positionNpc.Z + height;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdatePlayerCollidingStrength( otherPosition : Vector, otherSpeed : Vector )
	{	
		m_CollidingDirOtherV			= VecNormalize2D( m_ExplorationO.m_OwnerE.GetWorldPosition() - otherPosition );
		m_CollidingStrengthRelativeF	= VecDot2D( m_CollidingDirOtherV, otherSpeed );
		//m_CollidingStrengthRelativeF	= VecDot2D( m_ExplorationO.m_InputO.GetMovementOnPlaneV(), otherSpeed );
		
		if( m_CollidingStrengthRelativeF < 0.0f)
		{
			m_CollidingStrengthOtherF	= 0.0f;
		}
		else
		{
			m_CollidingSpeedOtherV		= otherSpeed;
			m_CollidingStrengthOtherF	= VecLength2D( otherSpeed );
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function GetPushData( out strength : float, out direction : Vector, out otherSpeed : float, out otherVelocity : Vector )
	{
		strength		= m_CollidingStrengthRelativeF;
		direction		= m_CollidingDirOtherV;
		otherSpeed		= m_CollidingStrengthOtherF;
		otherVelocity	= m_CollidingSpeedOtherV;
	}

	//------------------------------------------------------------------------------------------------------------------
	private function SetPlayerCollisionBehaviorData()
	{
		var desiredStance		: EPlayerCollisionStance;
		
		
		// Set the collision stance
		desiredStance	= GetDesiredStance();		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphStanceNameS, ( float ) ( int )desiredStance );
		
		// Set the collision side
		if( m_CollidingSideLastE != m_CollidingSideE )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphSideNameS, ( float ) ( int )m_CollidingSideE );
		}
		
		// Set height
		m_ExplorationO.SetBehaviorParamBool( m_CollideBehGraphHeightN, m_CollidingIsLowB );
		
		// Set the collision Strength
		if( m_VisualReactionToPushB )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphStrengthRelNameS, m_CollidingStrengthRelativeF );
			//m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_CollideBehGraphStrengthRelNameS, m_CollidingStrengthOtherF );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateCollidingSideEvent( _Dt : float )
	{
		if( m_CollidingSideLastE != m_CollidingSideE )
		{
			switch( m_CollidingSideE )
			{
				case SS_SelectedNone	:
					// Cooldown
					m_CollidingSideCooldownF	-= _Dt;
					if( m_CollidingSideCooldownF > 0.0f )
					{
						return;
					}
					
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideStop' );
					break;
				case SS_SelectedLeft	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideLeft' );
					m_CollidingSideCooldownF	= 0.0f;
					break;
				case SS_SelectedRight	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideRight' );
					m_CollidingSideCooldownF	= 0.0f;
					break;
				case SS_SelectedCenter	:
					m_ExplorationO.m_OwnerE.RaiseEvent( 'CollideCenter' );
					m_CollidingSideCooldownF	= 0.3f;
					break;
			}
			
			m_CollidingSideLastE		= m_CollidingSideE;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function GetDesiredStance() : EPlayerCollisionStance
	{
		// Only walk reactions for static collisions
		if( m_CollidingWithStaticsB )
		{
			return GCS_Walk;
		}
		
		if( thePlayer.GetIsSprinting() )
		{
			// When sprinting, only collide with npcs
			if( m_CollidingWithNpcB )
			{
				return GCS_Sprint;
			}
		}
		else if( thePlayer.IsInCombat() )
		{
			return GCS_Combat;
		}
		else if( thePlayer.GetIsRunning() )
		{
			return GCS_Run;
		}
		else if( thePlayer.IsMoving() )
		{
			return GCS_Walk;
		}
		
		return GCS_Idle;
	}
	
	//---------------------------------------------------------------------------------
	public function IsThereWaterAndIsItDeepEnough( point : Vector, height : float, radius : float ) : bool
	{
		var world 			: CWorld;
		var waterLevel 		: float;
		var res 			: bool;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posMid			: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var waterDepth		: float;
		var tempPlayerpos	: Vector;
		
		
		// World and water data
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		//save the endPos
		posEnd		= point;
		posEnd.Z	= height;
		posOrigin	= point;
		
		waterLevel	= world.GetWaterLevel( point );
		
		// Not at water level
		if( height >= waterLevel )
		{
			return false;
		}
		
		// Function GetWaterDepth gives wrong data when the point is below waterLevel
		point.Z = waterLevel + 0.2f;
		waterDepth = world.GetWaterDepth( point, true );
		
		// Not Deep enough?
		if( waterDepth < m_LandWaterMinDepthF )
		{
			return false;
		}
		
		// Terrain in between?
		posEnd.Z	= waterLevel - 0.2f; // To a bit below the water level, to make sure it is not exactl the same
		//res = world.SweepTest( posOrigin, posEnd, radius, posCollided, normalCollided, m_CollisionObstaclesNArr );
		res = world.StaticTrace( posOrigin, posEnd, posCollided, normalCollided, m_CollisionObstaclesNArr );
		if( res )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function CheckLandBelow( distance : float, optional offset : Vector, optional useDefaultCollisionObstacles : bool  ) : bool
	{
		return CheckSwipeInDir( -m_UpV, distance, 0.2f, offset, useDefaultCollisionObstacles );
	}
	
	//---------------------------------------------------------------------------------
	public function CheckCollisionsForwardInHands( distance : float ) : bool
	{
		return CheckSwipeInDir( m_ExplorationO.m_OwnerE.GetWorldForward(), distance, 0.3f, m_UpV );
	}
	
	//---------------------------------------------------------------------------------
	public function CheckCollisionsToNoStepOnInputDir( distForward, heightToStep : float ) : bool
	{
		var direction : Vector;
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			direction	= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		}
		else
		{
			direction	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		return CheckSwipeInDir( direction, distForward + 0.4f, 0.3f, m_UpV * ( heightToStep + 0.3f ), true );
	}
	
	//---------------------------------------------------------------------------------
	public function CheckCollisionsInJumpTrajectory( height : float, distance : float ) : bool
	{
		return CheckSwipeInDir( m_ExplorationO.m_OwnerE.GetWorldForward(), distance, 0.3f, m_UpV * ( height + 0.3f ) );
	}
	
	//---------------------------------------------------------------------------------
	public function EnableVerticalSliding( enable : bool )
	{		
		m_ExplorationO.m_OwnerMAC.EnableAdditionalVerticalSlidingIteration( enable );
	}
	
	//---------------------------------------------------------------------------------
	public function TeleportPlayerToHisGroundIfNeeded( tolerance : float )
	{
		var world 			: CWorld;
		var waterLevel 		: float;
		var res 			: bool;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var ticket			: SMovementAdjustmentRequestTicket;
		var movementAdjustor: CMovementAdjustor;
		
		
		// World and water data
		world		= theGame.GetWorld();
		if( !world )
		{
			return;
		}
		
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		// If the player is not in the water
		waterLevel	= world.GetWaterLevel( posOrigin );
		if( waterLevel >= posOrigin.Z )
		{
			return;
		}
		
		// Check the ground
		posEnd		= posOrigin;
		posOrigin.Z	+= 1.8f;
		posEnd.Z	-= 30.0f;
		res	= world.SweepTest( posOrigin, posEnd, 0.4f, posCollided, normalCollided, m_CollisionObstaclesNArr );
		
		// If there is ground, teleport
		if( res && AbsF( posOrigin.Z - posCollided.Z ) > tolerance || AbsF( posOrigin.Z - posCollided.Z ) < 1.0f )
		{
			// If there is water on the middle
			if( waterLevel >= posCollided.Z )
			{
				posOrigin.Z	= waterLevel;
			}
			// Or on the ground exactly
			else
			{
				posOrigin.Z	= posCollided.Z;
			}
			
			movementAdjustor	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
			ticket				= movementAdjustor.CreateNewRequest( 'teleported_moveDown' );
			
			thePlayer.Teleport( posOrigin );
			
			movementAdjustor.AdjustmentDuration( ticket, 0.1f );
			movementAdjustor.SlideBy( ticket, Vector( 0, 0, -0.3f ) );		
		}		
	}
	
	//---------------------------------------------------------------------------------
	public function CheckSwipeInDir( directionNormalized : Vector, distance : float, radius : float, optional vecOffset : Vector, optional useDefaultCollisionObstacles : bool ) : bool
	{
		var world 			: CWorld;
		var posCurrent		: Vector;
		var posPredicted	: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var res				: bool;
		
		// Physics World 
		world	= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		// Get points to sweep
		posCurrent		= m_ExplorationO.m_OwnerE.GetWorldPosition() + vecOffset;
		posPredicted	= posCurrent;
		posPredicted	+= directionNormalized * distance;
		
		// Do the sweep
		if( useDefaultCollisionObstacles )
		{
			res	= world.SweepTest( posCurrent, posPredicted, radius, posCollided, normalCollided, m_CollisionObstaclesNArr );
		}
		else
		{
			res	= world.SweepTest( posCurrent, posPredicted, radius, posCollided, normalCollided );
		}
		if( !res )
		{
			return false;
		}
		
		// Collision is going in the general direction
		if( VecDot( normalCollided, -directionNormalized ) < 0.75f )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function CheckLineOfSightHorizontal( point : Vector ) : bool
	{
		var world 			: CWorld;
		var posOrigin		: Vector;
		var direction		: Vector;
		var distance		: float;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var res				: bool;
		
		
		// World and water data
		world		= theGame.GetWorld();
		if( !world )
		{
			return true;
		}
		
		// Height modification
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp();
		point.Z		= posOrigin.Z;
		direction	= point - posOrigin;
		distance	= VecLength( direction );
		
		if( distance < 0.5f )
		{
			return true;
		}
		
		point		-= direction * 0.3f / distance;
		
		// Terrain in between?
		res = world.StaticTrace( posOrigin, point, posCollided, normalCollided, m_CollisionGroupsNamesNArr );
		if( res )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function HasGroundCollisions() : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		
		
		mac				= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		if( 	mac.GetGroundGridCollisionOn( CS_CENTER ) 
			||	mac.GetGroundGridCollisionOn( CS_FRONT )
			||	mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) 
			||	mac.GetGroundGridCollisionOn( CS_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_RIGHT ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) 
			||	mac.GetGroundGridCollisionOn( CS_BACK_RIGHT )  )
		{
			return true;
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function GetHasToFallInDirection( out direction: float ) : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		var hasCenterGround	: bool;
		var front			: bool;
		var left			: bool;
		var right			: bool;
		var back			: bool;
		
		
		if( !forceFallEnabled )
		{
			return false;
		}
		
		if( m_ExplorationO.GetStateCur() != 'Idle' && m_ExplorationO.GetStateCur() != 'CombatExploration' ) // || 
		{
			return false;
		}
		
		mac				= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		hasCenterGround	= mac.GetGroundGridCollisionOn( CS_CENTER );
		
		if( forceFallRequireCenter && hasCenterGround )
		{
			return false;
		}
		
		if( !forceFallRunning && thePlayer.GetIsRunning() )
		{
			return false;
		}
		
		// Init
		direction	= 0.0f;
		
		/*
		front	= !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_RIGHT );
		left	= !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_BACK );
		right	= !mac.GetGroundGridCollisionOn( CS_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_BACK );
		back	= !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_RIGHT );
		*/
		
		front	= !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		left	= !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT );
		right	= !mac.GetGroundGridCollisionOn( CS_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		//back	= !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT );
		back	= !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_LEFT ) && !mac.GetGroundGridCollisionOn( CS_RIGHT );
		
		// No ground anywhere
		if( front && left && right && back )
		{
			return false;
		}
		
		// Decide direction		
		else if( front  && left && right )
		{
			direction	= 0.0f;
		}
		else if( front && right && back )
		{
			direction	= 0.5f;
		}
		else if( front && left && back )
		{
			direction	= -0.5f;
		}
		else if( front || back )
		{
			if( left )
			{
				direction	= -0.25f;
			}
			else if( right )
			{
				direction	= 0.25f;
			}
			else if( front )
			{
				direction	= 0.0f;
			}
			else // back
			{
				direction	= -1.0f;
			}
		}
		else if( left )
		{
			direction	= -0.5f;
		}
		else if( right )
		{
			direction	= 0.5f;
		}
		
		// We have a direction to go
		if( front || right || left || back )
		{
			if( !front && !right && !left && m_ExplorationO.GetStateCur() != 'Idle' )
			{
				return false;
			}
			
			if( IsAngleBlockedByStatics( direction + m_ExplorationO.m_OwnerE.GetHeading(), 45.0f ) )
			{
				return false;
			}
			
			if( !IsDirectionToFallFree( direction + m_ExplorationO.m_OwnerE.GetHeading() ) )
			{
				return false;
			}
			
			return true;
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function IsInSolidGround() : bool
	{
		var mac	: CMovingPhysicalAgentComponent;
		
		mac		= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		if( !mac.GetGroundGridCollisionOn( CS_CENTER )
			|| !mac.GetGroundGridCollisionOn( CS_FRONT ) || !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) || !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT ) 
			|| !mac.GetGroundGridCollisionOn( CS_LEFT ) || !mac.GetGroundGridCollisionOn( CS_RIGHT ) 
			|| !mac.GetGroundGridCollisionOn( CS_BACK ) || !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) || !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT ) )
		{
			return false;
		}
		else
		{
			return true;
		}		
	}
	
	//---------------------------------------------------------------------------------
	public function IsDirectionToFallFree( headingLocal : float ) : bool
	{
		var direction	: Vector;
		
		
		// Is the capsule already colliding with a wall in that direction?
		
		
		direction	= VecFromHeading( headingLocal + m_ExplorationO.m_OwnerE.GetHeading() );
		
		// Direction is not clear
		if( CheckSwipeInDir( direction, 0.6f, 0.4f, m_ExplorationO.m_OwnerE.GetWorldUp(), true ) )
		{
			return false;
		}
		
		// There is ground to cloose forward
		/*if( CheckLandBelow( 0.3f, direction * 0.5f ) )
		{
			return false;
		}*/
		
		return true;
	}

	//---------------------------------------------------------------------------------
	public function GetLandGoesToFall( ) : bool
	{
		var mac				: CMovingPhysicalAgentComponent;
		var hasCenterGround	: bool;
		var front			: bool;
		var restOfCollisions: bool;
		
		
		mac					= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		// If we have no collisions on the sides and back, we will not enter
		restOfCollisions	= !mac.GetGroundGridCollisionOn( CS_CENTER ) && !mac.GetGroundGridCollisionOn( CS_BACK ) && !mac.GetGroundGridCollisionOn( CS_BACK_LEFT ) && !mac.GetGroundGridCollisionOn( CS_BACK_RIGHT );
		if( restOfCollisions )
		{
			return false;
		}
		
		// If we have no collisions in front, we will enter
		front	= !mac.GetGroundGridCollisionOn( CS_FRONT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_LEFT ) && !mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		
		return front;
	}
	
	
	//---------------------------------------------------------------------------------
	public function IsGoingDownSlopeInstant( _AutoRollSlopeCoefF : float ) : bool
	{
		var world 			: CWorld;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posCollided1	: Vector;
		var posCollided2	: Vector;
		var normalCollided1	: Vector;
		var normalCollided2	: Vector;
		var direction		: Vector;
		var res				: bool;
		
		var	slideCoef		: float;
		
		
		// World data
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		// We'll do 2 raycasts, one in the back and one in the front, and we'll get the forward slope of it
		// Positions to raycast
		posOrigin	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		direction	= m_ExplorationO.m_OwnerE.GetWorldForward() * 0.4f;
		
		posOrigin	-= direction;
		posEnd		= posOrigin;
		posEnd.Z	-= 0.75f;		
		posOrigin.Z	+= 0.75f;	
		
		//res = world.StaticTrace( posOrigin, posEnd, posCollided1, normalCollided1 );
		res = world.SweepTest( posOrigin, posEnd,0.2f, posCollided1, normalCollided1 );
		if( !res )
		{
			return false;
		}
		
		posOrigin	+= 2.0f * direction;
		posEnd		+= 2.0f * direction;
		
		//res = world.StaticTrace( posOrigin, posEnd, posCollided2, normalCollided2, m_CollisionObstaclesNArr );
		res = world.SweepTest( posOrigin, posEnd,0.2f, posCollided2, normalCollided2 );
		if( !res )
		{
			return false;
		}
		
		//slideCoef	= m_ExplorationO.m_MoverO.GetRawSlideCoef( false ); slideCoef > m_AutoRollSlopeCoefF
		
		direction	= VecNormalize( posCollided2 - posCollided1 ); 
		
		// If slope goes "down"
		if( VecDot( direction, Vector( 0.0f, 0.0f, -1.0f ) ) > 0.0f )
		{
			slideCoef	= direction.Z;
			// And is sloped enough
			if( slideCoef < -_AutoRollSlopeCoefF )
			{
				return true;
			}
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function IsGoingUpSlope( direction : Vector, optional upCoef : float, optional frontCoef : float ) : bool
	{	
		var slopeDir 	: Vector;
		var slopeNormal	: Vector;
		var slopeDot	: float;
		
		
		// Defaults
		if( upCoef == 0.0f )
		{
			upCoef	= 0.75;
		}
		
		
		//slopeNormal	= m_ExplorationO.m_OwnerMAC.GetTerrainNormal( false );
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slopeDir, slopeNormal );
		if( slopeNormal.Z < upCoef )
		{
			slopeDot	= VecDot( -slopeDir, direction ); 
			if( slopeDot > frontCoef )
			{
				return true;
			}
		}
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function IsGoingUpSlopeInInputDir( optional upCoef : float, optional frontCoef : float ) : bool
	{	
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return IsGoingUpSlope( m_ExplorationO.m_OwnerE.GetWorldForward(), upCoef, frontCoef );
		}
		
		return IsGoingUpSlope( m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV(), upCoef, frontCoef );
		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	public function GetJumpGoesToWater() : bool
	{
		var	inputVector			: Vector;
		var origin				: Vector;
		var end					: Vector;
		var midPoint			: Vector;
		var normal				: Vector;
		var collisionPoint		: Vector;
		var endUpPoint			: Vector;
		var	wallFound			: bool;
		var jumpDistance		: float		= 3.8f; //4.5f;
		var jumpRadius			: float		= 0.6f;
		var jumpHeight			: float		= 0.5f;
		var jumpMaxFallHeight	: float		= 250.0f;
		
		
		// get the direction to check the jump
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputVector	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		}
		else
		{
			inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV = inputVector;
		
		// Boat special case
		if( thePlayer.IsOnBoat() )
		{
			if( !GetJumpGoesToWaterFromBoat( inputVector ) )
			{
				return false;
			}
		}
		
		// Do we have some physic world?
		if( !theGame.GetWorld() )
		{
			return false;
		}
		
		// Get the points
		origin		= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp() * ( jumpHeight + jumpRadius ) + m_ExplorationO.m_OwnerE.GetWorldForward() * 0.4f;
		end			= origin + inputVector * jumpDistance;
		midPoint	= origin + inputVector * jumpDistance * 0.5f;
		
		// Do we have a clear path forward?		
		wallFound		= theGame.GetWorld().SweepTest( origin, midPoint, jumpRadius, collisionPoint, normal, m_CollisionObstaclesNArr );
		if( wallFound )
		{			
			lastWaterCheckPoint	= collisionPoint;
			return false;
		}
		wallFound		= theGame.GetWorld().SweepTest( midPoint, end, jumpRadius, collisionPoint, normal, m_CollisionObstaclesNArr );
		if( wallFound )
		{			
			lastWaterCheckPoint	= collisionPoint;
			return false;
		}
		
		// Is there water below?
		endUpPoint			= end;
		endUpPoint.Z		= origin.Z;
		lastWaterCheckPoint	= endUpPoint;
		return IsThereWaterAndIsItDeepEnough( endUpPoint, end.Z - jumpMaxFallHeight, jumpRadius );		
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function GetJumpGoesToWaterFromBoat( inputVector : Vector ) : bool
	{
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;	
		var direction			: Vector;
		
		var	dot					: float;
		var	dot2				: float;
		var	angle				: float;
		
		// Get exploration from closest boat vehicle
		vehicleComponent		= thePlayer.FindTheNearestVehicle( 6.0f, false );
		if( vehicleComponent )
		{
			vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
			if( vehicleEntity )
			{
				// Are we aiming to the side?
				dot				= VecDot( inputVector, vehicleEntity.GetWorldForward() );
				dot				= AbsF( dot );
				if( dot < 0.5f )
				{
					// To the proper side?
					direction	= m_ExplorationO.m_OwnerE.GetWorldPosition() - vehicleEntity.GetWorldPosition();
					dot			= VecDot( direction, vehicleEntity.GetWorldRight() );
					dot2		= VecDot( inputVector, vehicleEntity.GetWorldRight() );
					if( dot * dot2 > 0.0f )
					{
						return true;
					}
				} 
			}
		}
		
		return false;
	}

	//------------------------------------------------------------------------------------------------------------------
	public function GetJumpGoesOutOfBoat() : bool
	{
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;	
		var direction			: Vector;
		
		var	dot					: float;
		var	dot2				: float;
		var	angle				: float;
		var	inputVector			: Vector;
		
		
		// get the direction to check the jump
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputVector	= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		}
		else
		{
			inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		
		// Get exploration from closest boat vehicle
		vehicleComponent		= thePlayer.FindTheNearestVehicle( 6.0f, false );
		if( vehicleComponent )
		{
			vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
			if( vehicleEntity )
			{
				// Are we aiming to the side?
				dot				= VecDot( inputVector, vehicleEntity.GetWorldForward() );
				dot				= AbsF( dot );
				return dot < 0.6f;
			}
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function UpdateDebugInfo()
	{
		var auxString		: string;
		var textColor		: Color		= Color( 255,255,0 );
		var width			: int		= 200;
		var height			: int		= 10;
		var heightCur		: int;
		var heightInit		: int		= 100;
		var heightInactive	: int		= 300;
		var heightOffset	: int		= 15;
		var heightOffsetBig	: int		= 25;
		var left			: int		= 850;
		var center			: int		= 950;
		var right			: int		= 1050;
		var i				: int;
		var mac				: CMovingPhysicalAgentComponent;
		
		
		mac			= ( CMovingPhysicalAgentComponent ) m_ExplorationO.m_OwnerMAC;
		
		heightCur	= heightInit;
		thePlayer.GetVisualDebug().AddBar( 'GroundCollisionFail', left, heightCur, width, height, 0.0f, textColor, "Ground collisions", 0.0f );
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_FRONT_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_FRONT_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_CENTER );
		thePlayer.GetVisualDebug().AddBar( 'CS_CENTER', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		
		
		heightCur	+= heightOffset;
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK_LEFT );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK_LEFT', left, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK', center, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );	
		
		auxString	= "" + mac.GetGroundGridCollisionOn( CS_BACK_RIGHT );
		thePlayer.GetVisualDebug().AddBar( 'CS_BACK_RIGHT', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );		
	}	

	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		var vectorUp	: Vector;
		var destination	: Vector;
		
		if( !debugEnabled )
		{
			return true;
		}
		
		/*vectorUp	= Vector( 0.0f, 0.0f, 1.0f );
		
		destination	= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_CollidingDirOtherV * 1.3f + vectorUp;
		frame.DrawLine( m_ExplorationO.m_OwnerE.GetWorldPosition() + vectorUp, destination, Color( 0, 255, 0 ) );
		frame.DrawSphere( destination, 0.2f, Color( 0, 255, 0 ) );
		frame.DrawText( "Strength " + m_CollidingStrengthRelativeF, destination, Color( 0, 255, 0 ) );
		*/
		
		frame.DrawSphere( lastWaterCheckPoint, 0.3f, Color( 0, 255, 0 ) );
		frame.DrawText( "Water ", lastWaterCheckPoint, Color( 0, 255, 0 ) );
		
		
		return true;
	}
}
