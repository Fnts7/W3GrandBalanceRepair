class AxiiModsEnemyScale extends AxiiMods
{
	public function GetHealthMod (victim : CNewNPC) : float
	{
		return victim.NPCModHealth();
	}

	public function GetDamageMod (attacker : CNewNPC) : float
	{
		if (theGame.GetInGameConfigWrapper().GetVarValue('EnemyScale', 'ESEnabled'))
			return attacker.NPCModDamage();
		else
			return 1.0f;
	}
}
