class CR4HudModuleWatermark extends CR4HudModuleBase
{
	/* flash */ event OnConfigUI()
	{
		m_anchorName = "mcAnchorWatermark";
		super.OnConfigUI();

		//ShowElement(false);
	}
}

exec function hud_testwatermark( show : bool )
{
	var hud : CR4ScriptedHud;
	var watermarkModule : CR4HudModuleWatermark;

	hud = (CR4ScriptedHud)theGame.GetHud();
	watermarkModule = (CR4HudModuleWatermark)hud.GetHudModule("WatermarkModule");
	watermarkModule.ShowElement( show );
}
