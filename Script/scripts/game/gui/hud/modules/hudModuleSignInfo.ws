class CR4HudModuleSignInfo extends CR4HudModuleBase // #B deprecated - for remove
{
	private var _iconName : string;
	private var _CurrentSelectedSign : ESignType;
	private var m_fxShowBckArrowSFF : CScriptedFlashFunction;
	private var m_fxEnableSFF : CScriptedFlashFunction;


	/* flash */ event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		
		m_anchorName = "mcAnchorSignInfo";
		
		super.OnConfigUI();
		
		flashModule 			= GetModuleFlash();	
		m_fxShowBckArrowSFF		= flashModule.GetMemberFlashFunction( "ShowBckArrow" );
		m_fxEnableSFF			= flashModule.GetMemberFlashFunction( "EnableElement" );
		_CurrentSelectedSign 	= GetWitcherPlayer().GetEquippedSign();
		_iconName 				= GetSignIcon();
		UpdateSignData();
		
		ShowElement(true);
	}

	event OnTick( timeDelta : float )
	{
		if( thePlayer.GetEquippedSign() != _CurrentSelectedSign )
		{
			_CurrentSelectedSign = thePlayer.GetEquippedSign();
			UpdateSignData();
		}
	}

	event OnSignInfoShowBckArrow( bShow : bool )
	{
		ShowBckArrow(bShow);
	}
	
	public function UpdateSignData()
	{
		var flashValueStorage : CScriptedFlashValueStorage = GetModuleFlashValueStorage();
		
		flashValueStorage.SetFlashString( 'signinfo.iconname', GetSignIcon(), -1 );
	}
	
	private function GetSignIcon() : string
	{
		if((W3ReplacerCiri)thePlayer)
		{
			return "hud/radialmenu/mcCiriPower.png";
		}
		return GetSignIconByType(_CurrentSelectedSign); 
	}
	
	private function GetSignIconByType( signType : ESignType ) : string
	{
		switch( signType )
		{
			case ST_Aard:		return "hud/radialmenu/mcAard.png";
			case ST_Yrden:		return "hud/radialmenu/mcYrden.png";
			case ST_Igni:		return "hud/radialmenu/mcIgni.png";
			case ST_Quen:		return "hud/radialmenu/mcQuen.png";
			case ST_Axii:		return "hud/radialmenu/mcAxii.png";
			default : return "";
		}
	}
	
	public function ShowBckArrow(bShow : bool):void
	{
		m_fxShowBckArrowSFF.InvokeSelfOneArg( FlashArgBool( bShow ) );
	}
	
	public function EnableElement( enable : bool ) : void
	{
		m_fxEnableSFF.InvokeSelfOneArg( FlashArgBool( enable ) );
	}
}

exec function esign( enable : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleSignInfo;

	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		module = (CR4HudModuleSignInfo)hud.GetHudModule("SignInfoModule");
		module.EnableElement( enable );
	}
}