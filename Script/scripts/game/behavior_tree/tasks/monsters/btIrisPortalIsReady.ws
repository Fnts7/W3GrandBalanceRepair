//>--------------------------------------------------------------------------
// BTCondIrisPortalIsReady
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIrisPortalIsReady extends IBehTreeTask
{		
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	private editable var returnTrueIfOpen : bool;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_npc 		: W3NightWraithIris;
		l_npc = (W3NightWraithIris) GetNPC();
		
		if( !l_npc.GetPortal() )
			return false;
		
		if( returnTrueIfOpen )
			return l_npc.GetPortal().IsOpen();
		
		return l_npc.GetPortal().IsReady();
	}
	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondIrisPortalIsReadyDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIrisPortalIsReady';
	
	private editable var returnTrueIfOpen : bool;
}
