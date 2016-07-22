/*
enum EFocusModeCameraDirector_SelectSpot_State // I don't want to have special state machine here ( with several objects inside ). It is too simple.
{
	FMCD_SS_Init,
	FMCD_SS_Normal,
	FMCD_SS_NormalFar,
	FMCD_SS_Eye,
	FMCD_SS_LookAt,
}

enum EFocusModeCameraDirector_SelectSpot_Transition
{
	FMCD_SST_None,
	FMCD_SST_InitToNormal,
	FMCD_SST_InitToNormalFar,
	FMCD_SST_NormalToEye,
	FMCD_SST_EyeToNormal,
	FMCD_SST_EyeToLookAt,
	FMCD_SST_LookAtToEye,
	FMCD_SST_LookAtToNormal,
}

enum EFocusModeCameraDirector_SelectSpot_DaVinciState
{
	FMCD_SSD_Off,
	FMCD_SSD_On,
	FMCD_SSD_Act,
	FMCD_SSD_Deact,
	FMCD_SSD_Switch,
	FMCD_SSD_SwitchAct,
	FMCD_SSD_SwitchDeact,
}

class FocusModeCameraDirector_SelectSpot
{
	var vState : W3PlayerWitcherStateCombatFocusMode_SelectSpot;
	var player : W3PlayerWitcher;
	var enemy : CNewNPC;
	var enemyBoneIdx, playerBoneIdx : int;
	
	var shotHelper : FocusModeCameraShotHelper;
	
	var currState : EFocusModeCameraDirector_SelectSpot_State;
	var currSlot : int;
	
	var transition : EFocusModeCameraDirector_SelectSpot_Transition;
	var transitionMC : CFocusModeCombatCamera_CurveDamp_MC;
	var transitionPC : CFocusModeCombatCamera_CurveDamp_PC;
	var transitionSlot : int;
	
	var daVinciState : EFocusModeCameraDirector_SelectSpot_DaVinciState;
	var daVinciPosition : Vector;
	var daVinciSwitchPosition : Vector;
	var daVinciProgress : float;
	
	var prevCamera_MovementController : name;
	var prevCamera_PivotController : name;
	
	default currState = FMCD_SS_Init;
	default transition = FMCD_SST_None;
	default daVinciState = FMCD_SSD_Off;
	
	public function Init( s : W3PlayerWitcherStateCombatFocusMode_SelectSpot, p : W3PlayerWitcher )
	{
		Reset();
		
		vState = s;
		player = p;
		
		if ( !shotHelper )
		{
			shotHelper = new FocusModeCameraShotHelper in this;
		}
	}
	
	public function Deinit()
	{
		Reset();
	}

	public function Activate( e : CNewNPC )
	{
		enemy = e;
		
		shotHelper.Init( enemy, player );
		
		enemyBoneIdx = enemy.GetBoneIndex( 'pelvis' );
		playerBoneIdx = player.GetBoneIndex( 'pelvis' );
		
		GoToState( FMCD_SS_Normal );
	}

	public function ActivateFar( e : CNewNPC )
	{
		enemy = e;
		
		shotHelper.Init( enemy, player );
		
		GoToState( FMCD_SS_NormalFar );
	}
	
	public function Update( dt : float )
	{
		ProgressDaVinciEffect();
		
		if ( IsTransitionActive() )
		{
			CheckTransition();
		}
		
		UpdateCurrState( dt );
	}
	
	public function Deactivate()
	{
		shotHelper.Deinit();
		
		BackToCachedCameraControllers();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function EyeView() : bool
	{
		return GoToState( FMCD_SS_Eye );
	}
	
	public final function NormalView() : bool
	{
		return GoToState( FMCD_SS_Normal );
	}
	
	public final function NormalViewFar() : bool
	{
		return GoToState( FMCD_SS_NormalFar );
	}
	
	public function LookAtView( spotId : int ) : bool
	{
		if ( spotId == currSlot )
		{
			return false;
		}
		
		transitionSlot = spotId;
		return GoToState( FMCD_SS_LookAt );
	}
	
	public final function IsInEyeView() : bool
	{
		return !IsTransitionActive() && currState == FMCD_SS_Eye;
	}
	
	public final function IsInNormalView() : bool
	{
		return !IsTransitionActive() && currState == FMCD_SS_Normal;
	}
	
	public final function IsInNormalFarView() : bool
	{
		return !IsTransitionActive() && currState == FMCD_SS_NormalFar;
	}
	
	public function IsInLookAtView( spotId : int ) : bool
	{
		return !IsTransitionActive() && currState == FMCD_SS_LookAt && currSlot == spotId;
	}
	
	public function IsInAnyLookAtView() : bool
	{
		return !IsTransitionActive() && currState == FMCD_SS_LookAt;
	}
	
	public function GetLookAtViewSpot() : int
	{
		return currSlot;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function GoToState( newState : EFocusModeCameraDirector_SelectSpot_State ) : bool
	{	
		if ( IsTransitionActive() )
		{
			return false;
		}
		
		if ( newState != currState )
		{
			FinishCurrState();
		}
		
		switch ( currState )
		{
			case FMCD_SS_Init:
				{
					if ( newState == FMCD_SS_Normal ) 
					{ 
						Transition_InitToNormal(); 
						return true; 
					}
					else if ( newState == FMCD_SS_NormalFar ) 
					{ 
						Transition_InitToNormalFar(); 
						return true; 
					}
					break;
				}
			
			case FMCD_SS_Normal:
				{
					if ( newState == FMCD_SS_Eye ) 
					{
						Transition_NormalToEye(); 
						return true;
					}
					break;
				}
			
			case FMCD_SS_NormalFar:
				{
					break;
				}
				
			case FMCD_SS_Eye:
				{
					if ( newState == FMCD_SS_Normal )
					{
						Transition_EyeToNormal(); 
						return true;
					}
					else if ( newState == FMCD_SS_LookAt )
					{
						Transition_EyeToLookAt();
						return true;
					}
					break;
				}
			
			case FMCD_SS_LookAt:
				{
					if ( newState == FMCD_SS_Eye )
					{
						Transition_LookAtToEye(); 
						return true;
					}
					else if ( newState == FMCD_SS_Normal )
					{
						Transition_LookAtToNormal(); 
						return true;
					}
					else if ( newState == FMCD_SS_LookAt )
					{
						Transition_LookAtToLookAt(); 
						return true;
					}
					break;
				}
		}
		
		Error();
		
		return false;
	}
	
	private final function IsTransitionActive() : bool
	{
		return transition != FMCD_SST_None;
	}
	
	private final function Error()
	{
		var errorCode : int;
		errorCode = 0;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function CheckTransition()
	{
		var transitionToCheck : EFocusModeCameraDirector_SelectSpot_Transition;
		var finished : bool;
		
		finished = true;
		
		if ( transition == FMCD_SST_None )
		{
			Error();
		}
		
		if ( transitionMC && transitionMC.IsInterpolating() )
		{
			finished = false;
		}
		if ( transitionPC && transitionPC.IsInterpolating() )
		{
			finished = false;
		}
		
		if ( finished )
		{
			currSlot = transitionSlot;
			
			transitionMC = NULL;
			transitionPC = NULL;
			transitionSlot = -1;
			
			transitionToCheck = transition;
			transition = FMCD_SST_None;
			
			GoToTransitionDest( transitionToCheck );
		}
	}
	
	private final function GoToTransitionDest( t : EFocusModeCameraDirector_SelectSpot_Transition )
	{
		switch ( t )
		{
			case FMCD_SST_InitToNormal: 	GoToState_NormalView(); return;
			case FMCD_SST_InitToNormalFar:	GoToState_NormalViewFar(); return;
			case FMCD_SST_NormalToEye: 		GoToState_EyeView(); return;
			case FMCD_SST_EyeToNormal: 		GoToState_NormalView(); return;
			case FMCD_SST_EyeToLookAt: 		GoToState_LookAtView(); return;
			case FMCD_SST_LookAtToEye: 		GoToState_EyeView(); return;
			case FMCD_SST_LookAtToNormal: 	GoToState_NormalView(); return;
		}
		
		Error();
	}
	
	private final function Transition_InitToNormal()
	{
		var currHeading : float;
		
		if ( currState != FMCD_SS_Init ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_Normal;
		transition = FMCD_SST_InitToNormal;
		
		CacheCameraControllers();
		
		{
			//TODO MR: 
			currHeading = theGame.GetGameCamera().GetHeading();
			shotHelper.FindInitShotParams( currHeading );
			
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_MC' );
			
			Set_NormalShot( true );
		}
		
		CacheTransitionControllers();
	}
	
	private final function Transition_InitToNormalFar()
	{
		var currHeading, heading, distance, pitch : float;
		var position, currPosition, pivot : Vector;
			
		if ( currState != FMCD_SS_Init ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_NormalFar;
		transition = FMCD_SST_InitToNormalFar;
		
		CacheCameraControllers();
		
		{
			//TODO MR: 
			currHeading = theGame.GetGameCamera().GetHeading();
			shotHelper.FindInitShotParams( currHeading );
			
			position = CalcPivotPosition();	
			shotHelper.FindSSShotParams( position );
			
			// 1. Change pivot controller before distance calculations
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_PC' );
			theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( shotHelper.ssShot_pivot );
			
			// 2. Change movement controller
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_MC' );
			theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( shotHelper.ssShot_yaw );
			//TODO MR: 
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( shotHelper.ssShot_distance );
			theGame.GetGameCamera().GetActiveMovementController().SetDesiredPitch( shotHelper.ssShot_pitch );
		}
		
		CacheTransitionControllers();
	}
	
	private final function Transition_NormalToEye()
	{
		var yaw, distance, pitch : float;
		var pivot, dir, ePos, pPos, offset : Vector;
		var mat : Matrix;
		
		if ( currState != FMCD_SS_Normal ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_Eye;
		transition = FMCD_SST_NormalToEye;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_2_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_2_MC' );
			
			Set_EyeShot();
		}
		
		CacheTransitionControllers();
	}
	
	private final function Transition_EyeToNormal()
	{
		if ( currState != FMCD_SS_Eye ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_Normal;
		transition = FMCD_SST_EyeToNormal;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_3_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_3_MC' );
			
			Set_NormalShot( false );
		}
		
		CacheTransitionControllers();
	}
	
	private final function Transition_EyeToLookAt()
	{
		var distance : float;
		var pivot, slotPosition : Vector;
		var ret : bool;
		
		if ( currState != FMCD_SS_Eye ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_LookAt;
		transition = FMCD_SST_EyeToLookAt;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_4_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_4_MC' );
			
			Set_LookAtShot( transitionSlot );
		}
		
		CacheTransitionControllers();
		
		if ( ret )
		{
			ActivateDaVinciEffect( slotPosition );
		}
	}
	
	private final function Transition_LookAtToEye()
	{
		if ( currState != FMCD_SS_LookAt ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_Eye;
		transition = FMCD_SST_LookAtToEye;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_4_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_4_MC' );
			
			Set_EyeShot();
		}
		
		CacheTransitionControllers();
		
		DeactivateDaVinciEffect();
	}
	
	private final function Transition_LookAtToNormal()
	{
		if ( currState != FMCD_SS_LookAt ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_Normal;
		transition = FMCD_SST_LookAtToNormal;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_3_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_3_MC' );
			
			Set_NormalShot( false );
		}
		
		CacheTransitionControllers();
		
		DeactivateDaVinciEffect();
	}
	
	private final function Transition_LookAtToLookAt()
	{
		var distance, distToNewSlot : float;
		var pivot, slotPositionA, slotPositionB : Vector;
		var retA, retB : bool;
		var mc : CFocusModeCombatCamera_LookAtToLookAt_MC;
		
		if ( currState != FMCD_SS_LookAt ) Error();
		if ( transition != FMCD_SST_None ) Error();
		
		currState = FMCD_SS_LookAt;
		transition = FMCD_SST_EyeToLookAt;
		
		{
			theGame.GetGameCamera().ChangePivotController( 'ComFocusMode_SS_5_PC' );
			theGame.GetGameCamera().ChangeMovementController( 'ComFocusMode_SS_LookAtToLookAt_MC' );
			
			if ( transitionSlot != -1 || currSlot != -1 )
			{
				retA = vState.GetSlotPositionByID( transitionSlot, slotPositionA );
				retB = vState.GetSlotPositionByID( currSlot, slotPositionB );
				if ( retA || retB )
				{
					distToNewSlot = VecDistance( slotPositionA, slotPositionB );
					
					//TODO MR: 
					//mc = (CFocusModeCombatCamera_LookAtToLookAt_MC)theGame.GetGameCamera().GetActiveMovementController();
					if ( mc )
					{
						mc.SetDistanceToSlot( distToNewSlot );
					}
				}
			}
			
			Set_LookAtLookAtShot();
		}
		
		CacheTransitionControllers();
		
		if ( retB )
		{
			SwitchDaVinciEffect( slotPositionB );
		}
		else
		{
			DeactivateDaVinciEffect();
		}
	}
	
	private function GetSlotPositionOffsetForLookAt() : Vector
	{
		var ePos 	: Vector;
		var pPos	: Vector;
		var dir 	: Vector;
		var yaw 	: float;
		var mat		: Matrix;
		var offset	: Vector;
		
		ePos = enemy.GetWorldPosition();
		pPos = player.GetWorldPosition();

		dir = VecNormalize( ePos - pPos );
		yaw  = VecHeading( dir );
		
		mat = MatrixBuildFromDirectionVector( dir );
		offset = Vector( 0.3f, 0.f, 0.f );
		offset = VecTransformDir( mat, offset );
		
		return offset;			
	}
	
	private function GetSlotDistanceOffsetForLookAt() : float
	{
		return 0.85f;			
	}

	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function FinishCurrState()
	{
		switch ( currState )
		{
			case FMCD_SS_Init: 		return;
			case FMCD_SS_Normal: 	GoOutFromState_NormalView(); return;
			case FMCD_SS_NormalFar: GoOutFromState_NormalViewFar(); return;
			case FMCD_SS_Eye: 		GoOutFromState_EyeView(); return;
			case FMCD_SS_LookAt: 	GoOutFromState_LookAtView(); return;
		}
		
		Error();
	}
	
	private final function GoToState_NormalView()
	{
		if ( currState != FMCD_SS_Normal || IsTransitionActive() )
		{
			Error();
		}
	}
	
	private final function GoToState_NormalViewFar()
	{
		if ( currState != FMCD_SS_NormalFar || IsTransitionActive() )
		{
			Error();
		}
	}
	
	private final function GoToState_EyeView()
	{
		if ( currState != FMCD_SS_Eye || IsTransitionActive() )
		{
			Error();
		}
	}
	
	private final function GoToState_LookAtView()
	{
		if ( currState != FMCD_SS_LookAt || IsTransitionActive() )
		{
			Error();
		}
	}
	
	private final function GoOutFromState_NormalView()
	{
		
	}
	
	private final function GoOutFromState_NormalViewFar()
	{
		
	}
	
	private final function GoOutFromState_EyeView()
	{
		
	}
	
	private final function GoOutFromState_LookAtView()
	{
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function UpdateCurrState( dt : float )
	{
		if ( IsTransitionActive() )
		{
			switch ( transition )
			{
				case FMCD_SST_InitToNormal: 	{ UpdateTransition_InitToNormal( dt ); return; }
				case FMCD_SST_InitToNormalFar:	{ UpdateTransition_InitToNormalFar( dt ); return; }
				case FMCD_SST_NormalToEye: 		{ UpdateTransition_NormalToEye( dt ); return; }
				case FMCD_SST_EyeToNormal: 		{ UpdateTransition_EyeToNormal( dt ); return; }
				case FMCD_SST_EyeToLookAt: 		{ UpdateTransition_EyeToLookAt( dt ); return; }
				case FMCD_SST_LookAtToEye: 		{ UpdateTransition_LookAtToEye( dt ); return; }
				case FMCD_SST_LookAtToNormal: 	{ UpdateTransition_LookAtToNormal( dt ); return; }
			}
		}
		else
		{
			switch ( currState )
			{
				case FMCD_SS_Init: 		{ UpdateState_Init( dt ); return; }
				case FMCD_SS_Normal: 	{ UpdateState_Normal( dt ); return; }
				case FMCD_SS_NormalFar: { UpdateState_NormalFar( dt ); return; }
				case FMCD_SS_Eye: 		{ UpdateState_Eye( dt ); return; }
				case FMCD_SS_LookAt: 	{ UpdateState_LookAt( dt ); return; }
			}
		}
		
		Error();
	}
	
	private final function UpdateTransition_InitToNormal( dt : float )
	{
		//Update_NormalShot();
	}
	
	private final function UpdateTransition_InitToNormalFar( dt : float )
	{
	}
	
	private final function UpdateTransition_NormalToEye( dt : float )
	{
		Update_EyeShot();
	}
	
	private final function UpdateTransition_EyeToNormal( dt : float )
	{
		//Update_NormalShot();
	}
	
	private final function UpdateTransition_EyeToLookAt( dt : float )
	{
		Update_LookAtShot( transitionSlot );
	}
	
	private final function UpdateTransition_LookAtToEye( dt : float )
	{
		Update_EyeShot();
	}
	
	private final function UpdateTransition_LookAtToNormal( dt : float )
	{
		//Update_NormalShot();
	}
	
	private final function UpdateState_Init( dt : float )
	{
	}
	
	private final function UpdateState_Normal( dt : float )
	{
		//Update_NormalShot();
	}
	
	private final function UpdateState_NormalFar( dt : float )
	{
	}
	
	private final function UpdateState_Eye( dt : float )
	{
		Update_EyeShot();
	}
	
	private final function UpdateState_LookAt( dt : float )
	{
		Update_LookAtShot( currSlot );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function ApplyShot4( toSet : bool, pivot : Vector, yaw, pitch, distance : float )
	{
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var pc : CFocusModeCombatCamera_CurveDamp_PC;
		
		if ( toSet )
		{
			theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( pivot );
			theGame.GetGameCamera().GetActiveMovementController().SetDesiredHeading( yaw );
			theGame.GetGameCamera().GetActiveMovementController().SetDesiredPitch( pitch );
			//TODO MR: 
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( distance );
		}
		else
		{
			//TODO MR: 
			//pc = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
			//mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
			
			if ( pc && mc )
			{
				pc.ResetValue( pivot );
				mc.ResetValues( yaw, pitch, distance );
			}
		}
	}
	
	private final function ApplyShot2( toSet : bool, pivot : Vector, distance : float )
	{
		var mc : CFocusModeCombatCamera_CurveDamp_MC;
		var pc : CFocusModeCombatCamera_CurveDamp_PC;
		
		if ( toSet )
		{
			theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( pivot );
			//TODO MR: 
			//theGame.GetGameCamera().GetActiveMovementController().SetDesiredDistance( distance );
		}
		else
		{
			//pc = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
			//mc = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
			
			if ( pc && mc )
			{
				pc.ResetValue( pivot );
				mc.ResetDistanceValue( distance );
			}
		}
	}
	
	private final function Calc_NormalShot( toSet : bool, init : bool )
	{
		var position : Vector;
		
		position = CalcPivotPosition();
		
		if ( !init )
		{
			shotHelper.RefreshSSShotParams( 0.f );
		}
		else
		{
			shotHelper.FindSSShotParams( position );
		}
		
		ApplyShot4( toSet, shotHelper.ssShot_pivot, shotHelper.ssShot_yaw, shotHelper.ssShot_pitch, shotHelper.ssShot_distance );
	}
	
	private final function Set_NormalShot( init : bool )
	{
		Calc_NormalShot( true, init );
	}
	
	private final function Update_NormalShot()
	{
		Calc_NormalShot( false, false );
	}
	
	private final function Calc_EyeShot( toSet : bool )
	{
		var yaw, distance, pitch : float;
		var pivot, dir, ePos, pPos, offset, playerPos : Vector;
		var mat : Matrix;
		
		ePos = MatrixGetTranslation( enemy.GetBoneWorldMatrixByIndex( enemyBoneIdx ) );
		pPos = MatrixGetTranslation( player.GetBoneWorldMatrixByIndex( playerBoneIdx ) );
		
		dir = VecNormalize( ePos - pPos );
		yaw  = VecHeading( dir );
		distance = 1.7f; //2.f;
		pitch = 0.f;
		
		mat = MatrixBuildFromDirectionVector( dir );
		offset = Vector( 0.55f, 0.f, 1.2f );//Vector( 0.6f, 0.f, 1.2f );
		offset = VecTransformDir( mat, offset );
		
		playerPos = player.GetWorldPosition();
		ePos.Z = playerPos.Z;
		pivot = ePos + offset;
		
		ApplyShot4( toSet, pivot, yaw, pitch, distance );
	}
	
	private final function Set_EyeShot()
	{
		Calc_EyeShot( true );
	}
	
	private final function Update_EyeShot()
	{
		Calc_EyeShot( false );
	}
	
	private final function Calc_LookAtShot( toSet : bool, slot : int )
	{
		var distance : float;
		var pivot, slotPosition : Vector;
		var ret : bool;
		
		if ( slot == -1 )
		{
			Error();
		}
		
		ret = vState.GetSlotPositionByID( slot, slotPosition );
		if ( !ret )
		{
			Error();
		}
		else
		{
			distance = GetSlotDistanceOffsetForLookAt();
			pivot = slotPosition + GetSlotPositionOffsetForLookAt();
			
			ApplyShot2( toSet, pivot, distance );
		}
	}
	
	private final function Set_LookAtShot( slot : int )
	{
		Calc_LookAtShot( true, slot );
	}
	
	private final function Update_LookAtShot( slot : int )
	{
		Calc_LookAtShot( false, slot );
	}
	
	private final function Calc_LookAtLookAtShot( toSet : bool )
	{
		var distance : float;
		var pivot, slotPositionA, slotPositionB : Vector;
		var retA, retB : bool;
		
		if ( transitionSlot == -1 || currSlot == -1 )
		{
			Error();
		}
			
		retA = vState.GetSlotPositionByID( transitionSlot, slotPositionA );
		retB = vState.GetSlotPositionByID( currSlot, slotPositionB );
		if ( !retA || !retB )
		{
			Error();
		}
		else
		{
			distance = GetSlotDistanceOffsetForLookAt();
			pivot = slotPositionA + GetSlotPositionOffsetForLookAt();
			
			ApplyShot2( toSet, pivot, distance );
		}
	}
	
	private final function Set_LookAtLookAtShot()
	{
		Calc_LookAtLookAtShot( true );
	}
	
	private final function Update_LookAtLookAtShot()
	{
		Calc_LookAtLookAtShot( false );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function ActivateDaVinciEffect( point : Vector )
	{
		if ( daVinciState != FMCD_SSD_Off )
		{
			Error();
		}
		
		daVinciState = FMCD_SSD_Act;
		daVinciPosition = point;
	}
	
	private final function SwitchDaVinciEffect( point : Vector )
	{
		daVinciState = FMCD_SSD_Switch;
		daVinciSwitchPosition = point;
	}
	
	private final function DeactivateDaVinciEffect()
	{
		if ( daVinciState != FMCD_SSD_On )
		{
			Error();
		}
		
		daVinciState = FMCD_SSD_Deact;
	}
	
	private final function ProgressDaVinciEffect()
	{
		var running : bool;
		
		running = true;
		
		while ( running )
		{
			switch ( daVinciState )
			{
				case FMCD_SSD_Act:
				{
					if ( transitionMC )
					{
						daVinciProgress = transitionMC.GetProgress();
					}
					else
					{
						Error();
					}
					
					if ( daVinciProgress >= 1.f || !transitionMC )
					{
						daVinciState = FMCD_SSD_On;
					}
					else
					{
						running = false;
					}
						
					break;
				}
				
				
				case FMCD_SSD_Deact:
				{			
					if ( transitionMC )
					{
						daVinciProgress = 1.f - transitionMC.GetProgress();
					}
					else
					{
						Error();
					}
					
					if ( daVinciProgress <= 0.f || !transitionMC )
					{
						daVinciState = FMCD_SSD_Off;
					}
					else
					{
						running = false;
					}
						
					break;
				}
				
				
				case FMCD_SSD_On:
				{
					daVinciProgress = 1.f;
					running = false;
					break;
				}
					
					
				case FMCD_SSD_Off:
				{
					daVinciProgress = 0.f;
					running = false;
					break;
				}
					
					
				case FMCD_SSD_Switch:
				{
					daVinciState = FMCD_SSD_SwitchAct;
					
					break;
				}
				
				
				case FMCD_SSD_SwitchAct:
				{
					if ( transitionMC )
					{
						daVinciProgress = 1.f - transitionMC.GetProgress() * 2.f;
					}
					else
					{
						Error();
					}
					
					if ( daVinciProgress <= 0.f || !transitionMC )
					{
						daVinciPosition = daVinciSwitchPosition;
						daVinciSwitchPosition = Vector( 0.f, 0.f, 0.f );
						
						daVinciState = FMCD_SSD_SwitchDeact;
					}
					else
					{
						running = false;
					}
						
					break;
				}
				
				
				case FMCD_SSD_SwitchDeact:
				{
					if ( transitionMC )
					{
						daVinciProgress = transitionMC.GetProgress() * 2.f - 1.f;
					}
					else
					{
						Error();
					}
					
					if ( daVinciProgress >= 1.f || !transitionMC )
					{
						daVinciState = FMCD_SSD_On;
					}
					else
					{
						running = false;
					}
						
					break;
				}
			}
		}
		
		//LogChannel( 'TOMSIN', daVinciProgress );
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	private final function Reset()
	{
		player = NULL;
		enemy = NULL;
		
		currState = FMCD_SS_Init;
		currSlot = -1;
		transition = FMCD_SST_None;
		transitionMC = NULL;
		transitionPC = NULL;
		transitionSlot = -1;
		
		daVinciState = FMCD_SSD_Off;
		daVinciPosition = Vector( 0.f, 0.f, 0.f );
		daVinciSwitchPosition = Vector( 0.f, 0.f, 0.f );
		daVinciProgress = 0.f;
	}
	
	private final function CacheCameraControllers()
	{
		prevCamera_MovementController = theGame.GetGameCamera().GetActiveMovementController().controllerName;
		prevCamera_PivotController = theGame.GetGameCamera().GetActivePivotController().controllerName;
	}
	
	private final function BackToCachedCameraControllers()
	{
		theGame.GetGameCamera().ChangeMovementController( prevCamera_MovementController );
		theGame.GetGameCamera().ChangePivotController( prevCamera_PivotController );
		theGame.GetGameCamera().GetActivePivotController().SetDesiredPosition( CalcPivotPosition() );
	}
	
	private final function CacheTransitionControllers()
	{
		//TODO MR: 
		//transitionPC = (CFocusModeCombatCamera_CurveDamp_PC)theGame.GetGameCamera().GetActivePivotController();
		//transitionMC = (CFocusModeCombatCamera_CurveDamp_MC)theGame.GetGameCamera().GetActiveMovementController();
	}
	
	private final function CalcPivotPosition() : Vector
	{
		var position, mainPos, secPos, dir : Vector;
		var dist2D : float;
	
		mainPos = shotHelper.initShot_mainCharacter.GetWorldPosition();
		secPos = shotHelper.initShot_secCharacter.GetWorldPosition();
		
		dist2D = 0.4f * VecDistance2D( secPos, mainPos );
		dir = VecNormalize( secPos - mainPos );
		
		//if ( dist2D > 15.f )
		//{
		//	dist2D = 15.f;
		//}
		
		position = mainPos + dir * dist2D + Vector( 0.f, 0.f, 0.8f );
		
		return position;
	}
	
	private final function FindCameraParamsFar( out yaw : float, out pitch : float, out distance : float, out pivot : Vector )
	{
		var pointA, pointB, pointC : Vector;
		//var data : SCombatCameraPredData;	
		var factor : float;
		
		if ( shotHelper.initShot_cameraSecSide )
		{
			factor = 1.f;
		}
		else
		{
			factor = -1.f;
		}
		
		pointA = shotHelper.initShot_mainCharacter.GetWorldPosition() + Vector( 0.f, 0.f, 0.9f );
		pointB = pointA + Vector( 0.f, 0.f, 0.9f );
		pointC = shotHelper.initShot_secCharacter.GetWorldPosition() + Vector( 0.f, 0.f, 1.8f );
		
		/*data.inUseCurrentDistance = true;
		
		data.inUseCurrentPivot = true;
		data.inUsePivotDirection = true;
		data.inPivotDirection = VecNormalize( shotHelper.initShot_secCharacter.GetWorldPosition() - shotHelper.initShot_mainCharacter.GetWorldPosition() );
		
		data.inYaw = yaw;
		data.inPitch = -5.f;
		data.inPointA = pointA;
		data.inPointB = pointB;
		data.inPointC = pointC;
		
		data.inPointSsA = Vector( -factor*0.6f,  0.8f, 0.f );
		data.inPointSsB = Vector( -factor*0.6f, -1.0f, 0.f );
		data.inPointSsC = Vector(  factor*0.2f, -0.5f, 0.f );
	
		data.inFactorSsA = Vector( 1.f, 0.4f, 0.f );
		data.inFactorSsB = Vector( 1.f, 0.4f, 0.f );
		data.inFactorSsC = Vector( 1.f, 0.0f, 0.f );*/
		
		//TODO MR: 
		//theGame.GetGameCamera().CalcCameraParams( data );
		
		/*yaw = data.outYaw;
		pitch = data.outPitch;
		distance = data.outDistance;* /
		
		// TODO
		//pivot = data.outPivot;
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

class CFocusModeCombatCamera_LookAtToLookAt_MC extends CFocusModeCombatCamera_CurveDamp_MC
{
	editable var offsetCurveName : name;
	
	var offsetDamper : CurveDamper;
	
	public final function SetDistanceToSlot( dist : float )
	{
		offsetDamper.Init( 0.f, dist );
	}
	
	protected function ControllerGetDistance( out distance : float ) 
	{
		super.ControllerGetDistance( distance );
		
		distance += offsetDamper.GetValue();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////
	
	protected function InternalUpdate( timeDelta : float )
	{
		offsetDamper.Update( timeScale * timeDelta );
		
		super.InternalUpdate( timeDelta );
	}
	
	protected function CheckDampers()
	{
		var curveO : CCurve;
		
		super.CheckDampers();
		
		if ( !offsetDamper )
		{
			//curveO = FindCurve( offsetCurveName );
		
			offsetDamper = new CurveDamper in this;
			offsetDamper.SetCurve( curveO );
		}
	}
	
	protected function GetDistanceForUpdate() : float
	{
		return super.GetDistanceForUpdate() + offsetDamper.GetValue();
	}
}
*/