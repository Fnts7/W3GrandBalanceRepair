class CR4HudModuleTimeLapse extends CR4HudModuleBase
{
	private var m_fxSetShowTimeSFF						: CScriptedFlashFunction;
	private var m_fxSetTimeLapseMessage					: CScriptedFlashFunction;
	private var m_fxSetTimeLapseAdditionalMessage		: CScriptedFlashFunction;	


	event /* flash */ OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorTimelapse";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetShowTimeSFF 		= flashModule.GetMemberFlashFunction( "SetShowTime" ); 
		m_fxSetTimeLapseMessage = flashModule.GetMemberFlashFunction( "handleTimelapseTextSet" );
		m_fxSetTimeLapseAdditionalMessage = flashModule.GetMemberFlashFunction( "handleTimelapseAdditionalTextSet" );
		// ShowElement(false);

		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('TimeLapseModule', true);
		}
	}

	
	public function SetShowTime( showTime : float )
	{
		//GetWitcherPlayer().AddTimer('HideTimeLapse',showTime);
		m_fxSetShowTimeSFF.InvokeSelfOneArg(FlashArgNumber(showTime*1000));
	}	
	
	public function SetTimeLapseMessage( localisationKey : string )
	{
		var str : string;
		str = GetLocStringByKeyExt(localisationKey);
		if(str == "#" || StrUpper(str) == "#NONE")
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(""));
		}
		else
		{
			m_fxSetTimeLapseMessage.InvokeSelfOneArg(FlashArgString(str));
		}
	}			

	public function SetTimeLapseAdditionalMessage( localisationKey : string )
	{
		var str : string;
		str = GetLocStringByKeyExt(localisationKey);
		if(str == "#" || StrUpper(str) == "#NONE")
		{
			m_fxSetTimeLapseAdditionalMessage.InvokeSelfOneArg(FlashArgString(""));
		}
		else
		{
			m_fxSetTimeLapseAdditionalMessage.InvokeSelfOneArg(FlashArgString(str));
		}
	}		
	
	public function Show( bShow : bool )
	{
		ShowElement(bShow);
	}
}