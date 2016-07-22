// CExplorationStateClimb
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 08/08/2014 )	 
//------------------------------------------------------------------------------------------------------------------

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbRequirementType
{
	ECRT_Landed			= 0,
	ECRT_Jumping		= 1,
	ECRT_AirColliding	= 2,
	ECRT_Swimming		= 3,
	ECRT_Running		= 4,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbRequirementVault
{
	ECRV_NoVault	= 0,
	ECRV_Vault		= 1,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbRequirementPlatform
{
	ECRV_NoPlatform	= 0,
	ECRV_Platform	= 1,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbHeightType
{
	ECHT_Step		= 0,
	ECHT_VerySmall	= 1,
	ECHT_Small		= 2,
	ECHT_Medium		= 3,
	ECHT_High		= 4,
	ECHT_VeryHigh	= 5,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbDistanceType
{
	ECDT_Normal	= 0,
	ECDT_Close	= 1,
	ECDT_Far	= 2,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EClimbEndReady
{
	ECR_NotReady	= 0,
	ECR_Walk		= 1,
	ECR_Run			= 2,
	ECR_Fall		= 3,
	ECR_Idle		= 4,
}

//>-----------------------------------------------------------------------------------------------------------------
enum EOutsideCapsuleState
{
	EOCS_Inactive		= 0,
	EOCS_Starting		= 1,
	EOCS_PerfectFollow	= 2,
	EOCS_Recover		= 3,
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
struct CClimbType
{		
	// type
	editable			var requiredState			: EClimbRequirementType;
	editable			var requiredVault			: EClimbRequirementVault;
	editable			var requiredPlatform		: EClimbRequirementPlatform;
	editable			var	type					: EClimbHeightType;				default	type				= ECHT_Medium;
	
	// Heights
	editable			var	heightUseDefaults		: bool;							default	heightUseDefaults	= true;
	editable			var	heightMax				: float;						default	heightMax			= 1.4f;
	editable			var	heightMin				: float;						default	heightMin			= 0.2f;
	editable			var heightExact				: float;						default	heightExact			= 1.0f; // we will use to correct all heights in range to exact height 
	
	// Forward Distance
	editable			var forwardDistExact		: float;						default	forwardDistExact	= 0.4f;
	
	// Camera
	editable 			var	playCameraAnimation		: bool;							default	playCameraAnimation	= false;
	editable 			var	cameraAnimation			: name;
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateClimb extends CExplorationStateAbstract
{	
	public 						var	m_ClimbOracleO			: CExplorationClimbOracle;
	
	private editable			var	enabled					: bool;					default	enabled					= true;
	
	
	// Climb types
	private editable inlined	var	climbTypes				: array< CClimbType >;
	private						var	climbCur				: CClimbType;
	private	editable inlined	var	heightMaxToRun			: float;
	private	editable inlined	var	platformHeightMinAir	: float;
	private	editable inlined	var	platformHeightMin		: float;
	
	// Cur climb data
	private						var	climbPoint				: Vector;
	private						var	wallNormal				: Vector;
	private						var	heightTarget			: float;
	private						var	vaultingFound			: EClimbRequirementVault;
	private						var platformFound			: EClimbRequirementPlatform;
	private						var curPlayerStateType		: EClimbRequirementType;
	private						var	vaultEndsFalling		: bool;
	
	// State
	private						var	ended					: bool;
	private						var	canWalk					: bool;
	private						var	canRun					: bool;
	private						var	canFall					: bool;		
	editable					var animDurationLimit		: float;				default	animDurationLimit		= 5.0f;
	editable					var slideDistMaxOnRun		: float;				default	slideDistMaxOnRun		= 1.5f;
	
	// Input
	private	editable			var	autoClimb				: bool;					default	autoClimb				= false;
	private	editable			var	autoClimbOnAir			: bool;					default	autoClimbOnAir			= false;
	private editable			var	inputAngleToEnter		: float;				default	inputAngleToEnter		= 180.0f;
	private editable			var	inputAngleToRun			: float;				default	inputAngleToRun			= 45.0f;
	private						var	inputAttemptsTop		: bool;
	private						var	inputDirection			: Vector;
	private editable			var	inputAirHold			: bool;					default	inputAirHold			= true;
	private editable			var	inputAirTimeGap			: bool;					default	inputAirTimeGap			= false;
	private editable			var	inputTimeGapCheck		: float;				default	inputTimeGapCheck		= 0.3f;
	
	// Adjustment	
	private						var	characterRadius			: float;				default	characterRadius			= 0.4f;
	private						var	adjustInitiallRotat 	: float;
	private						var	adjustRotation			: float;
	private						var	adjustTranslation		: Vector;
	private						var adjustInitialRotDone	: bool;
	private						var adjustRotDone			: bool;
	private						var adjustTransDone			: bool;
	
	private						var adjustSpeedMax			: float;				default	adjustSpeedMax			= 12.0f;
	private						var adjustSpeedRequire		: bool;
	private						var adjustSpeedEndTime		: float;
	
	
	private						var adjust2Dduration		: float;
	private						var adjust2Speed			: float;
	private						var adjust2Translation		: Vector;
	
	private						var heightToAdd				: float;
	
	
	// Translation outside capsule
	private						var	pelvisTransMax			: float;				default	pelvisTransMax			= 0.4f;
	private						var	pelvisTransAllow		: bool;					default	pelvisTransAllow		= true;
	private						var	pelvisTransState		: EOutsideCapsuleState;
	private						var	pelvisTranslationN		: name;					default	pelvisTranslationN		= 'ClimbMoveForward';
	private						var	pelvisTransCur			: float;
	private						var	pelvisTransTarget		: float;
	private						var	pelvisTransSpeed		: float;				default	pelvisTransSpeed		= 3.0f;
	private						var	pelvisTransSpeedOut		: float;				default	pelvisTransSpeedOut		= 10.0f;
	
	
	// Anim Receive
	private editable			var	behAnimAdjustInitRot	: name;					default	behAnimAdjustInitRot	= 'ClimbInitialRotate';
	private editable			var	behAnimAdjustRot		: name;					default	behAnimAdjustRot		= 'ClimbStartRotate';
	private editable			var	behAnimAdjustTrans		: name;					default	behAnimAdjustTrans		= 'ClimbStartTranslate';
	private editable			var	behAnimEnded			: name;					default	behAnimEnded			= 'ClimbCanEnd';
	private editable			var	behAnimCanWalk			: name;					default	behAnimCanWalk			= 'ClimbCanWalk';
	private editable			var	behAnimCanRun			: name;					default	behAnimCanRun			= 'ClimbCanRun';
	private editable			var	behAnimCanFall			: name;					default	behAnimCanFall			= 'ClimbCanFall';
	
	private editable			var	behEnableIK				: name;					default	behEnableIK				= 'ClimbEnableIK';
	private editable			var	behDisablePelvisTrans	: name;					default	behDisablePelvisTrans	= 'ClimbDisablePelvisTrans';
	private editable			var	behEnableHandsIK		: name;					default	behEnableHandsIK		= 'ClimbEnableHandsIK';
	private editable			var	behEnableHandLIK		: name;					default	behEnableHandLIK		= 'ClimbEnableHandLIK';
	private editable			var	behEnableHandRIK		: name;					default	behEnableHandRIK		= 'ClimbEnableHandRIK';
	private editable			var	behDisableHandsIK		: name;					default	behDisableHandsIK		= 'ClimbDisableHandsIK';
	private editable			var	behDisableHandLIK		: name;					default	behDisableHandLIK		= 'ClimbDisableHandLIK';
	private editable			var	behDisableHandRIK		: name;					default	behDisableHandRIK		= 'ClimbDisableHandRIK';
	
	// Anim send
	private editable			var	behHeightTypeEnum		: name;					default	behHeightTypeEnum		= 'ClimbHeightType';
	private editable			var	behVaultTypeEnum		: name;					default	behVaultTypeEnum		= 'ClimbVaultType';
	private editable			var	behPlatformTypeEnum		: name;					default	behPlatformTypeEnum		= 'ClimbPlatformType';
	private editable			var	behStateTypeEnum		: name;					default	behStateTypeEnum		= 'ClimbStateType';
	private editable			var	behGoToRun				: name;					default	behGoToRun				= 'ClimbToRun';
	private editable			var	behGoToWalk				: name;					default	behGoToWalk				= 'ClimbToWalk';
	private editable			var	behToRun				: name;					default	behToRun				= 'ClimbEndsRunning';
	private editable			var	behVarEnd				: name;					default	behVarEnd				= 'ClimbCanEndMode';
	private editable			var	behAnimSpeed			: name;					default	behAnimSpeed			= 'ClimbAnimSpeed';
	
	
	// IK	
	private	editable			var continousHandIK			: bool;					default	continousHandIK			= true;
	private editable			var	handIKMinDistToEnable	: float;				default	handIKMinDistToEnable	= 0.05f;
	private editable			var	handIKMaxDist			: float;				default	handIKMaxDist			= 0.3f;
	private editable			var	handIKForwardOffset		: float;				default	handIKForwardOffset		= 0.2f;
	private editable			var	handIKHalfMaxHeight		: float;				default	handIKHalfMaxHeight		= 1.0f;
	private editable			var	handIKBlendSpeedIn		: float;				default	handIKBlendSpeedIn		= 3.5f;
	private editable			var	handIKBlendSpeedOut		: float;				default	handIKBlendSpeedOut		= 1.5f;
	private editable			var	handThickness			: float;				default	handThickness			= 0.02;//0,035f;
	protected 					var	boneRightHand			: name;					default	boneRightHand			= 'r_hand';
	protected 					var	boneLeftHand			: name;					default	boneLeftHand			= 'l_hand';
	protected 					var	boneIndexRightHand		: int;
	protected 					var	boneIndexLeftHand		: int;
	
	protected 					var rightHandOffset			: float;
	protected 					var leftHandOffset			: float;
	protected 					var rightHandOffsetCur		: float;
	protected 					var leftHandOffsetCur		: float;
	
	protected 					var handIKEnabled			: bool;
	protected 					var handIKEnabledLeft		: bool;
	protected 					var handIKEnabledRight		: bool;
	protected 					var handIKqueuedL			: bool;
	protected 					var handIKqueuedR			: bool;
	
	private						var	handIKLRayOrigin		: Vector;
	private						var	handIKLRayEnd			: Vector;
	private						var	handIKLRayCollision		: Vector;
	private						var	handIKRRayOrigin		: Vector;
	private						var	handIKRRayEnd			: Vector;
	private						var	handIKRRayCollision		: Vector;
	
	private						var	collisionObstaclesNames	: array<name>;
	
	// Cmaera
	protected editable inlined	var	cameraSetVault			: CCameraParametersSet;		
	protected editable inlined	var	cameraSetJump			: CCameraParametersSet;		
	private editable			var	updateCameraManual		: bool;					default	updateCameraManual		= false;
	private editable			var	updateCameraAnim		: bool;					default	updateCameraAnim		= false;
	private						var	camOriginalPosition		: Vector;
	private						var	camOriginalRotation		: EulerAngles;
	private						var	camCurRotation			: EulerAngles;
	private						var	camOriginalOffset		: Vector;
	private						var	camStart				: bool;
	private						var	camFollowBoneID			: int;
	private	editable			var	camFollowBoneName		: name;					default	camFollowBoneName		= 'torso';
	
	
	//Aux
	private						var	vectorUp				: Vector;	
	
	// Debug
	private	editable			var	forceAirCollision		: bool;					default	forceAirCollision		= false;
	private	editable			var	forceJumpGrab			: bool;					default	forceJumpGrab			= false;
	private	editable			var	noAdjustor				: bool;					default	noAdjustor				= false;
	private	editable			var	noPelvisCorection		: bool;					default	noPelvisCorection		= false;
	
	//items
	private	saved				var restoreUsableItemLAtEnd : bool;
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		var	heightTotalMin			: float;
		var	heightTotalMax			: float;
		
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Climb';
		}
		
		m_StateTypeE			= EST_OnAir;
		m_InputContextE			= EGCI_JumpClimb;
		m_UpdatesWhileInactiveB	= true;
		m_HolsterIsFastB		= true;
		
		
		LogExplorationClimb( "	Initialized Log channel: ExplorationStateClimb" );
		
		
		SetCanSave( false );
		
		
		// Init climbs
		if( climbTypes.Size() <= 0 )
		{
			LogExplorationError( "No climb data was found in state CExplorationStateClimb" );
			return;
		}
		InitClimbs();
		
		// Get min and max climb heights we have
		ComputeMinMaxHeight( heightTotalMin, heightTotalMax );
		
		// Oracle
		if( !m_ClimbOracleO )
		{
			m_ClimbOracleO	= new CExplorationClimbOracle in this;
		}		
		m_ClimbOracleO.Initialize( m_ExplorationO, heightTotalMin, heightTotalMax, MinF( platformHeightMin, platformHeightMinAir ), characterRadius );
		
		
		// Get and store bone indexes
		boneIndexRightHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneRightHand );
		boneIndexLeftHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneLeftHand );
		camFollowBoneID		= m_ExplorationO.m_OwnerE.GetBoneIndex( camFollowBoneName );
		
		
		// Collisions
		collisionObstaclesNames.PushBack( 'Terrain' );
		collisionObstaclesNames.PushBack( 'Static' );
		collisionObstaclesNames.PushBack( 'Platforms' );
		collisionObstaclesNames.PushBack( 'Fence' );
		collisionObstaclesNames.PushBack( 'Boat' );
		collisionObstaclesNames.PushBack( 'BoatDocking' );
		//collisionObstaclesNames.PushBack( 'Character' );
		collisionObstaclesNames.PushBack( 'Foliage' );
		collisionObstaclesNames.PushBack( 'Dynamic' );
		collisionObstaclesNames.PushBack( 'Destructible' );
		collisionObstaclesNames.PushBack( 'RigidBody' );
		
		
		// Init aux
		vectorUp	= Vector( 0.0f,0.0f, 1.0f );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
	}
	
	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{		
		// Get other input related stuff
		ComputeInput();
		
		// Get the player state
		curPlayerStateType								= FindPlayerState();
		m_ExplorationO.m_SharedDataO.m_ClimbStateTypeE	= curPlayerStateType;
		
		//DebugEnterToClimb();
		
		// Make the oracle find the best climb, if any
		if( !OracleWantsToEnter() )
		{
			return false;
		}
		
		// Do we have a raw situation valid
		if( !PreRefineIsValid() )
		{
			return false;
		}
		
		// Refine player state based on data
		RefinePlayerState();
		
		// Do we have a fitting climb?
		if( !FindApropriateClimb() )
		{
			return false;
		}	
		
		// Refine again
		PostRefineState();	
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function DebugEnterToClimb()
	{
		heightTarget		= 2.6f;
		vaultingFound		= ECRV_NoVault;
		vaultEndsFalling	= false;
		platformFound		= ECRV_NoPlatform;
		climbPoint			= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldForward() * 1.0f + m_ExplorationO.m_OwnerE.GetWorldUp() * 2.6f;
		wallNormal			= -m_ExplorationO.m_OwnerE.GetWorldForward();
	}

	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		// Input is required		
		if( !InputWantsToEnter() )
		{
			return false;
		}
		
		if( !thePlayer.IsActionAllowed( EIAB_Climb ) || !thePlayer.IsActionAllowed( EIAB_Movement ) || !thePlayer.IsActionAllowed( EIAB_Jump ) )
		{
			return false;
		}
		
		if( thePlayer.IsInCombat() )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{		
		// Leave swim state
		if( prevStateName == 'Swim' )
		{
			thePlayer.GotoState('Exploration');
		}
		
		// Update character radius (to make sure it works )
		//characterRadius		= m_ExplorationO.m_OwnerMAC.GetCapsuleRadius();
		//LogExplorationClimb( "characterRadius: " + characterRadius );
		
		// Initial displacement 
		SetInitialMovementAdjustor();
		
		// Disable snapping to ground
		m_ExplorationO.m_MoverO.SetManualMovement( true );
		
		//kill sheath sword timer
		thePlayer.RemoveTimer( 'DelayedSheathSword' );
		
		thePlayer.SetBehaviorVariable( 'inJumpState', 1.f );
		
		// Crossbow instant disappear
		thePlayer.OnRangedForceHolster( true, true );
		
		// Translation forward
		pelvisTransCur		= 0.0f;
		pelvisTransState	= EOCS_Inactive;
		
		// Anim
		SetBehaviorData();
		
		// Camera
		camStart	= true;
		//camOriginalPosition = m_ExplorationO.m_OwnerE.GetWorldPosition() - 0.5f * m_ExplorationO.m_OwnerE.GetWorldForward() + 2.0f * m_ExplorationO.m_OwnerE.GetWorldUp();
		SetProperCameraAnim( true, 1.0f );
		
		// Debug
		if( m_ExplorationO.m_IsDebugModeB )
		{			
			DebugLogSuccesfullClimb();
		}
		
		// Prepare		
		canFall					= false;
		ended					= false;
		canWalk					= false;
		adjustInitialRotDone	= false;
		canRun					= false;
		
		adjustRotDone			= false;	
		adjustTransDone			= false;	
		
		// IK		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
		
		leftHandOffset			= 0.0f;
		rightHandOffset			= 0.0f;
		rightHandOffsetCur		= 0.0f;
		leftHandOffsetCur		= 0.0f;
		handIKEnabled			= false;
		handIKEnabledLeft 		= false;
		handIKEnabledRight		= false;
		handIKqueuedL			= false;
		handIKqueuedR			= false;
		
		adjust2Dduration		= 0.0f;	
		
		// Items in hands
		if ( thePlayer.IsHoldingItemInLHand() )
		{			
			thePlayer.OnUseSelectedItem ( true );
			restoreUsableItemLAtEnd	= true;		
		}
		
		//Abort all signs
		thePlayer.AbortSign();
	}
	
	//---------------------------------------------------------------------------------
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_DrawWeapon );
	}
	
	//---------------------------------------------------------------------------------
	public function GetIfCameraIsKept() : bool
	{
		return false;
		/*
		if( curPlayerStateType == ECRT_Jumping || curPlayerStateType == ECRT_AirColliding )
		{
			return false;
		}
		*/
		//return vaultingFound != ECRV_Vault;
	}
	
	//---------------------------------------------------------------------------------
	public function GetCameraSet( out cameraSet : CCameraParametersSet) : bool
	{
		if( ( curPlayerStateType == ECRT_Jumping || curPlayerStateType == ECRT_AirColliding ) && cameraSetJump )
		{
			//cameraSet	= m_ExplorationO.m_DefaultCameraSetS;
			cameraSet	= cameraSetJump;
			return true;
		}
		else if( vaultingFound == ECRV_Vault && cameraSetVault )
		{
			cameraSet	= cameraSetVault;
			return true;
		}
		return super.GetCameraSet( cameraSet );
	}
	
	//---------------------------------------------------------------------------------
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanFall, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimEnded, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanWalk, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanRun, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustInitRot, 	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustRot, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustTrans, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisablePelvisTrans,	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableIK, 				'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandsIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandLIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandRIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandsIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandLIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandRIK, 		'OnAnimEvent_SubstateManager' );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{		
		if( canFall )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Fall );
			if( vaultingFound == ECRV_Vault )
			{
				return 'Jump';
			}
			else
			{
				if( m_ExplorationO.IsOnGround() )
				{
					return 'Idle';
				}
				else
				{
					return 'StartFalling';
				}
			}
		}
		
		// Blend to walk or runn
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
		{			
			if( AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputAngleToRun )
			{
				if( canRun && thePlayer.GetIsRunning() ) //m_ExplorationO.m_InputO.IsSprintPressed() )
				{
					if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						m_ExplorationO.SendAnimEvent( behGoToRun );
						m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Run );
						return 'Idle';
					}
				}
				else if( canWalk )
				{
					if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Walk );
						m_ExplorationO.SendAnimEvent( behGoToWalk );
						return 'Idle';
					}
				}
			}
			else if( ( canRun || canWalk ) && m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Idle );
				return 'Idle';				
			}
		}
		
		// End
		if( ended || m_ExplorationO.GetStateTimeF() > animDurationLimit ) // got the event to start blending out or the time has ended
		{
			if( vaultEndsFalling || !m_ExplorationO.m_CollisionManagerO.CheckLandBelow( 0.2f, Vector( 0.0f,0.0f, 0.0f ), true ) )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Fall );
				if( vaultingFound == ECRV_Vault )
				{
					return 'Jump';
				}
				else
				{
					return 'StartFalling';
				}
			}
			else if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Idle );
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var posCur	: Vector;
		
		
		// Recover time coef
		if( adjustSpeedRequire )
		{
			if( m_ExplorationO.GetStateTimeF() >= adjustSpeedEndTime )
			{				
				ApplyAnimationSpeed( 1.0f );
				adjustSpeedRequire	= false;
			}
		}
		
		UpdateAdjusting2D( _Dt );
		
		UpdateHandsIK( _Dt );
		
		UpdateTranslationOutsideCapsule( _Dt );
		
		UpdateRunOrWalk();
		
		// Disable vertical slidingness
		CheckVerticalSlideEnd();
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		var movAdj 			: CMovementAdjustor;
		
		// Recover snapping and cancel adjustments
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.CancelByName( 'ClimbAdjusInitialRotation' );
		movAdj.CancelByName( 'ClimbAdjustments' );
		movAdj.CancelByName( 'ClimbAdjusTranslation' );
		movAdj.CancelByName( 'ClimbAdjusRotation' );
		movAdj.CancelByName( 'ClimbFakeGravity' );
		//movAdj.CancelByName( 'ClimbAdjusPelvisCorrection' );
		
		CorrectPelvisStartEnd();
		
		
		// Anim speed coef
		if( adjustSpeedRequire )
		{				
			ApplyAnimationSpeed( 1.0f );
		}
		
		// Camera
		if( m_ExplorationO.GetStateTimeF() < 0.25f )
		{
			CancelCameraAnimation();
		}
		
		// Ik and physics
		if( vaultingFound == ECRV_NoVault ) // !vaultEndsFalling )
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
		}
		
		StopHandIK( true, true );
		
		
		m_ExplorationO.m_MoverO.SetManualMovement( false );
		
		// Items
		if ( restoreUsableItemLAtEnd )
		{
			restoreUsableItemLAtEnd = false;
			thePlayer.OnUseSelectedItem ();
		}
		
		thePlayer.SetBehaviorVariable( 'inJumpState', 0.f );
		
		thePlayer.ReapplyCriticalBuff();
		//thePlayer.SetBehaviorVariable( 'holsterFastForced', 0.f, true );
	}
	
	//---------------------------------------------------------------------------------
	function StateUpdateInactive( _Dt : float )
	{
		UpdateAndSetHandsIKBlend( _Dt );
	}
	
	//---------------------------------------------------------------------------------
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanFall );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimEnded );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanWalk );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanRun );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustInitRot );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustRot );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustTrans );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisablePelvisTrans );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandsIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandLIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandRIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandsIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandLIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandRIK );
	}
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{	
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) : bool
	{		
		return false;
	}
	
	//---------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var duration		: float	= -1.0f;
		var unwantedEvent	: bool	= false;
		var text			: string;
		
		
		// Fall
		if( animEventName == behAnimCanFall )
		{
			canFall = true;
			//m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Fall );
		}
		
		// End
		else if ( animEventName == behAnimEnded )
		{
			ended	= true;
			canWalk	= true;
			canRun	= true;
		}
		
		// Walk
		else if( !canWalk && animEventName == behAnimCanWalk )
		{
			canWalk	= true;
		}
		
		// Run
		else if( !canRun && animEventName == behAnimCanRun )
		{
			canRun	= true;
		} 
		
		else if( animEventName == behAnimAdjustInitRot  && !adjustInitialRotDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorInitialRotation( duration );
		}
		
		// Rotation
		else if( animEventName == behAnimAdjustRot && !adjustRotDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorRotation( duration );
		}
		
		// Translation
		else if( animEventName == behAnimAdjustTrans && !adjustTransDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorTranslation( duration );
			
			
			// Also, pivot translation
			if( pelvisTransAllow && pelvisTransState == EOCS_Inactive )
			{
				pelvisTransState	= EOCS_Starting;
			}
		}
		
		// Pelvis
		else if( animEventName == behDisablePelvisTrans )
		{
			// Also, translation
			CorrectPelvisStartEnd();
		}
		
		// FeetIk
		else if( animEventName == behEnableIK )
		{
			if( vaultingFound == ECRV_NoVault )
			{
				m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
				ApplyFakeGravity();
			}
		}
		
		// HandsIK
		else if( animEventName == behEnableHandsIK )
		{
			handIKqueuedL	= true;
			handIKqueuedR	= true;
		}
		else if( animEventName == behEnableHandLIK )
		{
			handIKqueuedL	= true;
		}
		else if( animEventName == behEnableHandRIK )
		{
			handIKqueuedR	= true;
		}
		else if( animEventName == behDisableHandsIK )
		{
			StopHandIK( true, true );
		}
		else if( animEventName == behDisableHandLIK )
		{
			StopHandIK( true, false );
		}
		else if( animEventName == behDisableHandRIK )
		{
			StopHandIK( false, true );
		}
		
		// Nothing to do
		else
		{
			unwantedEvent = true;
		}
		
		// Log the event
		if( !unwantedEvent )
		{
			text	= "GotEvent: " + animEventName;
			if( duration >= 0.0f )
			{
				text	+= " duration " + duration;
			}
			LogExplorationClimb( text );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function InitClimbs()
	{
		var i	: int;
		
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{
			InitializeClimb( i );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function InitializeClimb( i : int )
	{
		if( climbTypes[ i ].heightUseDefaults )
		{
			switch( climbTypes[ i ].type )
			{
				case ECHT_Step:
					climbTypes[ i ].heightMin	= 0.3f;
					climbTypes[ i ].heightMax	= 0.75f;
					break;
				case ECHT_VerySmall:
					climbTypes[ i ].heightMin	= 0.75f;
					climbTypes[ i ].heightMax	= 1.5f;
					break;
				case ECHT_Small:
					climbTypes[ i ].heightMin	= 1.5f;
					climbTypes[ i ].heightMax	= 2.0f;
					break;
				case ECHT_Medium:
					climbTypes[ i ].heightMin	= 2.0f;
					climbTypes[ i ].heightMax	= 2.5f;
					break;
				case ECHT_High:
					climbTypes[ i ].heightMin	= 2.5f;
					climbTypes[ i ].heightMax	= 3.0f;
					break;
				case ECHT_VeryHigh:
					climbTypes[ i ].heightMin	= 3.0f;
					climbTypes[ i ].heightMax	= 4.0f;
					break;
			}
			
			// The exact height is the minimum except for the very small
			if( climbTypes[ i ].type == ECHT_VerySmall )
			{
				climbTypes[ i ].heightExact	= 1.0f;
			}
			else
			{
				climbTypes[ i ].heightExact	= climbTypes[ i ].heightMin;
			}
		}
		else
		{
			climbTypes[ i ].heightUseDefaults	= climbTypes[ i ].heightUseDefaults;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function ComputeMinMaxHeight( out heightTotalMin : float, out heightTotalMax : float )
	{
		var i	: int;
		
		
		// Initialize
		heightTotalMin			= climbTypes[ 0 ].heightMin;
		heightTotalMax			= climbTypes[ 0 ].heightMax;
		platformHeightMin		= 1000.0f;
		platformHeightMinAir	= 1000.0f;
		heightMaxToRun			= 0.0f;
		
		// Find them
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{
			if( climbTypes[ i ].requiredState == ECRT_Running && heightMaxToRun < climbTypes[ i ].heightMax )
			{
				heightMaxToRun	= climbTypes[ i ].heightMax;
			}
			if( climbTypes[ i ].requiredPlatform == ECRV_Platform )
			{
				if( climbTypes[ i ].requiredState == ECRT_Jumping || climbTypes[ i ].requiredState == ECRT_AirColliding )
				{
					if( climbTypes[ i ].heightMin < platformHeightMinAir )
					{
						platformHeightMinAir	= climbTypes[ i ].heightMin;
					}
				}
				else  if( climbTypes[ i ].heightMin < platformHeightMin )
				{
					platformHeightMin	= climbTypes[ i ].heightMin;
				}
			}
			if( heightTotalMax < climbTypes[ i ].heightMax )
			{
				heightTotalMax	= climbTypes[ i ].heightMax;
			}
			if( heightTotalMin	> climbTypes[ i ].heightMin )
			{
				heightTotalMin	= climbTypes[ i ].heightMin;
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function FindPlayerState() : EClimbRequirementType
	{
		// Air
		if( m_ExplorationO.GetStateTypeCur() ==  EST_OnAir )
		{
			// Test force
			if( forceAirCollision )
			{
				return ECRT_AirColliding;
			}
			else if( forceJumpGrab )
			{
				return ECRT_Jumping;
			}
			
			if( m_ExplorationO.GetStateCur() == 'AirCollision' )
			{
				return ECRT_AirColliding;
			}
			return ECRT_Jumping;
		}
		
		// Swim
		else if( m_ExplorationO.GetStateTypeCur() ==  EST_Swim )
		{
			return ECRT_Swimming;
		}
		
		// Run
		//else if( thePlayer.GetIsRunning() )
		else if( thePlayer.GetIsRunning() && m_ExplorationO.m_InputO.IsModuleConsiderable() ) //&& m_ExplorationO.m_InputO.IsSprintPressed() 
		{
			return ECRT_Running;
		}
		
		// Idle or walk
		return ECRT_Landed;
	}
	
	//---------------------------------------------------------------------------------
	private function InputWantsToEnter() : bool
	{
		// Manual climb		
		if( m_ExplorationO.m_InputO.IsExplorationJustPressed() )
		{
			return true;
		}
		else if( m_ExplorationO.GetStateTypeCur() == EST_OnAir && m_ExplorationO.m_InputO.IsExplorationPressed() )
		{
			return true;
		}
		else
		{
			return false;
		}
		
		/*
		// Auto climb
		if( autoClimb && m_ExplorationO.m_InputO.IsModuleConsiderable() && AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) <= inputAngleToEnter && thePlayer.GetIsRunning() ) // && m_ExplorationO.m_InputO.IsSprintPressed()
		{
			return true;
		}
		
		// On air climb
		if( m_ExplorationO.GetStateTypeCur() == EST_OnAir )
		{
			if( autoClimbOnAir && m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				return true;
			}
			if( inputAirHold && m_ExplorationO.m_InputO.IsExplorationPressed() )
			{
				return true;
			}
			if( inputAirTimeGap && m_ExplorationO.m_InputO.GetExplorationLastJustPressedTime( ) < inputTimeGapCheck )
			{
				return true;
			}
		}
		
		return false;
		
		*/
	}
	
	//---------------------------------------------------------------------------------
	private function ComputeInput()
	{
		inputAttemptsTop	= !thePlayer.GetIsRunning(); //m_ExplorationO.m_InputO.IsSprintPressed();
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputDirection	= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		}
		else
		{		
			inputDirection	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
	}
	
	//---------------------------------------------------------------------------------
	private function OracleWantsToEnter() : bool
	{
		var originPosition	: Vector;
		var logFails		: bool;
		var	distanceType	: EClimbDistanceType;
		var	requireInputDir : bool;
		
		
		logFails		= m_ExplorationO.m_InputO.IsExplorationJustPressed();
		originPosition	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		distanceType	= GetDistanceType();
		
		// Do we require to go in the direction?
		requireInputDir		= m_ExplorationO.m_InputO.IsModuleConsiderable();
		
		// Compute
		m_ClimbOracleO.ComputeAll( inputAttemptsTop, originPosition, inputDirection, distanceType, requireInputDir, logFails );
		
		// No climb found
		if( !m_ClimbOracleO.CanWeClimb() )
		{
			return false;
		}
		
		// Get target climb data
		m_ClimbOracleO.GetClimbData( heightTarget, vaultingFound, vaultEndsFalling, platformFound, climbPoint, wallNormal );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function GetDistanceType() : EClimbDistanceType
	{
		// Which distance are we checking for
		if( curPlayerStateType == ECRT_Jumping )
		{		
			return ECDT_Close;
		}
		else if( curPlayerStateType == ECRT_Running )
		{
			return ECDT_Far;
		}
		else if( curPlayerStateType == ECRT_AirColliding )
		{
			return ECDT_Far;
		}
		
		return ECDT_Normal;
	}
	
	//---------------------------------------------------------------------------------
	private function PreRefineIsValid() : bool
	{
		var	dot			: float;
		var distance2D	: float;
		
		
		// No step climb or vault if running
		if( curPlayerStateType == ECRT_Running && heightTarget < 0.75f )
		{
			LogExplorationClimb( "Climb skipped because of running state and height < 0.75f" );
			return false;
		}
		
		// No climbing if it is a high climb and the poit is too far away
		if( curPlayerStateType == ECRT_Running && heightTarget >= 3.0f )
		{
			distance2D	= VecDistanceSquared2D( climbPoint, m_ExplorationO.m_OwnerE.GetWorldPosition() );
			if( distance2D > slideDistMaxOnRun * slideDistMaxOnRun )
			{
				LogExplorationClimb( "Climb skipped because of running state and distance " + distance2D + " > " + slideDistMaxOnRun * slideDistMaxOnRun );
				return false;
			}
		}
		
		// Check angle
		if( curPlayerStateType == ECRT_Running )
		{
			dot	= VecDot( wallNormal, inputDirection );
			if( dot > -0.65f )
			{
				LogExplorationClimb( "Climb skipped because of running state and dot from input to wall " + dot + " > -0.65f" );
				return false;
			}
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function RefinePlayerState()
	{
		// Run to landed
		if( curPlayerStateType == ECRT_Running && heightTarget > heightMaxToRun )
		{
     		curPlayerStateType = ECRT_Landed;
		}
		/*
		// For the lowest height, we use run if walking
		else if( curPlayerStateType == ECRT_Landed && heightTarget < 0.75f )
		{
			if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				curPlayerStateType = ECRT_Running;
			}
		}*/
		
		// Platform to no platform
		if( platformFound == ECRV_Platform )
		{
			if( curPlayerStateType == ECRT_Jumping || curPlayerStateType == ECRT_AirColliding )
			{
				if( heightTarget < platformHeightMinAir )
				{
					platformFound	= ECRV_NoPlatform;
				}
			}
			else
			{
				if( heightTarget < platformHeightMin )
				{
					platformFound	= ECRV_NoPlatform;
				}
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function PostRefineState()
	{
		var	characterPos	: Vector;
		var	distance2D		: float;
		
		return;
		// Going too close
		if( curPlayerStateType == ECRT_Running )
		{
			characterPos		= m_ExplorationO.m_OwnerMAC.GetWorldPosition();
			distance2D			= VecDistance2D( characterPos, climbPoint );
			
			if( distance2D < climbCur.forwardDistExact )
			{
				curPlayerStateType	= ECRT_Landed;
				FindApropriateClimb();
			}
		}
	}
	
	//---------------------------------------------------------------------------------
	private function FindApropriateClimb() : bool
	{	
		var i					: int;		
		var searchingForState	: EClimbRequirementType;
		
		
		// we use jump anims for air collision climbs
		searchingForState	= curPlayerStateType;
		
		if( searchingForState == ECRT_AirColliding )
		{
			searchingForState	= ECRT_Jumping;
		}
		
		// Find the closest explroation in the range that is valid
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{			
			// Proper state ?
			if( climbTypes[ i ].requiredState != searchingForState )//&& climbTypes[ i ].requiredStateAlt != curPlayerStateType )
			{
				continue;
			}
			
			// Vaulting ?
			if( vaultingFound != climbTypes[ i ].requiredVault ) 
			{
				continue;
			}
			
			// Platform?
			if( platformFound != climbTypes[ i ].requiredPlatform ) 
			{
				continue;
			}
			
			// Proper height ?
			if( climbTypes[ i ].heightMax < heightTarget || climbTypes[ i ].heightMin > heightTarget )
			{
				continue;
			}
			
			// Save the climb we found for when we enter the state
			climbCur	= climbTypes[ i ];
			
			return true;
		}
		
		LogExplorationClimb( " Could not find adequate climb type. heightTarget: " + heightTarget + ", State required: " + curPlayerStateType + ", vaultingFound: " + vaultingFound + ", platformFound: " + platformFound );
		return false;
	}
	
	//---------------------------------------------------------------------------------
	private function SetBehaviorData()
	{
		//m_ExplorationO.m_SharedDataO.ForceFotForward( false );
		m_ExplorationO.m_SharedDataO.SetFotForward();
		SetTranslationToBehaviour();
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_NotReady );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behHeightTypeEnum, ( float ) ( int ) climbCur.type );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVaultTypeEnum, ( float ) ( int ) climbCur.requiredVault );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behPlatformTypeEnum, ( float ) ( int ) climbCur.requiredPlatform );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStateTypeEnum, ( float ) ( int ) climbCur.requiredState );
		if( climbCur.requiredVault == ECRV_Vault )
		{
			m_ExplorationO.m_SharedDataO.m_JumpTypeE	= EJT_Vault;
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'JumpType', ( float ) ( int ) EJT_Vault );
		}
		else
		{
			m_ExplorationO.m_SharedDataO.m_JumpTypeE	= EJT_Fall;
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'JumpType', ( float ) ( int ) EJT_Fall );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function SetProperCameraAnim( reset : bool, speed : float )
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		var animation	: SCameraAnimationDefinition;
		
		if( !updateCameraAnim || !climbCur.playCameraAnimation )
		{
			return;
		}
		
		animation.animation	= climbCur.cameraAnimation; // 'vault_idle_300';
		animation.priority	= 10;
		animation.blendIn	= 0.5f;
		animation.blendOut	= 0.5f;
		animation.weight	= 1.0f;
		animation.speed		= speed;
		animation.loop		= false;
		animation.additive	= false;
		animation.reset		= reset;
		
		camera.PlayAnimation( animation );
	}
	
	//---------------------------------------------------------------------------------
	private function CancelCameraAnimation()
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		
		camera.StopAnimation( climbCur.cameraAnimation );
	}
	
	//---------------------------------------------------------------------------------
	private function SetInitialMovementAdjustor()
	{
		// Stop movement from jump if any
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		// Anim speed coef
		ApplyAnimationSpeed( 1.0f );
		
		// Gather info
		PrepareMovementAdjustorParameters();
	}
	
	//---------------------------------------------------------------------------------
	private function PrepareMovementAdjustorParameters()
	{
		var initialrotation		: float;
		var rotation			: float;
		var translation			: Vector;
		var translationBackDist	: float;
		var distanceToAdd		: float;
		var characterPos		: Vector;
		var	translationGoesBack	: bool;
		var	isCiri				: bool;
		
		
		// Get data
		heightToAdd			= heightTarget - climbCur.heightExact;	
		characterRadius		= 0.4f;//m_ExplorationO.m_OwnerMAC.GetCapsuleRadius();
		characterPos		= m_ExplorationO.m_OwnerMAC.GetWorldPosition();
		
		// Final orientation is perpendicular to the wall
		rotation			= VecHeading( -wallNormal );
		
		// Base translation
		translation			= climbPoint - characterPos;
		
		// Initial rotation is toward climb point, not target position point
		initialrotation		= VecHeading( translation ); 
		
		// Target position point is behind the point in the wall;
		translation			+= wallNormal * characterRadius;
		
		
		// The translation back is separate
		translationBackDist	= MaxF( 0.0f, VecDot( translation, wallNormal ) );
		// Temporary fix for Ciri
		isCiri	= false;
		if( (W3ReplacerCiri)thePlayer )
		{
			isCiri	= true;
		}
		if( isCiri )
		{
			translationBackDist	+= 0.125f; 
		}
		else
		{
			translationBackDist	+= 0.05f;
		}
		/*if( translationBackDist > 0.0f )
		{
			if( !isCiri )
			{
				translationBackDist	+= 1.2f;
			}
			//translation			= wallNormal * translationBackDist;
		}*/
		
		// Extra distances forward
		//if( climbCur.forwardDistExact > characterRadius ) //distanceToAdd )
		{
			distanceToAdd		= VecLength( translation ); 
			//translation			-= wallNormal * MaxF( 0.0f,  distanceToAdd - climbCur.forwardDistExact ) ;
			//translation			-= wallNormal * ( distanceToAdd - climbCur.forwardDistExact - 10.2f );
			translation			-= wallNormal * ( characterRadius - climbCur.forwardDistExact );
		}
		
		translation.Z			= heightToAdd;
		
		// Save distances
		adjustInitiallRotat		= initialrotation;
		adjustRotation			= rotation;
		adjustTranslation		= translation;
		
		// Init flags
		adjustInitialRotDone	= false;
		adjustRotDone			= false;
		adjustTransDone			= false;
		adjustSpeedRequire		= false;
		
		//StartMovementAdjustorInitialRotation( adjustInitRotTime );
		
		// Start the initial adjustments
		if( translationBackDist > 0.0f )
		{
			StartMovementAdjustorInitialTranslation( translationBackDist * wallNormal );
		}
	}
	
	//---------------------------------------------------------------------------------
	private function StartMovementAdjustorTranslation( duration : float )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		var ticket2			: SMovementAdjustmentRequestTicket;
		
		var distance		: float;
		var speed			: float;
		var timeRequired	: float;
		var animSpeedCoef	: float;
		
		if( noAdjustor )
		{
			return;
		}
		
		if( adjustTranslation == Vector( 0, 0, 0 ) )
		{
			return;
		}
		
		// Modify time and speed for a smoother translation
		distance	= VecLength( adjustTranslation );
		speed		= distance / duration;
		if( speed > adjustSpeedMax )
		{
			timeRequired		= distance / adjustSpeedMax;
			animSpeedCoef		= duration / timeRequired;
			duration			= timeRequired;
			adjustSpeedRequire	= true;
			adjustSpeedEndTime	= m_ExplorationO.GetStateTimeF() + duration;
			ApplyAnimationSpeed( animSpeedCoef );
		}
		
		// setup movement adjustment
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusTranslation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		movAdj.AdjustLocationVertically( ticket, true );
		
		movAdj.SlideBy( ticket, adjustTranslation );
		
		// Apply movement Vertical
		//movAdj.SlideBy( ticket, Vector( 0.0f, 0.0f, adjustTranslation.Z ) );
		
		adjust2Dduration	= duration;
		adjust2Translation	= Vector( adjustTranslation.X, adjustTranslation.Y, 0.0f );
		adjust2Speed		= VecLength2D( adjust2Translation ) / duration;
		
		/*
		// Aply movement 2D
		ticket2	= movAdj.CreateNewRequest( 'ClimbAdjusTranslation2D' );		
		movAdj.AdjustmentDuration( ticket2, duration );
		movAdj.AdjustLocationVertically( ticket2, false );
		
		
		// Apply movement
		movAdj.SlideBy( ticket2, Vector( adjustTranslation.X, adjustTranslation.Y, 0.0f ) );
		*/
		adjustTransDone	= true;
	}
	
	//---------------------------------------------------------------------------------
	private function StartMovementAdjustorInitialRotation( duration : float )
	{
		var movAdj 		: CMovementAdjustor;
		var ticket 		: SMovementAdjustmentRequestTicket;
		var	angle		: float;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		
		if( adjustInitiallRotat == m_ExplorationO.m_OwnerE.GetHeading() )
		{
			return;
		}
		
		
		// Initial rotation modification	
		angle	= 	AngleDistance( adjustInitiallRotat, adjustRotation );
		if( AbsF( angle ) > 90.0f ) //120.0f )
		{
			adjustInitiallRotat		= adjustRotation;
		}
		
		// setup movement adjustment
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'ClimbAdjusInitialRotation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		movAdj.LockMovementInDirection( ticket, adjustInitiallRotat );
		
		
		// Apply movement
		movAdj.RotateTo( ticket, adjustInitiallRotat );	
		adjustInitialRotDone	= true;
	}
	
	//---------------------------------------------------------------------------------
	private function StartMovementAdjustorInitialTranslation( translationBack : Vector )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		// setup movement adjustment
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusInitialTranslation' );		
		movAdj.AdjustmentDuration( ticket, 0.1f );
		movAdj.AdjustLocationVertically( ticket, true );
		
		
		// Apply movement
		movAdj.SlideBy( ticket, translationBack );
	}
	
	//---------------------------------------------------------------------------------
	private function StartMovementAdjustorRotation( duration : float )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.CancelByName( 'ClimbAdjusInitialRotation' );
		
		// already heading there
		if( adjustRotation	== m_ExplorationO.m_OwnerE.GetHeading() )
		{
			return;
		}
		
		// setup movement adjustment
		ticket = movAdj.CreateNewRequest( 'ClimbAdjusRotation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		
		
		// Apply movement
		movAdj.RotateTo( ticket, adjustRotation );	
		adjustRotDone	= true;
	}
	
	//---------------------------------------------------------------------------------
	private function ApplyFakeGravity()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		// setup movement adjustment
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'ClimbFakeGravity' );		
		movAdj.AdjustmentDuration( ticket, 0.5 );
		movAdj.AdjustLocationVertically( ticket, true );
		
		
		// Apply movement
		movAdj.SlideBy( ticket, Vector( 0.0f, 0.0f, -0.75f ) );
		adjustTransDone	= true;
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateAdjusting2D( _Dt : float )
	{
		var movAdj 		: CMovementAdjustor;
		var distance	: float;
		
		
		if( adjust2Dduration > 0.0f )
		{
			movAdj.AddOneFrameTranslationVelocity( adjust2Translation * adjust2Speed );// * _Dt );
			adjust2Dduration	-= _Dt;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function ApplyAnimationSpeed( speed : float )
	{
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behAnimSpeed, speed );
		SetProperCameraAnim( false, speed );
	}
	
	
	//---------------------------------------------------------------------------------
	private function StartMovementAdjustorCorrectPelvis()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		if( noPelvisCorection || noAdjustor )
		{
			return;
		}
		
		// setup movement adjustment
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		//movAdj.CancelByName( 'ClimbAdjusInitialRotation' );
		//movAdj.CancelByName( 'ClimbAdjustments' );
		//movAdj.CancelByName( 'ClimbAdjusTranslation' );
		//movAdj.CancelByName( 'ClimbAdjusRotation' );
		//movAdj.CancelByName( 'ClimbFakeGravity' );
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusPelvisCorrection' );		
		movAdj.AdjustmentDuration( ticket, 0.2f ); //pelvisTransCur * pelvisTransSpeedOut );
		
		
		// Apply movement
		movAdj.SlideBy( ticket, m_ExplorationO.m_OwnerE.GetWorldForward() * pelvisTransCur );
	}
	
	//---------------------------------------------------------------------------------
	private function StartHandIK( left : bool, right : bool )
	{
		var rightHand		: Vector;
		var leftHand		: Vector;
		
		var normal			: Vector;
		
		var world			: CWorld;
		
		
		// Left hand
		if( left )
		{
			leftHand			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexLeftHand );
			leftHand.Z			= climbPoint.Z;
			
			handIKLRayOrigin	= leftHand + m_ExplorationO.m_OwnerE.GetWorldForward() * handIKForwardOffset;
			handIKLRayEnd		= handIKLRayOrigin;
			handIKLRayOrigin.Z	+= handIKHalfMaxHeight;
			handIKLRayEnd.Z		-= handIKHalfMaxHeight;
			world				= theGame.GetWorld();
			if( world )
			{
				if( world.SweepTest( handIKLRayOrigin, handIKLRayEnd, 0.2f, handIKLRayCollision, normal, collisionObstaclesNames ) )
				{
					leftHandOffset		= handIKLRayCollision.Z - leftHand.Z + handThickness;
					if( AbsF( leftHandOffset ) >= handIKMinDistToEnable )
					{
						handIKEnabledLeft	= true;
						
						leftHandOffset	= ClampF( leftHandOffset, -handIKMaxDist, handIKMaxDist );
					}
				}
			}
		}
		
		// Right hand
		if( right )
		{
			rightHand			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexRightHand );
			rightHand.Z			= climbPoint.Z;
			
			handIKRRayOrigin	= rightHand + m_ExplorationO.m_OwnerE.GetWorldForward() * handIKForwardOffset;
			handIKRRayEnd		= handIKRRayOrigin;
			handIKRRayOrigin.Z	+= handIKHalfMaxHeight;
			handIKRRayEnd.Z		-= handIKHalfMaxHeight;
			if( theGame.GetWorld().SweepTest( handIKRRayOrigin, handIKRRayEnd, 0.2f, handIKRRayCollision, normal, collisionObstaclesNames ) )
			{
				rightHandOffset		= handIKRRayCollision.Z - rightHand.Z + handThickness;
				if( AbsF( rightHandOffset ) >= handIKMinDistToEnable )
				{
					handIKEnabledRight	= true;
					
					rightHandOffset	= ClampF( rightHandOffset, -handIKMaxDist, handIKMaxDist );
				}
			}
		}
		
		// Start it
		if( handIKEnabledLeft || handIKEnabledRight )
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( true );
			handIKEnabled	= true;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function StopHandIK(  left : bool, right : bool )
	{			
		if( left )
		{
			leftHandOffset	= 0.0f;
			handIKEnabledLeft	= false;
		}
		if( right )
		{
			rightHandOffset	= 0.0f;
			handIKEnabledRight	= false;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateHandsIK( _Dt : float )
	{
		// Waiting to check for hand IK?
		if( handIKqueuedL || handIKqueuedR )
		{
			StartHandIK( handIKqueuedL, handIKqueuedR );
			
			// If we found a proper IK adjustment for the request, the request is finished
			if( handIKqueuedL && handIKEnabledLeft )
			{
				handIKqueuedL	= false;
			}
			if( handIKqueuedR && handIKEnabledRight )
			{
				handIKqueuedR	= false;
			}
		}
		// If we are tracing every frame
		else if( continousHandIK )
		{
			if( handIKEnabledLeft || handIKEnabledRight )
			{
				StartHandIK( handIKEnabledLeft, handIKEnabledRight );
			}
		}
		
		// Blend and apply it
		UpdateAndSetHandsIKBlend( _Dt );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateAndSetHandsIKBlend( _Dt : float )
	{
		if( handIKEnabledLeft || handIKEnabledRight || AbsF( leftHandOffsetCur ) > 0.0f || AbsF( rightHandOffsetCur ) > 0.0f )
		{
			// Blend offsets
			if( leftHandOffset == 0.0f )
			{
				leftHandOffsetCur	= BlendLinearF( leftHandOffsetCur, leftHandOffset, _Dt * handIKBlendSpeedOut );
			}
			else
			{
				leftHandOffsetCur	= BlendLinearF( leftHandOffsetCur, leftHandOffset, _Dt * handIKBlendSpeedIn );
			}
			if( rightHandOffset == 0.0f )
			{
				rightHandOffsetCur	= BlendLinearF( rightHandOffsetCur, rightHandOffset, _Dt * handIKBlendSpeedOut );
			}
			else
			{			
				rightHandOffsetCur	= BlendLinearF( rightHandOffsetCur, rightHandOffset, _Dt * handIKBlendSpeedIn );
			}
			m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( leftHandOffsetCur, rightHandOffsetCur );
		}
		// Time to disable?
		else if( handIKEnabled && !handIKEnabledLeft && !handIKEnabledRight && leftHandOffsetCur == 0.0f && rightHandOffsetCur == 0.0f )
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( false );
			handIKEnabled	= false;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateTranslationOutsideCapsule( _Dt : float )
	{
		switch( pelvisTransState )
		{
			case EOCS_Inactive		:
				break;
			case EOCS_Starting		:
				UpdateTargetPelvisTranslationTarget();
				pelvisTransCur	= BlendLinearF( pelvisTransCur, pelvisTransTarget, pelvisTransSpeed * _Dt );
				SetTranslationToBehaviour();
				if( pelvisTransCur < pelvisTransSpeed * _Dt )
				{
					pelvisTransState	= EOCS_PerfectFollow;
				}
				break;
			case EOCS_PerfectFollow	:
				UpdateTargetPelvisTranslationTarget();
				pelvisTransCur	= pelvisTransTarget;
				SetTranslationToBehaviour();
				break;
			case EOCS_Recover		:
				break;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateTargetPelvisTranslationTarget()
	{
		var directionToPoint : Vector;
		
		
		directionToPoint	= climbPoint - m_ExplorationO.m_OwnerE.GetWorldPosition();		
		directionToPoint.Z	= 0.0f;
		
		directionToPoint	= directionToPoint * VecDot( directionToPoint, m_ExplorationO.m_OwnerE.GetWorldForward() );
		
		pelvisTransTarget	= VecLength2D( directionToPoint ) - characterRadius + 0.1f;
		pelvisTransTarget	= ClampF( pelvisTransTarget, 0.0f, pelvisTransMax );
	}
	
	//---------------------------------------------------------------------------------
	private function CorrectPelvisStartEnd()
	{
		if(	pelvisTransState == EOCS_PerfectFollow || pelvisTransState == EOCS_Starting )
		{
			pelvisTransState	= EOCS_Recover;
			pelvisTransTarget	= 0.0f;
			ResetTranslationToBehaviour();
			StartMovementAdjustorCorrectPelvis();
		}
	}
	
	//---------------------------------------------------------------------------------
	private function SetTranslationToBehaviour()
	{
		if( noPelvisCorection )
		{
			return;
		}
		
		m_ExplorationO.m_OwnerMAC.SetAdditionalOffsetToConsumeMS( Vector( 0.0f, pelvisTransCur, 0.0f ), EulerAngles( 0.0f, 0.0f, 0.0f ), 1.0f );
	}
	
	//---------------------------------------------------------------------------------
	private function ResetTranslationToBehaviour()
	{
		if( noPelvisCorection )
		{
			return;
		}
		
		m_ExplorationO.m_OwnerMAC.SetAdditionalOffsetToConsumeMS( Vector( 0.0f, pelvisTransCur, 0.0f ), EulerAngles( 0.0f, 0.0f, 0.0f ), 0.1f );
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateRunOrWalk()
	{
		var runValue	: float;
		
		// Check end type (we can end to idle walk (if there is anim) or run
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() && AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputAngleToRun )
		{
			if( thePlayer.GetIsRunning() ) //m_ExplorationO.m_InputO.IsSprintPressed() )
			{
				runValue	= 1.0f;
			}
			else
			{
				runValue	= 0.5f;
			}
		}
		else
		{
			runValue	= 0.0f; 
		}
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behToRun, runValue );
	}
	
	
	//---------------------------------------------------------------------------------
	private function CheckVerticalSlideEnd()
	{
		var posCur	: Vector;
		
		
		if( vaultingFound == ECRV_NoVault )
		{
			posCur	= m_ExplorationO.m_OwnerE.GetWorldPosition();
			if( posCur.Z > heightTarget + 0.1f )
			{
				m_ExplorationO.m_CollisionManagerO.EnableVerticalSliding( false );
			}
		}
	}
		
	//---------------------------------------------------------------------------------
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		var blend			: float;
		var targetPos		: Vector;
		var position		: Vector;
		var rotation		: EulerAngles;
		var positionDesired	: Vector;
		var rotationDesired	: EulerAngles;
		var inputX			: float;
		var inputY			: float;
		
		
		if( !updateCameraManual )
		{
			return false;
		}
		
		// Target position and rotation
		targetPos		= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( camFollowBoneID );
		rotationDesired	= m_ExplorationO.m_OwnerE.GetWorldRotation();
		
		// Start
		if( camStart == true )
		{
			//camOriginalPosition = moveData.pivotPositionValue - targetPos;
			camOriginalPosition = moveData.pivotPositionValue;// - targetPos;
			camOriginalRotation	= moveData.pivotRotationValue;
			camCurRotation		= rotationDesired;
			camOriginalOffset	= moveData.cameraLocalSpaceOffset;
			camStart			= false;
		}
		
		// Input
		inputX							= theInput.GetActionValue( 'GI_AxisRightX' );
		inputY							= theInput.GetActionValue( 'GI_AxisRightY' );
		camCurRotation.Yaw				= camCurRotation.Yaw - inputX * dt * 200.0f;
		camCurRotation.Pitch			= ClampF( camCurRotation.Pitch + inputY * dt * 100.0f, -45.0f, 45.0f );
		
		// Blend
		camOriginalRotation.Yaw			= LerpAngleF( dt * 5.0f, camOriginalRotation.Yaw, camCurRotation.Yaw );
		camOriginalRotation.Pitch		= LerpAngleF( dt * 5.0f, camOriginalRotation.Pitch, camCurRotation.Pitch );
		
		positionDesired					= targetPos - m_ExplorationO.GetWorldForward() * 0.8f + m_ExplorationO.m_OwnerE.GetWorldUp() * 0.8f;
		camOriginalPosition				= LerpV( camOriginalPosition, positionDesired, dt * 2.0f );
		
		// Set
		moveData.pivotPositionValue		= camOriginalPosition;
		moveData.pivotRotationValue		= camOriginalRotation;
		moveData.cameraLocalSpaceOffset	= camOriginalOffset;
		moveData.pivotPositionVelocity	= Vector( 0.0f, 0.0f, 0.0f );
		moveData.pivotRotationVelocity	= EulerAngles( 0.0f, 0.0f, 0.0f );
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		var text	: string;
		
		text	= climbCur.type				+ ", "
				+ climbCur.requiredVault	+ ", "
				+ climbCur.requiredPlatform	+ ", "
				+ climbCur.requiredState	+ ", "
				+ "PelvisT: " + pelvisTransCur;
		
		return text;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		var colorAux		: Color;
		
		
		m_ClimbOracleO.OnVisualDebug( frame, flag, active );
		
		colorAux	= Color( 80, 200, 80 );
		frame.DrawText( GetClimbTypeText(), climbPoint + Vector( 0.0f, 0.0f, 1.0f ) + VecFromHeading( adjustRotation ) * 2.0f , colorAux );
		colorAux	= Color( 100, 255, 100 );
		frame.DrawSphere( climbPoint, 0.1f, colorAux );
		frame.DrawLine( climbPoint, climbPoint + wallNormal, colorAux );
		
		// IK
		colorAux	= Color( 255, 255, 255 );
		frame.DrawLine( handIKLRayOrigin, handIKLRayEnd, colorAux );		
		frame.DrawText( "IK: " + leftHandOffsetCur,  handIKLRayCollision, colorAux );
		frame.DrawLine( handIKRRayOrigin, handIKRRayEnd, colorAux );		
		frame.DrawText( "IK: " + rightHandOffsetCur, handIKRRayCollision, colorAux );
		
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function DebugLogSuccesfullClimb()
	{				
		LogExplorationClimb( "------------------ Climb Found ------------------" );
		LogExplorationClimb( GetClimbTypeText() );
		LogExplorationClimb( "Translation " + VecToString( adjustTranslation ) + ", Rotation " + adjustRotation 
							//+ ", translationBackDist " + translationBackDist
							+ ", heightToAdd " + heightToAdd );		
		m_ClimbOracleO.DebugLogSuccesfullClimb();
		LogExplorationClimb( "------------------   ------   ------------------" );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function GetClimbTypeText() : string
	{
		return climbCur.requiredState + ", " + climbCur.type + ", " + climbCur.requiredVault + ", " + climbCur.requiredPlatform;
		//return "State: " + climbCur.requiredState + ", HeightType: " + climbCur.type + ", requiredVault: " + climbCur.requiredVault + "requiredPlatform: " + climbCur.requiredPlatform;
	}
}

//------------------------------------------------------------------------------------------------------------------
function LogExplorationClimb( text : string )
{
	LogChannel( 'ExplorationState'		, "Climb: " + text );
	LogChannel( 'ExplorationStateClimb'	, text );
}
