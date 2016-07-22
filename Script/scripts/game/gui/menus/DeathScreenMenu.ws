/***********************************************************************/
/** Witcher Script file - Main Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4DeathScreenMenu extends CR4MenuBase
{
	public var hasSaveData : bool;
	
	private var m_fxShowInputFeedback : CScriptedFlashFunction;
	
	event /*flash*/ OnConfigUI()
	{
		var tutorialPopupRef  : CR4TutorialPopup;
		
		super.OnConfigUI();
		
		PopulateData();
		
		m_fxShowInputFeedback = m_flashModule.GetMemberFlashFunction("showInputFeedback");
		
		tutorialPopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef)
		{
			tutorialPopupRef.ClosePopup();
		}
		
		theSound.EnterGameState(ESGS_Death);
		theSound.SoundEvent( 'gui_global_player_death_thump' );
		
		theGame.Pause( "DeathScreen" );
		
		theGame.ResetFadeLock('DeathScreenMenu');
		theGame.FadeInAsync( 1.2f );
		
		m_guiManager.RequestMouseCursor(true);
	}
	
	private function updateHudConfigs():void
	{
	}
	
	event /* C++ */ OnClosingMenu()
	{
		m_guiManager.RequestMouseCursor(false);
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		super.OnClosingMenu();
		
		theGame.Unpause( "DeathScreen" );
	}

	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
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
		
		if (hasSaveData != hasSaveDataToLoad())
		{
			PopulateData();
		}
		
		m_fxShowInputFeedback.InvokeSelfOneArg(FlashArgBool(true));
		
		/*menu = (CR4MenuBase)GetSubMenu();
	
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
		}*/
	}
	
	function PopulateData()
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;	
		
		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
				
		hasSaveData = hasSaveDataToLoad();
		if( hasSaveData )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_respawn") );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Respawn') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_load_x1") );
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_load_ps4") );
			}
			else
			{
				l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_load") );
			}
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Load') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
			
		}
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
		l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_common_quittomainmenu") );
		l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Quit') );
		l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
		if( theGame.IsDebugQuestMenuEnabled() && !theGame.IsFinalBuild() )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString	( "label", "***Debug Resurrect***" );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('DebugResurrect') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		}
		
		m_flashValueStorage.SetFlashArray( "hud.deathscreen.list", l_FlashArray );
	}
	
	function PlayOpenSoundEvent()
	{
	}
	
	public function SetMenuAlpha( value : int ) : void
	{
		m_flashModule.SetAlpha(value);
	}
	
	event /* flash */ OnPress( tag : name )
	{
		switch( tag )
		{
			case 'Load' :
				OnLoad();
				break;
			case 'Respawn' :
				OnRespawn();
				//ShowElement();
				break;
			case 'Quit' :
				OnQuit();
				//CloseMenu();
				break;
			case 'DebugResurrect' :
				thePlayer.CheatResurrect();
				break;
		}
	}
	
	public function HideInputFeedback() : void
	{
		m_fxShowInputFeedback.InvokeSelfOneArg(FlashArgBool(false));
	}
	
	event /* flash */ OnLoad()
	{
		var initData : W3MenuInitData = new W3MenuInitData in this;
		initData.setDefaultState('LoadGame');
		RequestSubMenu( 'IngameMenu', initData );
	}		

	event /* flash */ OnQuit()
	{
		theGame.GetGuiManager().TryQuitGame();
	}		
	
	event /* flash */ OnRespawn()
	{
		theGame.SetIsRespawningInLastCheckpoint();
		theGame.LoadLastGameInit( true );
	}
}

exec function deathscreen()
{
	theGame.RequestMenu('DeathScreenMenu');
}