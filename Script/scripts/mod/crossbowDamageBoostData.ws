// mod CrossbowDamageBoost data and config file

// This is the data used by CrossbowDamageBoost for calculations
// It can be used as config also. Every line for basic config will be marked with //EDIT:
// and below the line to edit a description will follow
// DON'T CHANGE ANY OTHER LINE UNLESS YOU FULLY UNDERSTAND WHAT YOU ARE DOING
 
class CrossbowDamageBoostData
{
	public var SteelBoltFactor : float;
	public var SilverBoltFactor : float;
	public var ExplosiveBoltFactor : float;
	default SteelBoltFactor = 1.0f;
	default SilverBoltFactor = 1.0f;
	default ExplosiveBoltFactor = 1.0f;

	public var SteelWitcherFactor : float;
	public var SilverWitcherFactor : float;
	public var ExplosiveWitcherFactor : float;
	
	public var boltBaseDamage : array<float>;

	public function Init()
	{
// BASIC CONFIG BEGIN

		SteelBoltFactor = 
//EDIT:
		1.0
// This is the multiplicator of the non silver damage types of the bolts (blunt, piercing, fire)
// Floating point with valid value range (0.0, inifinity). I suggest not using extreme values, very low or very high, as this may cause weird behavior in game
// Example: 2.5 // bolts will deal the ~2.5x higher damage than with the mod by default
//			0.5 // bolts will deal the ~2 times lower damage than with the mod by default
		;

		SilverBoltFactor = 
//EDIT:
		1.0
// This is the multiplicator of the silver damage of the bolts
// Floating point with valid value range (0.0, inifinity). I suggest not using extreme values, very low or very high, as this may cause weird behavior in game
// Example: 2.0f // bolts will deal the ~2x higher silver damage than with the mod by default
//			0.3333f // bolts will deal the ~3 times lower silver damage than with the mod by default
		;
		
		ExplosiveBoltFactor = 
//EDIT:
		1.0
// This is the multiplicator of the damage of explosive bolts (both fire and silver). 
// This one multiplicates with SteelBoltFactor and SilverBoltFactor accordingly depending on damage type
// Floating point with valid value range (0.0, inifinity). I suggest not using extreme values, very low or very high, as this may cause weird behavior in game
// Example: 1.5 // explosive will deal the ~1.5x higher damage than with the mod by default (assuming the SteelBoltFactor and SilverBoltFactor value is 1.0)
//			0.75 // explosive will deal the 75% of default damage with the mod (assuming the SteelBoltFactor and SilverBoltFactor value is 1.0)
		;
			
// BASIC CONFIG END

// ADVANCED CONFIG BEGIN

		// The multiplicator for the non silver damage used for the damage added to bolts because of Witcher level
		// You can edit it to change the balance between bolt combined damage from bolts and bolt damage from Witcher level
		SteelWitcherFactor = 1.25f * SteelBoltFactor;
		
		// The multiplicator for the silver damage used for the damage added to bolts because of Witcher level
		// You can edit it to change the balance between bolt combined damage from bolts and bolt damage from Witcher level
		SilverWitcherFactor = 1.6f * SilverBoltFactor;
		
		// The multiplicator for the explosive bolt damage added because of Witcher level
		// Combines with SteelWitcherFactor and SilverWitcherFactor accordingly
		// You can edit it to change the balance between explosive bolt combined damage from bolts and the damage from Witcher level
		ExplosiveWitcherFactor = 1.0f * ExplosiveBoltFactor;
		
		// Below is an array of bolt damage values added with every Witcher level
		// When calculating damage it is affected by the SteelWitcherFactor, SilverWitcherFactor or ExplosiveWitcherFactor accordingly
		// For example Witcher level 12 will have the total base bolt damage added equal to 7.5
		/* Example calculations of bolt combined base damage:
			
		   Suppose we have a blunt bolt that deals 40 blunt damage and Witcher level 10.
		   boltDamage = 40 then
		   boltWitcherDamage = 5 then
		   The total bolt damage (blunt not silver) will be: SteelBoltFactor * boltDamage + SteelWitcherFactor * boltWitcherDamage
		   Which is 1.0 * 40 + 1.25 * 5.5 = 46.875 with default factors
		   
		   Suppose we have an explosive bolt that deals  silver damage and Witcher level 20
		   boltDamage = 90 then
		   boltWitcherDamage = 20 then
		   The total bolt damage (silver from fire bolt) will be: SilverBoltFactor * ExplosiveBoltFactor * boltDamage + SilverWitcherFactor * ExplosiveWitcherFactor * boltWitcherDamage
		   Which is 1.0 * 1.0 * 90 + 1.6 * 1.0 * 21 =  123.6 with default factors
		*/
		boltBaseDamage.PushBack(0.0); // Lvl 1
		boltBaseDamage.PushBack(0.0); // Lvl 2
		boltBaseDamage.PushBack(0.0); // Lvl 3
		boltBaseDamage.PushBack(0.0); // Lvl 4
		boltBaseDamage.PushBack(0.0); // Lvl 5
		boltBaseDamage.PushBack(1.0); // Lvl 6
		boltBaseDamage.PushBack(1.0); // Lvl 7
	    boltBaseDamage.PushBack(1.0); // Lvl 8
		boltBaseDamage.PushBack(1.0); // Lvl 9
		boltBaseDamage.PushBack(1.5); // Lvl 10
		boltBaseDamage.PushBack(1.5); // Lvl 11
		boltBaseDamage.PushBack(1.5); // Lvl 12
		boltBaseDamage.PushBack(1.5); // Lvl 13
		boltBaseDamage.PushBack(1.5); // Lvl 14
		boltBaseDamage.PushBack(1.5); // Lvl 15
		boltBaseDamage.PushBack(1.5); // Lvl 16
		boltBaseDamage.PushBack(1.5); // Lvl 17
		boltBaseDamage.PushBack(1.5); // Lvl 18
		boltBaseDamage.PushBack(1.5); // Lvl 19
		boltBaseDamage.PushBack(2.0); // Lvl 20
		boltBaseDamage.PushBack(2.0); // Lvl 21
		boltBaseDamage.PushBack(2.0); // Lvl 22
		boltBaseDamage.PushBack(2.0); // Lvl 23
 		boltBaseDamage.PushBack(2.0); // Lvl 24
		boltBaseDamage.PushBack(2.0); // Lvl 25
		boltBaseDamage.PushBack(2.0); // Lvl 26
		boltBaseDamage.PushBack(2.0); // Lvl 27
		boltBaseDamage.PushBack(2.0); // Lvl 28
		boltBaseDamage.PushBack(2.5); // Lvl 29
		boltBaseDamage.PushBack(2.5); // Lvl 30

		boltBaseDamage.PushBack(3.5); // Lvl 31
		boltBaseDamage.PushBack(3.5); // Lvl 32
		boltBaseDamage.PushBack(3.5); // Lvl 33
		boltBaseDamage.PushBack(3.5); // Lvl 34
		boltBaseDamage.PushBack(3.5); // Lvl 35
	    boltBaseDamage.PushBack(3.0); // Lvl 36
		boltBaseDamage.PushBack(3.0); // Lvl 37
		boltBaseDamage.PushBack(3.0); // Lvl 38
		boltBaseDamage.PushBack(3.0); // Lvl 39
		boltBaseDamage.PushBack(3.0); // Lvl 40
		boltBaseDamage.PushBack(3.0); // Lvl 41
		boltBaseDamage.PushBack(3.0); // Lvl 42
		boltBaseDamage.PushBack(3.5); // Lvl 43
		boltBaseDamage.PushBack(3.5); // Lvl 44
		boltBaseDamage.PushBack(3.0); // Lvl 45
		boltBaseDamage.PushBack(3.5); // Lvl 46
		boltBaseDamage.PushBack(3.5); // Lvl 47
		boltBaseDamage.PushBack(3.5); // Lvl 48
		boltBaseDamage.PushBack(3.5); // Lvl 49
		boltBaseDamage.PushBack(3.5); // Lvl 50
		boltBaseDamage.PushBack(3.5); // Lvl 51
		boltBaseDamage.PushBack(3.5); // Lvl 52
		boltBaseDamage.PushBack(3.5); // Lvl 53
		boltBaseDamage.PushBack(3.5); // Lvl 54
		boltBaseDamage.PushBack(3.5); // Lvl 55
		boltBaseDamage.PushBack(3.5); // Lvl 56
		boltBaseDamage.PushBack(3.5); // Lvl 57
		boltBaseDamage.PushBack(3.5); // Lvl 58
		boltBaseDamage.PushBack(3.5); // Lvl 59
		boltBaseDamage.PushBack(3.5); // Lvl 60
		boltBaseDamage.PushBack(3.5); // Lvl 61
		boltBaseDamage.PushBack(3.5); // Lvl 62
		boltBaseDamage.PushBack(3.5); // Lvl 63
		boltBaseDamage.PushBack(3.5); // Lvl 64
		boltBaseDamage.PushBack(3.5); // Lvl 65
		boltBaseDamage.PushBack(3.5); // Lvl 66
		boltBaseDamage.PushBack(3.5); // Lvl 67
		boltBaseDamage.PushBack(3.5); // Lvl 68
		boltBaseDamage.PushBack(3.5); // Lvl 69
		boltBaseDamage.PushBack(3.5); // Lvl 70
		boltBaseDamage.PushBack(3.5); // Lvl 71
		boltBaseDamage.PushBack(3.5); // Lvl 72
		boltBaseDamage.PushBack(3.5); // Lvl 73
		boltBaseDamage.PushBack(3.5); // Lvl 74
		boltBaseDamage.PushBack(3.5); // Lvl 75
		boltBaseDamage.PushBack(3.5); // Lvl 76
		boltBaseDamage.PushBack(3.5); // Lvl 77
		boltBaseDamage.PushBack(3.5); // Lvl 78
		boltBaseDamage.PushBack(3.5); // Lvl 79
		boltBaseDamage.PushBack(3.5); // Lvl 80
		boltBaseDamage.PushBack(3.5); // Lvl 81
		boltBaseDamage.PushBack(3.5); // Lvl 82
		boltBaseDamage.PushBack(3.5); // Lvl 83
		boltBaseDamage.PushBack(3.5); // Lvl 84
		boltBaseDamage.PushBack(3.5); // Lvl 85
		boltBaseDamage.PushBack(3.5); // Lvl 86
		boltBaseDamage.PushBack(3.5); // Lvl 87
		boltBaseDamage.PushBack(3.5); // Lvl 88
		boltBaseDamage.PushBack(3.5); // Lvl 89
		boltBaseDamage.PushBack(3.5); // Lvl 90
		boltBaseDamage.PushBack(3.5); // Lvl 91
		boltBaseDamage.PushBack(3.5); // Lvl 92
		boltBaseDamage.PushBack(3.5); // Lvl 93
		boltBaseDamage.PushBack(3.5); // Lvl 94
		boltBaseDamage.PushBack(3.5); // Lvl 95
		boltBaseDamage.PushBack(3.5); // Lvl 96
		boltBaseDamage.PushBack(3.5); // Lvl 97
		boltBaseDamage.PushBack(3.5); // Lvl 98
		boltBaseDamage.PushBack(3.5); // Lvl 99
		boltBaseDamage.PushBack(3.5); // Lvl 100
	}

// // ADVANCED CONFIG END
}
