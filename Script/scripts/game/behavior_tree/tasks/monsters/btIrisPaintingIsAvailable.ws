//>--------------------------------------------------------------------------
// BTCondIrisPaintingIsAvailable
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIrisPaintingIsAvailable extends BTTaskIrisTask
{	
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_npc 		: W3NightWraithIris;
		l_npc 		= (W3NightWraithIris) GetNPC();
		
		return l_npc.GetAvailablePaitingsQuantity() > 0;
	}
	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondIrisPaintingIsAvailableDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIrisPaintingIsAvailable';
}
