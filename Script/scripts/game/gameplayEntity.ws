  /***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2010 Dexio's Late Night R&D Home Center
/***********************************************************************/

import class IPerformableAction extends CObject
{
	import final function Trigger( parnt : CEntity );
	import final function TriggerArgNode( parnt : CEntity, node : CNode );
	import final function TriggerArgFloat( parnt : CEntity, value : float );
}

function TriggerPerformableEvent( actionList : array< IPerformableAction >, parnt : CEntity )
{
	var i : int;
	var size : int = actionList.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		actionList[ i ].Trigger( parnt );
	}
}

function TriggerPerformableEventArgNode( actionList : array< IPerformableAction >, parnt : CEntity, node : CNode )
{
	var i : int;
	var size : int = actionList.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		actionList[ i ].TriggerArgNode( parnt, node );
	}
}

import class CScriptedAction extends IPerformableAction
{
	function Perform( parnt : CEntity )
	{
		LogAssert( false, "CScriptedAction::Perform() not implemented" );
	}

	function PerformArgNode( parnt : CEntity, node : CNode )
	{
		Perform( parnt );
	}

	function PerformArgFloat( parnt : CEntity, value : float )
	{
		Perform( parnt );
	}
}

import class CGameplayEntityParam extends CEntityTemplateParam
{

};

import class CBloodTrailEffect extends CGameplayEntityParam
{
	import final function GetEffectName() : name;
};

import class CGameplayEntity extends CPeristentEntity
{
	editable var minLootParamNumber			: int;					default minLootParamNumber = -1; // min & max specify how many loot params should be added to container
	editable var maxLootParamNumber			: int;					default maxLootParamNumber = -1; // -1 means all, handled from code

	import final function GetInventory() : CInventoryComponent;
	import protected final function GetCharacterStats() : CCharacterStats;
	public final function GetAllAttributes() : array<name>
	{
		var atts : array<name>;
		GetCharacterStats().GetAllAttributesNames(atts);
		return atts;
	}
	
	//called when entity is spawned by editor but not ingame - ACHTUNG!!! All objects inheriting from CActor are spawned as CActor!!!
	event OnSpawnedEditor( spawnData : SEntitySpawnData ){}

	// If 'fallBack' is false, then display name is taken only from the gameplay entity
	import final function GetDisplayName( optional fallBack : bool /* = true */ ) : string;
	
	// Plays animation on all linked properties; count of 0 indicates infinite looping; lengthScale defaults to 1.0f and mode defaults to EPropertyCurveMode_Forward
	import final function PlayPropertyAnimation( animationName : name, optional count : int, optional lengthScale : float, optional mode : EPropertyCurveMode );
	// Stops property animation on all linked properties; NOTE: changes property value immediately
	import final function StopPropertyAnimation( animationName : name, optional restoreInitialValues : bool );
	// Rewinds property animation on all linked properties to given time; NOTE: changes property value immediately
	import final function RewindPropertyAnimation( animationName : name, time : float );
	// Gets current time of running property animation instance; on failure returns 0.0f
	import final function GetPropertyAnimationInstanceTime( propertyName : name, animationName : name ) : float;
	// Gets property animation length; on failure returns 0.0f
	import final function GetPropertyAnimationLength( propertyName : name, animationName : name ) : float;
	// Gets property animation transform at given time; on failure returns identity transform
	import final function GetPropertyAnimationTransformAt( propertyName : name, animationName : name, time : float ) : Matrix;

	import final function GetGameplayEntityParam( className : name ) : CGameplayEntityParam;

	// Adds animation event callback
	import final function AddAnimEventCallback( eventName : name, functionName : name );
	// Removes animation event callback
	import final function RemoveAnimEventCallback( eventName : name );
	// Adds animation event child callback
	import final function AddAnimEventChildCallback( child : CNode, eventName : name, functionName : name );
	// Removes animation event child callback
	import final function RemoveAnimEventChildCallback( child : CNode, eventName : name );
	
	// Gets the SFX tag associated with this NPC
	import final function GetSfxTag() : CName;

	// Returns bb calculated based on CAttackableArea params, or on physics for actors
	import function GetStorageBounds( out box : Box );
	
	// Get runtime cached gameplay info
	// Possible types:
	// EGameplayInfoCacheType:
	// - GICT_IsInteractive - has interactive components
	// - GICT_HasDrawableComponents - has drawable components
	// - GICT_Custom0 - CFocusModeController: IsFocusSoundClue
	// - GICT_Custom1 - CombatTargetSelection: IsMonster
	// - GICT_Custom2 - W3MonsterClue: testLineOfSight property
	// - GICT_Custom3 - CInventoryComponent: HasAssociatedInventory
	// - GICT_Custom4 - focus mode visibility was updated
	import final function GetGameplayInfoCache( type : EGameplayInfoCacheType ) : bool;

	// Get focus mode visibility type
	import final function GetFocusModeVisibility() : EFocusModeVisibility;
	
	// Set focus mode visibility type
	// Use persistent = true only for entities for which visibiltiy is not handled by their classes (in general, only for CGameplayEntity or CNewNPC)
	// If force = true, the change will hapen also if the current visibility type is the same
	import final function SetFocusModeVisibility( focusModeVisibility : EFocusModeVisibility, optional persistent : bool, optional force : bool );

	// Turn on/off visual debug for the specified entity with giver filter.
	// When turned off, the entity will recevie OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags) event.
	// Does not work in final build!!!
	import final function EnableVisualDebug( flag : EShowFlags, enable : bool );
	
	import var aimVector : Vector;
	editable var iconOffset	: Vector;
	
	public	var highlighted			: bool;					//set to prevent stacking multiple FX
	
	public var focusModeSoundEffectType : EFocusModeSoundEffectType;
	default focusModeSoundEffectType = FMSET_None;
	var isPlayingFocusSound			: bool;
	default isPlayingFocusSound		= false;

	var isColorBlindMode			: bool;
	default isColorBlindMode		= false;
	
	// possible values:
	// - '' 		- not initialized
	// - 'entity' 	- no bone, play on entity
	// - 'bone_name - name of the bone that will be used to play effect
	var	focusSoundVisualEffectBoneName	: name;
	default focusSoundVisualEffectBoneName = '';

	editable var isHighlightedByMedallion : bool;
	editable var isMagicalObject 			: bool;
	hint isHighlightedByMedallion = "Highlight entity when it is scanned by Player's medallion";
	
	default isHighlightedByMedallion = true;
	default isMagicalObject = false;
	
	//THE SOUND
	editable var soundEntityName : string;
	editable var soundEntityGender : string;
	editable var soundEntitySet : string;
	
	// -----------------------------------------------------------------
	// Events
	// -----------------------------------------------------------------
	event OnGameplayPropertyChanged( propertyName : name ){}
	
	// Entity was dynamically spawned
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		isPlayingFocusSound = false;
		if ( soundEntityName )
			SoundSwitch("entity_name",soundEntityName);
		if ( soundEntityGender )
			SoundSwitch("entity_gender",soundEntityGender);
		if ( soundEntitySet )
			SoundSwitch("entity_sound_set",soundEntitySet);
	} 
	
	// Entity was destroyed
	event OnDestroyed()
	{
	}
	
	//On action ended
	event OnPlayerActionEnd()
	{
	}
	
	//On action start finished
	event OnPlayerActionStartFinished()
	{
	}
	
	//On sync anim leave state
	event OnSyncAnimEnd()
	{
	}

	// CPreAttackEvent
	event OnPreAttackEvent( animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
	}	

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Taking Damage
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function IsAlive() : bool 																	{return true;}	
	public function HasAbility(abilityName : name, optional includeInventoryAbl : bool) : bool			{return GetCharacterStats().HasAbility(abilityName, includeInventoryAbl);}
	public function AddAbility(abilityName : name, optional allowMultiple : bool) : bool				{return GetCharacterStats().AddAbility(abilityName,allowMultiple);}	
	public function RemoveAbility(abilityName : name)													{GetCharacterStats().RemoveAbility(abilityName);}
	public function AddAbilityMultiple(abilityName : name, count : int)									{GetCharacterStats().AddAbilityMultiple(abilityName, count);}
	public function RemoveAbilityMultiple(abilityName : name, count : int)								{GetCharacterStats().RemoveAbilityMultiple(abilityName, count);}
	public function RemoveAbilityAll(abilityName : name)												{GetCharacterStats().RemoveAbilityAll(abilityName);}
	public function GetAbilityCount(abilityName : name) : int											{return GetCharacterStats().GetAbilityCount(abilityName);}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function AddTag(tag : name)
	{
		var i : int;
		var ents : array<CGameplayEntity>;
		var area : CTriggerAreaComponent;
		var toxic : W3ToxicCloud;
		
		super.AddTag(tag);
		
		//if added fire then do a fire hit on all explosive entities
		if(tag == theGame.params.TAG_OPEN_FIRE)
		{
			FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 20, 100000, theGame.params.TAG_EXPLODING_GAS);
			for(i=0; i<ents.Size(); i+=1)
			{
				toxic = (W3ToxicCloud)ents[i];
				if(toxic)
				{
					area = toxic.GetGasAreaUnsafe();
					if(area && area.TestEntityOverlap(this))
						ents[i].OnFireHit(this);
				}
			}
		}
	}
		
	timer function MedallionEffectOff( deltaTime : float , id : int)
	{
		SetHighlighted( false );
		StopEffect( 'medalion_detection_fx' );
	}
	
	timer function EnemyHighlightOff(dt : float, id : int)
	{
		var catComponent : CGameplayEffectsComponent;
		
		catComponent = GetGameplayEffectsComponent(this);
		if(catComponent)
		{
			catComponent.ResetGameplayEffectFlag(EGEF_CatViewHiglight);
		}
	}
	
	timer function SonarEffectOff( deltaTime : float , id : int)
	{
		StopEffect( 'fx_sonar_detection' );
	}
	
	function FocusEffectOff()
	{
		StopEffect( 'focus_activation_fx' );
	}
	
	private var cutsceneForbiddenFXs: array<name>;
	
	public function AddCutsceneForbiddenFX( fx : name )
	{
		if( !cutsceneForbiddenFXs.Contains( fx ) )
		{
			cutsceneForbiddenFXs.PushBack( fx );
		}
	}
	public function StopCutsceneForbiddenFXs()
	{
		var i : int;
		for ( i = 0; i < cutsceneForbiddenFXs.Size() ; i += 1 )
		{
			StopEffectIfActive( cutsceneForbiddenFXs[i] );
		}
	}
	
	public function SetHighlighted( b : bool )
	{
		highlighted = b;
	}
	
	public function IsHighlighted() : bool
	{
		return highlighted;
	}
	
	public function ShouldBlockGameplayActionsOnInteraction() : bool
	{
		return false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////  @ITEMS  //////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//callback from CInventoryComponent, called when item was added to inventory
	event OnItemGiven(data : SItemChangedData){}
	
	//callback from CInventoryComponent, called when item was taken from inventory
	event OnItemTaken(itemId : SItemUniqueId, quantity : int){}
	
	/////////////////////////////////////////////
	// Medallion vibrates when Geralt sense magic
	/////////////////////////////////////////////
	function SenseMagic()
	{
		if ( thePlayer.PlayerCanComment() )
		{
			GetComponent("Medallion").SetEnabled( true );
			thePlayer.PlayerCommentary( PC_MedalionWarning );
		}
		GetWitcherPlayer().GetMedallion().Activate( true, 5.0f );
	}
	
	function AddSignHitFacts( sign : W3SignProjectile, signType : string )
	{
		AddHitFacts( GetTags(), sign.caster.GetTags(), signType );
	}
	
	event OnWeaponHit (act : W3DamageAction)
	{
	}
	
	event OnBoltHit()
	{
	
	}
		
	// SIGNS EVENTS	
	event OnAardHit( sign : W3AardProjectile )
	{
		var i : int;
		var doors : array<CComponent>;
		var R4Components : array < CComponent >;
		var gameLightComp : CGameplayLightComponent;
		
		AddSignHitFacts( sign, "_aard_hit" );
		
		// notify any door components 
		doors = GetComponentsByClassName('CDoorComponent');
		for(i=0; i<doors.Size(); i+=1)
		{
			((CDoorComponent)doors[i]).AddForceImpulse( sign.caster.GetWorldPosition(), 3000.0f );
		}
		
		R4Components = GetComponentsByClassName('CR4Component');
		for(i=0; i< R4Components.Size(); i+=1)
		{
			((CR4Component) R4Components[i]).OnAardHit();
		}
		
		if ( HasEffect('aardReaction') && !IsEffectActive('aardReaction') )
		{
			PlayEffect('aardReaction');
		}

		//notify the gameplay light component, if any (aard can turn off light sources)
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			gameLightComp.AardHit();
		}
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		var i : int;
		var gameLightComp : CComponent;
		var R4Components : array < CComponent >;
		
		AddSignHitFacts( sign, "_igni_hit" );

		//notify the gameplay light component, if any (igni can turn on light sources)
		gameLightComp = GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			((CGameplayLightComponent)gameLightComp).IgniHit();
		}
		
		R4Components = GetComponentsByClassName('CR4Component');
		for(i=0; i < R4Components.Size(); i+=1)
		{
			((CR4Component) R4Components[i]).OnIgniHit();
		}
	
		OnFireHit(sign);
	}
	
	event OnAxiiHit( sign : W3AxiiProjectile )
	{
		AddSignHitFacts( sign, "_axii_hit" );
	}
	
	event OnFrostHit(source : CGameplayEntity)
	{
		var gameLightComp 	: CGameplayLightComponent;
		var fireAuraCmp		: W3FireAuraManagerComponent;
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');

		if(gameLightComp)
		{
			gameLightComp.FrostHit();
		}
		
		fireAuraCmp = (W3FireAuraManagerComponent) GetComponentByClassName('W3FireAuraManagerComponent');
		if( fireAuraCmp )
		{
			fireAuraCmp.DeactivateAura();
		}
	}
	
	// event raised after entity was hit by fire
	event OnFireHit(source : CGameplayEntity)
	{
		var w3FoodComponents : array<CComponent>;
		var i : int;
		var actor : CActor;
		var gameLightComp : CGameplayLightComponent;
		
		//notify W3FoodComponents they were hit
		actor = (CActor)this;
		if(!actor || !actor.IsAlive())
		{
			w3FoodComponents = GetComponentsByClassName('W3FoodComponent');
			for (i=0; i<w3FoodComponents.Size(); i+=1)
			{
				((W3FoodComponent)w3FoodComponents[i]).OnFireHit();
			}
		}
		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			gameLightComp.FireHit();
		}
	}	
	
	event OnYrdenHit( caster : CGameplayEntity )
	{
		//tag for quest condition check
		AddHitFacts( GetTags(), caster.GetTags(), "_yrden_hit" );
	}
	
	//CUSTOM MONSTER ATTACK EVENTS
	event OnRootHit()
	{
		var i : int;
		var tags : array<name>;
		
		//tag for quest condition check
		tags = GetTags();
		for(i=0; i<tags.Size(); i+=1)
			FactsAdd( NameToString(tags[i])+"_roots_hit", 1, 1 );		//valid for 1 sec
	}
		
	event OnDamageFromJump( activator : CComponent, jumpDistance : float, jumpHeightDiff : float )
	{
		WhenFallen(jumpHeightDiff);
	}	
	event OnDamageFromFalling( activator : CComponent, fallingDistance : float, fallingHeightDiff : float )
	{
		WhenFallen(fallingHeightDiff);
	}
	
	protected function WhenFallen(fallingHeightDiff : float)
	{
		var vehicleComp : CVehicleComponent;
		var gpEnt : CGameplayEntity;
	
		if(-fallingHeightDiff > 0)
		{
			if(this == thePlayer || GetAttitudeBetween(thePlayer, this) == AIA_Hostile)
			{
				ApplyFallingDamage(-fallingHeightDiff);
			}			
		}
		
		if(IsVehicle())
		{
			vehicleComp = (CVehicleComponent)GetComponentByClassName('CVehicleComponent');
			gpEnt = (CGameplayEntity)vehicleComp.user;
			if(gpEnt)
			{
				gpEnt.WhenFallen(fallingHeightDiff);
					
				if( ((CNewNPC)this).IsHorse() && !gpEnt.IsAlive() )
				{
					((CNewNPC)this).GetHorseComponent().OnKillHorse();
				}
			}
		}
	}
	
	public function IsVehicle() : bool
	{
		return GetComponentByClassName('CVehicleComponent');
	}
	
	function ApplyFallingDamage( heightDiff : float, optional reducing : bool ) : float
	{
		return 0;
	}
	
	/////////////////////////////////////////////
	// focus mode
	/////////////////////////////////////////////
	
	function GetFocusModeSoundEffectName( colorBlindMode : bool ) : name
	{	
		if ( focusModeSoundEffectType == FMSET_Gray )
		{
			return 'focus_sound_fx';
		}
		else if ( focusModeSoundEffectType == FMSET_Red )
		{
			if( colorBlindMode ) return 'focus_sound_red_alt_fx';
			else
				return 'focus_sound_red_fx';
		}
		else if ( focusModeSoundEffectType == FMSET_Green )
		{
			return 'focus_sound_green_fx';
		}		
		return '';
	}
	
	function PlayFocusSoundVisualEffect( effectName : name )
	{
		var focusSoundParam : CFocusSoundParam;
		if ( focusSoundVisualEffectBoneName == '' ) // not initialized yet
		{
			focusSoundParam = (CFocusSoundParam)GetGameplayEntityParam( 'CFocusSoundParam' );
			if ( focusSoundParam )
			{
				focusSoundVisualEffectBoneName = focusSoundParam.GetVisualEffectBoneName();
			}
			if ( focusSoundVisualEffectBoneName == '' ) // if param not found or bone name not specified
			{
				focusSoundVisualEffectBoneName = 'entity';
			}
		}
		if ( focusSoundVisualEffectBoneName != 'entity' )
		{
			PlayEffectOnBone( effectName, focusSoundVisualEffectBoneName );
		}
		else
		{
			PlayEffect( effectName );		
		}
	}
	
	public function SetFocusModeSoundEffectType( type : EFocusModeSoundEffectType )
	{
		if ( focusModeSoundEffectType == type )
		{
			return;
		}
		
		if ( isPlayingFocusSound )
		{
			StopEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
		}

		focusModeSoundEffectType = type;

		if ( isPlayingFocusSound && type != FMSET_None )
		{
			PlayFocusSoundVisualEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );			
		}
	}
	
	event OnFocusModeSound( enabled : bool, colorBlind : bool )
	{
		// lazy init of fm colorblind mode check
		isColorBlindMode = colorBlind;

		if ( !IsAlive() )
		{
			enabled = false;
		}
		
		if ( enabled == isPlayingFocusSound )
		{
			return false;
		}
		isPlayingFocusSound = enabled;

		if ( isPlayingFocusSound )
		{
			PlayFocusSoundVisualEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
		}
		else
		{
			StopEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
		}
	}	
	
	public function GetFocusActionName() : name
	{
		var focusComponent : CFocusActionComponent;
		focusComponent = (CFocusActionComponent)GetComponentByClassName( 'CFocusActionComponent' );
		if ( focusComponent )
		{
			return focusComponent.actionName;		
		}
		return '';
	}	
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return true;
	}
	
	public function GetInteractionData( out actionName : name, out text : string ) : bool
	{
		//actionName = component.GetInputActionName();
		//text = component.GetInteractionFriendlyName();
		return false;
	}
}	
///////////////////////////////////////////////////////////////////////

import class IEntityStateChangeRequest extends CObject
{
};

import abstract class CScriptedEntityStateChangeRequest extends IEntityStateChangeRequest
{
	function Execute( entity : CGameplayEntity );
};

import class CEnableDeniedAreaRequest extends IEntityStateChangeRequest
{
	import var enable	: bool;
};

/* not used, old W2 code
import class CDoorStateRequest extends IEntityStateChangeRequest
{
	import var doorState : EDoorState; 
	import var immediate : bool;
};*/

import class CPlaySoundOnActorRequest extends IEntityStateChangeRequest
{
	import function Initialize( boneName : name, soundName : string, optional fadeTime : float );
};
