/***********************************************************************/
/** Witcher Script file - Main Menu Mouse Options
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4MainDbgStartQuestMenu extends CR4MenuBase
{
	private var m_optionsNames : array< name >;
	private var m_gameResources : array< string >;
	
	event /*flash*/ OnConfigUI()
	{
		super.OnConfigUI();
		MakeModal(true);
		
		UpdateMenuOptions();
	}
	
	function UpdateMenuOptions()
	{
		var i : int;
		var flashObject			: CScriptedFlashObject;
		var l_DataFlashArray			: CScriptedFlashArray;
		
		m_gameResources = theGame.GetGameResourceList();
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for ( i = 0; i < m_gameResources.Size(); i += 1 )
		{
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashString( "label", m_gameResources[ i ] );
			flashObject.SetMemberFlashString( "tag", m_gameResources[ i ] );
			flashObject.SetMemberFlashString( "iconPath", "" );
			flashObject.SetMemberFlashString( "description", "");
			l_DataFlashArray.PushBackFlashObject( flashObject );
		}
		
		m_flashValueStorage.SetFlashArray( "mainmenu.quests.entries", l_DataFlashArray );
	}

	event /*flash*/ OnItemChosen( optionName : name )
	{
	}
	
	event /*flash*/ OnStartQuest( optionName : string )
	{
		if ( theGame.RequestNewGame( optionName ) )
		{
			GetRootMenu().CloseMenu();
		}
	}	
	
	event /*flash*/ OnBack()
	{
		CloseMenu();
	}
}