class CBTCondHasActorWeaponDrawn extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var actor : CActor = GetActor();
		
		if( actor.HasWeaponDrawn( false ) ) // dont treat fists as weapon
		{	
			return true;
		}
		return false;
	}
};

class CBTCondHasActorWeaponDrawnDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHasActorWeaponDrawn';
};