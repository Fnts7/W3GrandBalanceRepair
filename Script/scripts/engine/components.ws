/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Generic component 
/////////////////////////////////////////////

import class CComponent extends CNode
{
	// Get entity that owns this component
	import final function GetEntity() : CEntity;
	
	// Is component enabled
	import final function IsEnabled() : bool;
	
	// Set component enabled
	import final function SetEnabled( flag : bool );
	
	// Set local-space position. PLEASE use with caution. It's broken, don't use it!! Sometimes the final position is few meters away from what you pass to this function!!
	import final function SetPosition( position : Vector );
	
	// Set local-space rotation. PLEASE use with caution.
	import final function SetRotation( rotation : EulerAngles );
	
	// Set local-space scale. PLEASE use with caution.
	import final function SetScale( scale : Vector );
	
	//physical part
	import final function HasDynamicPhysic() : bool;
	import final function HasCollisionType( collisionTypeName : name, optional actorIndex : int, optional shapeIndex : int ) : bool;
	import final function GetPhysicalObjectLinearVelocity( optional actorIndex : int ) : Vector;
	import final function GetPhysicalObjectAngularVelocity( optional actorIndex : int ) : Vector;
	import final function SetPhysicalObjectLinearVelocity( velocity : Vector, optional actorIndex : int ) : bool;
	import final function SetPhysicalObjectAngularVelocity( velocity : Vector, optional actorIndex : int ) : bool;
	import final function GetPhysicalObjectMass( optional actorIndex : int ) : Float; 
	import final function ApplyTorqueToPhysicalObject( torque : Vector, optional actorIndex : int );
	import final function ApplyForceAtPointToPhysicalObject( force : Vector, point : Vector, optional actorIndex : int );
	import final function ApplyLocalImpulseToPhysicalObject( impulse : Vector, optional actorIndex : int );
	import final function ApplyTorqueImpulseToPhysicalObject( impulse : Vector, optional actorIndex : int );
	import final function GetPhysicalObjectBoundingVolume( out box : Box ) : bool;
	
	import final function SetShouldSave( shouldSave : bool );
	
	// signal custom event
	public function SignalCustomEvent( eventName : name )
	{
	}
}

struct SAnimMultiplyCauser
{
	saved var id : int;
	saved var mul : float;
};

/////////////////////////////////////////////
// Interaction area component
/////////////////////////////////////////////

import class CInteractionAreaComponent extends CComponent
{
	import var performScriptedTest : bool;

	import final function GetRangeMin() : float;
	import final function GetRangeMax() : float;
	
	import final function SetRanges( rangeMin : float, rangeMax : float, height : float );
	import final function SetRangeAngle( rangeAngle : int );
	
	import final function SetCheckLineOfSight( flag : bool );
}

/////////////////////////////////////////////
// Interaction component
/////////////////////////////////////////////

import class CInteractionComponent extends CInteractionAreaComponent
{
	import protected var isEnabledInCombat : bool;
	import protected var shouldIgnoreLocks : bool;
	
	private editable var isEnabledOnHorse : bool;
	default isEnabledOnHorse = false;
	
	editable var aimVector : Vector;
	editable var iconOffset	: Vector;
	
	editable var iconOffsetSlotName	: name;
	default iconOffsetSlotName = 'icon';

	hint aimVector = "Offset from component center for camera to check whether the component is visible";
	hint iconOffset = "Offset from component center where the interaction icon will be shown";
	hint iconOffsetSlotName = "If there is a slot with the name, the icon offset position will match this slot position";
	
	public function IsEnabledOnHorse() : bool { return isEnabledOnHorse; }

	public function IsEnabledInCombat() : bool 	{return isEnabledInCombat;}

	public function ShouldIgnoreLocks() : bool 	{return shouldIgnoreLocks;}

	// Get the interaction name, as set from the 
	import final function GetActionName() : string;

	// Set interaction name
	import final function SetActionName( actionName : string );

	// Get the localized name of the interaction
	import final function GetInteractionFriendlyName() : string;

	import final function GetInteractionKey() : int;
	
	import final function GetInputActionName() : name;
	
	//default checkCameraVisibility = true;
	
	public function EnableInCombat( enable : bool )
	{
		isEnabledInCombat = enable;
	}
	
	public final function SetIconOffset( offset : Vector )
	{
		iconOffset = offset;
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		//MS: Event in component fires first before event in entity. If this event returns false, then event in entity is triggered after.
		if ( theGame.GetInteractionsManager().GetActiveInteraction() == this )
		{
			if ( thePlayer.IsInCombat() && !thePlayer.IsSwimming() )
			{
				if ( IsEnabledInCombat() )
					return false;
				else
					return true;
			}
			else if ( thePlayer.IsInCombatAction() || thePlayer.IsCrossbowHeld() )
				return true;
			else
				return false;
		}
		else
			return true;
		
	}
	
	public final function UpdateIconOffset()
	{
		var l_entity 			: CEntity;
		var l_localToWorld		: Matrix;
		var l_worldToLocal		: Matrix;
		var l_slotMatrix		: Matrix;
		var l_slotWorldPos		: Vector;
		var l_offset			: Vector;
		var l_box				: Box;		
		
		if( !IsNameValid( iconOffsetSlotName ) ) return;
		
		l_entity = GetEntity();
		
		if( l_entity.CalcEntitySlotMatrix( iconOffsetSlotName, l_slotMatrix ) )
		{
			l_localToWorld 	= GetLocalToWorld();
			l_worldToLocal 	= MatrixGetInverted( l_localToWorld );
			
			l_slotWorldPos 	= MatrixGetTranslation( l_slotMatrix );
			l_offset 		= VecTransform( l_worldToLocal , l_slotWorldPos );
			
			SetIconOffset( l_offset );
		}
	}
}

/////////////////////////////////////////////
// Animated component
/////////////////////////////////////////////

import class CAnimatedComponent extends CComponent
{
	var nextFreeAnimMultCauserId : int;
		default nextFreeAnimMultCauserId = 0;
	
	var animationMultiplierCausers : array<SAnimMultiplyCauser>;
	
	// Activate behavior graph instances
	import final latent function ActivateBehaviors( names : array< name > ) : bool;
	
	// Attach behavior graph
	import final latent function AttachBehavior( instanceName : name ) : bool;
	
	// Detach behavior graph
	import final function DetachBehavior( instanceName : name ) : bool;
	
	// Get behavior float variable
	import final function GetBehaviorVariable( varName : name ) : float;
	
	// Get behavior vector variable
	import final function GetBehaviorVectorVariable( varName : name ) : Vector;
	
	// Set behavior float variable
	import final function SetBehaviorVariable( varName : name, varValue : float ): bool;
	
	// Set behavior vector variable
	import final function SetBehaviorVectorVariable( varName : name, varValue : Vector ) : bool;

	// Display skeleton
	import final function DisplaySkeleton( bone : bool, optional axis : bool, optional names : bool );
	
	// Get animation time multiplier of this actor
	import final function GetAnimationTimeMultiplier() : float;
	
	// Updating by other animated component
	import final function DontUpdateByOtherAnimatedComponent();
	import final function UpdateByOtherAnimatedComponent( slaveComponent : CAnimatedComponent );
	
	//NOT SAFE WHEN MORE THAN 1 EFFECT
	//
	//
	// Set animation time multiplier of this actor
	import final function SetAnimationTimeMultiplier( mult : float );
		
	//Adds new 'causer' of animation multiplier and sets the final animation multiplier. Returns assigned causer's id.
	public function SetAnimationSpeedMultiplier(mul : float) : int
	{
		var causer : SAnimMultiplyCauser;
		var finalMul : float;
				
		//add new causer		
		causer.mul = mul;
		causer.id = nextFreeAnimMultCauserId;
		
		nextFreeAnimMultCauserId += 1;
		
		animationMultiplierCausers.PushBack(causer);
				
		//calculate output multiplier
		SetAnimationTimeMultiplier(CalculateFinalAnimationSpeedMultiplier());
		
		return causer.id;
	}
	
	//Calculates final animation multiplier based on working causers
	private function CalculateFinalAnimationSpeedMultiplier() : float
	{
		if(animationMultiplierCausers.Size() > 0)
			return animationMultiplierCausers[animationMultiplierCausers.Size()-1].mul;
		
		return 1;
	}
	
	//Removes animation multiplier causer and sets final animation multiplier.
	public function ResetAnimationSpeedMultiplier(id : int)
	{
		var i,size : int;
		
		size = animationMultiplierCausers.Size();
		if(size == 0)
			return;	//yeah, right
		
		for(i=size-1; i>=0; i-=1)
			if(animationMultiplierCausers[i].id == id)
				animationMultiplierCausers.Erase(i);
				
		if(animationMultiplierCausers.Size()+1 != size)
		{
			LogAssert(false, "CAnimatedComponent.ResetAnimationMultiplier: invalid causer ID passed, nothing removed!");
			return;
		}
		
		SetAnimationTimeMultiplier(CalculateFinalAnimationSpeedMultiplier());
	}
	
	// Get absolute move speed
	import final function GetMoveSpeedAbs() : float;
	
	// Retrieve relative speed
	import final function GetMoveSpeedRel() : float;

	// Raise behavior event
	import final function RaiseBehaviorEvent( eventName : name ) : bool;
	
	// Raise behavior force event
	import final function RaiseBehaviorForceEvent( eventName : name ) : bool;
	
	// Find bone nearest to given world-space position, and return bone index. Bone position will be written back to 'position' argument.
	import final function FindNearestBoneWS( out position : Vector ) : int; 
	
	import final function FindNearestBoneToEdgeWS( a : Vector, b : Vector ) : int; 

	// Get current state name in beavior graph with input instance name
	import final function GetCurrentBehaviorState( optional instanceName : name ) : string;
	
	// Use with care!!! Freeze pose, behavior and other stuff can not be update ect.
	import final function FreezePose();
	
	// Use with care!!! Unfreeze pose
	import final function UnfreezePose();
	
		// Use with care!!! Freeze pose, behavior and other stuff can not be update ect.
	import final function FreezePoseFadeIn( fadeInTime : float );
	
	// Use with care!!! Unfreeze pose
	import final function UnfreezePoseFadeOut( fadeOutTime : float );
	
	// Use with care!!! Has frozen pose
	import final function HasFrozenPose() : bool;
	
	// Synchronize slave component to master ( this ) component
	import final function SyncTo( slaveComponent : CAnimatedComponent, ass : SAnimatedComponentSyncSettings ) : bool;
	
	// Test if extracted motion is being used
	import final function UseExtractedMotion() : bool;
	
	// Set if extracted motion is being used
	import final function SetUseExtractedMotion( use : bool ); 
	
	// Checks if the ragdoll resource is set
	import final function HasRagdoll() : bool;

	import final function GetRagdollBoneName( actorIndex : int ) : name;

	// Pull ragdoll to capsule if too far away
	import final function StickRagdollToCapsule( stick : bool);
	
	// Play animation on slot
	import final function PlaySlotAnimationAsync( animation : name, slotName : name, optional settings : SAnimatedComponentSlotAnimationSettings ) : bool;
	
	// Play animation directly on skeleton ( don't use animation graph ). Default value for 'looped' is false
	import final function PlaySkeletalAnimationAsync ( animation : name, optional looped : bool ) : bool;

	import final function GetBoneMatrixMovementModelSpaceInAnimation( boneIndex : int, animation : name, time : float, deltaTime : float, out boneAtTimeMS : Matrix, out boneWithDeltaTimeMS : Matrix );
}

/////////////////////////////////////////////

import class CDropPhysicsComponent extends CComponent
{
	import final function DropMeshByName( meshName : string,
										  optional direction : Vector /* = Vector::ZEROS */,
     								      optional curveName : name /* = CName::NONE */ ) : bool;
	import final function DropMeshByTag( meshTag : name,
                                          optional direction : Vector /* = Vector::ZEROS */,
     									  optional curveName : name /* = CName::NONE */ ) : bool;
}

/////////////////////////////////////////////

enum EDismembermentEffectTypeFlags
{ 
	DETF_Base		= 1, 
	DETF_Igni		= 2, 
	DETF_Aaard		= 4, 
	DETF_Yrden		= 8, 
	DETF_Quen		= 16,
	DETF_Mutation6	= 32, 
};

/*
defined in C++

enum EWoundTypeFlags
{
	WTF_None		= 0,
	WTF_Cut			= FLAG( 0 ),
	WTF_Explosion	= FLAG( 1 ),
	WTF_Frost		= FLAG( 2 ),
	WTF_All			= WTF_Cut | WTF_Explosion | WTF_Frost,
};
*/

import class CDismembermentComponent extends CComponent
{
	import final function IsWoundDefined( woundName : name ) : bool;
	import final function SetVisibleWound( woundName : name, optional spawnEntity : bool, optional createParticles : bool,
															 optional dropEquipment : bool, optional playSound : bool,
															 optional direction : Vector, optional playedEffectsMask : int );
	import final function ClearVisibleWound();
	import final function GetVisibleWoundName() : name;
	import final function CreateWoundParticles( woundName : name ) : bool;
	import final function GetNearestWoundName( positionMS : Vector, normalMS : Vector,
											   optional woundTypeFlags : EWoundTypeFlags /* = WTF_All */ ) : name;
	import final function GetNearestWoundNameForBone( boneIndex : int, normalWS : Vector,
													  optional woundTypeFlags : EWoundTypeFlags /* = WTF_All */ ) : name;
	import final function GetWoundsNames( out names : array< name >,
										  optional woundTypeFlags : EWoundTypeFlags /* = WTF_All */ );
	import final function IsExplosionWound( woundName : name ) : bool;
	import final function IsFrostWound( woundName : name ) : bool;
	import final function GetMainCurveName( woundName : name ) : name;
}

/////////////////////////////////////////////
// Component with bounds
/////////////////////////////////////////////

import class CBoundedComponent extends CComponent
{
	// Gets component's bounding box
	import final function GetBoundingBox() : Box;
}

import class CAreaComponent extends CBoundedComponent
{
	//WARNING ! ! !
	//this is broken if the bottom of bounding box of entity is below the lower border of area
	//WARNING 2 ! ! !
	//even if there is no overlap, function might return true!
	import final function TestEntityOverlap( ent : CEntity ) : Bool;
	
	import final function TestPointOverlap( point : Vector ) : Bool;
	
	import final function GetWorldPoints( out points : array< Vector > );
}

/////////////////////////////////////////////
// Component that can be drawn
/////////////////////////////////////////////

import class CDrawableComponent extends CBoundedComponent
{
	// Is component visible
	import final function IsVisible() : bool;
	
	// Set component visible
	import final function SetVisible( flag : bool );

	// Changes gameplay parameter ( used for highlighting )
//	import final function SetGameplayParameter( paramIdx : int, enable : bool, changeTime : float );
	
	// Is component casting shadows
	import final function SetCastingShadows ( flag : bool );

	// By default we use physical bounds
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		return GetPhysicalObjectBoundingVolume( box );
	}	
}

/////////////////////////////////////////////
// Mesh components
/////////////////////////////////////////////

import class CRigidMeshComponent extends CStaticMeshComponent
{
	// Enables buoyancy on rigid mesh physics wrapper. Returns true on success.
	import function EnableBuoyancy( enable : bool ) : bool;
}

/////////////////////////////////////////////
// Decal component
/////////////////////////////////////////////

import class CDecalComponent extends CDrawableComponent
{
}

/////////////////////////////////////////////
// Normal-Blend component
/////////////////////////////////////////////

import class CNormalBlendComponent extends CComponent
{
}

/////////////////////////////////////////////
// Sprite component
/////////////////////////////////////////////

import class CSpriteComponent extends CComponent
{
}

/////////////////////////////////////////////
// Generic waypoint component
/////////////////////////////////////////////

import class CWayPointComponent extends CSpriteComponent 
{
}

/////////////////////////////////////////////
// Trigger channels
/////////////////////////////////////////////

enum ETriggerChannels
{
	TC_Default			= 1,			// Default group
	TC_Player			= 2,			// Player
	TC_Camera			= 4,			// Camera object
	TC_NPC				= 8,			// General NPC
	TC_SoundReverbArea	= 16,			// Sound source
	TC_SoundAmbientArea	= 32,			// Sound ambient area external shell
	TC_Quest			= 64,			// Used in quest conditions
	TC_Projectiles		= 128,			// Projectiles' collisions
	TC_Horse			= 256,			// Horse collisions	
	TC_Custom0			= 65536,		// Custom group
	TC_Custom1			= 131072,		// Custom group
	TC_Custom2			= 262144,		// Custom group
	TC_Custom3			= 524288,		// Custom group
	TC_Custom4			= 1048576,		// Custom group
	TC_Custom5			= 2097152,		// Custom group
	TC_Custom6			= 4194304,		// Custom group
	TC_Custom7			= 8388608,		// Custom group
	TC_Custom8			= 16777216,		// Custom group
	TC_Custom9			= 33554432,		// Custom group
	TC_Custom10			= 67108864,		// Custom group
	TC_Custom11			= 134217728,	// Custom group
	TC_Custom12			= 268435456,	// Custom group
	TC_Custom13			= 536870912,	// Custom group
	TC_Custom14			= 1073741824,	// Custom group
};

/////////////////////////////////////////////
// Generic trigger component
/////////////////////////////////////////////

import class CTriggerAreaComponent extends CAreaComponent
{
	// Change the trigger area channel masks
	import final function SetChannelMask( includedChannels, excludedChannes : int );
	
	// Add a trigger channel to the included channels list (trigger will start reacting to activators on this channel)
	import final function AddIncludedChannel( channel : ETriggerChannels );

	// Remove a trigger channel from the included channels list (trigger will stop reacting to activators on this channel)
	import final function RemoveIncludedChannel( channel : ETriggerChannels );

	// Add a trigger channel to the excluded channels list (trigger will ignore activators on this channel)
	import final function AddExcludedChannel( channel : ETriggerChannels );

	// Remove a trigger channel from the excluded channels list (trigger will ignore activators on this channel)
	import final function RemoveExcludedChannel( channel : ETriggerChannels );
	
	// Get entities inside area. Slow!!! Use with caution!!!
	public function GetGameplayEntitiesInArea( out entities : array< CGameplayEntity >, optional range : float, optional onlyActors : bool )
	{
		var i, curr, size : int;
		var source : CEntity;
		var box : Box;
		
		box = GetBoundingBox();
		if ( range == 0 )
		{
			range = GetBoxRange( box );
		}
		else 
		{
			range = MinF( range, GetBoxRange( box ) );
		}
	
		source = GetEntity();
		if ( onlyActors )
		{
			FindGameplayEntitiesInRange( entities, source, range, 1000, /* tag */, FLAG_ExcludeTarget + FLAG_OnlyActors, (CGameplayEntity)source );
		}
		else
		{
			FindGameplayEntitiesInRange( entities, source, range, 1000, /* tag */, FLAG_ExcludeTarget, (CGameplayEntity)source );
		}
		
		size = entities.Size();
		curr = 0;
		for ( i = 0; i < size; i+=1 )
		{
			if ( TestEntityOverlap( entities[ i ] ) )
			{
				entities[ curr ] = entities[ i ];
				curr += 1;
			}
		}
		entities.Resize( curr );
	}
}

/////////////////////////////////////////////
// Generic trigger activator
/////////////////////////////////////////////

import class CTriggerActivatorComponent extends CComponent
{
	// Change radius of the trigger activator
	import final function SetRadius( radius : float );
	
	// Change height of the trigger activator
	import final function SetHeight( height : float );
	
	// Get radius of the trigger activator
	import final function GetRadius() : float;
	
	// Get height of the trigger activator
	import final function GetHeight() : float;
	
	// Add activator to given trigger channel (activator will start interacting with triggers on this channel)
	import final function AddTriggerChannel( channel : ETriggerChannels );
	
	// Remove activator from given trigger channel
	import final function RemoveTriggerChannel( channel : ETriggerChannels );
}

/////////////////////////////////////////////
// Combat data
/////////////////////////////////////////////

import class CCombatDataComponent extends CComponent
{
	// Get number of attackers
	import final function GetAttackersCount() : int;
	import final function GetTicketSourceOwners( out actors : array< CActor >, ticketName : name );
	import final function HasAttackersInRange( range : float ) : bool;
	
	// Modifies ticket pool. Return override id used to cancel this precise override request. Returns -1 on faiulure.
	import final function TicketSourceOverrideRequest( ticketName : name, ticketsCountMod : int, minimalImportanceMod : float ) : int;
	// Clears ticket source override. Use override id provided from above function. Returns false on failure.
	import final function TicketSourceClearRequest( ticketName : name, requestId : int ) : bool;
	// Force importance update for every1 interested in given ticket.
	import final function ForceTicketImmediateImportanceUpdate( ticketName : name );
	
}

/////////////////////////////////////////////
// Destruction system
/////////////////////////////////////////////

import class CDestructionSystemComponent extends CDrawableComponent
{
	import final function GetFractureRatio() : float;
	import final function ApplyFracture() : bool;
	import final function IsDestroyed() : bool;
	import final function IsObstacleDisabled() : bool;
	
	// For destructions, let's try to use "visual" bounding box first
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		// first, lets try to use bounding box directly from drawable component	
		box = GetBoundingBox();
		if ( box.Min != box.Max )
		{
			return true;
		}
		// if this is not enough, calculate physical bounding box (can be expensive for many actors/shapes - e.g. CDestructionSystemComponent)
		return GetPhysicalObjectBoundingVolume( box );
	}	
}

/////////////////////////////////////////////
// Destruction system
/////////////////////////////////////////////

import class CDestructionComponent extends CMeshTypeComponent
{
	import final function ApplyFracture() : bool;
	import final function IsDestroyed() : bool;
	import final function IsObstacleDisabled() : bool;
	
	// For destructions, let's try to use "visual" bounding box first
	public function GetObjectBoundingVolume( out box : Box ) : bool
	{
		// first, lets try to use bounding box directly from drawable component	
		box = GetBoundingBox();
		if ( box.Min != box.Max )
		{
			return true;
		}
		// if this is not enough, calculate physical bounding box (can be expensive for many actors/shapes - e.g. CDestructionSystemComponent)
		return GetPhysicalObjectBoundingVolume( box );
	}	
}

import class CSoundAmbientAreaComponent extends CSoftTriggerAreaComponent
{

}

/////////////////////////////////////////////
// Cloth component
/////////////////////////////////////////////

import class CClothComponent extends CMeshTypeComponent
{
	import final function SetSimulated( value : bool );
	import final function SetMaxDistanceScale( scale : float );
	import final function SetFrozen( frozen : bool );
}
