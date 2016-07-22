class CR4HudModuleCrosshair extends CR4HudModuleBase
{	
	event /* flash */ OnConfigUI()
	{		
		m_anchorName = "mcAnchorCrosshair";
		super.OnConfigUI();
	}
}

exec function testcrosshair( value : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleCrosshair;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleCrosshair)hud.GetHudModule("CrosshairModule");
	module.ShowElement( value, false );
}
