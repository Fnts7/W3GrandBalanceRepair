/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Entity spawn data
/////////////////////////////////////////////
import struct SEntitySpawnData
{
	import var restored : bool;
}

/////////////////////////////////////////////
// Entity class
/////////////////////////////////////////////
import class CEntity extends CNode
{	
	//////////////////////////////////////////////////////////////////////////////////////////

	// Add named real time based timer to entity; returns unique timer id
	import final function AddTimer( timerName : name, period : float, optional repeats : bool /* false */, optional scatter : bool /* false */, optional group : ETickGroup /* Main */, optional saveable : bool /* false */, optional overrideExisting : bool /* true */ ) : int;
	// Add named gameplay time based timer to entity; returns unique timer id
	import final function AddGameTimeTimer( timerName : name, period : GameTime, optional repeats : bool /* false */, optional scatter : bool /* false */, optional group : ETickGroup /* Main */, optional saveable : bool /* false */, optional overrideExisting : bool /* true */ ) : int;
	// Removes all timers with matching name from entity (in given group or all groups if none is specified)
	import final function RemoveTimer( timerName : name, optional group : ETickGroup );
	// Removes all timers with matching id from entity (in given group or all groups if none is specified)
	import final function RemoveTimerById( id : int, optional group : ETickGroup );
	// Remove all timers from entity
	import final function RemoveTimers();
	// Checks if the entity is in a layer with the given tag
	import final function HasTagInLayer( tag : name ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Destroy this entity
	import final function Destroy();

	//////////////////////////////////////////////////////////////////////////////////////////	

	// Duplicate entity and place it on layer
	import final function Duplicate( optional placeOnLayer : CLayer ) : CEntity;
	
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	// Teleport entity to new location
	import final function Teleport( position : Vector );

	// Teleport entity to new location
	import final function TeleportWithRotation(position : Vector, rotation : EulerAngles );
	
	// Teleport entity to node (for CActor TeleportToWaypoint is used if possible)
	import final function TeleportToNode( node : CNode, optional applyRotation : bool /*= true */ ) : bool;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get root animated component
	import final function GetRootAnimatedComponent() : CAnimatedComponent;
	
	// Rise behavior event, returns true if event was processed
	import final function RaiseEvent( eventName : name ) : bool;
	
	// Rise behavior force event, returns true if event was processed
	import final function RaiseForceEvent( eventName : name ) : bool;
	
	// E3 hack dont use it
	import final function RaiseEventWithoutTestCheck( eventName : name ) : bool;
	import final function RaiseForceEventWithoutTestCheck( eventName : name ) : bool;
	// E3 hack end
	
	// Wait for behavior event processing. Default timeout is 10s. Return false if timeout occurred.
	import final latent function WaitForEventProcessing( eventName : name, timeout : float ) : bool;

	// Wait for behavior node activation. Default timeout is 10s. Return false if timeout occurred.
	import final latent function WaitForBehaviorNodeActivation( activationName : name, timeout : float ) : bool;
	
	// Wait for behavior node deactivation. Default timeout is 10s. Return false if timeout occurred.
	import final latent function WaitForBehaviorNodeDeactivation( deactivationName : name, timeout : float ) : bool;
	
	// Wait for animation event
	import final latent function WaitForAnimationEvent( animEventName : name, timeout : float ) : bool;
	
	// Check if node deactivation notification was received last frame
	import final function BehaviorNodeDeactivationNotificationReceived( deactivationName : name ) : bool;
	
	// Get the displayName from the entity
	import function I_GetDisplayName() : string;
	
	import function CalcBoundingBox( out box : Box );
	
	// Event called on behavior graph notification
	event OnBehaviorGraphNotification( notificationName : name, stateName : name ){}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	This function is super slow!!! You should cache bone index once and use it later.
	*/
	final function GetBoneWorldPosition( boneName : name ) : Vector
	{
		var boneIdx : int;
		var boneMatrix : Matrix;
		
		boneIdx = GetBoneIndex( boneName );
		
		if( boneIdx != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIdx );
			
			return MatrixGetTranslation( boneMatrix );
		}
		
		return Vector(0,0,0,1);
	}
	
	final function GetBoneWorldPositionByIndex( boneIndex : int ) : Vector
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			return MatrixGetTranslation( boneMatrix );
		}
		
		return Vector(0,0,0,1);
	}
	
	final function GetBoneWorldRotationByIndex( boneIndex : int ) : EulerAngles
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			return MatrixGetRotation( boneMatrix );
		}
		
		return EulerAngles(0,0,0);
	}
	
	final function GetBoneWorldPositionAndRotationByIndex(boneIndex : int, out position : Vector, out rotation : EulerAngles)
	{
		var boneMatrix : Matrix;
		
		if( boneIndex != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIndex );
			
			position = MatrixGetTranslation( boneMatrix );
			rotation =  MatrixGetRotation( boneMatrix );
		}
		else
		{
			position = Vector(0,0,0,1);
			rotation = EulerAngles(0,0,0);
		}
	}
	
	final function GetBoneWorldMatrix( boneName : name ) : Matrix
	{
		var boneIdx : int;
		var boneMatrix : Matrix;
		
		boneIdx = GetBoneIndex( boneName );
		
		if( boneIdx != -1 )
		{
			boneMatrix = GetBoneWorldMatrixByIndex( boneIdx );
		}
		
		return boneMatrix;
	}
	/**
	
	*/
	
	// Calc entity slot matrix (returns true if slot exists)
	import final function CalcEntitySlotMatrix( slot : name, out slotMatrix : Matrix ) : bool;

	// Get bone world matrix by index
	import final function GetBoneWorldMatrixByIndex( boneIndex : int ) : Matrix;

	// Get bone reference model space matrix by index
	import final function GetBoneReferenceMatrixMS( boneIndex : int ) : Matrix;

	// Get bone index, -1 if didn't find
	import final function GetBoneIndex( bone : name ) : int;
	
	// Get move target
	import final function GetMoveTarget() : Vector;
	
	// Get move final heading
	import final function GetMoveHeading() : float;
	
	// Preload behavior graph instances to activate them
	import final latent function PreloadBehaviorsToActivate( names : array< name > ) : bool;

	// Activate behavior graph instances
	import final latent function ActivateBehaviors( names : array< name > ) : bool;
	
	import final function ActivateBehaviorsSync( names : array< name > ) : bool; 
	
	// Activate and sync behavior graph instances
	import final latent function ActivateAndSyncBehaviors( names : array< name >, optional timeout : float ) : bool;
	
	// Activate and sync behavior graph instances
	import final latent function ActivateAndSyncBehavior( names : name, optional timeout : float ) : bool;
	
	// Attach behavior graph
	import final latent function AttachBehavior( instanceName : name ) : bool;
	
	// Attach behavior graph - only for permanent behaviors!
	import final function AttachBehaviorSync( instanceName : name ) : bool;
	
	// Detach behavior graph
	import final function DetachBehavior( instanceName : name ) : bool;
	
	// Get behavior float variable
	import final function GetBehaviorVariable( varName : name, optional defaultValue : float ) : float;
	
	// Get behavior vector variable
	import final function GetBehaviorVectorVariable( varName : name ) : Vector;
	
	// Set behavior float variable
	import final function SetBehaviorVariable( varName : name, varValue : float, optional inAllInstances : bool ) : bool;
	
	// Set behavior vector variable
	import final function SetBehaviorVectorVariable( varName : name, varValue : Vector, optional inAllInstances : bool ) : bool;
	
	// Get behavior graph instance name with given index (default is 0)
	import final function GetBehaviorGraphInstanceName( optional index : int ) : name;

	// Notify the code
	// import final function OnAardHit(); // deprecated
	
	// Fade
	import final function Fade( fadeIn : bool );
	
	// Hide/Show entity + its compoments + entities attached to it recursively
	import final function SetHideInGame( hide : bool );
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get component by name
	import function GetComponent( compName : string ) : CComponent;

	// Get first component of given class
	import function GetComponentByClassName( className : name ) : CComponent;
	
	// Get first component of given class
	import function GetComponentsByClassName( className : name ) : array< CComponent >;
	
	import function GetComponentByUsedBoneName( boneIndex : int ) : array< CComponent >;

	// Get number of components of given class
	import function GetComponentsCountByClassName( className : name ) : int;

	import function GetAutoEffect() : name;
	import function SetAutoEffect( effectName : name ) : bool; 
	import function PlayEffect( effectName : name, optional target : CNode  ) : bool;	
	import function PlayEffectOnBone( effectName : name, boneName : name, optional target : CNode ) : bool;
	import function StopEffect( effectName : name ) : bool;
	import function DestroyEffect( effectName : name ) : bool;
	import function StopAllEffects();
	import function DestroyAllEffects();
	
	// If treatStoppingAsActive is true, then if the effect is stopping this function will return true, otherwise it will return false
	// ACHTUNG treatStoppingAsActive IS TRUE BY DEFAULT!!!!!!
	import function IsEffectActive( effectName : name, optional treatStoppingAsActive : bool ) : bool;
	
	import function SetEffectIntensity( effectName : name, intensity : float, optional specificComponentName : name, optional effectParameterName : name );
	import function HasEffect( effectName : name ) : bool;
	
	public function PlayEffectSingle( effectName : name, optional target : CNode  ) : bool
	{
		if(!IsEffectActive(effectName, false))
			return PlayEffect(effectName, target);
			
		return false;
	}
	
	public function StopEffectIfActive( effectName : name ) : bool
	{
		if( IsEffectActive(effectName, false) )
		{
			return StopEffect( effectName );
		}
		return false;
	}
	
	public function DestroyEffectIfActive( effectName : name ) : bool
	{
		if( IsEffectActive(effectName, true) )
		{
			return DestroyEffect( effectName );
		}
		return false;
	}
	
	//uses data set by SoundSwitch to pick proper sound from the graph and play it
	import function SoundEvent( eventName : string, optional boneName : name, optional isSlot : bool );

	//Play a start event and than after a duration a stop event, optionally can update an 'eventTime' parameter on the gameObject
	import function TimedSoundEvent(duration : float, optional startEvent : string, optional stopEvent : string, optional shouldUpdateTimeParameter : bool, optional boneName : name);
	
	//only sets data sound, does not play it
	import function SoundSwitch( swichGroupName : string, optional stateName : string, optional boneName : name, optional isSlot : bool );
	
	import function SoundParameter( parameterName : string, value : float, optional boneName : name, optional duration : float, optional isSlot : bool );
	import function SoundIsActiveAny() : bool;
	import function SoundIsActiveName( eventName : name ) : bool;
	import function SoundIsActive( boneName : name, optional isSlot : bool ) : bool;

	import function PreloadEffect( effectName : name ) : bool;
	import function PreloadEffectForAnimation( animName : name ) : bool;
	
	import function SetKinematic( enable : bool );
	import function SetStatic( );
	import function IsRagdolled() : bool;
	import function IsStatic() : bool;
	
	import function GetGuidHash() : int;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Attachments
	// Flow:
	// 		CreateAttachment ( child->CreateAttachment( parent ) ):
	//			1. child->CanCreateParentAttachment( parent )
	//			 and
	//			   parent->CanCreateChildAttachment( child )
	//			2. creating attachment... (engine)
	//			3. child->OnParentAttachmentCreated( parent )
	//			4. parent->OnChildAttachmentCreated( child )
	//		BreakAttachment ( child->BreakAttachment() )
	//			...
	
	import function CreateAttachment( parentEntity : CEntity, optional entityTemplateSlot : name, optional relativePosition : Vector, optional relativeRotation : EulerAngles ) : bool;
	import function BreakAttachment() : bool;
	import function HasAttachment() : bool;
	import function HasSlot( slotName : name, optional recursive : bool ) : bool;

	// attach at bone using location and rotation in world space
	import function CreateAttachmentAtBoneWS( parentEntity : CEntity, bone : name, worldLocation : Vector, worldRotation : EulerAngles ) : bool;

	import function CreateChildAttachment( child : CNode, optional slot : name ) : bool;
	import function BreakChildAttachment( child : CNode, optional slot : name ) : bool;
	import function HasChildAttachment( child : CNode ) : bool;
	
	event OnCanCreateParentAttachment( parentEntity : CEntity ) { return true; }
	event OnCanBreakParentAttachment( parentEntity : CEntity ) 	{ return true; }
	
	event OnCanCreateChildAttachment( childEntity : CEntity ) 	{ return true; }
	event OnCanBreakChildAttachment( childEntity : CEntity ) 	{ return true; }
	
	event OnParentAttachmentCreated( parentEntity : CEntity ){}
	event OnParentAttachmentBroken( parentEntity : CEntity ){}
	
	event OnChildAttachmentCreated( childEntity : CEntity ){}
	event OnChildAttachmentBroken( childEntity : CEntity ){}
	
	
	function GetReadableName() : string
	{
		var s1,s2 : string;
	
		if( StrSplitLast( ToString(), "::", s1, s2 ) )
		{
			return s2;
		}
		else
		{
			return ToString();
		}
	}
	
	// Selects a different appearance for the entity.
	function ApplyAppearance( appearanceName : string )
	{
		var comp : CAppearanceComponent;
		comp = (CAppearanceComponent)GetComponentByClassName( 'CAppearanceComponent' );
		if ( comp )
		{
			comp.ApplyAppearance( appearanceName );
		}
	}
	
	function DestroyAfter( time : float )
	{
		AddTimer('DestroyTimer',time,false, , , true);
	}
	
	function StopAllEffectsAfter( time : float )
	{
		AddTimer('StopAllEffectsTimer',time,false, , , true);
	}
	
	private timer function DestroyTimer( delta : float , id : int)
	{
		Destroy();
	}
	
	private timer function StopAllEffectsTimer ( delta : float , id : int)
	{
		StopAllEffects();
	}
	
	public final function RemoveTag(tag : name)
	{
		var tags : array<name>;
		
		tags = GetTags();
		tags.Remove(tag);
		SetTags(tags);
	}
	
	//Snaps given component to terrain or static mesh. First it performs test from current position downwards, then from current position upwards.
	//
	//componentName - name of the component to snap
	//maxHeightDown - max distance tested downwards
	//maxHeightUp   - max distance tested upwards
	//
	//returns: true if snapped, false otherwise. If snapped newPos holds new component position else (0,0,0)
	protected function SnapComponentByName(componentName : name, maxHeightDown : float, maxHeightUp : float, collisionNames : array<name>, out newPos : Vector) : bool
	{
		var component : CComponent;
		var entityPos, componentPos, testUpPos, testDownPos, collisionNormal : Vector;
				
		component = GetComponent(componentName);		
		if(!component)
		{
			LogAssert(false, "CEntity.SnapComponentToTerrain: cannot snap component <<" + componentName + ">> - cannot find component with such name");
			newPos = Vector(0,0,0);
			return false;
		}
	
		entityPos      = GetWorldPosition();
		componentPos   = entityPos + component.GetLocalPosition();
		
		testUpPos      = componentPos;
		testUpPos.Z   += maxHeightUp;
		testDownPos    = componentPos;
		testDownPos.Z -= maxHeightDown;		

		//first test downwards
		if ( theGame.GetWorld().StaticTrace(componentPos, testDownPos, newPos, collisionNormal, collisionNames) )
		{
			component.SetPosition(newPos - entityPos);	//SetPos uses local space
			return true;
		}
		else
		{
			//if failed test upwards (starting from current position)
			if ( theGame.GetWorld().StaticTrace(componentPos, testUpPos, newPos, collisionNormal, collisionNames) )
			{
				component.SetPosition(newPos - entityPos);	//SetPos uses local space
				return true;
			}
		}
		
		//if not found		
		newPos = Vector(0,0,-1000);
		component.SetPosition(newPos);
		return false;
	}
	
	//Snaps given component to terrain or static mesh. First it performs test from current position downwards, then from current position upwards.
	//
	//componentName - component to snap
	//maxHeightDown - max distance tested downwards
	//maxHeightUp   - max distance tested upwards
	//
	//returns: true if snapped, false otherwise. If snapped newPos holds new component position else (0,0,0)
	protected function SnapComponent(component : CComponent, maxHeightDown : float, maxHeightUp : float, collisionNames : array<name>, out newPos : Vector) : bool
	{
		var entityPos, componentPos, testUpPos, testDownPos, collisionNormal : Vector;
		
		if(!component)
		{			
			LogAssert(false, "CEntity.SnapComponentToTerrain: cannot snap component <<" + component + ">> - cannot find component!");
			newPos = Vector(0,0,0);
			return false;
		}
	
		entityPos      = GetWorldPosition();
		componentPos   = entityPos + component.GetLocalPosition();
		
		testUpPos      = componentPos;
		testUpPos.Z   += maxHeightUp;
		testDownPos    = componentPos;
		testDownPos.Z -= maxHeightDown;		

		//first test downwards
		if ( theGame.GetWorld().StaticTrace(componentPos, testDownPos, newPos, collisionNormal, collisionNames) )
		{
			component.SetPosition(newPos);
			return true;
		}
		else
		{
			//if failed test upwards (starting from current position)
			if ( theGame.GetWorld().StaticTrace(componentPos, testUpPos, newPos, collisionNormal, collisionNames) )
			{
				component.SetPosition(newPos);
				return true;
			}
		}
		
		//if not found
		newPos = Vector(0,0,0);
		return false;
	}
}

import function EntityHandleGet( handle : EntityHandle ) : CEntity;
import function EntityHandleSet( handle : EntityHandle, entity : CEntity );

import function PreloadEffectForEntityTemplate( entityTemplate : CEntityTemplate, effectName : name ) : bool;
import function PreloadEffectForAnimationForEntityTemplate( entityTemplate : CEntityTemplate, animName : name ) : bool;



