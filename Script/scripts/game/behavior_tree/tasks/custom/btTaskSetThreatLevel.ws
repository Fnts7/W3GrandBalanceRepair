//>--------------------------------------------------------------------------
// BTTaskSetThreatLevel
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Change the default threat level value of the NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 03-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSetThreatLevel extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var threatLevel 				: int;	
	var addToCurrent				: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnActivate() : EBTNodeStatus
	{
		var finalValue : int;
		
		finalValue = threatLevel;
		if( addToCurrent )
		{
			finalValue += GetNPC().GetThreatLevel();
		}		
		finalValue = Max( 0, finalValue );
		GetNPC().ChangeThreatLevel( finalValue );
		
		return BTNS_Active;
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSetThreatLevelDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetThreatLevel';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	editable var threatLevel 		: int;
	editable var addToCurrent		: bool;	
	
	hint addToCurrent = "final threat level is guaranteed to be >= 0";
}
