/***********************************************************************/
/** Witcher Script file - Notice Board Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4NoticeBoardMenu extends CR4MenuBase
{
	public var board : W3NoticeBoard;
	private var m_fxSetSelectedIndex   	 : CScriptedFlashFunction;
	private var m_fxSetTitle   			 : CScriptedFlashFunction;
	private var m_fxSetDescription   	 : CScriptedFlashFunction;

	event /*flash*/ OnConfigUI()
	{			
		super.OnConfigUI();
		
		m_flashModule = GetMenuFlash();
		m_fxSetSelectedIndex = m_flashModule.GetMemberFlashFunction( "setSelectedIndex" );
		m_fxSetTitle = m_flashModule.GetMemberFlashFunction( "setTitle" );
		m_fxSetDescription = m_flashModule.GetMemberFlashFunction( "setDescription" );
		board = (W3NoticeBoard)GetMenuInitData();
		if( board )
		{
			//board.addedErrands
			UpdateDescription();
		}
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		thePlayer.BlockAction(EIAB_Interactions, 'NoticeBoard' );		
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.3, 0.5);
		}
		
		theGame.ResetFadeLock( "NoticeboardStart" );
		theGame.FadeInAsync( 3.0 );
		//board.UpdateBoard();
		//board.SetNoticeBoardMenu(this);
		//board.ShowErrand( board.FindFirstErrand() );
	}
	
	public function UpdateDescription()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var errands					: array< ErrandDetailsList >;
		var i						: int;
		var length					: int;
		var selected				: bool;
		
		errands = board.activeErrands;
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < errands.Size(); i += 1 )
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString("tag", errands[i].errandStringKey );
			if( !selected && errands[i].errandStringKey != "" )
			{
				selected = true;
				//l_DataFlashObject.SetMemberFlashBool("selected", true );
				m_fxSetSelectedIndex.InvokeSelfOneArg(FlashArgInt(i));
				OnErrandSelected( errands[i].errandStringKey );
			}
			/*else
			{
				l_DataFlashObject.SetMemberFlashBool("selected", false );
			}*/
			if( errands[i].newQuestFact == "flaw" || errands[i].displayAsFluff )
			{
				l_DataFlashObject.SetMemberFlashBool("isFluff", true );
			}
			else
			{
				l_DataFlashObject.SetMemberFlashBool("isFluff", false );
			}
			l_DataFlashObject.SetMemberFlashInt("posX", errands[i].posX );
			l_DataFlashObject.SetMemberFlashInt("posY", errands[i].posY );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			length += 1;
			
			if( length >= board.MAX_DISPLAYED_ERRANDS )
			{
				break;
			}
		}
		//board.RemoveEmptyActiveErrands();
		m_flashValueStorage.SetFlashArray( "noticeboard.errands.list", l_DataFlashArray );
	}
	
	public function SetBoardNoteTitle(value : string) : void
	{
		m_fxSetTitle.InvokeSelfOneArg(FlashArgString(value));
	}
	
	public function SetBoardNoteDescription(value : string) : void
	{
		m_fxSetDescription.InvokeSelfOneArg(FlashArgString(value));
	}

	event /*flash*/ OnTakeQuest( tag : string )
	{	
		if(ShouldProcessTutorial('TutorialQuestBoard'))
		{
			FactsAdd("tut_noticeboard_taken");
		}
		OnPlaySoundEvent("gui_noticeboard_paper");
		if( board.AcceptNewQuest(tag) )
		{
			OnCloseMenu();
		}
	}
	
	event /*flash*/ OnErrandSelected( tag : string )
	{
		SetBoardNoteTitle(GetLocStringByKeyExt(tag));
		SetBoardNoteDescription(GetLocStringByKeyExt(tag+"_text"));
	}
	
	event /*flash*/ OnCloseMenu()
	{
		//board.LeaveBoardPreview();
		
		//custom handling since it doesn't work from base for some reason???
		theGame.GetTutorialSystem().uiHandler.OnClosedMenu(GetMenuName());
		
		
		CloseMenu();
	}
	
		
	event /* C++ */ OnClosingMenu()
	{
		//custom handling since it doesn't work from base for some reason???
		theGame.GetTutorialSystem().uiHandler.OnClosingMenu(GetMenuName());
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		thePlayer.UnblockAction(EIAB_Interactions, 'NoticeBoard' );
		
		if(	!m_parentMenu)
			theSound.SoundEvent("system_resume");
		
		OnPlaySoundEvent( "gui_noticeboard_close" );
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_noticeboard_enter" );
	}
}
