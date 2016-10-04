// Interface class used to get necessary modifiers when calculating Axii puppet vs. non puppet damage
class AxiiMods
{
	public function GetHealthMod (victim : CNewNPC) : float
	{
		return 1.0f;
	}

	public function GetDamageMod (attacker : CNewNPC) : float
	{
		return 1.0f;
	}

	public function GetPuppetPowerBonusMod (puppet : CNewNPC) : float
	{
		return 1.0f;
	}
}
