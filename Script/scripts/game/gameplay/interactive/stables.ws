class W3Stables extends  CR4MapPinEntity
{	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();

		if( activator.GetEntity() == GetWitcherPlayer() )
		{
			mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
			area.SetEnabled( false );
		}
	}
}