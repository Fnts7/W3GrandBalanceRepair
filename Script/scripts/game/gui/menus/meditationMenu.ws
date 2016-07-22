/***********************************************************************/
/** Witcher Script file - Meditation Main Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4MeditationMenu extends CR4MenuBase
{	


	event /*flash*/ OnConfigUI()
	{
		initMeditationState();
		m_flashModule = GetMenuFlash();
		m_flashValueStorage = GetMenuFlashValueStorage();
		
		super.OnConfigUI();
		
		setMenuMode();
	}
	
	private function setMenuMode()
	{
		var RootMenu : CR4CommonMenu;
		
		RootMenu = (CR4CommonMenu)GetRootMenu();
		if ( RootMenu )
		{
			//RootMenu.EnableMenuTab('MeditationMenu');
		}
	}
	
	public function MeditatingEnd()
	{
		// TODO:
	}
	
	private function initMeditationState()
	{
		var medState : W3PlayerWitcherStateMeditation;
		medState = (W3PlayerWitcherStateMeditation)GetMenuInitData();
		//medState.meditationMenu = this;
	}
	
	event /* C++ */ OnClosingMenu()
	{
		theGame.GetGuiManager().SendCustomUIEvent( 'ClosedMeditationMenu' );
	}

	event /*flash*/ OnCloseMenu()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		
		theSound.SoundEvent( 'gui_global_quit' ); // #B sound - quit
		CloseMenu();
		if( m_parentMenu )
		{
			m_parentMenu.CloseMenu();
		}
		
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested();
			}
		}
		else
		{
			medd = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
			if(medd)
			{
				medd.StopRequested();
			}
		}
		
		//theInput.RestoreContext( 'EMPTY_CONTEXT', false );
	}
	
	

/*

	HOTFIX, TEMORARY NOT IN USE

	
	private var _SubMenusNames : array<name>;
	private var _SubMenusDisplayNames : array<string>;
	
	event  OnConfigUI()
	{	
		var medState : W3PlayerWitcherStateMeditation; //= (Meditation)GetMenuInitData();
		medState = (W3PlayerWitcherStateMeditation)GetMenuInitData();
		//medState.meditationMenu = this; // #Y Now we use preporation menu for this
		super.OnConfigUI();
		
		_SubMenusNames.PushBack('MeditationClockMenu');
		_SubMenusDisplayNames.PushBack(GetLocStringByKeyExt("panel_title_clock")); // #B change localization keys if we realy want to have small letters here
		_SubMenusNames.PushBack('AlchemyMenu');
		_SubMenusDisplayNames.PushBack(GetLocStringByKeyExt("panel_title_alchemy")); // #B change localization keys if we realy want to have small letters here
		_SubMenusNames.PushBack('PreparationMainMenu');
		_SubMenusDisplayNames.PushBack(GetLocStringByKeyExt("panel_title_preparation")); // #B change localization keys if we realy want to have small letters here
		_SubMenusNames.PushBack('CharacterMenu');
		_SubMenusDisplayNames.PushBack(GetLocStringByKeyExt("panel_title_character")); // #B change localization keys if we realy want to have small letters here
		
		SendSubMenusData();
	}
	
	
	function SendSubMenusData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var i : int;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < _SubMenusNames.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("iconName",_SubMenusNames[i]);
			l_flashObject.SetMemberFlashUInt("subPanelName",NameToFlashUInt(_SubMenusNames[i]));
			l_flashObject.SetMemberFlashString("label",_SubMenusDisplayNames[i]);
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		m_flashValueStorage.SetFlashArray( "meditation.main.subpanels", l_flashArray );
	}

	event  OnCloseMenu()
	{
		var medd : W3PlayerWitcherStateMeditation;
		var waitt : W3PlayerWitcherStateMeditationWaiting;
	
		if ( !GetSubMenu() )
		{
			CloseMenu();
			
			if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
			{
				waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
				if(waitt)
				{
					waitt.MeditationStopRequested();
				}
			}
			else
			{
				medd = (W3PlayerWitcherStateMeditation)GetWitcherPlayer().GetCurrentState();
				if(medd)
				{
					medd.StopRequested(false);
				}
			}
		}
	}
	
	function MeditatingEnd()
	{
		var clockMenu : CR4MeditationClockMenu;
			
		if ( GetSubMenu() )
		{
			clockMenu = ( CR4MeditationClockMenu)GetSubMenu();
			if( clockMenu )
			{
				clockMenu.MeditatingEnd();
			}
		}
	}
	
	event  OnSkills() // here kill
	{
		RequestSubMenu( 'CharacterMenu' );
	}	

	event  OnRequestSubMenu( subMenu : name )
	{
		if ( !GetSubMenu() )
		{
			m_flashValueStorage.SetFlashBool("restore.input",false,-1);
			RequestSubMenu( subMenu );	
		}
	}	
	*/
}
