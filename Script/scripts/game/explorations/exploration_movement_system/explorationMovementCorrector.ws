// CxplorationSharedData
//------------------------------------------------------------------------------------------------------------------
// This class will decide on movement direction correction
//
// Eduard Lopez Plans	( 25/07/2014 )	 
//------------------------------------------------------------------------------------------------------------------

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
enum EMovementCorrectionType
{
	EMCT_None			= 0	,
	EMCT_Collision			,
	EMCT_Push				,
	EMCT_Physics			,
	EMCT_NavMesh			,
	EMCT_Exploration		,
	EMCT_Door				,
	EMCT_Fall				,
	
	EMCT_Size				,
};
	
//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationMovementCorrector
{
	private var	m_ExplorationO				: CExplorationStateManager;
	
	// Corrected data
	private var correctionNone				: NavigationCorrection;
	private var correctionOnCollision		: NavigationCorrection;
	private var correctionOnPhysics			: NavigationCorrection;
	private var correctionOnPush			: NavigationCorrection;
	private var correctionOnNavMesh			: NavigationCorrection;
	private var correctionOnExploration		: NavigationCorrection;
	private var correctionOnDoors			: NavigationCorrection;
	private var correctionOnFalling			: NavigationCorrection;

	private var correctionAccepted			: NavigationCorrection;
	
	
	// Internal temporary data
	private var	validExploration			: SExplorationQueryToken;
	private var checkingForRun				: bool;
	private var checkingForCombat			: bool;
	private var	inputDiference				: float;
	
	// Push
	private var	pushSlowingTimeCooldown		: float;		default	pushSlowingTimeCooldown		= 0.01f;
	private var	pushSlowingTimeCur			: float;
	private var maxPushAngleSlow			: float;		default maxPushAngleSlow			= 45.0f;
	private var maxPushAngleTurn			: float;		default maxPushAngleTurn			= 70.0f;
	private var	pushCooldownTotal			: float;		default pushCooldownTotal			= 0.05f;
	private var	pushCooldownCur				: float;
	private var	pushDirection				: Vector;
	
	// Collision
	private var	collisionStopped			: bool;
	
	// Enable
	private var enableCollisionWalking		: bool;			default	enableCollisionWalking		= true;	
	private var enableCollisionRunning		: bool;			default	enableCollisionRunning		= true;
	private var enablePushCombat			: bool;			default	enablePushCombat			= true;	
	private var enablePushWhileMoving		: bool;			default	enablePushWhileMoving		= true;
	private var enablePhysicsWalking		: bool;			default	enablePhysicsWalking		= false;
	private var enablePhysicsRunning		: bool;			default	enablePhysicsRunning		= false;
	private var enableNavMeshWalking		: bool;			default	enableNavMeshWalking		= false;
	private var enableNavMeshRunning		: bool;			default	enableNavMeshRunning		= false;
	private var enableExplorationWalking	: bool;			default	enableExplorationWalking	= false;
	private var enableExplorationRunning	: bool;			default	enableExplorationRunning	= false;
	private var enableDoorsWalking			: bool;			default	enableDoorsWalking			= true;
	private var enableDoorsRunning			: bool;			default	enableDoorsRunning			= true;
	
	// Configuration
	private var limitCorrectionTurningSide	: bool;			default	limitCorrectionTurningSide	= true;
	private var inputDifToSide				: float;		default	inputDifToSide				= 1.0f;
	
	
	private var maxPhysicSideDistance		: float;		default maxPhysicSideDistance		= 0.7f;
	private var maxPhysicPortalDistance		: float;		default maxPhysicPortalDistance		= 1.0f;
	
	// Base parameters
	private var maxPhysicDistanceWalk		: float;		default maxPhysicDistanceWalk		= 0.5f;
	private var maxPhysicDistanceRun		: float;		default maxPhysicDistanceRun		= 0.7f;
	private var maxPhysicAngleWalk			: float;		default maxPhysicAngleWalk			= 45.0f;
	private var maxPhysicAngleRun			: float;		default maxPhysicAngleRun			= 60.0f;
	
	private var maxNavmeshDistanceWalk		: float;		default maxNavmeshDistanceWalk		= 0.7f;
	private var maxNavmeshDistanceRun		: float;		default maxNavmeshDistanceRun		= 2.0f;
	private var maxNavmeshAngleWalk			: float;		default maxNavmeshAngleWalk			= 45.0f;
	private var maxNavmeshAngleRun			: float;		default maxNavmeshAngleRun			= 60.0f;
	
	private var maxExplorationDistanceWalk	: float;		default maxExplorationDistanceWalk	= 0.5f;
	private var maxExplorationDistanceRun	: float;		default maxExplorationDistanceRun	= 2.1f;
	private var maxExplorationAngleWalk		: float;		default maxExplorationAngleWalk		= 15.0f;
	private var maxExplorationAngleRun		: float;		default maxExplorationAngleRun		= 15.0f;
	
	private var maxDoorDistanceWalk			: float;		default maxDoorDistanceWalk			= 2.5f;
	private var maxDoorDistanceRun			: float;		default maxDoorDistanceRun			= 2.1f;
	private var maxDoorAngleWalk			: float;		default maxDoorAngleWalk			= 65.0f;
	private var maxDoorAngleRun				: float;		default maxDoorAngleRun				= 65.0f;
	private var maxDoorAngleGather			: float;		default maxDoorAngleGather			= 45.0f;
	private var maxDoorBack					: float;		default maxDoorBack					= 1.0f;
	private var maxDoorHeight				: float;		default maxDoorHeight				= 1.0f;
	
	
	// Turn adjustment
	private var	turnAdjustBlocked			: bool;
	private var	animEventBlockTurnAdjust	: name;			default	animEventBlockTurnAdjust	= 'blockTurnAdjust';
	private var turnAdjustmentEnabled		: bool;			default	turnAdjustmentEnabled		= true;
	private var turnAdjustmentTimeCur		: float;
	private var turnAdjustmentTimeMax		: float;		default	turnAdjustmentTimeMax		= 0.3f;
	
	// Start run adjustment
	private var inputLastModule				: float;
	private	var inputSpeedLast				: float;
	private	var inputSpeedToStartRun		: float;		default	inputSpeedToStartRun		= 30.0f;
	private	var inputSpeedToStartRunHiFPS	: float;		default	inputSpeedToStartRunHiFPS	= 22.0f;
	
	
	// Camera
	private var cameraRequestByDoor			: bool;	
	
	
	// Debug only
	private	var	doorPoint					: Vector;
	private var	auxDiff						: float;
	private var	debugPush					: bool;			default	debugPush					= false;
	private var	debugingSpeed				: bool;			default	debugingSpeed				= false;
	
	// Totally not a hack
	public var disallowRotWhenGoingToSleep	: bool;			default disallowRotWhenGoingToSleep = false;
	
	//------------------------------------------------------------------------------------------------------------------
	public function Initialize( explorationManager : CExplorationStateManager )
	{
		m_ExplorationO						= explorationManager;
		
		
		correctionNone						= new NavigationCorrection in this;
		correctionNone.color				= Color( 0, 0, 0 );
		correctionNone.type					= EMCT_None;
		correctionNone.corrected			= false;
		correctionNone.angle				= 0.0f;
		
		correctionOnExploration				= new NavigationCorrection in this;
		correctionOnExploration.color		= Color( 255, 50, 50 );
		correctionOnExploration.type		= EMCT_Exploration;
		
		
		correctionOnDoors					= new NavigationCorrection in this;
		correctionOnDoors.color				= Color( 50, 155, 155 );
		correctionOnDoors.type				= EMCT_Door;
		
		correctionOnFalling					= new NavigationCorrection in this;
		correctionOnFalling.color			= Color( 155, 50, 155 );
		correctionOnFalling.type			= EMCT_Fall;
		
		correctionOnCollision				= new NavigationCorrection in this;
		correctionOnCollision.color			= Color( 155, 155, 50 );
		correctionOnCollision.type			= EMCT_Collision;
		
		correctionOnPush					= new NavigationCorrection in this;
		correctionOnPush.color				= Color( 50, 255, 50 );
		correctionOnPush.type				= EMCT_Push;
		
		correctionOnPhysics					= new NavigationCorrection in this;
		correctionOnPhysics.color			= Color( 50, 255, 50 );
		correctionOnPhysics.type			= EMCT_Physics;
		
		correctionOnNavMesh					= new NavigationCorrection in this;
		correctionOnNavMesh.color			= Color( 50, 50, 255 );
		correctionOnNavMesh.type			= EMCT_NavMesh;
		
		// Register events
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( animEventBlockTurnAdjust, 'OnAnimEvent_SubstateManager' );
		
		turnAdjustBlocked					= false;
		turnAdjustmentTimeCur				= 0.0f;
	}
	
	//---------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == animEventBlockTurnAdjust )
		{
			turnAdjustBlocked = true;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function PreUpdate( _Dt : float )
	{		
		pushSlowingTimeCur	-= _Dt;
		pushCooldownCur		-= _Dt;
		
		UpdateTurnAdjustment( _Dt );
		
		UpdateStartRun( _Dt );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function PostUpdate( _Dt : float )
	{ 
		turnAdjustBlocked	= false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function CorrectDirectionToAvoid( direction : Vector, out newDirection : Vector, anyInput : bool ) : bool
	{		
		UpdatePlayerData();
		
		// Check all corrections
		UpdateCorrections( direction, anyInput ); 
		
		// Decide best correction
		FindBestCorrection();		
		
		
		if( correctionAccepted.type != EMCT_None )
		{
			newDirection	= correctionAccepted.direction;
			
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function ModifySpeedRequired( out speed : float ) : bool
	{	
		if( correctionAccepted.type == EMCT_Push )
		{
			if( pushSlowingTimeCur > 0.0f )
			{
				speed	= 0.0f;
			}
			else
			{
				speed	= 1.0f;
			}
			
			return true;
		}
		
		else if( collisionStopped )
		{
			if ( m_ExplorationO.GetStateCur() == 'Swim' )
				speed	= MinF( speed, 0.21f );
			else
				speed	= MinF( speed, 0.1f );
			
			
			return true;
		}
		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function IsDoorRequestingCamera() : bool
	{
		return cameraRequestByDoor;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdatePlayerData()
	{
		if( thePlayer.GetIsRunning() || thePlayer.GetIsSprinting() )
		{
			checkingForRun	= true;
		}
		else
		{
			checkingForRun	= false;
		}
		
		if( m_ExplorationO.GetStateCur() == 'CombatExploration' )
		{
			checkingForCombat	= true;
		}
		else
		{
			checkingForCombat	= false;
		}
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			//inputDiference	= m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF();
			inputDiference	= m_ExplorationO.m_InputO.GetHeadingOnPadF();
		}
		else
		{
			inputDiference	= 0.0f;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function StartTurnAdjustment( )
	{
		if( turnAdjustmentEnabled )
		{		
			turnAdjustmentTimeCur	= turnAdjustmentTimeMax;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function CancelTurnAdjustment()
	{
		turnAdjustmentTimeCur	= 0.0f;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateTurnAdjustment( _Dt : float )
	{
		var	adjustTime		: float;
		var playerActionEventListeners : array<CGameplayEntity>;
		var vel : float;
		var player : CR4Player;
		
		if ( !theGame.IsUberMovementEnabled() || disallowRotWhenGoingToSleep )
			turnAdjustBlocked = true;
		else if ( AbsF( AngleDistance( thePlayer.rawPlayerHeading, thePlayer.GetHeading() ) ) >= 144.f )
			turnAdjustBlocked = true;
		else if ( thePlayer.IsInCombatAction() )
			turnAdjustBlocked = true;	
		//else if ( theInput.GetContext() == 'ScriptedAction' )
		//	turnAdjustBlocked = true;
		else if ( VecLength( m_ExplorationO.m_OwnerMAC.GetVelocity() ) <= 0.f )
			turnAdjustBlocked = true;
		/*else
		{
			playerActionEventListeners = thePlayer.GetPlayerActionEventListeners();
			if ( playerActionEventListeners.Size() > 0 )
				turnAdjustBlocked = true;
		}*/
			
		if( turnAdjustmentTimeCur > 0.0f && thePlayer.IsAlive() )
		{
			m_ExplorationO.m_MoverO.UpdateOrientToInput( 3.0f, _Dt );
			turnAdjustmentTimeCur	-= _Dt;
		}
		else
		{		
			if( !turnAdjustBlocked )
			{
				adjustTime	= m_ExplorationO.GetTurnAdjustmentTime();
				if( adjustTime > 0.0f )
				{
					m_ExplorationO.m_MoverO.UpdateOrientToInput( 2.5f, _Dt );
				}
				else if ( thePlayer.GetPlayerCombatStance() == PCS_Normal )
				{
					player = thePlayer;
					
					if ( player.rangedWeapon && player.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
						m_ExplorationO.m_MoverO.UpdateOrientToInput( 2.5f, _Dt );
				}
			}
		}		
	} 
	private function UpdateStartRun( _Dt : float )
	{	
		var inputModule		: float;
		var inputSpeed		: float;
		var	isInputFast		: bool;
		var	isRunAllowed	: bool;
		var speedRequired	: float;
		
		inputModule		= m_ExplorationO.m_InputO.GetModuleF();
		inputSpeed		= AbsF( inputLastModule - inputModule ) / _Dt;
		
		// If we have super high framerrate, we check a different speed
		if( _Dt < 0.0153846f ) //1.0f / 65.0f)
		{
			speedRequired	= inputSpeedToStartRunHiFPS;
		}
		else
		{
			speedRequired	= inputSpeedToStartRun;
		}
		
		/*
		if( inputSpeed > 0.0f && inputModule > 0.2f  && inputModule > inputLastModule )
		{
			debugingSpeed	= true;
			LogChannel( 'ForceRun', "speed :" + inputSpeed );
		}
		else if( debugingSpeed )
		{
			debugingSpeed	= false;
			LogChannel( 'ForceRun', "Stopped" );
		}
		*/
		
		// Input module is run already or it is changing fast enough
		isInputFast		= inputSpeed > speedRequired || inputSpeedLast > speedRequired;
		// And it is increasing
		isInputFast		= isInputFast && inputModule > 0.0f && inputModule >= inputLastModule;
		// Or it is already running
		isInputFast		= isInputFast || inputModule >= 0.8f;
		
		isRunAllowed	= thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && thePlayer.IsActionAllowed( EIAB_Sprint ) && !thePlayer.GetIsWalkToggled();
		if( isInputFast && isRunAllowed && theGame.IsUberMovementEnabled() )
		{
			thePlayer.SetBehaviorVariable( 'inputForceRun', 1.0f );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'inputForceRun', 0.0f );
		}
		inputLastModule		= m_ExplorationO.m_InputO.GetModuleF();
		if( thePlayer.GetBehaviorVariable( 'inputDirectionIsNotReady' ) )
		{
			inputSpeedLast	= MaxF( inputSpeedLast, inputSpeed );
		}
		else
		{
			inputSpeedLast	= inputSpeed;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function UpdateCorrections( direction : Vector, anyInput : bool )
	{
		// Init
		correctionOnCollision.corrected		= false;
		correctionOnFalling.corrected		= false;
		correctionOnPhysics.corrected		= false;
		correctionOnPush.corrected			= false;
		correctionOnExploration.corrected	= false;
		correctionOnNavMesh.corrected		= false;
		correctionOnDoors.corrected			= false;
		cameraRequestByDoor					= false;
		collisionStopped					= false;
		
		
		// Other npcs pushing you away
		if( enablePushCombat && checkingForCombat && ( anyInput || enablePushWhileMoving ) )
		{
			CorrectDirectionOnPush( direction, correctionOnPush );
		}
		
		// For the rest of corrections we need the character to actually move
		if( !anyInput )
		{
			return;
		}
		
		// Correction for smooth Collision avoiding
		if( ( !checkingForRun && enableCollisionWalking ) || ( checkingForRun && enableCollisionRunning ) )
		{
			CorrectDirectionOnCollision( direction, correctionOnCollision );
		}
		
		// Physics navigation correction
		if( ( !checkingForRun && enablePhysicsWalking ) || ( checkingForRun && enablePhysicsRunning ) )
		{
			CorrectDirectionOnPhysycs( direction, correctionOnPhysics );
		}
		
		// Navmesh and fall corrections
		if( ( !checkingForRun && enableNavMeshWalking ) || ( checkingForRun && enableNavMeshRunning ) )
		{
			CorrectDirectionOnNavmesh( direction, correctionOnNavMesh );
		}
		
		// Exploration correction
		if( ( !checkingForRun && enableExplorationWalking ) || ( checkingForRun && enableExplorationRunning ) )
		{
			CorrectDirectionOnExploration( direction, correctionOnExploration );
		}
		
		// To enter doors
		if( ( !checkingForRun && enableDoorsWalking ) || ( checkingForRun && enableDoorsRunning ) )
		{
			CorrectDirectionOnDoors( direction, correctionOnDoors );
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function FindBestCorrection()
	{
		// Collision overrides all kind of correction
		if( correctionOnCollision.corrected )
		{
			correctionAccepted	= correctionOnCollision;
			
			return;
		}
		
		// Push also overrides all others
		if( correctionOnPush.corrected )
		{
			correctionAccepted	= correctionOnPush;
			
			return;
		}
		
		// Fall is next
		if( correctionOnFalling.corrected )
		{
			correctionAccepted	= correctionOnFalling;
			
			return;
		}
		
		// For now, doors also override everything
		if( correctionOnDoors.corrected )
		{
			correctionAccepted	= correctionOnDoors;
			
			return;
		}
		
		// Between physics and navmesh, we take the correction that moves us farther away
		if( correctionOnPhysics.corrected )
		{
			if( correctionOnNavMesh.corrected && AbsF( correctionOnNavMesh.angle ) > AbsF( correctionOnPhysics.angle ) )
			{
				correctionAccepted	= correctionOnNavMesh;
			}
			else
			{
				correctionAccepted	= correctionOnPhysics;
			}
		}
		else if( correctionOnNavMesh.corrected )
		{
			correctionAccepted	= correctionOnNavMesh;
		}
		
		// For exploration, we take the correction if it is closer than any physics or navmesh
		if( correctionOnExploration.corrected )
		{
			if( ( !correctionOnPhysics.corrected && !correctionOnNavMesh.corrected ) || AbsF( correctionOnExploration.angle ) < AbsF( correctionAccepted.angle ) )
			{
				correctionAccepted	= correctionOnExploration;
			}
		}	
		
		// Found no correction available
		else if( !correctionOnPhysics.corrected && !correctionOnNavMesh.corrected )
		{
			correctionAccepted	= correctionNone;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnDoors( direction : Vector, out correction : NavigationCorrection )
	{
		var entities		: array<CGameplayEntity>;
		var maxAngle		: float;
		var maxDist			: float;
		var maxAngleDot		: float;
		var doorMark		: CDoorMarking;
		var playerPos		: Vector;
		var normal			: Vector;
		var point			: Vector;
		var correctedDir	: Vector;
		var foundDoors		: int;
		var i				: int;
		var	distance		: float;
		
		
		// Get the max angle depending on state
		if( checkingForRun )
		{
			maxAngle	= maxDoorAngleRun;
			maxDist		= maxDoorDistanceRun;
		}
		else
		{
			maxAngle	= maxDoorAngleWalk;
			maxDist		= maxDoorDistanceWalk;
		}		
		playerPos	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		// Get doors around
		FindGameplayEntitiesInCone( entities, playerPos - m_ExplorationO.m_OwnerE.GetWorldForward() * maxDoorBack, VecHeading( direction ), maxDoorAngleGather, maxDist + maxDoorBack, 100, 'navigation_correction' );
		foundDoors	= entities.Size();
		
		if( foundDoors <= 0 )
		{
			return;
		}
		
		maxAngleDot	= CosF( Deg2Rad( maxAngle ) );
		
		// Get the first valid door
		for( i = 0; i < foundDoors; i += 1 )
		{
			doorMark		= ( CDoorMarking ) entities[i].GetComponentByClassName( 'CDoorMarking' );
			
			// Did we found an entity with the door_marking tag that is not a CDoorMarking
			if( !doorMark )
			{
				continue;
			}
			
			// Tell the door we found it, for debug purposes
			doorMark.SetCheckState( EDMCT_Considered );
			
			// Get the normal and location
			doorMark.GetClosestPointAndNormal( point, normal );
			
			
			// Filter by height
			if( point.Z < playerPos.Z - maxDoorHeight || point.Z > playerPos.Z + maxDoorHeight )
			{
				continue;
			}
			
			// Can we correct to it by normal angle?
			if( AbsF( VecDot( normal, direction ) ) < maxAngleDot )
			{
				continue;
			}
			
			// Can we correct to it by direction angle?
			correctedDir	= point - playerPos;
			if( VecDot( correctedDir, direction ) < 0.0f )
			{
				continue;
			}
			
			distance	= VecLength( correctedDir );
			
			// Find a better approximation
			if( distance < 0.5f )
			{
				if( VecDot( normal, direction ) > 0.0f )
				{
					normal	= -normal;
				}
				point	-= normal * 0.5f;
				
				correctedDir	= VecNormalize( point - playerPos );
			}			
			else if( distance > 1.0f )
			{
				if( VecDot( normal, direction ) > 0.0f )
				{
					normal	= -normal;
				}
				point	+= normal * 0.5f;
				
				correctedDir	= VecNormalize( point - playerPos );
			}
			else
			{
				correctedDir	/= distance;
			}
			
			// We found it
			correction.Set( true, direction, correctedDir );
			
			// Camera?
			cameraRequestByDoor	= doorMark.IsChangingCamera();
			
			
			// Debug purposes
			doorPoint	= point;
			doorMark.SetCheckState( EDMCT_Selected );
			break;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnCollision( direction : Vector, out correction : NavigationCorrection )
	{
		var correctedDir		: Vector;
		var min					: float;
		var max					: float;
		var desiredAngle		: float;
		var angleDist			: float;
		var closestCorrection	: float;
		
		
		if( !m_ExplorationO.m_CollisionManagerO.IsCollidingWithStatics() )
		{
			return;
		}
		
		// Get free range
		if( !m_ExplorationO.m_CollisionManagerO.GetAngleBlockedByStatics( min, max, 90.0f ) )
		{
			return;
		}
		
		// Get best angle correction
		desiredAngle			= VecHeading( direction );		
		if( AbsF( AngleDistance( desiredAngle, min ) ) < AbsF( AngleDistance( desiredAngle, max ) ) )
		{
			closestCorrection	= min;
		}
		else
		{
			closestCorrection	= max;
		}
		
		// Stop
		angleDist				= AbsF( AngleDistance( closestCorrection, desiredAngle ) );
		LogExplorationCorrection( "Collision angleDist: " + angleDist );
		
		if( angleDist > 45.0f )
		{
			correctedDir		= direction;
			collisionStopped	= true;
		}
		
		// Correct
		else if( angleDist < 75.0f )
		{
			correctedDir		= VecFromHeading( closestCorrection );
		}
		
		// Nothing
		else
		{
			return;
		}
		
		correction.Set( true, direction, correctedDir );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function LogExplorationCorrection( text : string )
	{
		LogChannel( 'ExplorationCorrection', text );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function IsTurnAdjusted() : bool
	{
		return turnAdjustmentTimeCur > 0.0f;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnPush( direction : Vector, out correction : NavigationCorrection )
	{
		var pushing			: bool;
		var slowing			: bool;
		var back			: bool;
		var pushCorrectDir	: Vector;
		
		
		if( !CanBePushed() )
		{
			return;
		}
		
		// Get the status of the push
		FindCurrentPushData( pushCorrectDir, slowing, pushing, back );
		
		// Update the current data		
		if( slowing )
		{
			pushSlowingTimeCur	= pushSlowingTimeCooldown;
		}			
		
		
		if( back )
		{
			pushDirection		= pushCorrectDir;
			pushCooldownCur		= pushCooldownTotal;
		}
		else if( pushing )
		{
			pushDirection		= pushCorrectDir;
			pushCooldownCur		= 0.0f;
		}	
		
		// Apply
		if( pushCooldownCur >= 0.0f )
		{
			correction.Set( true, direction, pushDirection );
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CanBePushed() : bool
	{
		if ( thePlayer.GetPlayerCombatStance() == PCS_AlertNear && 
			( thePlayer.playerMoveType == PMT_Idle || thePlayer.playerMoveType == PMT_Walk ) )
			return true;
		else
			return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function FindCurrentPushData( out pushDirection : Vector, out slowing : bool, out pushing : bool, out pushBack : bool )
	{
		var pudhDir				: Vector;
		var pushAngle			: float;
		var diffAngle			: float;
		var pushStrength		: float;
		var otherPushStrength	: float;
		var otherPushDir		: Vector;
		
		// Init
		slowing 	= false;
		pushing		= false;
		pushBack	= false;
		
		
		// Get colliison data
		m_ExplorationO.m_CollisionManagerO.GetPushData( pushStrength, pudhDir, otherPushStrength, otherPushDir );
		
		// No push
		if( pushStrength <= -1.0f )
		{
			return;
		}
		
		// No input: accept push
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			pushDirection	= pudhDir;
			pushing			= true;
			pushBack		= VecDot( pudhDir, m_ExplorationO.m_OwnerE.GetWorldForward() ) < -0.5f;
		}
		
		// Input: slow , modify, or leave alone
		else
		{
			//Get the angles
			pushAngle	= AngleNormalize180( VecHeading( -pudhDir ) );
			diffAngle	= AngleNormalize180( m_ExplorationO.m_InputO.GetHeadingDiffFromYawF( pushAngle ) ); 
			auxDiff		= diffAngle;
			
			// Opposite
			if( AbsF( diffAngle ) < maxPushAngleSlow )
			{
				pushing			= otherPushStrength > 0.0f;
				slowing			= !pushing;
				pushDirection	= pudhDir;
				
				//MAke sure you need this or not, also don't make him go right back, make him go a bit to the side so he changes stance
				pushBack		= true;
			}
			// To the side
			else if( AbsF( diffAngle ) < maxPushAngleTurn )
			{
				pushing	= true;
				if( diffAngle > 0.0f )
				{
					pushDirection	= VecFromHeading( m_ExplorationO.m_InputO.GetHeadingOnPlaneF() + maxPushAngleTurn );
				}
				else
				{
					pushDirection	= VecFromHeading( m_ExplorationO.m_InputO.GetHeadingOnPlaneF() - maxPushAngleTurn );
				}
			}
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnPush2( direction : Vector, out correction : NavigationCorrection )
	{
		var pudhDir				: Vector;
		var pushAngle			: float;
		var diffAngle			: float;
		var pushStrength		: float;
		var correctedDir		: Vector;
		var otherPushStrength	: float;
		var otherPushDir		: Vector;
		
		
		m_ExplorationO.m_CollisionManagerO.GetPushData( pushStrength, pudhDir, otherPushStrength, otherPushDir );
		
		// No push
		if( pushStrength <= -1.0f )
		{
			return;
		}
		
		// No input: accept push
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			direction		= m_ExplorationO.m_OwnerE.GetWorldForward();
			correctedDir	= pudhDir;
		}
		
		// Input: slow , modify, or leave alone
		else
		{
			//Get the angles
			pushAngle	= AngleNormalize180( VecHeading( -pudhDir ) );
			diffAngle	= AngleNormalize180( m_ExplorationO.m_InputO.GetHeadingDiffFromYawF( pushAngle ) ); 
			auxDiff		= diffAngle;
			// Too opposite
			if( AbsF( diffAngle ) < maxPushAngleSlow )
			{
				// push back
				if( otherPushStrength > 0.0f )
				{
					correctedDir	= pudhDir;
				}
				// or slow down
				else
				{
					pushSlowingTimeCur	= pushSlowingTimeCooldown;
				}
			}
			else
			{
				// No push: don't do a thing
				if( pushStrength <= 0.0f )
				{
					return;
				}
				
				// If a bit to the side, completely to the side
				if( AbsF( diffAngle ) < maxPushAngleTurn )
				{
					if( diffAngle > 0.0f )
					{
						correctedDir	= VecFromHeading( m_ExplorationO.m_InputO.GetHeadingOnPlaneF() + maxPushAngleTurn );
					}
					else
					{
						correctedDir	= VecFromHeading( m_ExplorationO.m_InputO.GetHeadingOnPlaneF() - maxPushAngleTurn );
					}
				}
				// Or leave the same direction
				else
				{
					return;
				}
			}
		}
		
		if( VecDot( correctedDir, pudhDir ) < 0.0f )
		{
			pushSlowingTimeCur		= pushSlowingTimeCooldown;
		}
		
		correction.Set( true, direction, correctedDir );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnPhysycs( direction : Vector, out correction : NavigationCorrection )
	{
		var corrected		: bool;
		var	correctedDir	: Vector;
		var corner			: bool;
		var portal			: bool;
		var speed			: float;
		var maxAngle		: float;
		var maxDist			: float;
		var shouldStop 		: bool;
		
		
		// Get the max angle depending on state
		if( checkingForRun )
		{
			maxAngle	= maxPhysicAngleRun;
			maxDist		= maxPhysicDistanceRun;
		}
		else
		{
			maxAngle	= maxPhysicAngleWalk;
			maxDist		= maxPhysicDistanceWalk;
		}
		
		// Consult the correction
		correctedDir	= direction;		
		
		speed			= maxDist;
		corrected		= m_ExplorationO.m_OwnerMAC.AdjustRequestedMovementDirectionPhysics( correctedDir, shouldStop, speed, maxAngle, maxPhysicSideDistance, corner, portal );
		correction.Set( corrected, direction, correctedDir );
		if( corrected && AbsF( correction.angle ) > maxAngle )
		{
			correction.corrected	= false;
		}
		
		if( correction.corrected && !IsCorrectionSideAcceptable( correction.direction ) )
		{
			correction.corrected	= false;
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnNavmesh( direction : Vector, out correction : NavigationCorrection )
	{
		var forwardDir		: Vector;
		var correctedDir	: Vector;
		var corrected		: bool;
		var modifiedAngle	: float;
		var maxDist			: float;
		var maxAngle		: float;
		
		// Get the max angle depending on state
		if( checkingForRun )
		{
			maxDist		= maxNavmeshDistanceRun;
			maxAngle	= maxNavmeshAngleRun;
		}
		else
		{
			maxDist		= maxNavmeshDistanceWalk;
			maxAngle	= maxNavmeshAngleWalk;
		}
		
		//correctedDir	= direction;
		correctedDir	=  m_ExplorationO.m_OwnerE.GetWorldForward();
		
		corrected		= m_ExplorationO.m_OwnerMAC.AdjustRequestedMovementDirectionNavMesh( correctedDir, maxDist, maxAngle, 15, 5, direction, true );
		correction.Set( corrected, direction, correctedDir );
		
		if( correction.corrected && !IsCorrectionSideAcceptable( correction.direction ) )
		{
			correction.corrected	= false;
		}
		
		// Modify turn
		//if( corrected )
		//{
			//correction.angle		*= 1.5f;
			//modifiedAngle			= VecHeading( correctedDir );
			//modifiedAngle			+= correction.angle;
			//correction.direction	= VecFromHeading( modifiedAngle );
		//}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function CorrectDirectionOnExploration( inputDir : Vector, out correction : NavigationCorrection )
	{
		var	directionToInteract	: Vector;
		var newExploration		: SExplorationQueryToken;
		
		
		// See if we can get a new exploration point in range
		if( GetClosestExploration( inputDir, newExploration ) )
		{ 
			if( GetDirectionToReachExploration( inputDir, newExploration, directionToInteract ) )
			{
				validExploration	= newExploration;
				
				correction.Set( true, inputDir, directionToInteract );				
				if( IsCorrectionSideAcceptable( correction.direction ) )
				{
					return;
				}
			}
		}
		
		// Try the old exploration point
		if( GetDirectionToReachExploration( inputDir, validExploration, directionToInteract) )
		{
			correction.Set( true, inputDir, directionToInteract );				
			if( IsCorrectionSideAcceptable( correction.direction ) )
			{
				return;
			}
		}
		
		// Could not find any
		correction.corrected	= false;
		return;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function GetClosestExploration( direction : Vector, out exploration : SExplorationQueryToken ) : bool
	{
		var queryContext		: SExplorationQueryContext;
		
		
		// Prepare query
		queryContext.inputDirectionInWorldSpace	= direction;
		queryContext.maxAngleToCheck			= 5.0f;	
		//queryContext.forJumping				= true;	
		queryContext.forJumping					= false;	
		queryContext.dontDoZAndDistChecks 		= true;		
		
		
		// Get the closest exploration
		if( m_ExplorationO.m_SharedDataO.m_UseClimbB )
		{
			queryContext.laddersOnly	= true;
		}
		exploration = theGame.QueryExplorationSync( thePlayer, queryContext );
		
		
		// Is it valid?
		return exploration.valid;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function GetDirectionToReachExploration( direction : Vector, exploration : SExplorationQueryToken, out directionToInteract : Vector ) : bool
	{
		var distToExploration	: float;
		var dot					: float;
		var dotLimit			: float;
		var distanceMax			: float;
		var angleMax			: float;
		
		
		// save the direction to exploration
		directionToInteract	= exploration.pointOnEdge - thePlayer.GetWorldPosition();
		
		// Check height
		if( directionToInteract.Z < -2.0f || directionToInteract.Z > 2.75f )
		{
			return false;
		}
		
		if( checkingForRun )
		{
			distanceMax	= maxExplorationDistanceRun;
			angleMax	= maxExplorationAngleRun;
		}
		else
		{
			distanceMax	= maxExplorationDistanceWalk;
			angleMax	= maxExplorationAngleWalk;
		}
		
		// We don't need the height anymore, let's remove it
		directionToInteract.Z	= 0.0f;
		distToExploration		= VecLength( directionToInteract );
		directionToInteract		= directionToInteract / distToExploration;
		
		// Prepare angular study
		dot		= VecDot( directionToInteract, direction );
		
		// If it is an exploration of only one side, correct only in that side
		/*if( IsExplorationOneSided( exploration ) )
		{
			if( VecDot( exploration.normal, directionToInteract ) < 0.0f )
			{
				return false;
			}
		}*/
		
		
		// Check the angle
		dotLimit	= CosF( Deg2Rad( angleMax ) );		
		if( dot < dotLimit ) //AbsF( AngleDistance( VecHeading( directionToInteract ), thePlayer.GetHeading() ) ) > angleMax
		{
			return false;
		}
		
		// We may need a modified location depending on our position 
		if( dot < CosF( Deg2Rad( 75.0f ) ) ) //exploration.type == && 
		{
			directionToInteract		= exploration.pointOnEdge + exploration.normal - thePlayer.GetWorldPosition();
			directionToInteract.Z	= 0.0f; // just in case
			
			distToExploration		= VecLength( directionToInteract );
			//directionToInteract		= directionToInteract / distToExploration;
			
			//dot						= VecDot( directionToInteract, direction );
		}
		
		// Can we physically reach it
		if( distToExploration > distanceMax )
		{
			return false;
		}
		
		// finish by normalizing the new direction
		directionToInteract		/= distToExploration;
		
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function IsCorrectionSideAcceptable( correctionDirection : Vector ) : bool
	{
		var angle	: float;
		
		
		if( !limitCorrectionTurningSide )
		{
			return true;
		}
		
		angle	= VecHeading( correctionDirection );
		angle	= m_ExplorationO.m_InputO.GetHeadingDiffFromYawF( angle );
		
		if( AbsF( inputDiference ) > inputDifToSide && angle * inputDiference > 0.0f )
		{
			return false;
		}
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function GetIsCollisionCorrected() : bool
	{
		return collisionStopped;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	// We want output like this:
	// ...............ECT_Physics..................................
	// ECT_None....................................................
	//------------------------------------------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		var text, typeText		: string;
		var i, cases, accepted	: int;
		var j, length			: int;
		
		cases 		= ( int ) EMCT_Size;
		accepted	= ( int ) correctionAccepted.type;
		
		text	= "Correction: ";
		for( i = 0; i < cases; i += 1 )
		{
			if( i == accepted )
			{
				// Get the type name
				typeText	= ( string ) correctionAccepted.type;
				// Fill the spaces left with "." so it is easy to read the changes
				length		= StrLen( typeText );
				for( j = 0; j < 15 - length; j += 1 )
				{
					typeText	+=  ".";
				}
				text	+= typeText;
			}
			else
			{
				text	+= "...............";
			}
		}
		if( pushSlowingTimeCur > 0.0f )
		{
			text	+= "Stopping ";
		}
		if( collisionStopped )
		{
			text	+= "Stopping Collision";
		}
		
		return text + auxDiff;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		var green	: Color;
		var auxText	: string;
		
		
		if( !debugPush )
		{
			return true;
		}
		
		green	= Color( 0, 255, 0 );
		correctionOnCollision.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnCollision.type ) );
		correctionOnPush.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnCollision.type ) );
		correctionOnPhysics.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnPhysics.type ) );
		correctionOnNavMesh.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnNavMesh.type ) );
		correctionOnExploration.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnExploration.type ) );
		correctionOnDoors.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnDoors.type ) );
		correctionOnFalling.OnVisualDebug( frame, flag, ( correctionAccepted.type == correctionOnFalling.type ) );
		
		/*if( correctionAccepted.type == correctionOnDoors.type )
		{
			frame.DrawSphere( doorPoint, 0.2f, Color( 0, 255, 0 ) );
		}*/
		frame.DrawSphere( doorPoint, 0.2f, green );
		frame.DrawText( "Door Correction", doorPoint, green );
		
		// Push
		if( false ) // Disabled for now
		{
			auxText	= "Angle " + auxDiff;
			if( pushSlowingTimeCur > 0.0f )
			{
				auxText	+= "-> Slowing";
			}
			frame.DrawText( auxText, m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldUp() * 2.0f, green );
		}
		
		return true;
	}
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class NavigationCorrection
{
	var	corrected	: bool;
	var	direction	: Vector;
	var	angle		: float;
	var type		: EMovementCorrectionType;
	var	color		: Color;
	
	
	//------------------------------------------------------------------------------------------------------------------
	function Set( isCorrected : bool, oldDirection : Vector, newDirection : Vector )
	{
		corrected	= isCorrected;
		direction	= newDirection;
		angle		= AngleDistance( VecHeading( oldDirection ), VecHeading( newDirection ) );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
		var origin, end : Vector;
		
		if( !corrected )
		{
			return true;
		}
		
		origin	= thePlayer.GetWorldPosition();
		end		= thePlayer.GetWorldPosition() + direction * 2.0f;
		
		frame.DrawLine( origin, end, color );
		if( selected )
		{
			frame.DrawSphere( end, 0.2f, color );
		}
		
		return true;
	}
};

