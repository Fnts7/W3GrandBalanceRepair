class BTCondIsPlayerInSpecialAttack extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		if( thePlayer.IsInCombatAction_SpecialAttack() )
		{
			return true;
		}
		
		return false;
	}
}

class BTCondIsPlayerInSpecialAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsPlayerInSpecialAttack';
}