class CR4HudModuleMessage extends CR4HudModuleBase
{	
	private var _bDuringDisplay : bool;		default _bDuringDisplay = false;
	private var _flashValueStorage : CScriptedFlashValueStorage;

	event /* flash */ OnConfigUI()
	{		
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorMessage";
		super.OnConfigUI();
		_flashValueStorage = GetModuleFlashValueStorage();

		//ShowElement(false);
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('MessageModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		if( !_bDuringDisplay )
		{
			if( CheckPendingMessages() )
			{
				DisplayPendingMessage();
			}
		}
	}
	
	event /* flash */ OnMessageHidden()
	{
		// remove message
		thePlayer.RemoveHudMessageByIndex(0);
		_bDuringDisplay = false;
		// clear
		_flashValueStorage.SetFlashString( 'hud.message', "" );
	}
	
	function CheckPendingMessages() : bool
	{
		if( thePlayer.GetHudMessagesSize() > 0 )
		{
			return true;
		}
		return false;
	}

	function DisplayPendingMessage()
	{
		var str : string;
		var strDebug : string;

		_bDuringDisplay = true;
		str = thePlayer.GetHudPendingMessage();
		strDebug = GetLocStringByKey(str);
		if( strDebug != "" )
		{
			str = strDebug;
		}
		_flashValueStorage.SetFlashString( 'hud.message', str );
		ShowElement(true); //#B OnDemand or OnUpdate ?
	}
}
