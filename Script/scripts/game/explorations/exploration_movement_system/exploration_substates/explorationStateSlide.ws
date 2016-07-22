// CExplorationStateSlide
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 09/01/2014 )	 
//------------------------------------------------------------------------------------------------------------------

function LogSlidingTerrain( text : string )
{
	LogChannel('SlideTerrain', text );
}

//>-----------------------------------------------------------------------------------------------------------------
enum ESlidingSubState
{
	SSS_Entering	= 0,
	SSS_Sliding		= 1,
	SSS_HardSliding	= 2,
	SSS_Exiting		= 3,
	SSS_Exited		= 4,
}

//>-----------------------------------------------------------------------------------------------------------------
enum ESlideCameraShakeState
{
	SCSS_None	,
	SCSS_Soft	,
	SCSS_Hard	,
}

//>-----------------------------------------------------------------------------------------------------------------
struct SSlidingMaterialPresetParams
{
	editable	var presetName				: name;
	
	editable	var angleMin				: float;		default	angleMin				= 55.0f;
	editable	var angleMinRain			: float;		default	angleMinRain			= 50.0f;
	editable	var frictionMultiplier		: float;		default	frictionMultiplier		= 1.0f;
	editable	var frictionMultiplierRain	: float;		default	frictionMultiplierRain	= 0.8f;
}

//>-----------------------------------------------------------------------------------------------------------------
struct SSlidingMaterialNamesToPresets
{
	editable	var materialName			: name;
	editable	var presetName				: name;
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationStateSlide extends CExplorationStateAbstract
{	
	protected			var	subState				: ESlidingSubState;
	private	editable	var	enableWallSlide			: bool;						default	enableWallSlide			= false;
	
	// Coeficients
	protected editable	var	useSmothedCoefOnIdle	: bool;						default	useSmothedCoefOnIdle	= false;
	protected editable	var	angleMinDefault			: float;					default	angleMinDefault			= 70.0f;
	protected editable	var	anglefMax				: float;					default	anglefMax				= 80.0f;
	protected editable	var	coefExtraToStop			: float;					default	coefExtraToStop			= 0.2f;
	
	// Coef for inputs
	protected editable	var	slideCoefRelatedToInput	: bool;						default	slideCoefRelatedToInput	= false;
	protected editable	var	dotToStartForward		: float;					default	dotToStartForward		= 0.5f;
	protected editable	var	coefToStartBackward		: float;					default	coefToStartBackward		= 0.35f;
	protected editable	var	coefToStartCenter		: float;					default	coefToStartCenter		= 0.25f;
	protected editable	var	coefToStartForward		: float;					default	coefToStartForward		= 0.0f;
	
	// wide terrain
	protected editable	var	useWideTerrainCheckToEnter	: bool;					default	useWideTerrainCheckToEnter	= true;
	/*
	protected editable	var angleMinWideAvg			: float;					default	angleMinWideAvg			= 45.0f;
	protected editable	var	angleMinWideGlobal		: float;					default	angleMinWideGlobal		= 45.0f;
	protected editable	var coefMinWideAvg			: float;					
	protected 			var	coefMinWideGlobal		: float;
	*/
	
	
	// Material influences
	protected 			var	updateMaterials			: bool;
	protected editable	var	materialParams			: array<SSlidingMaterialPresetParams>;
	protected editable	var	materialNamesToPresets	: array<SSlidingMaterialNamesToPresets>;
	protected editable	var	materialParamsDefaultN	: name;						default	materialParamsDefaultN	= 'Default';
	protected 			var	materialDefault			: int;
	protected 			var	materialCurId			: int;
	protected			var	materialNameCur			: name;
	
	// Start sliding
	protected editable	var	minTimeToIdle			: float;					default	minTimeToIdle			= 0.3f;
	protected editable	var	orientingInitial		: float;					default	orientingInitial		= 200.0f;
	protected editable	var	initialImpulse			: float;					default	initialImpulse			= 1.0f;
	protected			var startedFromJump			: bool;
	protected			var startedFromRoll			: bool;
	
	// Sliding idle
	protected editable	var	orientingSpeedMin		: float;					default	orientingSpeedMin		= 300.0f;
	protected editable	var	orientingSpeedMax		: float;					default	orientingSpeedMax		= 900.0f;
	protected editable	var	orientingMaxSlope		: float;					default	orientingMaxSlope		= 0.7f;
	
	// Hard slide
	protected editable	var timeToHardSlide			: float;					default	timeToHardSlide			= 0.2f;
	protected editable	var behGraphEventSlideHard	: name;						default	behGraphEventSlideHard	= 'SlideHard';
	
	// Stop sliding
	protected editable	var	requireSpeedToExit 		: bool;						default	requireSpeedToExit		= true;
	protected editable	var	speedToExitForward		: float;					default	speedToExitForward		= 7.0f;
	protected editable	var	speedToExitCenter		: float;					default	speedToExitCenter		= 15.0f;
	protected editable	var	speedToExitBackward		: float;					default	speedToExitBackward		= 20.0f;
	
	protected editable	var exitingTimeMinSoft		: float;					default	exitingTimeMinSoft		= 0.2f;
	protected 			var	exitingTimeCur			: float;
	protected editable	var	exitingTimeTotal		: float;					default	exitingTimeTotal		= 2.0f;
	protected editable	var	exitingTimeTotalInput	: float;					default	exitingTimeTotalInput	= 0.5f;
	private				var	stoppingFriction		: bool;
	
	// Cooldown
	protected editable	var	cooldownMax				: float;					default	cooldownMax				= 0.1f;
	protected 			var	cooldownCur				: float;
	
	// Slide from land
	protected			var landCoolingDown			: bool;
	protected editable	var	landCoolDownTime		: float;					default	landCoolDownTime		= 0.7f;
	
	// Slide to jump
	protected editable	var fromJumpBehGraphEvent	: name;						default	fromJumpBehGraphEvent	= 'Slide_From_Jump';
	protected editable	var fromRollBehGraphEvent	: name;						default	fromRollBehGraphEvent	= 'Slide_From_Roll';
	protected editable	var	jumpAllowed				: bool;						default	jumpAllowed				= true;
	protected editable	var	jumpCoolDownTime		: float;					default	jumpCoolDownTime		= 0.3f;
	
	
	// To Fall
	protected editable	var	fallSpeedMaxConsidered	: float;					default	fallSpeedMaxConsidered	= 10.0f;
	protected editable	var	fallSpeedCoef			: float;					default	fallSpeedCoef			= 0.6f;
	protected editable	var	fallHorizImpulse		: float;					default	fallHorizImpulse		= 2.0f;
	protected editable	var	fallHorizImpulseCancel	: float;					default	fallHorizImpulseCancel	= 1.0f;
	protected editable	var	fallExtraVertImpulse	: float;					default	fallExtraVertImpulse	= -2.0f;
	
	// physics
	protected editable	var	slidingPhysicsSpeed		: float;					default	slidingPhysicsSpeed		= 26.0f;
	protected editable	var	movementParams			: SSlidingMovementParams;
	protected editable	var	movementStoppingParams	: SSlidingMovementParams;
	
	protected editable	var	usePhysics				: bool;						default usePhysics				= false;
	
	// Smooth direction
	protected			var slideDirectionDamped	: Vector;
	//protected			var smoothedYawDir			: float;	
	protected editable	var	smoothedDirBlendCoef	: float;					default smoothedDirBlendCoef	= 1.1f;	
	
	// To Fall
	private	  editable	var	slideKills				: bool;						default	slideKills				= false;
	private				var	m_DeadB					: bool;
	protected editable	var	toFallEnabled			: bool;						default toFallEnabled			= true;
	protected 			var	toFallTimeCur			: float;
	protected editable	var	toConsiderFallTimeTotal	: float;					default	toConsiderFallTimeTotal	= 1.5f;
	protected editable	var	toFallTimeTotal			: float;					default	toFallTimeTotal			= 1.5f;
	protected editable	var	toFallSlopeCoefMin		: float;					default toFallSlopeCoefMin		= 0.25f;
	protected editable	var	toFallSlopeSpeedMin		: float;					default toFallSlopeSpeedMin		= 0.1f;
	protected editable	var	toFallSlopeCoef			: float;					default toFallSlopeCoef			= 2.25f;
	protected editable	var	toFallSpeedCoef			: float;					default toFallSpeedCoef			= 0.25f;
	protected editable	var	toFallRecoverCoef		: float;					default toFallRecoverCoef		= 0.5f;
	protected editable	var	toFallCameraLevel		: int;
	private				var	cameraShakeState		: ESlideCameraShakeState;
	protected editable	var	cameraAnimName			: name;						default	cameraAnimName			= 'camera_shake_loop_lvl1_1';
	protected editable	var behTripToDeath			: name;						default	behTripToDeath			= 'TripToDeath';
	
	// Animation
	protected editable	var	behHeightVar			: name;						default	behHeightVar			= 'Slide_Height';
	protected editable	var	behInclinationVar		: name;						default	behInclinationVar		= 'Slide_Inclination';
	protected editable	var	behTurnVar				: name;						default	behTurnVar				= 'Slide_Turn';
	protected editable	var	behAccelVar				: name;						default	behAccelVar				= 'Slide_Accel';
	protected editable	var	behRightFootForwardVar	: name;						default	behRightFootForwardVar	= 'Slide_RightFootForward';
	protected editable	var	inclinationBlendSpeed	: float;					default	inclinationBlendSpeed	= 40.0f;
	protected editable	var	inclinationStart		: float;					default	inclinationStart		= 45.0f;
	protected editable	var	turnInclinationMax		: float;					default	turnInclinationMax		= 12.0f;
	protected editable	var	turnInclinationBlend	: float;					default	turnInclinationBlend	= 5.0f;
	protected editable	var	turnInclinationCur		: float;
	protected editable	var	inclinationEnterTimeMax	: float;					default	inclinationEnterTimeMax	= 0.5f;
	protected 			var	inclinationEnterTimeCur	: float;
	
	protected 			var	inclination				: float;
	protected editable	var	behForwardVar			: name;						default	behForwardVar			= 'Slide_Forward';
	protected editable	var	behSlideRestart			: name;						default	behSlideRestart			= 'Slide_Restart';
	protected editable	var	behSlideEnd				: name;						default	behSlideEnd				= 'Slide_End';
	protected editable	var	behSlideEndRun			: name;						default	behSlideEndRun			= 'Slide_ToRun';
	protected editable	var	behSlideEndIdle			: name;						default	behSlideEndIdle			= 'Slide_ToIdle';
	protected editable	var	boneToStickName			: name;						default	boneToStickName			= 'l_hand';
	protected 			var	boneToStickId			: int;
	
	protected editable	var animEventHardSliding	: name;						default animEventHardSliding	= 'Slide_HardIsReady';
	protected			var lockedOnHardSliding		: bool;
	
	// Particles
	protected editable	var	particlesEnabled			: bool;					default	particlesEnabled		= false;
	protected editable	var particlesName				: name;					default particlesName			= 'fx_steps_other';
	protected editable	var boneLeftFoot 				: name;					default boneLeftFoot			= 'l_foot';
	protected editable	var boneRightFoot 				: name;					default boneRightFoot			= 'r_foot';
	protected 			var timeToRespawnParticlesCur	: float;
	protected editable	var timeToRespawnParticlesMax	: float;				default	timeToRespawnParticlesMax	= 0.2f;
	
	
	
	//---------------------------------------------------------------------------------
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		var angleMin		: float;
		var i				: int;
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Slide';
		}
		
		SetCanSave( false );
		
		// If we have this state, disable sliding by default, till we enter here
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		
		updateMaterials		= m_ExplorationO.m_MoverO.m_UseMaterialsB;
		
		if( updateMaterials )
		{
			GrabOrCreateDefaultMaterialParams();
			
			materialCurId	= materialDefault;
			// do not set the materialCurName on purpouse, so first time we'll set the proper one
			
			
			// Defualt min angle
			angleMin			= 90.0f;
			
			// Get the min coef from all the materials
			for ( i = 0; i < materialParams.Size(); i += 1 )
			{
				if( angleMin > materialParams[i].angleMin )
				{
					angleMin = materialParams[i].angleMin;
				}
				if( angleMin > materialParams[i].angleMinRain )
				{
					angleMin = materialParams[i].angleMinRain;
				}
			}
			
			m_ExplorationO.m_SharedDataO.terrainSlidePresetName	= materialParamsDefaultN;
		}
		
		m_ExplorationO.m_MoverO.SetSlidingLimits( angleMin, anglefMax );
		
		// Also set some defautls, just in case
		m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
		m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMin, materialParams[materialCurId].frictionMultiplier );
		
		
		// Prepare anim
		boneToStickId	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneToStickName );
		
		// Substate
		m_StateTypeE			= EST_Idle;
		m_InputContextE			= EGCI_JumpClimb; 		
		m_UpdatesWhileInactiveB	= true;
		
		// To fall
		toFallTimeCur		= 0.0f;
	}
	
	//---------------------------------------------------------------------------------
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_Signs );
		AddActionToBlock( EIAB_Fists );
		AddActionToBlock( EIAB_SwordAttack );
		AddActionToBlock( EIAB_Parry );
		AddActionToBlock( EIAB_Counter );
	}
	
	//---------------------------------------------------------------------------------
	private function AddDefaultStateChangesSpecific()
	{
		//AddStateToTheDefaultChangeList('Jump');
		if( enableWallSlide )
		{
			AddStateToTheDefaultChangeList('WallSlide', -1.0f );
		}
		
		//AddStateToTheDefaultChangeList('Interaction');
		//AddStateToTheDefaultChangeList('Climb');
	}

	//---------------------------------------------------------------------------------
	function StateWantsToEnter() : bool
	{			
		if( !WantsToEnterBasic() )
		{
			return false;
		}
		
		// special check for wide terrain normal
		if( useWideTerrainCheckToEnter )
		{
			if( !WantsToEnterWide() )
			{
				return false;
			}
		}
		
		return true;		
	}
	
	//---------------------------------------------------------------------------------
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !thePlayer.IsActionAllowed( EIAB_Slide ) )
		{
			return false;
		}
		
		if( !m_ExplorationO.IsOnGround() )
		{
			return false;
		}
		
		return cooldownCur <= 0.0f;
	}
	
	//---------------------------------------------------------------------------------
	private function StateEnterSpecific( prevStateName : name )	
	{
		var velocity			: Vector;
		var slideDir			: Vector;
		var slideNormal			: Vector;
		var slidingDirDot		: float;
		var slidingForward		: bool;
		var isRightFootForward	: bool;
		
		
		m_DeadB		= false;
		
		// Landing on slide?
		startedFromJump	= prevStateName == 'Jump' && m_ExplorationO.GetStateTimeF() >= m_ExplorationO.m_SharedDataO.m_SkipLandAnimTimeMaxF;
		startedFromRoll	= prevStateName	== 'Roll';// && m_ExplorationO.m_SharedDataO.m_LastLandTypeE	== LT_Roll;
		
		// Damage if we come from jump or wallslide
		if( startedFromJump || prevStateName == 'WallSlide' )
		{
			CheckLandingDamage();
		}
		
		// We will have some considerations when entering after land
		landCoolingDown	= prevStateName	== 'Land' || prevStateName	== 'Jump';
		
		
		// Movement
		m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( false );	
		
		SetTerrainParameters(); 		
		
		m_ExplorationO.m_OwnerMAC.SetSliding( usePhysics );
		m_ExplorationO.m_OwnerMAC.SetSlidingSpeed( slidingPhysicsSpeed );
		
		// Initial speed		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slideDir, slideNormal );
		velocity		= m_ExplorationO.m_MoverO.GetMovementVelocity();		
		velocity		-= slideNormal * VecDot( slideNormal, velocity );
		velocity		+= slideDir * initialImpulse;
		m_ExplorationO.m_MoverO.SetVelocity( velocity );
		
		// Init soft direction				
		//smoothedYawDir	= AngleNormalize180( VecHeading( slideDir ) );
		slideDirectionDamped	= slideDir;
		
		// Forcing jump direction
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= slideDir;
		
		// Anim
		inclination				=  m_ExplorationO.m_MoverO.GetRealSlideAngle( ); //inclinationStart;
		inclinationEnterTimeCur	= inclinationEnterTimeMax;
		turnInclinationCur		= 0.0f;
		
		// Forward or backward ?
		slidingDirDot	= VecDot( slideDir, m_ExplorationO.m_OwnerE.GetWorldForward() );
		slidingForward	= slidingDirDot >= 0.0f;
		m_ExplorationO.SetBehaviorParamBool( behForwardVar, slidingForward );
		
		// If sliding forward, get the foot that is more forward
		if( slidingForward )
		{
			isRightFootForward	= !m_ExplorationO.m_MoverO.IsRightFootForwardTowardsDir( slideDir );
		}
		
		// If slifding backward, get the foot closer to the side we have to turn to
		else
		{
			isRightFootForward	= VecDot( slideDir, m_ExplorationO.m_OwnerE.GetWorldRight() ) < 0.0f;
		}
		m_ExplorationO.SetBehaviorParamBool( behRightFootForwardVar, isRightFootForward );
		
		// Action blocks
		BlockActions();
		
		// No IK at the slide
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false ); //false, 0.005f ); // jus to test
		//m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
		//m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( false );
		
		// Init particles
		if( particlesEnabled )
		{
			thePlayer.PlayEffectOnBone( particlesName, boneLeftFoot );
			thePlayer.PlayEffectOnBone( particlesName, boneRightFoot );
			timeToRespawnParticlesCur	= timeToRespawnParticlesMax;
		}
		
		// To fall
		toFallCameraLevel	= 0;
		cameraShakeState = SCSS_None;
		
		// Substate
		if( startedFromJump || startedFromRoll )
		{
			subState			= SSS_HardSliding;
			lockedOnHardSliding	= true;
		}
		else
		{
			subState			= SSS_Entering;
			lockedOnHardSliding	= false;
		}
		exitingTimeCur		= 0.0f;		
		
		//Abort all signs
		thePlayer.AbortSign();	
	}
	
	//---------------------------------------------------------------------------------
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( animEventHardSliding,	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( 'DisableFeetIK',		'OnAnimEvent_SubstateManager' );
	}
	
	//---------------------------------------------------------------------------------
	function StateChangePrecheck( )	: name
	{
		if( m_DeadB )
		{
			return GetStateName();
		}
		
		// jump
		if( jumpAllowed && m_ExplorationO.GetStateTimeF() >= jumpCoolDownTime )
		{
			// Speciall check for combat trying to enter, we can't jump then 
			if( !thePlayer.IsCombatMusicEnabled() )
			{
				if( m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) )
				{
					return 'Jump';
				}
				else if( m_ExplorationO.StateWantsAndCanEnter( 'Climb' ) )
				{
					return 'Climb';
				}
			}
		}
		
		// Normal exit
		if( subState >= SSS_Exited )
		{
			return 'Idle';
		}
		
		// Fast exit
		if( !lockedOnHardSliding && m_ExplorationO.GetStateTimeF() > exitingTimeMinSoft )// subState < SSS_HardSliding && m_ExplorationO.GetStateTimeF() > 0.0f )
		{		
			if( StateWantsToExit() )
			{
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	//---------------------------------------------------------------------------------
	protected function StateUpdateSpecific( _Dt : float )
	{
		var slideDirection		: Vector;
		var slideNormal			: Vector;
		var slideCoef			: float;
		var targetYaw			: float;
		var finalOrientingSpeed	: float;
		var newInclination		: float;
		var turn				: float;
		var accel				: float;
		
		
		if( m_DeadB )
		{
			return;
		}
		
		// substate change
		SubstateChangePrecheck( _Dt );
		
		// Get the directions	
		slideCoef		= m_ExplorationO.m_MoverO.GetSlideCoef( true );		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slideDirection, slideNormal );
		
		// Dmap the slide direction
		//slideDirectionDamped	= LerpV( slideDirectionDamped, slideDirection, smoothedDirBlendCoef * _Dt );
		
		// Ger the orienting speed and forced direction
		UpdateForcedDirection( slideDirection );		
		
		// Orient	
		finalOrientingSpeed	= ComputeOrientingSpeed( slideCoef );
		if( slideCoef > 0.0f )
		{			
			targetYaw	= VecHeading( slideDirection );
			//smoothedYawDir	= AngleNormalize180( LerpAngleF( smoothedYawDir, targetYaw, MinF( 1.0f, _Dt * smoothedDirBlendCoef ) ) );
			//m_ExplorationO.m_MoverO.RotateYawTowards( targetYaw, _Dt * finalOrientingSpeed, 0.2f, true ); //0.15
		}
		else
		{
			if( m_ExplorationO.m_MoverO.GetMovementSpeedF() > 1.0f )
			{
				targetYaw		= m_ExplorationO.m_MoverO.GetMovementSpeedHeadingF(); 
				//smoothedYawDir	= AngleNormalize180( LerpAngleF( smoothedYawDir, targetYaw, MinF( 1.0f, _Dt * smoothedDirBlendCoef ) ) );
				//m_ExplorationO.m_MoverO.RotateYawTowards( targetYaw, _Dt * finalOrientingSpeed, 0.25f, true ); //0.2
			}
			else
			{
				targetYaw		= m_ExplorationO.m_OwnerE.GetHeading();
			}
		}	
		
		// Add control
		if( !usePhysics && subState	!= SSS_Exited )
		{
			// Extra stop
			stoppingFriction	= subState == SSS_Exiting || !WantsToEnterBasic( true );
			
			m_ExplorationO.m_MoverO.UpdateSlidingInertialMovementWithInput( _Dt, turn, accel, stoppingFriction, targetYaw, finalOrientingSpeed );
		}
		
		// Pitch Inclination		
		UpdateAngleToRotateToAdaptToSlope( slideDirection, _Dt );
		
		// Update speed		
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( m_ExplorationO.GetStateTimeF() > toConsiderFallTimeTotal );	
		
		// Update fall
		if( slideKills )
		{
			UpdateFallCoef( _Dt );
		}
		
		// Particles	
		if( particlesEnabled && timeToRespawnParticlesMax > 0.0f )
		{
			timeToRespawnParticlesCur	-= _Dt;		
			if( timeToRespawnParticlesCur <= 0.0f )
			{
				//thePlayer.StopEffect( particlesName );
				thePlayer.PlayEffectOnBone( particlesName, boneLeftFoot );
				thePlayer.PlayEffectOnBone( particlesName, boneRightFoot );
				timeToRespawnParticlesCur	= timeToRespawnParticlesMax;
			}
		}
		
		// set turn and accel vars
		turn				*= turnInclinationMax;
		turnInclinationCur	= BlendF( turnInclinationCur, turn, turnInclinationBlend * _Dt );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behTurnVar, turnInclinationCur );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behAccelVar, accel );		
	}
	
	//---------------------------------------------------------------------------------
	private function StateExitSpecific( nextStateName : name )
	{
		//sliding achievement
		theGame.GetGamerProfile().SetStat(ES_SlideTime, FloorF(m_ExplorationO.GetStateTimeF()) );
	
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		if( nextStateName == 'Idle' )
		{
			//check this out add specific anims to exit
			LogExploration("Left slide to Idle" );
			if( exitingTimeCur < exitingTimeTotal )// || m_ExplorationO.m_InputO.IsModuleConsiderable() && m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() < 45.0f )
			{
				m_ExplorationO.SendAnimEvent( behSlideEndRun );
			}
			else
			{
				m_ExplorationO.SendAnimEvent( behSlideEndIdle );
			}
		}
		else if( nextStateName == 'CombatExploration' )
		{
			LogExploration("Left slide to Combat" );
			if( exitingTimeCur < exitingTimeTotal )// || m_ExplorationO.m_InputO.IsModuleConsiderable() && m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() < 45.0f )
			{
				m_ExplorationO.SendAnimEvent( behSlideEndRun );
			}
			else
			{
				m_ExplorationO.SendAnimEvent( behSlideEndIdle );
			}
		}
		
		thePlayer.SetBIsCombatActionAllowed( true );
		
		// Ended going fast
		if( m_ExplorationO.m_MoverO.GetMovementSpeedF() > 5.0f )
		{
			thePlayer.SetIsSprinting( true );
			m_ExplorationO.m_OwnerMAC.SetGameplayRelativeMoveSpeed( 2.0f );
		}
		
		// Cooldown to reenter
		cooldownCur = cooldownMax;
		
		// Restore state
		subState	= SSS_Entering;
		
		// Restore IK
		//m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( false );
		
		// Particles
		if( particlesEnabled )
		{
			thePlayer.StopEffect( particlesName );
			//thePlayer.StopEffect( particlesName, boneNameRightFoot );
		}
		
		// Camera
		StopCameraAnim();
		
		// To fall speed
		if( nextStateName == 'StartFalling' )
		{
			PrepareFallFromSlide();
		}
		
		// Fast to combat?
		if( nextStateName != 'StartFalling' )
		{
			thePlayer.GoToCombatIfWanted();
		}
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function PrepareFallFromSlide()
	{
		var macVelocity	: Vector;
		var impulse		: Vector;
		
		
		impulse			= m_ExplorationO.m_OwnerE.GetWorldForward();
		impulse.Z		= 0.0f;
		
		
		// Impulse strength
		// No input
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			impulse *= fallHorizImpulseCancel;
		}
		// Countering
		if( VecDot( impulse, m_ExplorationO.m_InputO.GetMovementOnPlaneV() ) < 0.0f )
		{
			impulse *= fallHorizImpulseCancel;
		}
		// Moving forward
		else
		{
			impulse	*= fallHorizImpulse;
		}
		
		// Get the MAC Velocity we are interested in
		macVelocity		= m_ExplorationO.m_OwnerMAC.GetVelocity();
		macVelocity.Z	= 0.0f;	
		
		if( VecLengthSquared( macVelocity ) > fallSpeedMaxConsidered * fallSpeedMaxConsidered )
		{
			macVelocity	= VecNormalize( macVelocity ) * fallSpeedMaxConsidered;
		}
		
		// Add it to the impulse		
		impulse			+= macVelocity * fallSpeedCoef;
		
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		//m_ExplorationO.m_MoverO.SetVerticalSpeed( -AbsF( fallExtraVertImpulse ) );
		//m_ExplorationO.m_MoverO.SetVerticalSpeed( 0.0f);
		
		m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
	}
	
	//---------------------------------------------------------------------------------
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( animEventHardSliding );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( 'DisableFeetIK' );
	}
	
	//---------------------------------------------------------------------------------
	function StateUpdateInactive( _Dt : float )
	{
		var camera 	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		cooldownCur	-= _Dt;
		
		// To fall
		toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
	}
	
	//---------------------------------------------------------------------------------
	function GetBehaviorEventName() : name
	{
		if( startedFromJump )
		{
			return fromJumpBehGraphEvent;
		}
		else if( startedFromRoll )
		{
			return fromRollBehGraphEvent;
		}
		return m_BehaviorEventN;
	}
	
	
	//---------------------------------------------------------------------------------
	function GetBehaviorIsEventForced( fromState : name ) : bool
	{
		return true;
	}
	
	//---------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		var text	: string;
		
		
		switch( subState )
		{
			case SSS_Entering:
				text	=  "Entering";
			break;
			case SSS_Sliding:	
				text	=  "Soft Sliding";	
			break;
			case SSS_HardSliding:
				text	=  "Hard Sliding";
			break;
			case SSS_Exiting:
				text	=  "Exiting";	
			break;
			case SSS_Exited:	
				text	=  "Exited";
			break;
			default:
				text	=  "Unknown substate";
		}
		
		text	+= ".  StoppingFriction: " + stoppingFriction;
		
		return text;
	}
	
	//---------------------------------------------------------------------------------
	private function GrabOrCreateDefaultMaterialParams()
	{
		var defaultMaterial	: SSlidingMaterialPresetParams;
		var index	: int;
		
		materialDefault	= -1;
		index = FindPresetByName( materialParamsDefaultN );
		if( index >= 0 )
		{
			materialDefault	= index;
			LogSlidingTerrain( "found default sliding terrain parameters in the array" );
		}
		// Create the default material params if none is found
		else
		{
			LogSlidingTerrain( "NOT found default sliding terrain parameters in the array, creating defaults" );
			defaultMaterial.presetName				= materialParamsDefaultN;
			defaultMaterial.angleMin				= angleMinDefault;
			defaultMaterial.angleMinRain			= angleMinDefault;
			defaultMaterial.frictionMultiplier		= 1.0f;
			defaultMaterial.frictionMultiplierRain	= 1.0f;
			
			
			materialParams.PushBack( defaultMaterial );
			materialDefault	= materialParams.Size() - 1;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function WantsToEnterBasic( optional checkingForExit : bool ) : bool
	{
		var dot				: float;
		var coef			: float;
		var result			: bool;
		
		
		// Do we need the cc to want to slide with its damped terrain normal?
		if( useSmothedCoefOnIdle && ( m_ExplorationO.GetStateCur() == 'Idle' || m_ExplorationO.GetStateCur() == 'CombatExploration' ) )
		{
			if( !m_ExplorationO.m_OwnerMAC.IsSliding() )
			{ 
				return false;
			}
		}
		
		// Update the terrain data in case it changed, before getting the new coef
		SetTerrainParameters();
		
		// Get slide coef		
		if( checkingForExit )// Exit hysteresis check
		{
			coef = m_ExplorationO.m_MoverO.GetSlideCoef( true, coefExtraToStop );
		}
		else
		{
			coef = m_ExplorationO.m_MoverO.GetSlideCoef( true );// m_ExplorationO.GetStateCur() == 'WallSlide' );// || m_ExplorationO.GetStateCur() == 'Slide');
		}
		
		// No sliding at all
		if( coef <= 0.0f )
		{
			return false;
		}
		
		
		
		// Special landing requirement
		if( coef < coefToStartBackward )
		{
			if( m_ExplorationO.GetStateCur() == 'Land' )
			{
				return false;
			}
		}		
		
		// Extra requirementd depending on movement direction
		dot = m_ExplorationO.m_InputO.GetInputDirOnSlopeDot();
		if( slideCoefRelatedToInput )
		{
			if( dot <= -dotToStartForward )
			{
				result	=  coef >= coefToStartBackward;
			}
			else if( dot >= dotToStartForward )
			{
				result	= coef >= coefToStartForward;
			}
			else
			{
				result	= coef >= coefToStartCenter;
			}
		}
		else
		{		
			if( dot >= dotToStartForward )
			{
				result	= coef >= coefToStartForward;
			}
			else
			{
				result	=  coef >= coefToStartBackward;
			}
		}
		
		if( !result )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function WantsToEnterWide() : bool
	{
		var coefWideAverage	: float;
		var coefWideGlobal	: float;
		
		
		coefWideGlobal	= m_ExplorationO.m_MoverO.GetSlideWideCoefFromTerrain( false );
		if( coefWideGlobal == 0.0f || coefWideGlobal < coefToStartForward )
		{
			return false;
		}
		
		coefWideAverage	= m_ExplorationO.m_MoverO.GetSlideWideCoefFromTerrain( true );
		if( coefWideAverage == 0.0f || coefWideAverage < coefToStartForward )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function StateWantsToExit() : bool
	{
		if( requireSpeedToExit )
		{
			if( !SpeedAllowsExit() )
			{
				return false;
			}
		}
		
		// then check the rest
		if( WantsToEnterBasic( true ) )
		{
			return false;
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	private function SpeedAllowsExit() : bool
	{
		var dot			: float;
		var speed		: float;
		var slowEnough	: bool;
		
		
		// Decide min speed depending on the input
		speed	= m_ExplorationO.m_MoverO.GetMovementSpeedF();
		dot 	= m_ExplorationO.m_InputO.GetInputDirOnSlopeDot();		
		if( dot <= -dotToStartForward )
		{
			slowEnough	=  speed < speedToExitBackward;
		}
		else if( dot >= dotToStartForward )
		{
			slowEnough	= speed < speedToExitForward;
		}
		else
		{
			slowEnough	= speed < speedToExitCenter;
		}
		
		if( !slowEnough )
		{
			return false;
		}
		
		return true;
	}
	
	
	//---------------------------------------------------------------------------------
	private function UpdateFallCoef( _Dt : float )
	{
		var speed			: float;
		var	slideCoef		: float;
		var	isGoingToFall	: bool		= false;
		
		
		if( !toFallEnabled || m_DeadB )
		{
			return;
		}
		
		//speed		= m_ExplorationO.m_MoverO.GetMovementSpeedF();		
		speed		= VecLength( m_ExplorationO.m_MoverO.GetDisplacementLastFrame() ) / _Dt;
		speed		= ClampF( speed / m_ExplorationO.m_MoverO.GetSlideSpeedMax(), 0.0f, 1.0f );
		slideCoef	= m_ExplorationO.m_MoverO.GetRawSlideCoef( true );	
		if( subState == SSS_Exiting )
		{
			toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
		}
		else
		{
			if( slideCoef >= toFallSlopeCoefMin && speed >= toFallSlopeSpeedMin && m_ExplorationO.GetStateTimeF() > toConsiderFallTimeTotal )
			{	
				toFallTimeCur	+= _Dt;
				isGoingToFall	= true;
				ApplySlideDamage( _Dt );
				//LogChannel( 'ExplorationSlide', "toFallTimeCur: " + toFallTimeCur + "speed: " + speed + " slideCoef: " + slideCoef );
			}
			else
			{
				toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
			}
		}
		
		// Fall
		if( toFallTimeCur >= toFallTimeTotal )
		{
			// Set him to fall and die
			//m_ExplorationO.SendAnimEvent( behTripToDeath );
			/*
			thePlayer.SetKinematic( false );
			SetProperCameraAnim( false );
			m_DeadB	= true;
			*/
		}
		
		// Speed
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( isGoingToFall );	
		
		
		// Camera		
		SetProperCameraAnim( slideCoef >= toFallSlopeCoefMin );
	}
	
	//---------------------------------------------------------------------------------
	private function ApplySlideDamage( _Dt : float )
	{
		var action			: W3DamageAction;
		
		var damageValue		: float;
		
		
		action = new W3DamageAction in this;
		action.Initialize(NULL, thePlayer, NULL, "SlidingDamage", EHRT_None, CPS_Undefined, false, false, false, true);
		action.SetCanPlayHitParticle(false);
		damageValue	= toFallTimeCur / toFallTimeTotal * thePlayer.GetMaxHealth() * _Dt;
		action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, damageValue );
		
		theGame.damageMgr.ProcessAction( action );
		
		delete action;
	}
	
	//---------------------------------------------------------------------------------
	private function SetProperCameraAnim( increasing : bool )
	{
		var camera 		: CCustomCamera = theGame.GetGameCamera();
		var animation	: SCameraAnimationDefinition;
		var newState	: ESlideCameraShakeState;
		
		// Get the new state		
		
		/*if( increasing )
		{
			newState = SCSS_Hard;
		}
		else*/ if( toFallTimeCur > 0.0f )
		{
			//newState = SCSS_Soft;
			newState = SCSS_Hard;
		}
		else
		{
			newState = SCSS_None;
		}
		
		// did the camera change?
		if( cameraShakeState == newState )
		{
			return;
		}
		
		cameraShakeState	= newState;
		switch( cameraShakeState )
		{
			case SCSS_Hard:
				animation.weight = 4.0f ;
				break;
			case SCSS_Soft:
				StopCameraAnim();
				animation.weight = 1.2f;
				break;
			case SCSS_None:
				StopCameraAnim();
				return;
				break;
		}
		animation.animation = cameraAnimName;
		animation.priority = CAP_High;
		animation.blendIn = 0.1f;
		animation.blendOut = 0.1f;
		animation.speed = 3.0f;
		animation.additive = true;
		animation.reset = false;
		animation.loop = true;
		
		camera.PlayAnimation( animation );
	}
	
	//---------------------------------------------------------------------------------
	private function StopCameraAnim()
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		
		camera.StopAnimation( cameraAnimName );
	}
	
	//---------------------------------------------------------------------------------
	protected  function CheckLandingDamage()
	{
		var fallDiff		: float;
		var jumpTotalDiff	: float;
		var damagePerc		: float;
		
		
		// Get the falling heights
		m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
		
		
		// Apply Damage
		damagePerc		= m_ExplorationO.m_OwnerE.ApplyFallingDamage( fallDiff, true );
		
		
		// Reset fall height
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();
		
		
		// Death Ragdoll?
		if( damagePerc >= 1.0f )
		{
			m_ExplorationO.m_SharedDataO.GoToRagdoll();
		}
		
		// Log
		LogExploration( "Landed height difference " + jumpTotalDiff );
		if ( damagePerc >= 1.0f )
		{
			LogExploration( "DEAD from falling" );
		}
		else if( damagePerc > 0.0f )
		{
			LogExploration( "Damaged: " + damagePerc * 100.0f + "%" );
		}
		else
		{
			LogExploration( "Not Damaged from falling" );
		}
	}
 
	//---------------------------------------------------------------------------------
	private function SetTerrainParameters()
	{
		var	newMaterial			: name;
		var isItRaining			: bool;
		
		// HACK for wallslide
		if( !updateMaterials )
		{
			return;
		}
		
		// Get the material
		newMaterial		= m_ExplorationO.m_OwnerMAC.GetMaterialName();
		
		// No material, no change
		if( newMaterial == 'None' )
		{
			LogSlidingTerrain( "!!!! Error: No material found" );
			return;
		}
		
		// Do not set the same material
		if( newMaterial	== materialNameCur	)
		{
			return;
		}
		
		materialNameCur	= newMaterial;
		
		LogSlidingTerrain( "Ground material changed: " + materialNameCur );
		
		
		// Find material Id
		materialCurId	= FindMaterialId( materialNameCur );
		
		// Save it to shared data
		m_ExplorationO.m_SharedDataO.terrainSlidePresetName	= materialParams[materialCurId].presetName;
		
		// TODO: Check if it is raining
		
		// Set the params
		if( isItRaining )
		{
			m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMin, materialParams[materialCurId].frictionMultiplier );
		}
		else
		{
			m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMinRain, materialParams[materialCurId].frictionMultiplierRain );
		}		
	}
	
	//---------------------------------------------------------------------------------
	private function FindMaterialId( materialName : name ) : int
	{
		var presetName		: name;
		var maxCount		: int;
		var i				: int;
		
		// Find preset name		
		maxCount	= materialNamesToPresets.Size();
		for ( i = 0; i < maxCount; i += 1 )
		{
			if( materialName == materialNamesToPresets[i].materialName )
			{
				presetName	= materialNamesToPresets[i].presetName;
				LogSlidingTerrain( "Material preset corresponding to name " + materialName + " found, named " + presetName );
				break;
			}
		}
		// Preset not found
		if( i >= maxCount )
		{
			LogSlidingTerrain( "Material preset corresponding to this material name ( " + materialName + " ) name not found, using default preset" );
			return materialDefault;
		}
		
		// Find the preset params
		return FindPresetByName( presetName );
	}
	
	//---------------------------------------------------------------------------------
	private function FindPresetByName( presetName : name ) : int
	{
		var maxCount		: int;
		var i				: int;
		
		// Find the preset params
		maxCount	= materialParams.Size();
		for ( i = 0; i < maxCount; i += 1 )
		{
			if( presetName == materialParams[i].presetName )
			{
				LogSlidingTerrain( "Material presset " + presetName + " found" );
				return i;
			}
		}
		
		LogSlidingTerrain( "!!!ERROR: The preset name " + presetName + " does not exist in the array materialParams" );
		
		return materialDefault;
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateForcedDirection( slideDir : Vector)
	{	
		var jumpDirection	: Vector;
		
		
		switch( subState )
		{
			case SSS_Entering:
				jumpDirection		= slideDir;
			break;
			case SSS_Sliding:		
			case SSS_HardSliding:
				jumpDirection		= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
			break;
			case SSS_Exiting:	
			case SSS_Exited:	
				jumpDirection		= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
			break;
		}
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= jumpDirection;
	}
	
	//---------------------------------------------------------------------------------
	private function ComputeOrientingSpeed( slideCoef : float ) : float
	{	
		var speed	: float;
		
		switch( subState )
		{
			case SSS_Entering:
				speed = orientingInitial;
			break;
			case SSS_Sliding:	
			case SSS_HardSliding:	
				speed =  MapF( slideCoef, 0.0f, orientingMaxSlope, orientingSpeedMin, orientingSpeedMax );
			break;
			case SSS_Exiting:	
				speed =  MapF( slideCoef, 0.0f, orientingMaxSlope, orientingSpeedMin, orientingSpeedMax );
			break;
			default :				
				LogExplorationError("Missing state in ComputeOrientingSpeed function in script explorationStateSlide.ws");
				speed = orientingInitial;
		}
		
		// Control improvement
		if( m_ExplorationO.m_InputO.IsSprintPressed() )
		{
			speed	*= 0.5f;
		}
		
		return speed;		
	}	
	
	//---------------------------------------------------------------------------------
	private function SubstateChangePrecheck( _Dt : float )
	{	
		// Land specific slide
		if( landCoolingDown )
		{
			// Allaws for instant exit
			if( StateWantsToExit() )
			{
				subState		= SSS_Exited;
				return;
			}
			if( m_ExplorationO.GetStateTimeF() >= landCoolDownTime )
			{
				landCoolingDown	= false;
			}
		}
		
		switch( subState )
		{
			case SSS_Entering:
				if( m_ExplorationO.GetStateTimeF() >= minTimeToIdle )
				{
					subState	= SSS_Sliding;
				}
				break;
			case SSS_Sliding:	
				if( m_ExplorationO.GetStateTimeF() >= timeToHardSlide )
				{
					subState			= SSS_HardSliding;
					lockedOnHardSliding	= true;
					m_ExplorationO.SendAnimEvent( behGraphEventSlideHard );
				}
				break;
			case SSS_HardSliding :
				if( StateWantsToExit() )
				{
					subState		= SSS_Exiting;
					m_ExplorationO.SendAnimEvent( behSlideEnd );
					exitingTimeCur	= 0.0f;
				}	
				break;
			case SSS_Exiting:
				if( WantsToEnterBasic() )
				{
					subState		= SSS_Sliding;
					m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
					m_ExplorationO.SendAnimEvent( behSlideRestart );
				}
				else
				{
					exitingTimeCur	+= _Dt;
					if( exitingTimeCur > 0.2f )
					{					
						m_ExplorationO.m_MoverO.SetSlidingParams( movementStoppingParams );
					}
					if( exitingTimeCur > exitingTimeTotalInput )
					{
						// By moving the character we can stop it faster
						if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
						{
							subState	= SSS_Exited;
						}
						if( exitingTimeCur > exitingTimeTotal )
						{
							subState	= SSS_Exited;
						}
					}
				}
				break;
			case SSS_Exited:
				break;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function UpdateAngleToRotateToAdaptToSlope( slideDirection : Vector, _Dt : float )
	{
		var world 				: CWorld;
		var res 				: bool		= false;
		var bonePos				: Vector;
		var boneIdlePos			: Vector;
		var boneRayOrigin		: Vector;
		var boneRayEnd			: Vector;
		var slideNormal			: Vector;
		var pos					: Vector;
		var normal				: Vector;
		var boneDist			: float;
		var boneHeight			: float;
		
		var IKSucceeded			: bool		= false;
		var	newInclination		: float;
		
		/*
		world	= theGame.GetWorld();
		if( world )
		{
			bonePos			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneToStickId );
			//slideNormal		= VecCross( slideDirection, Vector( 0.0f, 0.0f, 1.0f ) );
			//slideNormal		= VecCross( slideDirection, boneRayEnd );
			slideNormal		= Vector( 0.0f, 0.0f, 1.0f );
			boneRayOrigin	= bonePos - slideNormal * 0.5f;
			boneRayEnd		= bonePos + slideNormal * 0.5f;
			res				= world.StaticTrace( boneRayOrigin, boneRayEnd, pos, normal );
			if( res )
			{
				boneDist	= VecDistance( bonePos, m_ExplorationO.m_OwnerE.GetWorldPosition() );
				boneIdlePos	= m_ExplorationO.m_OwnerE.GetWorldPosition() - m_ExplorationO.m_OwnerE.GetWorldForward() * boneDist;
				boneHeight	= VecDistance( boneIdlePos, pos );
				// C2 = A2 + B2 - 2*A*B*Cos(c)
				// c = ACos( (A2 + B2 - C2 ) / 2AB )
				// inclination = ACos( ( boneDist * boneDist + boneDist * boneDist - boneHeight * boneHeight) / ( 2 * boneDist * boneDist ) )
				// inclination = ACos( 1 - boneHeight * boneHeight  / ( 2 * boneDist * boneDist ) )
				
				newInclination = AcosF( 1.0f - boneHeight * boneHeight  / ( 2.0f * boneDist * boneDist ) );
				
				IKSucceeded	= true;
			}
		}
		*/
		// If we don't have IK, then, use the slope
		if( true )//if( !IKSucceeded )
		{
			// Angle from coef
			//newInclination = -20.0f -( 0.2f + ( slideCoef * 0.8f ) ) * 90.0f;
			newInclination = m_ExplorationO.m_MoverO.GetRealSlideAngle( );
		}
		
		if( inclinationEnterTimeCur <= 0.0f )
		{
			inclination = BlendLinearF( inclination, newInclination, inclinationBlendSpeed * _Dt );
		}
		else
		{
			inclination = BlendLinearF( inclination, newInclination, 1.0f - inclinationEnterTimeCur / inclinationEnterTimeMax );
			inclinationEnterTimeCur	-= _Dt;
		}
		
		//inclination = newInclination;
		
		// Set it to the behabior graph
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behInclinationVar, inclination );
		
		// Add the extra height to avoid clipping
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behHeightVar, 0.1f );
	}
	
	//---------------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == animEventHardSliding )
		{
			lockedOnHardSliding	= true;
		}
		
		else if( animEventName == 'DisableFeetIK' )
		{
			// Special IK at the moment
			//m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( true );
		}
	}
	
	//---------------------------------------------------------------------------------
	// Collision events
	//---------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------
	private function UpdateCollisions()
	{
	}
	
	//---------------------------------------------------------------------------------
	function ReactToLoseGround() : bool
	{
		if( subState > SSS_Entering )
		{
			SetReadyToChangeTo( 'StartFalling' );
		}
		
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function ReactToHitGround() : bool
	{		
		return true;
	}	
	
	//---------------------------------------------------------------------------------
	function ReactToSlide() : bool
	{
		return true;
	}
	
	//---------------------------------------------------------------------------------
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		frame.DrawText( "Slide To Fall: " + toFallTimeCur * 100 + "%", m_ExplorationO.m_OwnerE.GetWorldPosition() + Vector( 0.0f, 0.0f, 1.3f ) , Color( 80, 200, 80 ) );
	}
}
