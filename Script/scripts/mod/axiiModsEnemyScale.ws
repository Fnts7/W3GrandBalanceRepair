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

	public function GetPuppetPowerBonusMod(puppet : CNewNPC) : float
	{
		var stats : CCharacterStats;
		var count : int;
		var result : float;

		result = 1.0f;		
		stats = puppet.GetCharacterStats();
		if (!stats)
			return result;
		
		if (stats.HasAbility('ESBuffDamage'))
		{
			count = stats.GetAbilityCount('ESBuffDamage');
			result += count * 0.01f;
		}
		else if (stats.HasAbility('ESWeakenDamage'))
		{
			count = stats.GetAbilityCount('ESWeakenDamage');
			result -= count * 0.01f;
			if (result < 0.01f)
				result = 0.01f;
		}

		return result;
	}
}
