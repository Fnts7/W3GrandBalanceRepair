/***********************************************************************/
/** Witcher Script file - Ingame menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4CommonIngameMenu extends CR4MenuBase
{
	private var m_menuData 	  		: array< SMenuTab >;
	protected var currentMenuName 	: name;
	public var reopenRequested	: bool; default reopenRequested = false;
	
	event /*flash*/ OnConfigUI()
	{
		var menuName : name;
		//initData.SetPanelXOffset(595);
		
		if ((!thePlayer.IsAlive() && !thePlayer.OnCheckUnconscious()) || theGame.HasBlackscreenRequested() || theGame.IsDialogOrCutscenePlaying() )
		{
			CloseMenu();
		}
		else
		{
			m_hideTutorial = true;
			m_forceHideTutorial = true;
			super.OnConfigUI();
			menuName = theGame.GetMenuToOpen();
			
			theGame.GetGuiManager().RequestMouseCursor(true);
			
			if (theInput.LastUsedPCInput())
			{
				theGame.MoveMouseTo(0.17, 0.36);
			}
			
			//if( menuName == '')
			{
				menuName = 'IngameMenu';
			}
			
			//DefineMenuStructure();
			
			theSound.SoundEvent("system_pause");
			
			SetupMenu();
			OnRequestSubMenu( menuName, GetMenuInitData() );
			
			theInput.StoreContext( 'EMPTY_CONTEXT' );
		}
	}
	
	event /* C++ */ OnClosingMenu()
	{
		super.OnClosingMenu();
		
		if (m_configUICalled)
		{
			theGame.GetGuiManager().RequestMouseCursor(false);
			
			theSound.SoundEvent("system_resume");
			
			theInput.RestoreContext( 'EMPTY_CONTEXT', false );
			
			OnPlaySoundEvent( "gui_global_panel_close" );
		}
	}

	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu( menuName, initData );
		currentMenuName = menuName;
	}

	event /*flash*/ OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
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
	}

	event /*flash*/ OnCloseMenu()
	{
		var menu			: CR4MenuBase;
		
		//menu = (CR4MenuBase)GetSubMenu();
		//if( menu )
		//{
		//	menu.CloseMenu();
		//}
		//CloseMenu();
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
		var initData : W3MainMenuInitData;
		initData = new W3MainMenuInitData in this;
		//initData.SetPanelXOffset(595);
		
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
					OnRequestSubMenu( menuToOpen, initData );
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

	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent("gui_global_panel_open");	
	}
}

exec function ingamemenu()
{
	//theGame.RequestMenuWithBackground('MainMenu','CommonMainMenu');
	theGame.SetMenuToOpen( '' );
	theGame.RequestMenu('CommonIngameMenu' );
}