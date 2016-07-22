//>--------------------------------------------------------------------------
// BTCondIsInImportantAnim
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Task description
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Andrzej Kwiatkowski
// Copyright © 2016 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIsInImportantAnim extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;	
	
	final function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		
		return combatDataStorage.GetIsInImportantAnim();
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
class BTCondIsInImportantAnimDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsInImportantAnim';
};