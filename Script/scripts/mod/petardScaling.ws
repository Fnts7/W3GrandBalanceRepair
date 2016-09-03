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
	percentFactorDmg.PushBack(1.0);  // petard on 1 level
	percentFactorDmg.PushBack(1.5);  // petard on 2 level
	percentFactorDmg.PushBack(2.0);  // petard on 3 level
	
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
	percentFactorAim.PushBack(10.0);  // petard on 1 level
	percentFactorAim.PushBack(15.0); // petard on 2 level
	percentFactorAim.PushBack(20.0); // petard on 3 level
	
	switch(type)
	{
		case "dmg":
			return (thePlayer.GetLevel() * (percentFactorDmg[petardLevel] / 100));
		case "dmgPyro":
			return 1.0f + (thePlayer.GetLevel() * (percentFactorDmgPyro[petardLevel] / 100));
		case "dragonBurningChance":
			return (thePlayer.GetLevel() * (percentFactorDragonBurning[petardLevel] / 100));
		case "duration":
			return (thePlayer.GetLevel() * (percentFactorDuration[petardLevel] / 100));
		case "aim":
			return percentFactorAim[petardLevel] / 100;
	}
}
