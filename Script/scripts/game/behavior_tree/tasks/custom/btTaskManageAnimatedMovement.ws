//>--------------------------------------------------------------------------
// BTTaskManageAnimatedMovement
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Modify the animated movement value of the moving agent component
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - DD-Month-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskManageAnimatedMovement extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var onDeactivate		: bool;
	public var flag				: bool;	
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate )
		{
			Execute( flag );
		}
		return BTNS_Active;
	}	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		if( onDeactivate )
		{
			Execute( flag );
		}
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private final function Execute( _Flag : bool )
	{
		var npc : CNewNPC = GetNPC();
		if( _Flag )
		{
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( true );
		}
		else
		{
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );
		}
	}

}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskManageAnimatedMovementDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageAnimatedMovement';
	
	editable var onDeactivate		: bool;
	editable var overrideOnly		: bool;
	editable var flag				: bool;
}