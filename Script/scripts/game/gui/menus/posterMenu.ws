class CR4PosterMenu extends CR4MenuBase
{
	private var	m_posterEntity : W3Poster;

	private var m_fxSetDescriptionSFF			: CScriptedFlashFunction;
	private var m_fxSetSubtitlesHackSFF			: CScriptedFlashFunction;

	event /*flash*/ OnConfigUI()
	{	
		var flashModule : CScriptedFlashSprite;
		var description : string;

		super.OnConfigUI();
		
		flashModule = GetMenuFlash();

		m_fxSetDescriptionSFF = flashModule.GetMemberFlashFunction( "SetDescription" );
		m_fxSetSubtitlesHackSFF = flashModule.GetMemberFlashFunction( "SetSubtitlesHack" );

		m_posterEntity = ( W3Poster )GetMenuInitData();
		if ( m_posterEntity )
		{
			description = m_posterEntity.GetDescription();
			
			if( m_posterEntity.GetIsDescriptionGenerated() )
			{
				m_fxSetDescriptionSFF.InvokeSelfTwoArgs( FlashArgString( description ), FlashArgBool( m_posterEntity.IsTextAlignedToLeft() ) );
			}
			else
			{
				if ( StrLen( description ) > 0 )
				{
					description = GetLocStringByKeyExt( description );
				}
				
				m_fxSetDescriptionSFF.InvokeSelfTwoArgs( FlashArgString( description ), FlashArgBool( m_posterEntity.IsTextAlignedToLeft() ) );
			}
		}

		theInput.StoreContext( 'EMPTY_CONTEXT' );
	}
	
	event /*C++*/ OnClosingMenu()
	{
		super.OnClosingMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		
		m_posterEntity.LeavePosterPreview();
		
		OnPlaySoundEvent( "gui_noticeboard_close" );
	}

	event /*flash*/ OnCloseMenu()
	{
		CloseMenu();
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_noticeboard_enter" );
	}
	
	function CanPostAudioSystemEvents() : bool
	{
		return false;
	}
	
	public function AddSubtitle( speaker : string, text : string )
	{
		m_fxSetSubtitlesHackSFF.InvokeSelfTwoArgs( FlashArgString( speaker ), FlashArgString( text ) );
	}

	public function RemoveSubtitle()
	{
		m_fxSetSubtitlesHackSFF.InvokeSelfTwoArgs( FlashArgString( "" ), FlashArgString( "" ) );
	}
}

exec function postermenu()
{
	theGame.RequestMenu('PosterMenu');
}
