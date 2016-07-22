/***********************************************************************/
/** Witcher Script file - death screen module
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4HudModuleDeathScreen extends CR4HudModuleBase
{
	private var m_fxSetShowBlackscreenSFF			: CScriptedFlashFunction;
	public var m_flashValueStorage : CScriptedFlashValueStorage;	
	public var hasSaveData : bool;	
	public var isOpened : bool;
	
	///////////////////////////////////////////////////////////////////////////////////////////
	//    W           W       A      TTTTTTTT   CCCC   H   H           OOOO  U    U TTTTTTT
	//    W           W      A A        T      C    c  H   H          O    O U    U    T
	//     W    W    W      A   A       T      C       HHHHH          O    O U    U    T
	//      W  W  W W      A AAA A      T      C    c  H   H          O    O U    U    T
	//        W    W      A       A     T       CCCC   H   H           OOOO   UUUU     T
	///////////////////////////////////////////////////////////////////////////////////////////
	// This file is deprecated system. Looting moved to DeathScreenMenu.ws. Did not delete to 
	// avoid breaking things. Also used a reference to how it worked before in case anything broke.
	///////////////////////////////////////////////////////////////////////////////////////////

	event /* flash */ OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		
		isOpened = false;
		m_anchorName = "ScaleOnly";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetShowBlackscreenSFF			= flashModule.GetMemberFlashFunction( "setShowBlackscreen" );
		PopulateData();
		SetTickInterval( 1 );
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
		
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
			l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_deathscreen_respawn") );
			l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Respawn') );
			l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		}
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();	
		l_DataFlashObject.SetMemberFlashString	( "label", GetLocStringByKeyExt("panel_button_common_quittomainmenu") );
		l_DataFlashObject.SetMemberFlashUInt	( "tag", NameToFlashUInt('Quit') );
		l_FlashArray.PushBackFlashObject( l_DataFlashObject );
		
		m_flashValueStorage.SetFlashArray( "hud.deathscreen.list", l_FlashArray );
	}
	
	event OnTick( timeDelta : float )
	{
		if (isOpened)
		{
			if ( !CanTick( timeDelta ) )
			{
				return true;
			}
			
			if( hasSaveData != hasSaveDataToLoad() )
			{
				PopulateData();
			}
			
			if( theGame.IsBlackscreen() || theGame.IsFading() )
			{
				m_fxSetShowBlackscreenSFF.InvokeSelfOneArg(FlashArgBool(true));
				theGame.FadeInAsync(0);
			}
		}
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
		}
	}
	
	event /* flash */ OnOpened( opened : bool )
	{	
		var tutorialPopupRef  : CR4TutorialPopup;
		if ( opened )
		{
			tutorialPopupRef = (CR4TutorialPopup)theGame.GetGuiManager().GetPopup('TutorialPopup');
			if (tutorialPopupRef)
			{
				tutorialPopupRef.ClosePopup();
			}
			PopulateData();
			
			theSound.EnterGameState(ESGS_Death);
			theSound.SoundEvent( 'gui_global_player_death_thump' );
			
			theGame.Pause( "DeathScreen" );
		}
		else
		{
			theGame.Unpause( "DeathScreen" );
		}
		isOpened = opened;
	}		

	event /* flash */ OnLoad()
	{
		var initData : W3MenuInitData = new W3MenuInitData in this;
		initData.setDefaultState('LoadGame');
		theGame.RequestMenuWithBackground( 'IngameMenu', 'CommonIngameMenu', initData );
	}		

	event /* flash */ OnQuit()
	{
		theGame.GetGuiManager().TryQuitGame();
		isOpened = false;
	}		
	
	event /* flash */ OnRespawn()
	{
		theGame.SetIsRespawningInLastCheckpoint();
		theGame.LoadLastGameInit( true );
	}
}
