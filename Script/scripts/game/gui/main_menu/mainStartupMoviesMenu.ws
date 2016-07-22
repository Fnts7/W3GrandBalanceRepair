/***********************************************************************/
/** Witcher Script file - Startup Movies Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

// WARNING changes done here should also be done in mainRecapMoviesMenu.ws

struct SMovieData
{
	var movieName : string;
	var isSkipable : bool;
	var showLogo : bool;
};

class CR4StartupMoviesMenu extends CR4MenuBase
{
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	private var m_MovieData 		: array<SMovieData>;
	private var m_CurrentMovieID	: int;
	default m_CurrentMovieID		= 0;
	private var guiManager 			: CR4GuiManager;
	private var wasSkipped 			: bool;
	default wasSkipped 				= false;
	private var languageName : string;
	
	event /*flash*/ OnConfigUI()
	{
		var menuName : name;
		var audioLanguageName : string;
		SetupMoviesData();
		m_flashValueStorage = GetMenuFlashValueStorage();
		super.OnConfigUI();
		m_flashModule = GetMenuFlash();
		guiManager = theGame.GetGuiManager();
		
		if (m_MovieData.Size() == 0)
		{
			CloseMenu();
		}
		else
		{
			m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
			//m_fxSetMovieData.InvokeSelfOneArg(FlashArgString(GetCurrentBackgroundMovie()));
			theGame.GetGameLanguageName(audioLanguageName,languageName);
			m_fxSetGameLogoLanguage.InvokeSelfTwoArgs( FlashArgBool(m_MovieData[m_CurrentMovieID].showLogo), FlashArgString(languageName) );
			guiManager.PlayFlashbackVideoAsync(GetCurrentBackgroundMovie());
			//SetButtons();
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
	}
	
	private function SetupMoviesData() // #B setup movies played on game start
	{
		var movieData : SMovieData;
		
		m_MovieData.Clear();
		
		// legalscreen and publisher_bumpers are already played back on PS4 at this point
		if( theGame.GetPlatform() == Platform_PC ) 
		{
			movieData.movieName = "gamestart/bumpers/bumpers.usm";
			movieData.isSkipable = true;
			movieData.showLogo = false;
			m_MovieData.PushBack(movieData);
		}
	}
	
	function GetCurrentBackgroundMovie() : string
	{
		return m_MovieData[m_CurrentMovieID].movieName;
	}
	
	event /* C++ */ OnClosingMenu()
	{
		super.OnClosingMenu();
		guiManager.CancelFlashbackVideo();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}	
	
	event /* flash */ OnSkipMovie()
	{
		m_CurrentMovieID += 1;
		if( m_CurrentMovieID >= m_MovieData.Size() )
		{
			CloseMenu();
			return false;
		}
		SetButtons();
		m_fxSetGameLogoLanguage.InvokeSelfTwoArgs( FlashArgBool(m_MovieData[m_CurrentMovieID].showLogo), FlashArgString(languageName) );
		guiManager.PlayFlashbackVideoAsync(GetCurrentBackgroundMovie());
		wasSkipped = true;
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

	event /*flash*/ OnCloseMenu()
	{
		CloseMenuRequest();
	}
	
	function CloseMenuRequest():void
	{
		var menu			: CR4MenuBase;
		
		menu = (CR4MenuBase)GetSubMenu();
		if( !menu )
		{
			CloseMenu();
		}
		else
		{
			//menu.CloseMenu();
			
			// get parent menu
		}
	}
	
	event OnVideoSubtitles( subtitles : string )
	{
		// #J Look at recap Movies menu to implement this. Currently not needed
		// May require a rexport of the menu
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
		m_flashValueStorage.SetFlashArray("startup.movies.buttons.setup", gfxDataList);
	}
		
	function SetButtons()
	{	
		var ButtonsDef	: array<SMenuButtonDef>;
		m_defaultInputBindings.Clear();
		if( m_MovieData[m_CurrentMovieID].isSkipable )
		{
			AddInputBinding("panel_button_dialogue_skip", "gamepad_X", 32 );
		}
		UpdateInputFeedback();
	}	
	
	protected function AddInputBinding(label:string, padNavCode:string, optional keyboardKeyCode:int)
	{
		var bindingDef:SKeyBinding;
		bindingDef.Gamepad_NavCode = padNavCode;
		bindingDef.Keyboard_KeyCode = keyboardKeyCode;
		bindingDef.LocalizationKey = label;
		m_defaultInputBindings.PushBack(bindingDef);
	}
	
	function PlayOpenSoundEvent()
	{
	}
	
	event OnVideoStarted()
	{
		LogChannel('MOVIES',"OnVideoStarted");
	}
	
	event OnVideoStopped()
	{
		LogChannel('MOVIES',"OnVideoStopped");
		if( !wasSkipped )
		{
			OnSkipMovie();
		}
		wasSkipped = false;
	}
}


exec function startupmovies()
{
	theGame.RequestMenu( 'StartupMoviesMenu' );
}