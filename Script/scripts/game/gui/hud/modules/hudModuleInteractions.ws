struct SFocusInteractionIcon
{
	var m_id				: int;
	var m_actionName		: name;
	var m_entity			: CEntity;
	var m_screenPos			: Vector;
	var m_distanceSquared	: float;
	var m_valid				: bool;		// is visible according to focus controller in current tick
	var m_canBeSeen			: bool;		// atm its position is on screen
	var m_isSeen			: bool;		// it's the closest to the player, is choosen from icons that have m_canBeSeen set to true
};

class CR4HudModuleInteractions extends CR4HudModuleBase
{
	public var bShowHoldIndicator 				: bool;	default bShowHoldIndicator		= false;
	public var bShowInteraction 				: bool;	default bShowInteraction		= false;
	public var bShowFocusInteractions			: bool;	default bShowFocusInteractions	= false;
	
	private var m_fxDisableHoldIndicator					: CScriptedFlashFunction;
	private var m_fxEnableHoldIndicator						: CScriptedFlashFunction;
	private var m_fxSetInteractionKeySFF					: CScriptedFlashFunction;
	private var m_fxSetInteractionIconSFF					: CScriptedFlashFunction;
	private var m_fxSetInteractionTextSFF					: CScriptedFlashFunction;
	private var m_fxSetInteractionIconAndTextSFF			: CScriptedFlashFunction;
	private var m_fxSetInteractionKeyIconAndTextSFF			: CScriptedFlashFunction;
	private var m_fxAddFocusInteractionIconSFF				: CScriptedFlashFunction;
	private var m_fxSetInteractionHoldDuration				: CScriptedFlashFunction;
	private var m_fxRemoveFocusInteractionIconSFF			: CScriptedFlashFunction;
	private var m_fxUpdateFocusInteractionIconPositionSFF	: CScriptedFlashFunction;
	private var m_fxSetVisibilitySFF						: CScriptedFlashFunction;
	private var m_fxSetVisibilityExSFF						: CScriptedFlashFunction;
	private var m_fxSetPositionsSFF							: CScriptedFlashFunction;
	
	private var _interactionEntity			: CGameplayEntity;
	private var _interactionEntityComponent	: CInteractionComponent;
	
	private var m_focusInteractionIcons : array< SFocusInteractionIcon >;
	
	private var m_previouslyShow				: bool;
	private var m_previousInteractionEntity		: CGameplayEntity;
	private var m_previousDisplayEntity			: CGameplayEntity;
	private var m_previousDisplayEntityDataRet	: bool;
	private var m_forceUpdate					: bool;
	private var m_currentHoldInteraction		: name;
	
	private const var FOCUS_INTERACION_UPDATE_INTERVAL			: float;	default FOCUS_INTERACION_UPDATE_INTERVAL			= 0.3;	// (seconds)
	private const var FOCUS_INTERACION_RADIUS					: float;	default FOCUS_INTERACION_RADIUS						= 10;	// (meters)
	private const var FOCUS_INTERACTION_OPAQUE_ICON_RADIUS		: float;	default FOCUS_INTERACTION_OPAQUE_ICON_RADIUS		= 100;	// (pixels)
	private const var FOCUS_INTERACTION_TRANSPARENT_ICON_RADIUS	: float;	default FOCUS_INTERACTION_TRANSPARENT_ICON_RADIUS	= 500;	// (pixels)
 
	event /* flash */ OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		
		flashModule 			= GetModuleFlash();
		m_anchorName = "ScaleOnly";
		m_fxEnableHoldIndicator						= flashModule.GetMemberFlashFunction( "EnableHoldIndicator" );
		m_fxDisableHoldIndicator					= flashModule.GetMemberFlashFunction( "DisableHoldIndicator" );
		m_fxSetInteractionKeySFF					= flashModule.GetMemberFlashFunction( "SetInteractionKey" );
		m_fxSetInteractionIconSFF					= flashModule.GetMemberFlashFunction( "SetInteractionIcon" );
		m_fxSetInteractionTextSFF					= flashModule.GetMemberFlashFunction( "SetInteractionText" );
		m_fxSetInteractionIconAndTextSFF			= flashModule.GetMemberFlashFunction( "SetInteractionIconAndText" );
		m_fxSetInteractionKeyIconAndTextSFF			= flashModule.GetMemberFlashFunction( "SetInteractionKeyIconAndText" );
		m_fxSetInteractionHoldDuration				= flashModule.GetMemberFlashFunction( "SetHoldDuration" );
		m_fxAddFocusInteractionIconSFF				= flashModule.GetMemberFlashFunction( "AddFocusInteractionIcon" );
		m_fxRemoveFocusInteractionIconSFF			= flashModule.GetMemberFlashFunction( "RemoveFocusInteractionIcon" );
		m_fxUpdateFocusInteractionIconPositionSFF	= flashModule.GetMemberFlashFunction( "UpdateFocusInteractionIconPosition" );
		m_fxSetVisibilitySFF						= flashModule.GetMemberFlashFunction( "SetVisibility" );
		m_fxSetVisibilityExSFF						= flashModule.GetMemberFlashFunction( "SetVisibilityEx" );
		m_fxSetPositionsSFF							= flashModule.GetMemberFlashFunction( "SetPositions" );

		//m_mcIcon									= flashModule.GetChildFlashSprite( "mcIcon" );
		//m_mcIcon_mcPicture							= m_mcIcon.GetChildFlashSprite( "mcPicture" );
		//m_mcInteraction								= flashModule.GetChildFlashSprite( "mcInteraction" );
		//m_mcInteraction_mcButton					= m_mcInteraction.GetChildFlashSprite( "btnInteract" );
		//m_mcInteraction_mcActionName				= m_mcInteraction.GetChildFlashSprite( "mcActionName" );

		super.OnConfigUI();

		m_forceUpdate = false;

		ShowElement( false ); // #B temporary
		
		theGame.GetGuiManager().checkHoldIndicator();
	}
	
	event /* falsh */ OnRequestShowHold()
	{
		bShowHoldIndicator = true;
	}
	
	event /* falsh */ OnRequestHideHold()
	{
		bShowHoldIndicator = false;
	}
	
	event /* falsh */ OnHoldInteractionCallback()
	{
		switch (m_currentHoldInteraction)
		{
		    case 'HorseDismount':
				thePlayer.OnDismountActionScriptCallback();
				break;
			case 'PlaceOfPower':
				// ignore
				break;
			default:
				break;
		}
	}

	event OnTick( timeDelta : float )
	{
		var screenPos 			: Vector;
		var displayEntity		: CGameplayEntity;
		var displayEntityDataRet : bool;
		var currentlyShow		: bool;
		var actionName			: name;
		var actionText			: string;
		var key					: int;
		var key2				: int;
		var keys				: array< EInputKey >;
		
		var showInteractionIcon : bool;

		//
		// IF YOU ARE GOING TO CHANGE SOMETHING HERE, BE EXTREMELY CAREFUL OR TALK TO ME (PawelM)
		//
		displayEntity = thePlayer.GetDisplayTarget();
		
		// MS: If player is not holding a steel or silver sword, the Finish interaction button should not appear
		if ( _interactionEntityComponent && _interactionEntityComponent.GetActionName() == "Finish" )
		{
			if ( !thePlayer.IsHoldingDeadlySword() )
			{
				_interactionEntity = NULL;
				displayEntity = NULL;
			}
		}
		
		// general visibility
		currentlyShow = bShowInteraction || ( displayEntity ) || bShowFocusInteractions || ( bShowHoldIndicator && !thePlayer.IsInNonGameplayCutscene() );
		if ( m_previouslyShow != currentlyShow )
		{
			m_previouslyShow = currentlyShow;
			ShowElement( currentlyShow, bShowHoldIndicator ); //#B OnDemand
		}

		// changed data for displayEntity
		displayEntityDataRet = false;
		if ( !_interactionEntity && displayEntity )
		{
			displayEntityDataRet = displayEntity.GetInteractionData( actionName, actionText );
		}

		// specific visibility
		if ( m_forceUpdate ||
			 m_previousInteractionEntity    != _interactionEntity ||
			 m_previousDisplayEntity        != displayEntity ||
			 m_previousDisplayEntityDataRet != displayEntityDataRet )
		{
			m_forceUpdate                  = false;
			m_previousInteractionEntity    = _interactionEntity;
			m_previousDisplayEntity        = displayEntity;
			m_previousDisplayEntityDataRet = displayEntityDataRet;
			
			if ( _interactionEntity )
			{
				key  = _interactionEntityComponent.GetInteractionKey();
				actionName = _interactionEntityComponent.GetInputActionName();
				actionText = _interactionEntityComponent.GetInteractionFriendlyName();

				theInput.GetPCKeysForAction( actionName, keys );
				if ( keys.Size() )
				{
					key2 = (int)keys[ 0 ];
				}
				
				//MS: Hack to remove the E icon for finishers when using pc controls (bug 115769)
				showInteractionIcon = true;
				if ( actionName == 'Finish' && theInput.LastUsedPCInput() )
				{
					showInteractionIcon = false;
				}

				m_fxSetInteractionKeyIconAndTextSFF.InvokeSelfFourArgs( FlashArgInt( key ), FlashArgInt( key2 ), FlashArgString( actionName ), FlashArgString( GetLocStringByKeyExt( actionText ) ) );
				m_fxSetVisibilityExSFF.InvokeSelfFiveArgs( FlashArgBool( true ), FlashArgBool( false ), FlashArgBool( true ), FlashArgBool( showInteractionIcon ), FlashArgBool( true ) );
			}
			else if ( displayEntity )
			{
				if ( displayEntityDataRet )
				{
					m_fxSetInteractionIconAndTextSFF.InvokeSelfTwoArgs( FlashArgString( actionName ), FlashArgString( GetLocStringByKeyExt( actionText ) ) );
					m_fxSetVisibilityExSFF.InvokeSelfFiveArgs( FlashArgBool( true ), FlashArgBool( true ), FlashArgBool( true ), FlashArgBool( false ), FlashArgBool( true ) );
				}
				else
				{
					m_fxSetVisibilityExSFF.InvokeSelfFiveArgs( FlashArgBool( true ), FlashArgBool( false ), FlashArgBool( true ), FlashArgBool( false ), FlashArgBool( false ) );
				}
			}
			else
			{
				m_fxSetVisibilitySFF.InvokeSelfTwoArgs( FlashArgBool( false ), FlashArgBool( false ) );
			}
		}
		
		if ( _interactionEntity )
		{
			if ( GetInteractionScreenPosition( _interactionEntity, _interactionEntityComponent, screenPos ) )
			{
				m_fxSetPositionsSFF.InvokeSelfTwoArgs( FlashArgNumber( screenPos.X ), FlashArgNumber( screenPos.Y ) );			
			}
		}
		else if ( displayEntity )
		{
			if ( GetInteractionScreenPosition( displayEntity, NULL, screenPos ) )
			{
				m_fxSetPositionsSFF.InvokeSelfTwoArgs( FlashArgNumber( screenPos.X ), FlashArgNumber( screenPos.Y ) );
			}
		}
		
		UpdateFocusInteractionIcons();
	}
	
	event /*C++*/ OnInteractionsUpdated( component : CInteractionComponent )
	{
		var inputActionName : name;
		var actionName : string;
		var text : string;
		var key : int;
		var delay : float;
		var interaction : bool;
		var flashValueStorage : CScriptedFlashValueStorage = GetModuleFlashValueStorage();
		var door		: W3NewDoor;
		var gameplayEnt	: CGameplayEntity;

		if ( component )
		{
			gameplayEnt = (CGameplayEntity)component.GetEntity();
			actionName = component.GetActionName();
			
			if ( actionName == "Finish" && gameplayEnt.HasAbility( 'ForceFinisher' )  )
				SetInteractionEntity( NULL, NULL );
			else
				SetInteractionEntity( gameplayEnt, component );
		}
		else
		{
			SetInteractionEntity( NULL, NULL );
		}
		
		if( component && thePlayer.IsActionAllowed( EIAB_Interactions ) )
		{
			thePlayer.SetIsInsideInteraction(true);
			
			inputActionName = component.GetInputActionName();
			if( inputActionName == 'MountHorse' )
			{
				thePlayer.SetIsInsideHorseInteraction( true, component.GetEntity() );
			}
			
			component.UpdateIconOffset();
			
			door = (W3NewDoor) component.GetEntity();
			if( door )
			{
				door.UpdateIconOffset(0,0);
			}
			
			// #Y We can't get info about hold duration from ini file, so it is hardcoded here
			delay = -1;
			switch (inputActionName)
			{
				case 'InteractHold':
					delay = -1;
					break;
				case 'HorseDismount':
					delay = 0.5;
					break;
				default:
					delay = -1;
					break;
			}
			m_fxSetInteractionHoldDuration.InvokeSelfOneArg( FlashArgNumber(delay) );
			
			if(	!bShowInteraction && actionName != "Finish" && !thePlayer.IsUsingVehicle() )
			{
				bShowInteraction = true;
			}
			else if( component.IsEnabledOnHorse() )
			{
				bShowInteraction = true;
			}
		}
		else
		{
			thePlayer.SetIsInsideInteraction(false);
			thePlayer.SetIsInsideHorseInteraction(false, NULL);
			bShowInteraction = false;
		}
	}
	
	function GetInteractionScreenPosition( interactionEntity : CEntity, interactionComponent : CInteractionComponent, out screenPos : Vector, optional normalized : bool ) : bool
	{
		if ( !interactionEntity )
		{
			return false;
		}
		
		if( (CActor)interactionEntity )
		{
			if ( GetBaseScreenPosition( screenPos, interactionEntity, , , , normalized ) )
			{
				return true;
			}
		}
		else 
		{
			if ( GetBaseScreenPosition( screenPos, interactionEntity, interactionComponent, , , normalized ) )
			{
				return true;
			}
		}		
		return false;
	}
	
	protected function SetInteractionEntity( entity : CGameplayEntity, comp : CInteractionComponent )
	{
		_interactionEntity			= entity;
		_interactionEntityComponent	= comp;
	}
	
	public function IsInteractionInCameraView( interactionComponent : CInteractionComponent ) : bool
	{
		var interactionEntity : CEntity;
		var screenPos : Vector;
	
		if ( !interactionComponent )
		{
			return false;
		}
		interactionEntity = interactionComponent.GetEntity();
		if ( !interactionEntity )
		{
			return false;
		}
		
		// get normalized [0,1] screen position
		if ( GetInteractionScreenPosition( interactionEntity, interactionComponent, screenPos, true ) )
		{
			return ( screenPos.X >= 0.0f && screenPos.X <= 1.0f && screenPos.Y >= 0.0f && screenPos.Y <= 1.0f );					
		}
		
		return false;
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool // #B should be scaling ?
	{
		return false;
	}
	
	public function ForceUpdateModule()
	{
		m_forceUpdate = true;
	}
	
	public function EnableHoldIndicator(gpadKeyCode:int, kbKeyCode:int, label:string, holdDuration:float, optional intName:name):void
	{
		var locLabel:string = GetLocStringByKeyExt(label);
		
		m_currentHoldInteraction = intName;
		m_fxEnableHoldIndicator.InvokeSelfFourArgs(FlashArgInt(gpadKeyCode), FlashArgInt(kbKeyCode), FlashArgString(locLabel), FlashArgNumber( holdDuration));
	}
	
	public function DisableHoldIndicator():void
	{
		m_currentHoldInteraction = '';
		m_fxDisableHoldIndicator.InvokeSelf();
	}

	public function AddFocusInteractionIcon( entity : CEntity, actionName : name )
	{
		var i : int;
		var id : int;
		var icon : SFocusInteractionIcon;
		var component : CInteractionComponent;
		var fixedActionName : name;
		var door : W3NewDoor;

		id = entity.GetGuidHash();
		for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
		{
			if ( m_focusInteractionIcons[ i ].m_id == id )
			{
				m_focusInteractionIcons[ i ].m_valid = true;
				return;
			}
		}

		icon.m_id				= id;
		
		//////////////////////////////
		//
		// not the most beautiful solution, but there's nothing better, doors have 'Open' action name and so have containers
		// sombody would have to rename it to something like 'OpenDoor' in all templates to make it different
		// additionaly we need to update icon offset in interaction component because it's needed for focus icon as well
		//
		door = (W3NewDoor)entity;
		if ( door )
		{
			door.UpdateIconOffset(0,0);
			icon.m_actionName = 'Door';
		}
		else
		{
			icon.m_actionName = actionName;
		}
		//
		///////////////////////////////

		icon.m_entity			= entity;
		//icon.m_screenPos			// to be determined later
		//icon.m_distanceSquared	// to be determined later
		icon.m_valid			= true;
		icon.m_canBeSeen		= false; // to be determined later
		icon.m_isSeen			= false; // to be determined later

		m_focusInteractionIcons.PushBack( icon );
	}

	public function InvalidateAllFocusInteractionIcons()
	{
		var i : int;
		
		for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
		{
			m_focusInteractionIcons[ i ].m_valid = false;
		}
	}
	
	public function RemoveAllFocusInteractionIcons()
	{
		var i : int;
		
		for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
		{
			if ( m_focusInteractionIcons[ i ].m_isSeen )
			{
				//m_focusInteractionIcons[ i ].m_isSeen = false;
				m_fxRemoveFocusInteractionIconSFF.InvokeSelfOneArg( FlashArgInt( m_focusInteractionIcons[ i ].m_id ) );
			}
		}
		m_focusInteractionIcons.Clear();
	}

	public function UpdateFocusInteractionIcons()
	{
		var i : int;
		var playerPos, screenPos : Vector;
		var alpha : float;
		var iconIndex : int;
		var components : array<CComponent>;
		var l_destructibleCmp	: CDestructionSystemComponent;
		
		bShowFocusInteractions = ( m_focusInteractionIcons.Size() > 0 );
		
		// remove invalid icons
		for ( i = 0; i < m_focusInteractionIcons.Size(); )
		{
			if ( m_focusInteractionIcons[ i ].m_valid )
			{
				i += 1;
			}
			else
			{
				// if seen remove also in flash
				if ( m_focusInteractionIcons[ i ].m_isSeen )
				{
					//m_focusInteractionIcons[ i ].m_isSeen = false;
					m_fxRemoveFocusInteractionIconSFF.InvokeSelfOneArg( FlashArgInt( m_focusInteractionIcons[ i ].m_id ) );
				}
				m_focusInteractionIcons.EraseFast( i );
			}
		}

		// update visibility of icons
		if ( bShowInteraction )
		{
			// there is some interaction, do not show any focus icon 

			for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
			{
				if ( m_focusInteractionIcons[ i ].m_isSeen )
				{
					m_focusInteractionIcons[ i ].m_isSeen = false;
					m_fxRemoveFocusInteractionIconSFF.InvokeSelfOneArg( FlashArgInt( m_focusInteractionIcons[ i ].m_id ) );
				}
			}
		}
		else
		{
			// there is no interaction, update distances and visibility
			playerPos = thePlayer.GetWorldPosition();
			for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
			{
				// destructible components are a special case because they are allowed to still be around even if the visual object is gone. the following
				// check will make sure that if the object is destroyed, it will not show the focus interaction icon
				l_destructibleCmp = (CDestructionSystemComponent)m_focusInteractionIcons[ i ].m_entity.GetComponentByClassName('CDestructionSystemComponent');
				if( l_destructibleCmp && l_destructibleCmp.IsObstacleDisabled() )
				{
					m_focusInteractionIcons[ i ].m_canBeSeen = false;
				}
				// get screen position of icon
				else if ( GetBaseScreenPosition( screenPos, m_focusInteractionIcons[ i ].m_entity, (CInteractionComponent)m_focusInteractionIcons[ i ].m_entity.GetComponentByClassName('CInteractionComponent') ) )
				{
					if ( IsPointOnScreen( screenPos ) )
					{
						// it's on the screen, get the rest of things
						m_focusInteractionIcons[ i ].m_screenPos = screenPos;
						m_focusInteractionIcons[ i ].m_canBeSeen = true;
						m_focusInteractionIcons[ i ].m_distanceSquared = VecDistanceSquared( playerPos, m_focusInteractionIcons[ i ].m_entity.GetWorldPosition() );
					}
					else
					{
						// out of screen
						m_focusInteractionIcons[ i ].m_canBeSeen = false;
					}
				}
				else	
				{
					// can't get screen coords
					m_focusInteractionIcons[ i ].m_canBeSeen = false;
				}
			}
			
			// find icon where ( m_canBeSeen == true ) and distanceSquared is smallest
			iconIndex = -1;
			for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
			{
				if ( m_focusInteractionIcons[ i ].m_canBeSeen )
				{
					if ( iconIndex == -1 )
					{
						iconIndex = i;
					}
					else
					{
						if ( m_focusInteractionIcons[ iconIndex ].m_distanceSquared > m_focusInteractionIcons[ i ].m_distanceSquared )
						{
							iconIndex = i;
						}
					}
				}
			}
			
			// finally update all icons, remove old one, than add new one (only one exists)
			for ( i = 0; i < m_focusInteractionIcons.Size(); i += 1 )
			{
				if ( iconIndex != i )
				{
					if ( m_focusInteractionIcons[ i ].m_isSeen )
					{
						m_focusInteractionIcons[ i ].m_isSeen = false;
						m_fxRemoveFocusInteractionIconSFF.InvokeSelfOneArg( FlashArgInt( m_focusInteractionIcons[ i ].m_id ) );
					}
				}
			}

			if ( iconIndex > -1 )
			{
				if ( !m_focusInteractionIcons[ iconIndex ].m_isSeen )
				{
					m_focusInteractionIcons[ iconIndex ].m_isSeen = true;
					m_fxAddFocusInteractionIconSFF.InvokeSelfTwoArgs(				FlashArgInt(	m_focusInteractionIcons[ iconIndex ].m_id ),
																					FlashArgString(	m_focusInteractionIcons[ iconIndex ].m_actionName ) );
					m_fxUpdateFocusInteractionIconPositionSFF.InvokeSelfThreeArgs(	FlashArgInt(	m_focusInteractionIcons[ iconIndex ].m_id ),
																					FlashArgNumber(	m_focusInteractionIcons[ iconIndex ].m_screenPos.X ),
																					FlashArgNumber(	m_focusInteractionIcons[ iconIndex ].m_screenPos.Y ) );
																					
					//destructible objects tutorial
					if(m_focusInteractionIcons[ iconIndex ].m_actionName == 'Aard' && ShouldProcessTutorial('TutorialDestructiblesDescription'))
					{
						components = m_focusInteractionIcons[ iconIndex ].m_entity.GetComponentsByClassName('CDestructionSystemComponent');
						if(components.Size() == 0)
							components = m_focusInteractionIcons[ iconIndex ].m_entity.GetComponentsByClassName('CBoatDestructionComponent');
						
						if(components.Size() > 0)
							FactsAdd("tut_fm_destr_prepared");
					}
				}
				else
				{
					m_fxUpdateFocusInteractionIconPositionSFF.InvokeSelfThreeArgs(	FlashArgInt(    m_focusInteractionIcons[ iconIndex ].m_id ),
																					FlashArgNumber( m_focusInteractionIcons[ iconIndex ].m_screenPos.X ),
																					FlashArgNumber( m_focusInteractionIcons[ iconIndex ].m_screenPos.Y )		 );

				}
			}
		}
	}
	
	public function GetFocusInteractionUpdateInterval() : float
	{
		return FOCUS_INTERACION_UPDATE_INTERVAL;
	}

	public function GetFocusInteractionRadius() : float
	{
		return FOCUS_INTERACION_RADIUS;
	}
	
	public function OnInputContextChanged()
	{
		m_forceUpdate = true;
	}
}

exec function yen1()
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleOneliners;
	var entity : CEntity;

	entity = theGame.GetEntityByTag( 'yen' );
	if ( entity )
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		module = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
		module.OnCreateOneliner( entity, "Ja pierdolę! Geralt, pokurwiło Cię do reszty?", 12345 );
	}
}

exec function yen2()
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleOneliners;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
	module.OnRemoveOneliner( 12345 );
}

