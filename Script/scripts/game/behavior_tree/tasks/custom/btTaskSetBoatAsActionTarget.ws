/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskSetBoatAsActionTarget extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		FindBoat();
		if ( GetActionTarget() )
			return true;
			
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		SetActionTarget(NULL);
	}
	
	function FindBoat()
	{
		var destructionComp : CBoatDestructionComponent;
		if ( GetCombatTarget() == thePlayer && thePlayer.IsSailing() )
		{
			this.SetActionTarget(thePlayer.GetUsedVehicle());
			/*destructionComp = (CBoatDestructionComponent)thePlayer.GetUsedVehicle().GetComponentByClassName('CBoatDestructionComponent');
			if ( destructionComp )
			{
				this.SetActionTarget(thePlayer.GetUsedVehicle())
			}*/
		}
	}
}

class CBTTaskSetBoatAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBoatAsActionTarget';
}
