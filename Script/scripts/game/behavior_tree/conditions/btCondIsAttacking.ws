//>--------------------------------------------------------------------------
// BTCondIsAttacking
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Task description
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Andrzej Kwiatkowski
// Copyright © 2016 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIsAttacking extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;	
	
	final function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		
		return combatDataStorage.GetIsAttacking();
	}
	
	final function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
};

//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondIsAttackingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsAttacking';
};