//>--------------------------------------------------------------------------
// BTTaskIrisSetClosestPaintingAsTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskIrisSetClosestPaintingAsTarget extends BTTaskIrisTask
{
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		var l_npc : W3NightWraithIris;
		
		l_npc = (W3NightWraithIris) GetNPC();
		SetActionTarget( l_npc.GetClosestPainting() );		
		
		return BTNS_Active;
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskIrisSetClosestPaintingAsTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisSetClosestPaintingAsTarget';
}