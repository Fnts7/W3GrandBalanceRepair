/*
state CombatFocusMode_SelectSpot in W3PlayerWitcher extends ExtendedMovable
{		
	var focusModeTarget 		: CNewNPC;
	var focusModeTargetVS 		: array<CVitalSpot>;
	var aSpots					: array<SVitalSpotInfo>;
	var enemyData 				: SCombatFocusModeEnemyData;
	var initialSpotId			: int;
	var cameraDirector			: FocusModeCameraDirector_SelectSpot;
	
	default initialSpotId = -1;

	///////////////////////////////////////////////////////////////////////////////////
	// States events
	
	event OnEnterState( prevStateName : name )
	{
		if ( prevStateName == 'CombatFocusMode_PlayAnimation' )
		{
			parent.PopState();
			return true;
		}

		//disable player hit animations
		thePlayer.SetCanPlayHitAnim(false);
		
		// Create state's objects
		CreateStatesObjects();
		
		// Camera
		cameraDirector.Init( this, parent );
		
		super.OnEnterState( prevStateName );

		// Play sound
		theSound.SoundEvent("cmb_focus_start");
		
		// Add fact for quest condition
		FactsAdd("PlayerUsedFocus");
		
		// Disable player hit animations
		thePlayer.SetCanPlayHitAnim( false );
		
		// Target immortality		
		focusModeTarget.SetImmortalityMode( AIM_Immortal, AIC_CombatFocusMode );
//		parent.AddEffectDefault(EET_FocusSustainCost, NULL, "combat_focus_sustain_cost");
		
		parent.AddTimer( 'CombatComboUpdate', 0, true, false,  TICK_PrePhysics );
		
		// Go to logic entry funtion
		CombatFocusModeLogic();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		// Call clean up function
		CleanUp();
		
		parent.RemoveTimer( 'CombatComboUpdate' );
		
		// Pass to base class
		super.OnLeaveState( nextStateName );
		
		// Stop sound
		theSound.SoundEvent("cmb_focus_stop");
		
		// Remove fact for quest
		FactsRemove("PlayerUsedFocus");
				
		cameraDirector.Deinit();
		
		//enable player hit animations
		thePlayer.SetCanPlayHitAnim(true);
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	
	timer function CombatComboUpdate( timeDelta : float , id : int)
	{
		var s : W3PlayerWitcherStateCombatSteel;
		
		s = (W3PlayerWitcherStateCombatSteel)thePlayer.GetState( 'CombatSteel' );
		if ( s )
		{
			s.HACK_ExternalCombatComboUpdate( timeDelta );
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Public control functions
	
	public final function EyeView() : bool
	{
		return cameraDirector.EyeView();
	}
	
	public final function NormalView() : bool
	{
		return cameraDirector.NormalView();
	}
	
	public final function NormalViewFar() : bool
	{
		return cameraDirector.NormalViewFar();
	}
	
	public function LookAtView( spotId : int ) : bool
	{
		return cameraDirector.LookAtView( spotId );
	}
	
	public final function IsInEyeView() : bool
	{
		return cameraDirector.IsInEyeView();
	}
	
	public final function IsInNormalView() : bool
	{
		return cameraDirector.IsInNormalView();
	}
	
	public final function IsInNormalFarView() : bool
	{
		return cameraDirector.IsInNormalFarView();
	}
	
	public function IsInLookAtView( spotId : int ) : bool
	{
		return cameraDirector.IsInLookAtView( spotId );
	}
	
	public function IsInAnyLookAtView() : bool
	{
		return cameraDirector.IsInAnyLookAtView();
	}

	public function GetLookAtViewSpot() : int
	{
		return cameraDirector.GetLookAtViewSpot();
	}
	
	public final function HereAreTheSpotsToUse( spotIds : array<int> )
	{
		var size, firstSpotId : int;
		var spot : SVitalSpotInfo;
		
		size = spotIds.Size();
		if ( size > 0 )
		{
			parent.LockEntryFunction( true ); // WHY DO WE NEED THIS?
			
			// Get only first slot
			firstSpotId = spotIds[ 0 ];
			
			spot = aSpots[ firstSpotId ];
			
			// Setup state
			((W3PlayerWitcherStateCombatFocusMode_PlayAnimation)parent.GetState('CombatFocusMode_PlayAnimation')).SetupState( spot );
			
			// Calc and add focus cost
			CalcAndAddFocusCost( spotIds );
			
			parent.LockEntryFunction( false ); // WHY DO WE NEED THIS?
			
			// Go to next state => PlayAnimation
			parent.PushState( 'CombatFocusMode_PlayAnimation' );
		}
		else
		{
			LogChannel('FocusMode', "Error: No vital spots have been selected for execution!!!" );
		}
	}
	
	public final function GetSlotPositionByID( slotId : int, out position : Vector ) : bool
	{
		var spot : SVitalSpotInfo;
		var slotMatrix : Matrix;
		
		if ( slotId >= 0 && slotId < aSpots.Size() )
		{
			spot = aSpots[ slotId ];
						
			spot.owner.CalcEntitySlotMatrix( spot.ambientSound.slotName, slotMatrix );
			position = MatrixGetTranslation( slotMatrix );
			
			return true;
		}
		
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Latent and entry functions
	
	entry function CombatFocusModeLogic()
	{
		var initialTarget : CNewNPC;
		
		parent.LockEntryFunction( true ); // WHY DO WE NEED THIS?
		
		SetGameplayStuff();
		
		// Play sounds
		theSound.ChangeSoundState( 'combat', 'focus_combat' );
		theSound.SoundParameter( 'focus_active', 10.0f );
		
		// Find initial target for focus mode
		initialTarget = (CNewNPC)parent.target;
		SetFocusModeTarget( initialTarget );

		// Activate camera
		if( VecDistance( parent.GetWorldPosition(), focusModeTarget.GetWorldPosition() ) > 6.f )
			cameraDirector.ActivateFar( focusModeTarget );
		else
			cameraDirector.Activate( focusModeTarget );
		
		// Update timer
		parent.AddTimer( 'Timer_UpdateState', 0.0005f, true );
		
		parent.LockEntryFunction( false ); // WHY DO WE NEED THIS?
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	// Logic
	
	private final function CleanUp()
	{
		// Enable player hit animations
		thePlayer.SetCanPlayHitAnim( true );
		
		// Target immortality		
		focusModeTarget.SetImmortalityMode( AIM_None, AIC_CombatFocusMode );
		
		//cfm stamina cost
		//parent.RemoveBuff(EET_FocusSustainCost);
		
		// Deativate camera
		cameraDirector.Deactivate();
			
		// Remove update timer
		parent.RemoveTimer( 'Timer_UpdateState' );
		
		// Sounds
		theSound.ChangeSoundState( 'combat', '' );
		theSound.SoundParameter( 'focus_active', 0.0f );
		
		// Reset all variables
		focusModeTarget = NULL;
		focusModeTargetVS.Clear();
		aSpots.Clear();
		initialSpotId = -1;
		
		ResetGameplayStuff();			
	}
	
	private final function SetGameplayStuff()
	{
		parent.EnableFindTarget( false );
		
		//parent.effectManager.SwitchCameraEffects()
		
		theGame.SetTimeScale( theGame.params.CFM_SLOWDOWN_RATIO, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On) );
	}
	
	private final function ResetGameplayStuff()
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_CFM_On) );
		
		parent.switchFocusModeTargetAllowed = true;
		
		parent.EnableFindTarget( true ); 
			
		parent.LockEntryFunction( false );
	}
	
	private final function CreateStatesObjects()
	{
		if ( !cameraDirector )
		{
			cameraDirector = new FocusModeCameraDirector_SelectSpot in this;
		}
	}

	private final function CalcAndAddFocusCost( spotIds : array<int> )
	{
		var cost : int;
		var i, size : int;
		var newVal : float;
		
		cost = 0;
		
		size = aSpots.Size();
		for ( i=0; i<size; i+=1 )
		{
			cost += aSpots[ i ].focusPointsCost;
		}
		
		newVal = parent.GetStat(BCS_Focus) - (float)cost;
		if ( newVal < 0.f )
		{
			LogChannel( 'FocusMode', "Error CalcAndAddFocusCost: cost is greater then current level" );
		}
		
		parent.DrainStamina(ESAT_FixedValue, newVal, 2 );
	}
	
	private final function CollectAllAvailableSpotsFromTarget()
	{
		var i, j 					: int;
		var visible 				: bool;
		var vsSize, geSize 			: int;
		var currVS 					: CVitalSpot;
		var currVSInfo 				: SVitalSpotInfo;
		var playerToVitalSpotDist 	: array<float>;
		var manager					: CWitcherJournalManager; //#B
		var points, percents		: float; //#B
		var creatureEntry 			: CJournalCreature; //#B
		
		manager = theGame.GetJournalManager(); //#B
		
		vsSize = focusModeTargetVS.Size();
		
		// Set new size, can be zero
		aSpots.Resize( vsSize );
		
		// Reset initial id
		initialSpotId = -1;
		
		if ( vsSize > 0 )
		{
			for ( i=0; i<vsSize; i+=1 )
			{
				currVS = focusModeTargetVS[ i ];
				currVSInfo = aSpots[ i ];
				
				// Update spot info
				visible = UpdateSpotInfo( currVS, currVSInfo );
				
				// Is spot visible?
				if ( visible ) // manager.GetEntryStatus(currVS.GetJournalEntry()) != JS_Inactive ) //#B checks if spot is active in journal -> it check if Geralt has knowledge about this vital spot
				{
					currVSInfo.isVisible = true;
					
					playerToVitalSpotDist.PushBack( VecDistance( currVSInfo.slotWorldPos, parent.GetWorldPosition() ) );
				}
				else
				{
					currVSInfo.isVisible = false;
					
					playerToVitalSpotDist.PushBack( 1000.f );
				}
				
				if(i == 0)
				{
					creatureEntry = currVS.GetJournalEntry().GetCreatureEntry();
				}
				
				// Setup all spot's data
				currVSInfo.owner = (CNewNPC)( parent.target );
				currVSInfo.spotName = currVS.GetJournalEntry().GetTitleStringId();
				currVSInfo.spotDescription = currVS.GetJournalEntry().GetDescriptionStringId();
				currVSInfo.focusPointsCost =  (int)( currVS.focusPointsCost );
				currVSInfo.ambientSound.soundEvent = currVS.soundOnFocus;
				currVSInfo.ambientSound.soundEventOff = currVS.soundOffFocus;
				currVSInfo.ambientSound.slotName = currVS.entitySlotName;
				currVSInfo.hitReactionAnimation = currVS.hitReactionAnimation;
				currVSInfo.destroyAfterExecution = currVS.destroyAfterExecution;
				currVSInfo.vitalSpotIndex = i;
				//currVSInfo.enemyName = currVS.GetCreatureEntry().GetNameStringId(); // CJournalCreature . int
				// Setup gameplay effects
				currVSInfo.gameEffects = currVS.gameplayEffects;
				
				// TODO
				// Do we need it?
				aSpots[ i ] = currVSInfo;
			}
			
			// Select initial spot
			initialSpotId = ArrayFindMinF( playerToVitalSpotDist );
		}
		else
		{
			LogChannel( 'FocusMode', "No available vital spots to process!!!" );
		}
		
		enemyData.enemyName = creatureEntry.GetNameStringId(); //focusModeTarget.GetDisplayName();
		enemyData.enemyDescription = GetCreatureDescription(manager,creatureEntry)	;//focusModeTarget.GetDisplayName();
		focusModeTarget.GetHealthPercents(true, true, enemyData.health);
		enemyData.stamina = focusModeTarget.GetStat( BCS_Stamina );
		enemyData.knowledgePoints = 0; //#B ??
		focusModeTarget.GetResistValue(CDS_PhysicalRes, points, percents);
		enemyData.armor = percents;
		
		//DEBUG 
		/*
		focusModeTarget.AddBuffByType(	EET_Paralyzed, focusModeTarget, 'CFMDEBUG' );
		focusModeTarget.AddBuffByType(	EET_Stagger, focusModeTarget, 'CFMDEBUG' );
		focusModeTarget.AddBuffByType(	EET_Freeze, focusModeTarget, 'CFMDEBUG' );
		focusModeTarget.AddBuffByType(	EET_Blindness, focusModeTarget, 'CFMDEBUG' );
		* /
			
		enemyData.currentEffects = focusModeTarget.GetCurrentEffects();
	}
	
	private function GetCreatureDescription( manager : CWitcherJournalManager, creatureEntry : CJournalCreature ) : int //#B
	{
		var i				 : int;
		var entries 		 : array< CJournalBase >;
		var descriptionGroup : CJournalCreatureDescriptionGroup;
		var description		 : CJournalCreatureDescriptionEntry;
		//manager.GetActivatedChildren( creatureEntry, entries ); // this is fucked 
		for( i = 0; i < creatureEntry.GetNumChildren(); i += 1 )//entries.Size(); i += 1 )
		{
			descriptionGroup = (CJournalCreatureDescriptionGroup)creatureEntry.GetChild(i);//entries[i];
			if(descriptionGroup)
			{				
				description = (CJournalCreatureDescriptionEntry)descriptionGroup.GetChild(0); //@FIXME BIDON - only first description
				return description.GetDescriptionStringId();
			}
		}
		
		return 0;
	}
	
	private final function SetFocusModeTarget( t : CNewNPC )
	{
		//disable old target's CDM immortality
		focusModeTarget.SetImmortalityMode( AIM_None, AIC_CombatFocusMode );
		
		// Set new target
		focusModeTarget = t;		
		
		//enable new target's CFM immortality
		t.SetImmortalityMode( AIM_Immortal, AIC_CombatFocusMode );
		
		// Collect spots
		CollectAllAvailableSpotsFromTarget();
	}
		
	private final function UpdateSpotInfo( spot : CVitalSpot, out spotInfo : SVitalSpotInfo ) : bool
	{
		var ret : bool;
		var screenPos : Vector;
		var x,y : float;
		
		spotInfo.slotWorldPos = SlotGetWorldPosition( spot.entitySlotName );
		theCamera.WorldVectorToViewRatio( spotInfo.slotWorldPos, x, y );
		
		spotInfo.slotScreenCoord.X = x;
		spotInfo.slotScreenCoord.Y = y;
		spotInfo.slotScreenCoord.Z = 0.f;
		spotInfo.slotScreenCoord.W = 0.f;
		
		ret = CheckSpotVisibility( spotInfo.slotWorldPos, VecTransformDir( spotInfo.owner.GetLocalToWorld(), spot.normal ) );
		
		return ret;
	}
	
	private final function CheckSpotVisibility( slotWorldPos : Vector, spotNormal : Vector ) : bool
	{
		var spotNormalToPlayerAngle : float;
		var spotNormalNew : Vector;
		
		spotNormalNew = slotWorldPos - focusModeTarget.GetWorldPosition();
		spotNormalToPlayerAngle = AbsF( AngleDistance( VecHeading( spotNormalNew ), VecHeading( parent.GetWorldPosition() - focusModeTarget.GetWorldPosition() ) ) );
			
		if ( spotNormalToPlayerAngle < 110 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	/*private final function DecodeVitalSpotName( spotType : EVitalSpotType ) : string
	{
		var spotName : string;
		spotName = GetLocStringByKey( (string)spotType );
		return spotName;
	}* /
	
	timer function Timer_UpdateState( dt : float , id : int)
	{
		var i, eSize, aSize : int;
		
		aSize = aSpots.Size();
		eSize = focusModeTargetVS.Size();
		
		if ( aSize != eSize )
		{
			LogChannel( 'FocusMode', "Error: Timer_UpdateState" );
			return;
		}
		
		for ( i=0; i<aSize; i+=1 )
		{
			UpdateSpotInfo( focusModeTargetVS[ i ], aSpots[ i ] );
			
			// Don't update visibility flag
			//aSpots[ i ].isVisible = visible && currVS.isEnabled;
		}
		
		cameraDirector.Update( dt );
	}
	
	private final function SlotGetWorldPosition( slotName : name ) : Vector
	{
		var slotWorldPos : Vector;
		var slotMatrix : Matrix;

		focusModeTarget.CalcEntitySlotMatrix( slotName, slotMatrix );
		slotWorldPos = MatrixGetTranslation( slotMatrix );
		
		return slotWorldPos;
	}	
}
*/