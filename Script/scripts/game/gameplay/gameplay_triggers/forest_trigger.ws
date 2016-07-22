/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class W3ForestTrigger extends CEntity
{
	saved var isPlayerInForest : bool;
	
		default isPlayerInForest = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( (CPlayer)(activator.GetEntity()) )
			isPlayerInForest = true;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( (CPlayer)(activator.GetEntity()) )
			isPlayerInForest = false;
	}
	
	public function IsPlayerInForest() : bool
	{
		return isPlayerInForest;
	}
}