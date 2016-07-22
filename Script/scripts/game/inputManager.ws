
import class CInputManager
{
	import final function GetLastActivationTime( actionName : name ) : float; 	// clamped at 10s 
	import final function GetActionValue( actionName : name ) : float; 			//[0-1]
	import final function GetAction( actionName : name ) : SInputAction;

	import final function ClearIgnoredInput();									// Resets all blocked inputs
	//import final function IgnoreGameInput( actionName : name, ignore : bool );	// Ignore input for action 
	import final function IsInputIgnored( actionName : name ) : bool;			
		
	//one listener per action - registerring second one will unregister first
	import final function RegisterListener( listener : IScriptable, eventName : name, actionName : name );
	import final function UnregisterListener( listener : IScriptable, actionName : name );
	
	import final function SetContext( contextName : name );						// changes current input context
	import final function GetContext() : name;									// returns name of current context
	
	//import final function SuppressSendingEvents( val : bool );
	
	import final function StoreContext( newContext : name );
	
	// @param storedContext - what was the name of the context stored (what do we restore from)
	// @param contextCouldChange - is it possible that context has changed?
	import final function RestoreContext( storedContext : name, contextCouldChange : bool );
	
	import final function EnableLog( val : bool );
	
	import final function LastUsedPCInput() : bool;
	import final function LastUsedGamepad() : bool;
	
	import final function UsesPlaystationPad() : bool;	
	public final function UsesPlaystationPadScript() : bool
	{
		return UsesPlaystationPad() || FactsQuerySum("dbg_force_ps_pad") > 0;
	}
	
	import final function ForceDeactivateAction( actionName : name );
	
	// get all keys mapped to action (actionName), for PC (keyboard + mouse) input schema
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetPCKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	// get all keys mapped to action (actionName), for gamepad input schema
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetPadKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	// get all keys mapped to action on currently used device (keyboard + mouse / pad )
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetCurrentKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	
	// get all keys mapped to action (actionName), for PC (keyboard + mouse) input schema
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetPCKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	// get all keys mapped to action (actionName), for gamepad input schema
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetPadKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	// get all keys mapped to action on currently used device (keyboard + mouse / pad )
	//ACHTUNG!!! outKeys is not cleared!!!!
	import final function GetCurrentKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	
	function IsActionPressed( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsPressed( action, true );
	}

	function IsActionReleased( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsReleased( action, true );
	}
	
	function IsActionJustPressed( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsPressed( action );
	}

	function IsActionJustReleased( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsReleased( action );
	}
	
	
	event OnInputDeviceChanged()
	{
		var guiManager       : CR4GuiManager;
		var hud              : CR4ScriptedHud;
		var overlayPopupRef  : CR4OverlayPopup;
		var tutorialPopupRef : CR4TutorialPopup;
		var glossaryTutorial : CR4GlossaryTutorialsMenu;
		var tutorialSystem   : CR4TutorialSystem;
		var commonMenuRef    : CR4CommonMenu;		
		
		guiManager = theGame.GetGuiManager();
		
		if (guiManager.GetLockedControlScheme() == LCS_None)
		{			
			
			tutorialSystem = theGame.GetTutorialSystem();
			if(tutorialSystem && tutorialSystem.IsRunning())
			{
				tutorialSystem.OnInputDeviceChanged();
			}
			
			tutorialPopupRef = (CR4TutorialPopup) guiManager.GetPopup('TutorialPopup');
			if (tutorialPopupRef)
			{
				tutorialPopupRef.UpdateInputDevice();
			}
			
			overlayPopupRef = (CR4OverlayPopup) guiManager.GetPopup('OverlayPopup');
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateInputDevice();
			}
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			if(hud)
			{
				hud.UpdateInputDevice();
			}
			
			commonMenuRef = guiManager.GetCommonMenu();
			if (commonMenuRef)
			{
				commonMenuRef.UpdateInputDevice();
				
				glossaryTutorial = (CR4GlossaryTutorialsMenu)commonMenuRef.GetSubMenu();
				if (glossaryTutorial)
				{
					//glossaryTutorial.UpdateTutorials();
				}
			}
			
		}
	}
	
	import final function SetInvertCamera( invert : bool );
	
	
	function IsAttackWithAlternateBound() : bool
	{
		var outKeys : array<EInputKey>;
		if ( LastUsedGamepad() )
		{
			return false;
		}
		else if ( LastUsedPCInput() )
		{
			GetPCKeysForAction('PCAlternate',outKeys);
			if ( outKeys.Size() > 0 )
				return true;
		}
		return false;
	}
	
	function IsToggleSprintBound() : bool
	{
		var outKeys : array<EInputKey>;
		if ( LastUsedGamepad() )
		{
			return false;
		}
		else if ( LastUsedPCInput() )
		{
			GetPCKeysForAction('SprintToggle',outKeys);
			if ( outKeys.Size() > 0 )
				return true;
		}
		return false;
	}
}

import struct SInputAction
{
	import const var aName : name;
	import const var value : float;
	import const var lastFrameValue : float;
}

function IsPressed( action : SInputAction, optional justValue : bool ) : bool
{
	return action.value > 0.7f && ( justValue || action.lastFrameValue <= 0.7f );
}

function IsReleased( action : SInputAction, optional justValue : bool ) : bool
{
	return action.value < 0.7f && ( justValue || action.lastFrameValue >= 0.7f );
}
