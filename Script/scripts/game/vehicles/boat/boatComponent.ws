/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013-2014 CDProjektRed
/** Author : Radosław Grabowski
/**			 Tomek Kozera
/**			 Wojtek Żerek
/***********************************************************************/

struct ParticleEffectNames
{
	var rightSplash : name;
	var leftSplash : name;
	var backSplash : name;
}

import statemachine class CBoatComponent extends CVehicleComponent
{
	default autoState = 'Idle';
	private var effects : ParticleEffectNames;
	
	private var boatEntity : W3Boat;
	private var passenger : CActor;
	
	import var mountAnimationFinished : bool;
	import var sailDir : float;
	var sailTilt : float;

	private var sailAnim : CAnimatedComponent;
	private var boatAnim : CAnimatedComponent;
	private var rudderDir : float;
	private var isChangingSteer : bool;
	private var steerSound : bool;
	private var enableCustomMastRotation : bool;
	
	public const var IDLE_SPEED_THRESHOLD : float;
	private const var MAST_PARTICLE_THRESHOLD : float;
	private const var TILT_PARTICLE_THRESHOLD : float;
	private const var DIVING_PARTICLE_THRESHOLD : float;
	private const var WATER_THRESHOLD : float;
	private const var MAST_ROTX_THRESHOLD : float;
	private const var MAST_ROT_SAIL_VAL : float;
	
	// buoyancy points
	private var fr,ba,ri,le: Vector;
	
	// cached data
	private var prevTurnFactorX : float;
	private var previousGear: int;
	
	private var prevMastPosZ : float;
	private var prevMastVelZ : float;
	
	private var prevFrontPosZ : float;
	private var prevFrontVelZ : float;
	
	private var prevRightPosZ : float;
	private var prevRightVelZ : float;
	
	private var prevLeftPosZ : float;
	private var prevLeftVelZ : float;
	
	private var prevBackPosZ : float;
	private var prevBackVelZ : float;
	
	private var prevFrontWaterPosZ : float;
	//debug
	private var sphereSize : float;
	
	// slots
	private var mastSlotTransform : Matrix;
	private var frontSlotTransform : Matrix;
	private var backSlotTransform : Matrix;
	private var rightSlotTransform : Matrix;
	private var leftSlotTransform : Matrix;
	
	private var wasSailFillSoundPlayed: bool;
	private var boatMastTrailLoopStarted: bool; default boatMastTrailLoopStarted = false;
	
	public var dismountStateName: name;
	
	public var localSpaceCameraTurnPercent : float;
		
	// Event called when component is attached
    event OnComponentAttached()
	{
		GotoStateAuto();
	}
	
	default localSpaceCameraTurnPercent = 0.0f;
	default isChangingSteer = false;
	default rudderDir = 0.0f;
	default sailDir = 0.45f;
	default sailTilt = 0.0f;
	default IDLE_SPEED_THRESHOLD = 0.2f;
	default MAST_PARTICLE_THRESHOLD = 0.25f;
	default TILT_PARTICLE_THRESHOLD = -0.4f;
	default DIVING_PARTICLE_THRESHOLD = 0.01f;
	default WATER_THRESHOLD = 0.15f;
	default wasSailFillSoundPlayed = false;
	default previousGear = 0;
	default prevTurnFactorX = 1;
	default enableCustomMastRotation = false;
	default MAST_ROT_SAIL_VAL = 0.7f;
	
	default MAST_ROTX_THRESHOLD = 0.6f;
		
	import function GetLinearVelocityXY() : float;
	
	// Start drowning procedure
	import final function TriggerDrowning( globalHitPosition : Vector );
	import final function IsDrowning() : bool;								// MS TODO: change it please to IsDestroyed()
	
	// Get boat body mass
	import function GetBoatBodyMass() : float;
	
	import final function GetCurrentGear() : int;
	import final function GetCurrentSpeed() : Vector;
	import final function GetMaxSpeed() : float;

	// Get buoyancy point status
	// It is global position of controll point where point.W is global water level at that point
	import final function GetBuoyancyPointStatus_Front() : Vector;
	import final function GetBuoyancyPointStatus_Back()  : Vector;
	import final function GetBuoyancyPointStatus_Right() : Vector;
	import final function GetBuoyancyPointStatus_Left()  : Vector;
	
	// Notify mounting/dismounting procedures
	import final function MountStarted();
	import final function DismountFinished();
	
	// Enables out of frustum teleportation for boats steered by NPCs
	// This causes automatic boat teleportation when NPC in boat is to far from player
	import function UseOutOfFrustumTeleportation( enable : bool );
	
	import final function GameCameraTick( out fovDistPitch : Vector, out offsetZ : float, out sailOffset : float, dt : float, passenger : bool ) : bool;
	
	//stops boat before dismounting. When stopped sends the OnTriggerBoatDismountAnim event -  this has to be changed in order not to double code // vehicleCleanup
	import function StopAndDismountBoat();
	
	event OnTriggerBoatDismountAnim()
	{
		thePlayer.BlockAction( EIAB_Crossbow, 'DismountVehicle2' );
		( (CR4PlayerStateUseGenericVehicle)thePlayer.GetState( dismountStateName ) ).DismountVehicle();
	}
	
	event OnDismountImediete()
	{
		// Force instant dismount
		IssueCommandToDismount( DT_instant );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// INIT AND INTERACTION ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnInit()
	{
		boatEntity = GetBoatEntity();
		if( !boatEntity )
		{
			LogBoatFatal( "Entity doesn't exist." );
			return false;
		}
		if( InitializeComponents( boatEntity ) )
		{
			InitializeSlots();
			//boatEntity.ApplyAppearance('destr');
			boatEntity.ApplyAppearance('default');
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( !user && IsMountPossible() )
		{
			thePlayer.OnEquipMeleeWeapon( PW_None, true );
			Mount( thePlayer, VMT_MountIfPossible, EVS_driver_slot );
		}
	}
	
	function OnInteractionPassenger( )
	{
		if ( !passenger && IsMountPossible() )
		{
			thePlayer.OnEquipMeleeWeapon( PW_None, true );
			Mount( thePlayer, VMT_MountIfPossible, EVS_passenger_slot );
		}
	}
	
	function IsMountPossible() : bool
	{
		return thePlayer.IsActionAllowed( EIAB_MountVehicle );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MOUNTING AND DISMOUNTING ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnDrowningDismount()
	{
		canBoardTheBoat = false;
		GetEntity().AddTimer( 'DrowningDismount', 2.0 );
	}
	
	event OnDrowningFinished()
	{
		GetEntity().StopAllEffects();
	}
	
	event OnMountStarted( entity : CEntity, vehicleSlot : EVehicleSlot ) 
	{
		if ( vehicleSlot == EVS_passenger_slot )
		{
			passenger = (CActor)entity;
		}
	
		mountAnimationFinished = false;
		boatEntity.GetMountInteractionComponent().SetEnabled( false );
		
		UpdateHigherMast( 0.f );
		super.OnMountStarted( entity, vehicleSlot );
		
		// Call code functions
		MountStarted();
	}
	
	event OnMountFinished( entity : CEntity )
	{
		mountAnimationFinished = true;
		boatEntity.SoundEvent( "boat_sail_water_loop" );
		boatEntity.SoundEvent( "boat_sail_flapping_loop" );
		enableCustomMastRotation = true;
		theSound.EnterGameState( ESGS_Boat );
		super.OnMountFinished( entity );
	}
	
	event OnDismountStarted( entity : CEntity )
	{
		mountAnimationFinished = false;
		entity.StopEffectIfActive( 'fake_wind_right' );
		entity.StopEffectIfActive( 'fake_wind_left' );
		entity.StopEffectIfActive( 'fake_wind_back' );
		boatEntity.SoundEvent( "boat_sail_water_loop_stop" );
		boatEntity.SoundEvent( "boat_sail_flapping_loop_stop" );
		UpdateHigherMast( 1.f );
		enableCustomMastRotation = false;
		theSound.LeaveGameState( ESGS_Boat );
		super.OnDismountStarted( entity );
	}
	
	event OnDismountFinished( entity : CEntity, vehicleSlot : EVehicleSlot  )
	{		
		boatEntity.GetMountInteractionComponent().SetEnabled( true );
		mountAnimationFinished = false;
			
		if ( vehicleSlot == EVS_passenger_slot )
		{
			passenger = NULL;
		}
		super.OnDismountFinished( entity, vehicleSlot );
		
		// Call code functions
		DismountFinished();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// OTHER ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function GetPassenger() : CActor
	{
		return passenger;
	}
	
	event OnTick( dt : float )	
	{
		var currentFrontPosZ : float;
		var currentFrontVelZ : float;
		var currentFrontAccZ : float;
		
		var currentRightPosZ : float;
		var currentRightVelZ : float;
		var currentRightAccZ : float;

		var currentMastPosZ : float;
		var currentMastVelZ : float;
		
		var sailingMaxSpeed : float;
		var currentSpeed : float;
		var isMoving : bool;
		var tilt : float;
		var turnFactor : float;
		var currentGear: int;
		
		var fDiff,bDiff,rDiff,lDiff: float;
		
		if ( dt <= 0.f )
		{
			LogBoat( "!!!!!!!!!!!!! dt <= 0.f !!!!!!!!!!!!!" );
			return false;
		}
		
		if( !boatEntity )
		{
			LogBoatFatal( "Entity not set in CBoatComponent::OnTick event." );
			return false;
		}
		
		// get buyancy points
		fr = GetBuoyancyPointStatus_Front();
		ba = GetBuoyancyPointStatus_Back();
		ri = GetBuoyancyPointStatus_Right();
		le = GetBuoyancyPointStatus_Left();
		
		fDiff = fr.Z - fr.W;
		bDiff = ba.Z - ba.W;
		rDiff = ri.Z - ri.W;
		lDiff = le.Z - le.W;
		
		// update sailDir by current tilt
		tilt = le.Z - ri.Z;
		sailDir = tilt*dt;
		sailTilt = tilt;
		
		// front
		boatEntity.CalcEntitySlotMatrix( 'front_splash', frontSlotTransform );
		currentFrontPosZ = (frontSlotTransform.W).Z;
		currentFrontVelZ = currentFrontPosZ - prevFrontPosZ;
		currentFrontAccZ = currentFrontVelZ - prevFrontVelZ;
		
		// mast
		boatEntity.CalcEntitySlotMatrix( 'mast_trail', mastSlotTransform );
		currentMastPosZ = (mastSlotTransform.W).Z;
		if( tilt > 0.f )
		{
			currentMastVelZ = currentMastPosZ - ri.W;
		}
		else
		{
			currentMastVelZ = currentMastPosZ - le.W;
		}
		
		isMoving = ( GetLinearVelocityXY() > IDLE_SPEED_THRESHOLD );
		sailingMaxSpeed = GetMaxSpeed();
		
		if( isMoving )
		{
			// stop idle particle
			boatEntity.StopEffectIfActive( 'idle_splash' );
			
			// get current speed
			// calculate current speed for sound params (analog)
			currentSpeed = GetLinearVelocityXY() / sailingMaxSpeed;
			
			// right tilt effect
			if( IsInWater(ri) && rDiff < TILT_PARTICLE_THRESHOLD )
			{
				boatEntity.PlayEffectSingle( 'right_splash_stronger' );
			}
			else
			{
				boatEntity.StopEffectIfActive( 'right_splash_stronger' );
			}
			
			// left tilt effect
			if( IsInWater(le) && lDiff < TILT_PARTICLE_THRESHOLD )
			{
				boatEntity.PlayEffectSingle( 'left_splash_stronger' );
			}
			else
			{
				boatEntity.StopEffectIfActive( 'left_splash_stronger' );
			}
			
			// effect from mast
			if( currentMastVelZ < MAST_PARTICLE_THRESHOLD )
			{
				boatEntity.PlayEffectSingle( 'mast_trail' );
				
				if( !boatEntity.SoundIsActiveName( 'boat_mast_trail_loop' ) && !boatMastTrailLoopStarted)
				{
					boatEntity.SoundEvent( 'boat_mast_trail_loop', 'mast_trail', true );
					boatMastTrailLoopStarted = true;
				}
			}
			else
			{
				boatEntity.StopEffectIfActive( 'mast_trail' );
				if( boatEntity.SoundIsActiveName( 'boat_mast_trail_loop' ) && boatMastTrailLoopStarted )
				{
					if( !boatEntity.SoundIsActiveName( 'boat_mast_trail_loop_stop' ) )
					{
						boatEntity.SoundEvent( 'boat_mast_trail_loop_stop' , 'mast_trail', true );
						boatMastTrailLoopStarted = false;
					}
				}
			}
			
			// front splash effect
			if( IsDiving( currentFrontVelZ, prevFrontWaterPosZ, fDiff ) )
			{
				boatEntity.SoundEvent( "boat_stress" );
				if ( !boatEntity.IsEffectActive('front_splash') )
				{
					boatEntity.SoundEvent( "boat_water_splash_soft" );
					boatEntity.PlayEffect( 'front_splash' );
				}
			}
		}
		else
		{
			// start idle particle
			if( IsInWater(le) && IsInWater(ri) && IsInWater(fr) && IsInWater(ba) && !boatEntity.IsEffectActive('idle_splash') )
			{
				boatEntity.PlayEffect( 'idle_splash' );
			}
			
			SwitchEffectsByGear( 0 );
			
			// Stop particles
			boatEntity.StopEffectIfActive( 'front_splash' );
			boatEntity.StopEffectIfActive( 'mast_trail' );
			boatEntity.StopEffectIfActive( 'right_splash_stronger' );
			boatEntity.StopEffectIfActive( 'left_splash_stronger' );
			
			// Stop wind effect
			boatEntity.StopEffectIfActive( 'fake_wind_right' );
			boatEntity.StopEffectIfActive( 'fake_wind_left' );
			boatEntity.StopEffectIfActive( 'fake_wind_back' );
			currentSpeed = 0.f;
		}
		
		// update particles based on current gear
		currentGear = GetCurrentGear();
		
		// update currentGear in beh graph for passenger animation
		if( passenger )
			UpdatePassengerSailAnimByGear( currentGear );
		
		if( IsInWater(le) && IsInWater(ri) && IsInWater(fr) && IsInWater(ba) && currentGear != previousGear )
		{
			SwitchEffectsByGear( currentGear );
		}
		
		// update mast position
		UpdateMastPositionAndRotation( currentGear, tilt, isMoving );
		
		//update sound params
		UpdateSoundParams( currentSpeed );
		
		// last part
		// cache part
		previousGear = currentGear;
		
		// cache water pos
		prevFrontWaterPosZ = fr.W;
		
		//front slot
		prevFrontPosZ += currentFrontVelZ;
		prevFrontVelZ = currentFrontVelZ;
		
		// mast slot
		prevMastPosZ += currentMastVelZ;
		prevMastVelZ = currentMastVelZ;
		
		// right slot
		prevRightPosZ += currentRightVelZ;
		prevRightVelZ = currentRightVelZ;
		
		// custom idle animation for strong waves - only for not mounted player
		if( thePlayer.IsOnBoat() && !thePlayer.IsUsingVehicle() )
		{
			if( GetWeatherConditionName() == 'WT_Rain_Storm' )
			{
				if( thePlayer.GetBehaviorVariable( 'bRainStormIdleAnim' ) != 1.0 )
				{
					thePlayer.SetBehaviorVariable( 'bRainStormIdleAnim', 1.0 );
				}
			}
			else
			{
				if( thePlayer.GetBehaviorVariable( 'bRainStormIdleAnim' ) != 0.0 )
				{
					thePlayer.SetBehaviorVariable( 'bRainStormIdleAnim', 0.0 );
				}
			}
		}
	}
	
	final function SetRudderDir( rider : CActor, value : float ) // [-1,1]
	{
		var aimHorizontal : float;
		var item : SItemUniqueId;
		var change : float;
	
		if ( rider == thePlayer )
		{
			item = rider.GetInventory().GetItemFromSlot( 'l_weapon' );
				
			if ( ( rider.GetInventory().IsIdValid( item ) && rider.GetInventory().IsItemCrossbow( item ) )
				|| thePlayer.GetThrownEntity() )
			{
				boatAnim.SetBehaviorVariable( 'isWeaponInWaitState', 0.f );
				aimHorizontal = rider.GetBehaviorVariable( 'aimHorizontal' );
				boatAnim.SetBehaviorVariable( 'aimHorizontal', aimHorizontal );		
				
				if ( ( rider.GetInventory().IsItemCrossbow( item ) && thePlayer.rangedWeapon.GetCurrentStateName() == 'State_WeaponReload' ) 
					|| aimHorizontal <= -0.25 )
				{
					boatAnim.SetBehaviorVariable( 'latchRudderControl', 1.f );
					rider.SetBehaviorVariable( 'latchRudderControl', 1.f );
				}
				else
				{
					boatAnim.SetBehaviorVariable( 'latchRudderControl', 0.f );
					rider.SetBehaviorVariable( 'latchRudderControl', 0.f );
				}
			}
			else
				boatAnim.SetBehaviorVariable( 'isWeaponInWaitState', 1.f );
		}
		
		change = AbsF(rudderDir - value);
		
		LogChannel('Boat', "Rudder change: " + change );
		
		if ( change != 0.0f )		
		{
			LogChannel('Boat', "Rudder SET dir: " + value );
			
			boatAnim.SetBehaviorVariable( 'rudderAngle', value );
			rider.SetBehaviorVariable( 'rudderDir', value );
			
			if( !boatEntity.SoundIsActiveName( 'boat_steering_loop' ) )
			{
				boatEntity.SoundEvent( 'boat_steering_loop' );
			}
			steerSound = true;
			
			rudderDir = value;
		}
		else
		{
			if( steerSound )
			{
				boatEntity.SoundEvent( 'boat_steering_loop_stop' );
				steerSound = false;
			}
		}		
	}
	
	private function IsDiving( curVel : float, cachedWaterPosZ : float, underWater : float ) : bool
	{
		var ret : bool;
		ret = false;
		
		//if( curAcc > DIVING_PARTICLE_THRESHOLD && curVel < 0.0f )
		if( underWater < 0.f && cachedWaterPosZ > 0.f && curVel < -DIVING_PARTICLE_THRESHOLD )
		{
			ret = true;
		}
		return ret;
	}
	
	private function InitializeSlots() : bool
	{
		var ret : bool;
		ret = false;
		
		// clear slot cached data only once when initialize
		prevFrontPosZ = 0.0f;
		prevFrontVelZ = 0.0f;
		
		prevMastPosZ = 0.0f;
		prevMastVelZ = 0.0f;
		
		prevRightPosZ = 0.0f;
		prevRightVelZ = 0.0f;
		
		prevLeftPosZ = 0.0f;
		prevLeftVelZ = 0.0f;

		// initialize slots
		// front
		if ( boatEntity.CalcEntitySlotMatrix( 'front_splash', frontSlotTransform ) )
		{
			prevFrontPosZ = (frontSlotTransform.W).Z;
			ret = true;
		}
		else
		{
			LogBoat( "no splash_point_l slot in boat entity" );
			return false;
		}
		
		// right
		if ( boatEntity.CalcEntitySlotMatrix( 'right_splash', rightSlotTransform ) )
		{
			prevRightPosZ = (rightSlotTransform.W).Z;
			ret = true;
		}
		else
		{
			LogBoat( "no right_splash slot in boat entity" );
			return false;
		}
		
		// left
		if ( boatEntity.CalcEntitySlotMatrix( 'left_splash', leftSlotTransform ) )
		{
			prevLeftPosZ = (leftSlotTransform.W).Z;
			ret = true;
		}
		else
		{
			LogBoat( "no left_splash slot in boat entity" );
			return false;
		}
		
		// back
		if ( boatEntity.CalcEntitySlotMatrix( 'back_splash', backSlotTransform ) )
		{
			prevBackPosZ = (backSlotTransform.W).Z;
			ret = true;
		}
		else
		{
			LogBoat( "no back_splash slot in boat entity" );
			return false;
		}
		
		// mast
		if ( boatEntity.CalcEntitySlotMatrix( 'mast_trail', mastSlotTransform ) )
		{
			prevMastPosZ = (mastSlotTransform.W).Z;
			ret = true;
		}
		else
		{
			LogBoat( "no water_trial slot in boat entity" );
			return false;
		}
		return ret;
		
	}
	
	private function InitializeComponents( e : CEntity ) : bool
	{
		var ret : bool;
		ret = false;
		
		if( !e )
		{
			LogBoatFatal( "Entity doesn't exist." );
			return false;
		}
		else
		{
			boatAnim = (CAnimatedComponent)e.GetComponent( 'mast_and_steer' );
			sailAnim = (CAnimatedComponent)e.GetComponent( 'sail' );
			ret = true;
		}
		return ret;
	}
	
	public function UpdateHigherMast( mastHeight : float ) : bool
	{
		if( !boatAnim )
		{
			LogBoatFatal( "Entity doesn't have mast_and_steer animated component, modification aborted." );
			return false;
		}
		boatAnim.SetBehaviorVariable( 'upperMastHeight', mastHeight );
		return true;
	}
	
	private function UpdateMast( mastAngle : float, mastHeight : float, rotationSpeed : float ) : bool
	{
		if( !boatAnim )
		{
			LogBoatFatal( "Entity doesn't have mast_and_steer animated component, modification aborted." );
			return false;
		}
		boatAnim.SetBehaviorVariable( 'mastAngle', mastAngle );
		boatAnim.SetBehaviorVariable( 'mastHeight', mastHeight );
		boatAnim.SetBehaviorVariable( 'mastRotationSpeed', rotationSpeed );
		return true;
	}	
	
	final function GetBoatEntity() : W3Boat
	{
		return (W3Boat)GetEntity();
	}
	
	private function UpdateSoundParams( value : float )
	{
		var scaler : float;
		scaler = 0.8f;
		// update sound params
		// SOUND PARAMETERS should be always!! always !! in range 0 to 1 // min max
		// debug with Pawel Daudzward cause its wwise param.
		// value comes already normalized so we dont have to clamp it
		value = ClampF(value, 0.f, 1.f );

		// There have to be two of this calls here, because first one will set the RTCP value on the 
		// game object created for entity (without the bone specified or slot, so that would usually 
		// be in the position of the entity). The second one sets the RTCP value for a different game 
		// object, created for a bone "mast_trail".
		boatEntity.SoundParameter( "boat_speed", value );
		boatEntity.SoundParameter( "boat_speed", value,'mast_trail', 0 , true);

		// clamp it later cause we are boosting some extra intensity
		value = ClampF(value*scaler, 0.f, 1.f );
		boatEntity.SoundParameter( "boat_sail_intensity", value );
	}
	
	private function UpdatePassengerSailAnimByGear( currentGear : int )
	{
		passenger.SetBehaviorVariable( 'currentGear', currentGear );
	}
	
	private function IsInWater( vec : Vector ) : bool
	{
		return ((vec.Z-vec.W)<WATER_THRESHOLD);
	}
	
	event OnBoatDismountRequest()
	{
		boatEntity.StopEffectIfActive( effects.rightSplash );
		boatEntity.StopEffectIfActive( effects.leftSplash );
		boatEntity.StopEffectIfActive( effects.backSplash );
	}
	
	private function SwitchEffectsByGear( currentGear : int )
	{
		// stop current effects for all moving slots
		boatEntity.StopEffectIfActive( effects.rightSplash );
		boatEntity.StopEffectIfActive( effects.leftSplash );
		boatEntity.StopEffectIfActive( effects.backSplash );
		
		if( currentGear != 0 )
		{
			// fill
			switch( currentGear )
			{
				case 1:
					effects.rightSplash = 'right_splash_slow';
					effects.leftSplash = 'left_splash_slow';
					effects.backSplash = 'back_splash_slow';
					break;
				case 2:
					effects.rightSplash = 'right_splash_normal';
					effects.leftSplash = 'left_splash_normal';
					effects.backSplash = 'back_splash_normal';
					break;
				case 3:
					effects.rightSplash = 'right_splash_fast';
					effects.leftSplash = 'left_splash_fast';
					effects.backSplash = 'back_splash_fast';
					break;
			}
			
			// play effect with new name
			boatEntity.PlayEffectSingle( effects.rightSplash );
			boatEntity.PlayEffectSingle( effects.leftSplash );
			boatEntity.PlayEffectSingle( effects.backSplash );
		}
	}
	
	private function UpdateMastPositionAndRotation( gear : int, angle : float, isMoving : bool )
	{
		var mastRot : float;
		
		mastRot = CalcMastRotation( angle, isMoving, gear );
		
		// Set mast position and rotation
		if( isMoving )
		{
			if( !wasSailFillSoundPlayed )
			{
				wasSailFillSoundPlayed = true;
				boatEntity.SoundEvent( "boat_sail_fill" );
			}
			if( gear == 3 )
			{
				UpdateMast( mastRot, 1.f, 0.2f );
			}
			else if( gear == 2 )
			{
				UpdateMast( mastRot, 0.4f, 0.5 );
			}	
			else if( gear != 0 )
			{
				UpdateMast( mastRot, 0.f, 1.f );
			}
		}
		else
		{
			UpdateMast( mastRot, 0.f, 1.f );
			wasSailFillSoundPlayed = false;
		}
	}
	
	event OnGatherBoatInput()
	{
		var accelerate : SInputAction;
		var decelerate : SInputAction;
		var stickTilt : Vector;
		
		accelerate = theInput.GetAction( 'GI_Accelerate' );
		decelerate = theInput.GetAction( 'GI_Decelerate' );
		
		stickTilt.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		stickTilt.Y = theInput.GetActionValue( 'GI_AxisLeftY' );

		SetInputValues( accelerate, decelerate, stickTilt, localSpaceCameraTurnPercent );
	}
	
	import private final function SetInputValues( accelerate : SInputAction, decelerate : SInputAction, stickTilt : Vector, localSpaceCameraTurnPercent : float );
	
	private function CalcMastRotation( val : float, isMoving : bool, gear : int ) : float
	{
		var turnFactorY : float;
		var turnFactorX : float;
		
		
		if( enableCustomMastRotation )
		{
			turnFactorX	= theInput.GetActionValue( 'GI_AxisLeftX' );
			turnFactorY	= theInput.GetActionValue( 'GI_AxisLeftY' );
		}
		
		if( isMoving )
		{
			if( turnFactorX < MAST_ROTX_THRESHOLD && turnFactorX > -MAST_ROTX_THRESHOLD )
			{
				if( turnFactorX <= 0.f )
				{
					val = MAST_ROT_SAIL_VAL * prevTurnFactorX;
				}
				else
				{
					val = MAST_ROT_SAIL_VAL * prevTurnFactorX;
				}
			}
			else if( turnFactorX < -MAST_ROTX_THRESHOLD )
			{
				val = 1.f;
				prevTurnFactorX = val;
			}
			else if( turnFactorX > MAST_ROTX_THRESHOLD )
			{
				val = -1.f;
				prevTurnFactorX = val;
			}
			
			if( gear != -1 )
			{
				// disable back fake wind effect
				boatEntity.StopEffectIfActive( 'fake_wind_back' );
				// update wind effect
				if( val <= -MAST_ROTX_THRESHOLD )
				{
					// Play wind fake right
					boatEntity.StopEffectIfActive( 'fake_wind_right' );
					boatEntity.PlayEffectSingle( 'fake_wind_left' );
				}
				else if( val >= MAST_ROTX_THRESHOLD )
				{
					// Play wind fake left
					boatEntity.StopEffectIfActive( 'fake_wind_left' );
					boatEntity.PlayEffectSingle( 'fake_wind_right' );
				}
			}
			else
			{
				boatEntity.StopEffectIfActive( 'fake_wind_left' );
				boatEntity.StopEffectIfActive( 'fake_wind_right' );
				boatEntity.PlayEffectSingle( 'fake_wind_back' );
			}
		}
		thePlayer.GetVisualDebug().AddText( 'fake_wind', ("fake_wind: " + val), fr-1.5f, true, 0, Color(0,255,0), true );
		return val;
	}
	
	public function GetSailDir() : float
	{
		return sailDir;
	}
	
	public function GetSailTilt() : float
	{
		return sailTilt;
	}
	
	// Cutscene events
	event OnCutsceneStarted(){}
	event OnCutsceneEnded(){}
	
	// Switches cutscene mode on/off
	import function TriggerCutsceneStart();
	import function TriggerCutsceneEnd();
	
	public function IsMountingPossible() : bool
	{
		return !user || !passenger;
	}
}

class CBoatPassengerInteractionComponent extends CInteractionComponent
{
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var boatComponent : CBoatComponent;
		boatComponent = (CBoatComponent)( GetEntity().GetComponentByClassName('CBoatComponent') );
		
		if ( boatComponent )
		{
			boatComponent.OnInteractionPassenger();
		}
	}
}
