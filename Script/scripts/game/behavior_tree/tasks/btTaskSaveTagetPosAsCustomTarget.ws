//>--------------------------------------------------------------------------
// BTTaskSaveTargetPosAsCustomTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Create a custom target out of the current position on the target
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - DD-Month-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSaveTargetPosAsCustomTarget extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var useActionTarget 	: bool;
	public var onDeactivate 	: bool;
	public var snapToGround		: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function OnActivate() : EBTNodeStatus
	{
		if( onDeactivate ) return BTNS_Active;
		
		SaveTarget();
		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function OnDeactivate()
	{
		if( !onDeactivate ) return;
		
		SaveTarget();
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function SaveTarget()
	{
		var l_pos 		: Vector;
		var l_heading	: float;
		var l_groundZ	: float;
		
		if( useActionTarget )
		{
			l_pos		= GetActionTarget().GetWorldPosition();
			l_heading 	= GetActionTarget().GetHeading();
		}
		else
		{
			l_pos		= GetCombatTarget().GetWorldPosition();
			l_heading 	= GetCombatTarget().GetHeading();
		}
		
		if( snapToGround && theGame.GetWorld().NavigationComputeZ( l_pos, l_pos.Z - 100, l_pos.Z + 100, l_groundZ ))
		{
			l_pos.Z = l_groundZ;
		}
		
		//GetNPC().GetVisualDebug().AddArrow('toCustomTarget', GetNPC().GetWorldPosition() + Vector( 0, 0, 1), l_pos, 1, 0.5f, 0.8f, true, Color( 205, 156, 89 ),, -1 );
		
		SetCustomTarget( l_pos, l_heading );
	}

}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSaveTargetPosAsCustomTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSaveTargetPosAsCustomTarget';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var useActionTarget 	: bool;
	private editable var onDeactivate 		: bool;
	private editable var snapToGround		: bool;
}