//>--------------------------------------------------------------------------
// BTTaskSetEncounterAsActionTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Set the NPC encounter as the action Target
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 28-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSetEncounterAsActionTarget extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	var onDeactivate	: bool;	
	var encounter		: CEncounter;
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{	
		if( !onDeactivate ) Execute();
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnDeactivate()
	{	
		if( onDeactivate ) Execute();
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function Execute()
	{
		if( encounter )
		{
			SetActionTarget( encounter );
		}
	}

}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSetEncounterAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetEncounterAsActionTarget';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	editable var onDeactivate	: bool;
	hint onDeactivate = "Execute on deactivate instead of on Activate";
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var l_encounter : CEncounter;
		var task 		: BTTaskSetEncounterAsActionTarget;
		task = (BTTaskSetEncounterAsActionTarget) taskGen;
		
		l_encounter 		= (CEncounter)GetObjectByVar( 'encounter' );		
		task.encounter		= l_encounter;
	}
}
