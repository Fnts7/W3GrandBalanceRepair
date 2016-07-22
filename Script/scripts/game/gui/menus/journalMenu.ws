/***********************************************************************/
/** Witcher Script file - journal : Main
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4JournalMenu extends CR4MenuBase // #B obsolete
{	
	private var m_menuNames : array< name >;

	event /*flash*/ OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		super.OnConfigUI();
		//theSound.SoundEvent( 'gui_global_panel_open' );  // #B sound - open
		
		//@FIXME BIDON open menu depending on selected tab
		
		m_menuNames.PushBack( 'JournalQuestMenu' );
		m_menuNames.PushBack( 'JournalQuestMenu' );
		m_menuNames.PushBack( 'JournalQuestMenu' );
	}
	
	event /*flash*/ OnCloseMenu()
	{
		var commonMenu : CR4CommonMenu;
		
		//theSound.SoundEvent( 'gui_global_quit' ); // #B sound - quit
		CloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}

	event /*flash*/ OnJournalTabSelected( index : int )
	{
		var menu : CR4MenuBase;

		if ( index >= 0 && index < m_menuNames.Size() )		
		{
			menu = (CR4MenuBase)GetSubMenu();
			if ( menu )
			{
				menu.SetParentMenu(NULL);
				menu.OnCloseMenu();
			}
			RequestSubMenu( m_menuNames[ index ] );
		}
	}
	
	event OnTrackQuest( _QuestID : int ) // #B add untracking quest
	{
		LogChannel('KURWA'," journalMenu OnTrackQuest( _QuestID "+  _QuestID );
	}
}