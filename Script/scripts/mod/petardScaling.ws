//////////////////////////////////////////////////////
//////////// Grand Balance Repair Petards ////////////
//////////////////////////////////////////////////////

function PetardBonus(type : string, petardLevel : int) : float
{
	var percentFactorDmg : array<float>;
	var percentFactorAim : array<float>;
	var percentFactorDuration : array<float>;
	var percentFactorDmgPyro : array<float>;
	var percentFactorDragonBurning : array<float>;
	
	// % dmg bonus multiplied by player level
	percentFactorDmg.PushBack(1.5f);  // petard on 1 level
	percentFactorDmg.PushBack(2.25f);  // petard on 2 level
	percentFactorDmg.PushBack(3.0f);  // petard on 3 level
	
	// % pyrotechnics dmg multiplied by player level
	percentFactorDmgPyro.PushBack(2.0f);  // petard on 1 level
	percentFactorDmgPyro.PushBack(3.0f);  // petard on 2 level
	percentFactorDmgPyro.PushBack(4.0f);  // petard on 3 level
	
	// % Dragons Dream burning chance bonus multiplied by player level
	percentFactorDragonBurning.PushBack(0.5);  // petard on 1 level
	percentFactorDragonBurning.PushBack(0.75);  // petard on 2 level
	percentFactorDragonBurning.PushBack(1.0);  // petard on 3 level
	
	//% duration time bonus multiplied by player level
	percentFactorDuration.PushBack(1.0);  // petard on 1 level
	percentFactorDuration.PushBack(1.5);  // petard on 2 level
	percentFactorDuration.PushBack(2.0);  // petard on 3 level
	
	//% dmg bonus applied with manual aiming
	percentFactorAim.PushBack(6.0f);  // petard on 1 level
	percentFactorAim.PushBack(9.0f); // petard on 2 level
	percentFactorAim.PushBack(12.0f); // petard on 3 level
	
	switch(type)
	{
		case "dmg":
			return (thePlayer.GetLevel() * (percentFactorDmg[petardLevel - 1] / 100));
		case "dmgPyro":
			return 1.0f + (thePlayer.GetLevel() * (percentFactorDmgPyro[petardLevel - 1] / 100));
		case "dmgHalved":
			return (thePlayer.GetLevel() * (percentFactorDmg[petardLevel - 1] / 200));
		case "dragonBurningChance":
			return (thePlayer.GetLevel() * (percentFactorDragonBurning[petardLevel - 1] / 100));
		case "duration":
			return (thePlayer.GetLevel() * (percentFactorDuration[petardLevel - 1] / 100));
		case "durationHalved":
			return (thePlayer.GetLevel() * (percentFactorDuration[petardLevel - 1] / 200));
		case "aim":
			if (thePlayer.CanUseSkill(S_Alchemy_s09))
			{
				return (1.0f + thePlayer.GetSkillLevel(S_Alchemy_s09) * 0.5f) * percentFactorAim[petardLevel - 1] / 100;
			}
			else
				return percentFactorAim[petardLevel - 1] / 100;
		default:
			return 0;
	}
}

function GrapeshotBonus() : float
{
	var level : int;

	level = thePlayer.GetLevel();

	if (level < 0)
		level = 0;

	if (level <= 30)
		return 0.025f * level;
	else
		return 0.75f + 0.05f * (level - 30);
}

function GetPetardClusterDamageBonus(_skillLevel : int) : float
{
	var skillLevel : int;
	if (_skillLevel > 0)
		skillLevel = _skillLevel;
	else if (thePlayer.CanUseSkill(S_Alchemy_s11))
		skillLevel = thePlayer.GetSkillLevel(S_Alchemy_s11);
	else
		skillLevel = 0;

	if (skillLevel >= 4)
		return 0.2f;
	else if (skillLevel >= 2)
		return 0.1f;
	else
		return 0;
}
