class CBTCondPlayerHasSwordInHand extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var currentWeapon : EPlayerWeapon;
		
		currentWeapon = thePlayer.GetCurrentMeleeWeaponType();
		
		return currentWeapon == PW_Steel || currentWeapon == PW_Silver;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondPlayerHasSwordInHandDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondPlayerHasSwordInHand';
}
