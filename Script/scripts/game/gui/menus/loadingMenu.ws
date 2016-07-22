/***********************************************************************/
/** Witcher Script file - Loading StoryBook Screen
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4LoadingMenu extends CR4MenuBase
{
	//private var m_fxSetMovieData : CScriptedFlashFunction;
	//private var m_fxEnableSkip : CScriptedFlashFunction;
	//private var m_fxSetWorldBackground : CScriptedFlashFunction;
	//protected var m_journalManager		: CWitcherJournalManager;
	private var guiManager : CR4GuiManager;
	
	event /*flash*/ OnConfigUI()
	{
		//var initData : W3MenuInitData;
		//var initData2 : IScriptable;
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		
		super.OnConfigUI();
		
		m_flashModule = GetMenuFlash();
		MakeModal(true);
	}

	event /*flash*/ OnCloseMenu()
	{
		CloseMenu();
	}	
	
	event /* C++ */ OnClosingMenu()
	{
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}
	
	event OnPlaySoundEvent( soundName : string )
	{
	}
}

exec function loadingmenu()
{
	theGame.RequestMenu('LoadingMenu');
}

exec function loadingmenuclose()
{
	var guiManager : CR4GuiManager;
	guiManager = theGame.GetGuiManager();
	guiManager.CancelFlashbackVideo();
	theGame.CloseMenu('LoadingMenu');
}