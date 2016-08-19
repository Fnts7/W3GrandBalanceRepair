//////////////////////////////////////////////////////
//////////// Grand Balance Repair Petards ////////////
//////////////////////////////////////////////////////

function PetardBonus(type : string, petardLevel : int) : float
{
	var percentFactorDmg : array<float>;
	var percentFactorAim : array<float>;
	var percentFactorDuration : array<float>;
	
	// % dmg bonus multiplied by player level
	percentFactorDmg.PushBack(1.0);  // petard on 1 level
	percentFactorDmg.PushBack(1.5);  // petard on 2 level
	percentFactorDmg.PushBack(2.0);  // petard on 3 level
	
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
		case "duration":
			return (thePlayer.GetLevel() * (percentFactorDuration[petardLevel] / 100));
		case "aim":
			return percentFactorAim[petardLevel] / 100;
	}
}
