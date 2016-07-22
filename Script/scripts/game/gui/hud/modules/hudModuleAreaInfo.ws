class CR4HudModuleAreaInfo extends CR4HudModuleBase // #B deprecated
{	
	private var m_fxSetTextSFF	: CScriptedFlashFunction;
	private var dt	: float;
	private var showTime	: float;
	private var bShow	: bool;
	

	event /* flash */ OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		m_anchorName = "mcAnchorAreaInfo";
		super.OnConfigUI();
	
		flashModule = GetModuleFlash();	
		m_fxSetTextSFF = flashModule.GetMemberFlashFunction( "SetText" );
	}

	function ShowAreaInfo( localisationKey : string )
	{
		var text : string;
		
		text = GetLocStringByKeyExt( localisationKey );
		m_fxSetTextSFF.InvokeSelfOneArg(FlashArgString(text));
		ShowElement(true);
		showTime = 3;
		dt = 0;
		bShow = true;
	}

	event /* C++ */ OnTick( timeDelta : float )
	{
		if( bShow )
		{
			dt += timeDelta;
			if( dt > showTime )
			{
				ShowElement(false);
				bShow = false;
			}
		}
	}
}

exec function testarea( text : string )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleAreaInfo;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleAreaInfo)hud.GetHudModule("AreaInfoModule");
	module.ShowAreaInfo( text );
}
