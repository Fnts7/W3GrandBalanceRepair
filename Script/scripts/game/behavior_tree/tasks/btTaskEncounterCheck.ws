//>--------------------------------------------------------------------------
// Andrzej Kwiatkowski
// Copyright © 2016 CD Projekt RED
//---------------------------------------------------------------------------

class BTTaskEncounterCheck extends IBehTreeTask
{
	var encounter			: CEncounter;
	var taskExecuted 		: bool;
	
	
	function OnActivate() : EBTNodeStatus
	{	
		if ( !taskExecuted && encounter )
		{
			GetNPC().SetParentEncounter( encounter );
			taskExecuted = true;
		}
		
		return BTNS_Active;
	}
}

//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskEncounterCheckDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEncounterCheck';
	
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var encounter 	: CEncounter;
		var task 		: BTTaskEncounterCheck;
		
		task 			= (BTTaskEncounterCheck) taskGen;
		encounter 		= (CEncounter)GetObjectByVar( 'encounter' );		
		task.encounter	= encounter;
	}
}
