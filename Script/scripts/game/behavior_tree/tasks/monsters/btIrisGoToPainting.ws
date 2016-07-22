//>--------------------------------------------------------------------------
// BTTaskIrisGoToPainting
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskIrisGoToPainting extends BTTaskIrisTask
{
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		var l_npc 		: W3NightWraithIris;
		var l_painting	: W3IrisPainting;
		
		l_npc = (W3NightWraithIris) GetNPC();
		
		l_painting = l_npc.GetPortal();
		
		SetActionTarget( l_painting );
		
		l_npc.PlayEffect( 'suck_into_painting', l_painting );
		l_painting.PlayEffect('glow_penetration');
		l_npc.StopEffect('drained_paint');
		
		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		var l_npc 		: W3NightWraithIris;
		var l_painting	: W3IrisPainting;
		
		l_npc = (W3NightWraithIris) GetNPC();
		l_painting = l_npc.GetPortal();
		l_painting.Close();
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskIrisGoToPaintingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisGoToPainting';
}