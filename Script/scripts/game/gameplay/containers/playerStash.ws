class W3Stash extends CInteractiveEntity
{
	editable var forceDiscoverable : bool;	default forceDiscoverable = false;

	event OnInteraction( actionName : string, activator : CEntity )
	{
		if(activator != thePlayer)
			return false;
			
		theGame.GameplayFactsAdd("stashMode", 1);
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
	
	public function /* C++ */ IsForcedToBeDiscoverable() : bool
	{
		return forceDiscoverable;
	}
}