﻿/***********************************************************************/
/** Witcher Script file - Main Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4CommonMainMenuBase extends CR4MenuBase
{
	private var m_menuData 	  : array< SMenuTab >;
	
	private var m_fxSetMovieData : CScriptedFlashFunction;
	
	public var importSelected : bool;
	public var reopenRequested	: bool; default reopenRequested = false;
	
	protected var currentMenuName : name;
	
	event /*flash*/ OnConfigUI()
	{
		var menuName : name;
		var inGameConfigWrapper	: CInGameConfigWrapper;
		var overlayPopupRef  : CR4OverlayPopup;
		
		super.OnConfigUI();
		m_flashModule = GetMenuFlash();
		theGame.GetGuiManager().OnEnteredMainMenu();
		
		//m_fxSetMovieData = m_flashModule.GetMemberFlashFunction( "SetMovieData" );
		//m_fxSetMovieData.InvokeSelfOneArg(FlashArgString(GetCurrentBackgroundMovie()));
		
		//menuName = theGame.GetMenuToOpen();
		
		//if( menuName == '')
		{
			menuName = 'IngameMenu';
		}
		
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (!overlayPopupRef)
		{
			theGame.RequestPopup( 'OverlayPopup' );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.17, 0.36);
		}
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		inGameConfigWrapper.SetVarValue('Hidden', 'HasSetup', "true");
		theGame.SaveUserSettings();
		
		SetupMenu();
		OnRequestSubMenu( menuName, GetMenuInitData() );
		
		theGame.FadeInAsync(300); // 0.3 seconds
		
		theInput.StoreContext( 'MAIN_MENU_CONTEXT' );
		
		theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
		
		// Every time we end up in main menu, update hud values in case hud is still loaded but profile has changed
		updateHudConfigs();
		
		theSound.SoundEvent( "play_music_main_menu" );
		
		if ( theGame.GetDLCManager().IsEP2Available() )
		{
			theSound.SoundEvent( "play_music_toussaint" );
			theSound.SoundEvent( "mus_main_menu_ep2" );
		}
		else if ( theGame.GetDLCManager().IsEP1Available() )
		{
			theSound.SoundEvent( "mus_main_menu_theme_ep1" );
		}
		else
		{
			theSound.SoundEvent( "mus_main_menu_theme" );
		}
	}
	
	private function updateHudConfigs():void
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if (hud)
		{
			hud.UpdateHudConfigs();
		}
	}
	
	function GetCurrentBackgroundMovie() : string
	{
		return "mainmenu.usm"; // #B differ it depending on game advance
	}
	
	event /* C++ */ OnClosingMenu()
	{
		if (m_configUICalled)
		{
			theInput.RestoreContext( 'MAIN_MENU_CONTEXT', true );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		super.OnClosingMenu();
	}

	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
		currentMenuName = menuName;
	}

	/*
	enum EStandardSwipe
	{
		SWIPE_LEFT,
		SWIPE_RIGHT,
		SWIPE_DOWN,
		SWIPE_UP
	};
	*/

	event /* C++ */ OnSwipe( swipe : int )
	{
	}

	private function DefineMenuItem(itemName:name, itemLabel:string, optional parentMenuItem:name) : void
	{
		var newMenuItem 	: SMenuTab;

		newMenuItem.MenuName = itemName;
		newMenuItem.MenuLabel = itemLabel;
		newMenuItem.Enabled = true;
		newMenuItem.Visible = true;
		
		newMenuItem.ParentMenu = parentMenuItem;
		m_menuData.PushBack(newMenuItem);
	}
	
	private function SetupMenu() : void
	{
		/*var l_flashSubArray   : CScriptedFlashArray;
		
		l_flashSubArray = m_flashValueStorage.CreateTempFlashArray();
		GetGFxMenuStruct(l_flashSubArray);
		
		m_flashValueStorage.SetFlashArray( "panel.main.setup", l_flashSubArray);*/
	}

	event /*flash*/ OnCloseMenu()
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( menu )
		{
			menu.CloseMenu();
		}
		CloseMenu();
	}
	
	function CloseMenuRequest():void
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( !menu )
		{
			CloseMenu();
		}
	}
	
	function ChildRequestCloseMenu()
	{
		var menu			: CR4MenuBase;
		var menuToOpen		: name;
		
		if (reopenRequested)
		{
			reopenRequested = false;
			OnRequestSubMenu( 'IngameMenu', GetMenuInitData() );
		}
		else
		{
			menu = (CR4MenuBase)GetSubMenu();
		
			if( menu )
			{
				//menu.CloseMenu();
				menuToOpen = GetParentMenuName(currentMenuName);
				if( menuToOpen )
				{
					OnRequestSubMenu( menuToOpen, GetMenuInitData() );
				}
				else
				{
					CloseMenu();
				}
			}
		}
	}
	
	function GetParentMenuName( menu : name ) : name
	{
		var i : int;
		var parentName : name;
		var CurDataItem : SMenuTab;
		
		for ( i = 0; i < m_menuData.Size(); i += 1 )
		{
			CurDataItem = m_menuData[i];
			
			if ( CurDataItem.MenuName == menu )
			{
				parentName = CurDataItem.ParentMenu;
			}
		}
		return parentName;
	}
	
	protected function GatherBindersArray(out resultArray : CScriptedFlashArray, bindersList : array<SKeyBinding>, optional isContextBinding:bool)
	{
		var tempFlashObject	: CScriptedFlashObject;
		var bindingGFxData  : CScriptedFlashObject;
		var curBinding	    : SKeyBinding;
		var bindingsCount   : int;
		var i			    : int;
		
		bindingsCount = bindersList.Size();
		for( i =0; i < bindingsCount; i += 1 )
		{
			curBinding = bindersList[i];
			tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
			bindingGFxData = tempFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
			bindingGFxData.SetMemberFlashString("gamepad_navEquivalent", curBinding.Gamepad_NavCode );
			bindingGFxData.SetMemberFlashInt("keyboard_keyCode", curBinding.Keyboard_KeyCode );
			bindingGFxData.SetMemberFlashString("label", GetLocStringByKeyExt(curBinding.LocalizationKey) );
			bindingGFxData.SetMemberFlashString("isContextBinding", isContextBinding);
			resultArray.PushBackFlashObject(bindingGFxData);
		}
	}
	
	protected function UpdateInputFeedback():void
	{
		var gfxDataList	: CScriptedFlashArray;
		gfxDataList = m_flashValueStorage.CreateTempFlashArray();
		GatherBindersArray(gfxDataList, m_defaultInputBindings);
		m_flashValueStorage.SetFlashArray("mainmenu.buttons.setup", gfxDataList);
	}
		
	function SetButtons()
	{
		AddInputBinding("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddInputBinding("panel_button_common_use", "enter-gamepad_A", IK_Enter);
		AddInputBinding("panel_button_common_navigation", "gamepad_L3");
		UpdateInputFeedback();
	}	

	function PlayOpenSoundEvent()
	{
	}
	
	public function SetMenuAlpha( value : int ) : void
	{
		m_flashModule.SetAlpha(value);
	}
}
