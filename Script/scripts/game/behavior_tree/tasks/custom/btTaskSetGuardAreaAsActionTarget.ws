//>--------------------------------------------------------------------------
// BTTaskSetGuardAreaAsActionTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Set the NPC's guard area as the action Target
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 17-November-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSetGuardAreaAsActionTarget extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	var onDeactivate	: bool;	
	
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
		var l_guardArea : CAreaComponent;
		
		l_guardArea = GetNPC().GetGuardArea();
		
		if( l_guardArea )
		{
			SetActionTarget( l_guardArea.GetEntity() );
		}
	}

}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSetGuardAreaAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetGuardAreaAsActionTarget';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	editable var onDeactivate	: bool;
	hint onDeactivate = "Execute on deactivate instead of on Activate";
}
