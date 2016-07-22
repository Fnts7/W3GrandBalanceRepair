class CR4HudModuleTest extends CR4HudModuleBase
{	
	/* flash */ event OnConfigUI()
	{
		super.OnConfigUI();

		ShowElement(false);
	}

	event OnTick( timeDelta : float )
	{
	}

}